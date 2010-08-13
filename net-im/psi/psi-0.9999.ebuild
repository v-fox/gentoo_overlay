# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-im/psi/psi-0.11_pre20070314.ebuild,v 1.2 2007/05/05 05:05:17 jer Exp $

inherit confutils eutils qt4 subversion

#MY_PV="${PV:8:4}-${PV:12:2}-${PV:14:2}"
#MY_P="${PN}-dev-snapshot-${MY_PV}"

IUSE="alsa crypt debug doc dbus jingle +plugins portaudio sasl spell ssl xscreensaver"

DESCRIPTION="QT 4.x Jabber Client, with Licq-like interface"
HOMEPAGE="http://psi-im.org/"
SRC_URI=""
ESVN_REPO_URI="http://svn.psi-im.org/psi/trunk"
ESVN_PROJECT="psi"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~hppa ~x86"

S="${WORKDIR}/${PN}"

DEPEND="|| ( x11-libs/qt-gui:4 =x11-libs/qt-4.3* )
	media-libs/libpng
	sys-libs/zlib
	alsa? ( media-libs/alsa-lib )
	portaudio? ( media-libs/portaudio )
	crypt? ( >=app-crypt/qca-gnupg-2.0.0_beta2 )
	doc? ( app-doc/doxygen )
	jingle? ( dev-libs/glib
		dev-libs/expat
		~net-libs/ortp-0.7.1
		media-libs/speex
		dev-libs/ilbc-rfc3951
		dev-libs/expat )
	sasl? ( dev-libs/cyrus-sasl )
	spell? ( app-text/aspell )
	ssl? ( 	dev-libs/openssl
		=app-crypt/qca-2*
		>=app-crypt/qca-ossl-2.0.0_beta2 )
	xscreensaver? ( x11-libs/libXScrnSaver )"

RDEPEND="${DEPEND}"

pkg_setup() {
	if has_version "=x11-libs/qt-4.3*"; then
		QT4_BUILT_WITH_USE_CHECK="qt3support png"
		QT4_OPTIONAL_BUILT_WITH_USE_CHECK="dbus"
	else
		if ! built_with_use "x11-libs/qt-gui:4" qt3support; then
			eerror "You have to build x11-libs/qt-gui:4 with qt3support."
			die "qt3support in qt-gui disabled"
		fi
		if ( use dbus && ! built_with_use "x11-libs/qt-gui:4" dbus ); then
			eerror "You have to build x11-libs/qt-gui:4 with dbus"
			die "dbus in qt-gui disabled"
		fi
	fi
	qt4_pkg_setup
}

src_unpack() {
	subversion_src_unpack

	cd ${S}
#	use jingle && epatch "${FILESDIR}/psi-jingle-gcc4.patch"
}

src_compile() {
	local myconf="--prefix=/usr --qtdir=/usr --disable-growl \
		$(use kernel_linux 	|| echo "--disable-dnotify" ) \
		$(use debug 		&& echo "--enable-debug") \
		$(use dbus 		|| echo "--disable-qdbus") \
		$(use spell 		|| echo "--disable-aspell") \
		$(use ssl 		|| echo "--disable-openssl") \
		$(use ssl 		&& echo "--disable-bundled-qca") \
		$(use xscreensaver 	|| echo "--disable-xss")
		$(use jingle && echo "--enable-google-ft"|| echo "--disable-google_ft")"

	# cannot use econf because of non-standard configure script
	mv configure-jingle configure
	./configure \
		$(use_enable plugins) \
		$(use_enable jingle) \
		${myconf} || die

	eqmake4 ${PN}.pro || die

	SUBLIBS="-L/usr/${get_libdir}/qca2" emake || die

	if use doc; then
		cd doc
		make api_public || die "make api_public failed"
	fi
}

src_install() {
	emake INSTALL_ROOT="${D}" install || die "emake install failed"

	# this way the docs will be installed in the standard gentoo dir
	newdoc iconsets/roster/README README.roster
	newdoc iconsets/system/README README.system
	newdoc certs/README README.certs
	dodoc README

	if use doc; then
		cd doc
		dohtml -r api || die "dohtml failed"
	fi
}

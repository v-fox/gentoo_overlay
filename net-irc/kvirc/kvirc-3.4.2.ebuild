# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-irc/kvirc/kvirc-3.4.0.ebuild,v 1.6 2008/09/05 17:52:44 gentoofan23 Exp $

inherit eutils kde-functions autotools

DESCRIPTION="An advanced IRC Client"
HOMEPAGE="http://www.kvirc.net/"
SRC_URI="ftp://ftp.kvirc.ru/pub/kvirc/${PV}/source/${P}.tar.bz2
	 ftp://ftp.kvirc.de/pub/kvirc/${PV}/source/${P}.tar.bz2"

LICENSE="kvirc"
SLOT="3"
KEYWORDS="amd64 ~mips ppc sparc x86"
IUSE="debug esd gsm ipv6 kde oss qt4 ssl"

RDEPEND="esd? ( media-sound/esound )
	gsm? ( media-sound/gsm )
	ssl? ( dev-libs/openssl )
	oss? ( media-libs/audiofile )
	qt4? ( x11-libs/qt:4
	      kde? ( kde-base/kdelibs:4.1 ) )
	!qt4? ( x11-libs/qt:3
	      kde? ( kde-base/kdelibs:3.5 ) )"

DEPEND="${RDEPEND}
	sys-devel/gettext"

src_unpack() {
	unpack ${A}
	cd "${S}"
	#epatch "${FILESDIR}"/${PN}-3.4.0-kdedir-fix.patch
	epatch "${FILESDIR}"/${PN}-gendoc.patch
}

src_compile() {
	if use qt4 ; then
		set-qtdir 4
		use kde && set-kdedir 4
	else
		set-qtdir 3
		use kde && set-kdedir 3
	fi

	econf --disable-static --with-aa-fonts --without-splash-screen \
	      --with-big-channels --with-pizza \
	      $(use debug && echo "--enable-debug") \
	      $(use qt4 && echo "--enable-qt4 --with-qt4-moc=/usr/bin/moc") \
	      $(use kde || echo "--without-kde-support") \
	      $(use ipv6 || echo "--without-ipv6-support") \
	      $(use esd || echo "--without-esd-support") \
	      $(use ssl || echo "--disable-ssl-support") \
	      $(use gsm || echo "--without-gsm") \
	      $(use_with x86 ix86-asm) \
	|| die "econf failed"
	emake -j1 || die "econf failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	emake DESTDIR="${D}" docs || die "emake docs failed"
	dodoc ChangeLog INSTALL README TODO
}

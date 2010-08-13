# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils qt4 cmake-utils subversion

DESCRIPTION="New Qt4-based Instant Messenger (ICQ)."
HOMEPAGE="http://www.qutim.org"
LICENSE="GPL-2"
SRC_URI=""
ESVN_REPO_URI="http://qutim.org/svn/"
ESVN_PROJECT="qutim-svn-"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug icq jabber ssl gnutls mrim vkontakte"

CDEPEND="x11-libs/qt-core:4
	x11-libs/qt-gui:4
	x11-libs/qt-webkit:4
	media-sound/phonon
	jabber? ( ssl? ( dev-libs/openssl )
		  gnutls? ( net-libs/gnutls ) )"
DEPEND="${CDEPEND}
	>=dev-util/cmake-2.6"
RDEPEND="${CDEPEND}"
S="${WORKDIR}/${PN}"

pkg_setup() {
	if ! use jabber && $( use ssl || use gnutls ); then
		ewarn "warning! 'ssl' or 'gnutls'-flags make sense"
		ewarn "only then used in conjunction with 'jabber'"
	fi
}

src_unpack() {
	# fetch protocol plugins
	for i in icq jabber mrim vkontakte;do
		if use ${i}; then
			ESVN_REPO_URI="${ESVN_REPO_URI}${i}" \
			ESVN_PROJECT="${ESVN_PROJECT}${i}" \
				subversion_src_unpack
			mv "${S}" "${WORKDIR}/${PN}-${i}" || die
		fi
	done

	# fetch main application
	ESVN_REPO_URI="${ESVN_REPO_URI}qutim/trunk" \
	ESVN_PROJECT="${ESVN_PROJECT}core" \
		subversion_src_unpack
}

src_configure() {
	cmake-utils_src_configure
}

src_compile() {
	# build main executable
	cmake-utils_src_compile

	# build protocol support
	if use jabber; then
		mv "${WORKDIR}/${PN}"-jabber "${S}"/plugins/jabber || die
		cd  "${S}"/plugins/jabber || die
		mkdir build
		cd build
		cmake -C "${TMPDIR}"/gentoo_common_config.cmake \
			  -DCMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE}" \
			  $(cmake-utils_use ssl OpenSSL) \
			  $(cmake-utils_use gnutls GNUTLS) ../ || die
		emake || die
	fi

	cd "${S}"/plugins || die
	for i in icq mrim vkontakte;do
		if use ${i}; then
			mv "${WORKDIR}/${PN}-${i}" ./"${i}" || die
			cd "${i}"
			einfo "now building ${i}-plugin"
			eqmake4 "${i}.pro" || die
			emake || die
			cd ..
		fi
	done
}

src_install(){
	# not recommended by upstream and probably broken
	#cmake-utils_src_install

	dobin "${WORKDIR}/${PN}_build/${PN}" || die "Failed to install the programme"
	doicon icons/qutim_64.png || die "Failed to install icon"
	make_desktop_entry qutim QuTIM qutim_64.png "Network;InstantMessaging;Qt" || die "Failed to create a shortcut"

	cd "${S}"/plugins || die
	insinto "/usr/$(get_libdir)/qutim"
	doins $(find . -type f -executable -iname "*.so") || die "Failed to install plugins"
}

# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-im/licq/licq-1.3.8-r1.ebuild,v 1.5 2010/01/13 20:26:52 armin76 Exp $

EAPI=3
MY_P="${P/_/-}"
S="${WORKDIR}/${MY_P}"
inherit cmake-utils eutils flag-o-matic

DESCRIPTION="nice Qt4 ICQ/Jabber Client"
HOMEPAGE="http://www.licq.org/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="alpha amd64 ia64 ppc sparc x86"
IUSE="debug docs linguas_he nls +plugins socks5 ssl"

RDEPEND=">=app-crypt/gpgme-1
	net-libs/gloox
	x11-libs/qt-gui:4
	x11-libs/aosd
	docs? ( app-doc/doxygen )
	ssl? ( >=dev-libs/openssl-0.9.5a )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	dev-libs/boost"

pkg_setup() {
	# crutch
	append-flags -pthread
}

src_configure() {
	local myopts="-DCMAKE_BUILD_TYPE=$(use debug && echo 'Debug' || echo 'Release')"
	mycmakeargs="$myopts
		$(cmake-utils_use plugins BUILD_PLUGINS)
		$(cmake-utils_use linguas_he USE_HEBREW)
		$(cmake-utils_use socks5 USE_SOCKS5)
		$(cmake-utils_use ssl USE_OPENSSL)
		$(cmake-utils_use nls ENABLE_NLS)"

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	dodoc README

	docinto doc
	dodoc doc/*

	use crypt && dodoc README.GPG
	use ssl && dodoc README.OPENSSL

	exeinto /usr/share/${PN}/upgrade
	doexe upgrade/*.pl || die
}

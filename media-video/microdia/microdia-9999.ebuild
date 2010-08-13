# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/kqemu/kqemu-1.4.0_pre1.ebuild,v 1.4 2009/05/25 10:00:31 lu_zero Exp $

inherit eutils flag-o-matic linux-mod toolchain-funcs git

DESCRIPTION="Webcam Support group for all Microdia chipsets under Linux"
HOMEPAGE="http://groups.google.com/group/microdia/"
EGIT_REPO_URI="http://repo.or.cz/r/microdia.git"
EGIT_PROJECT="microdia"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="strip"
IUSE="doc"

RDEPEND="media-libs/libv4l"
DEPEND="${DEPEND}
	doc? ( 	app-doc/doxygen
		media-gfx/graphviz )"

pkg_setup() {
	MODULE_NAMES="sn9c20x(video:${S})"
	linux-mod_pkg_setup
}

src_unpack() {
	git_src_unpack
	cd "${S}"

	sed -i -e "/CONFIG_SN9C20X_DEBUGFS=/s:y:n:" .config || die
	sed -i -e "s:driver:module:g" Makefile || die
}

src_compile() {
	linux-mod_src_compile

	use doc && make doc
}

src_install() {
	linux-mod_src_install
}

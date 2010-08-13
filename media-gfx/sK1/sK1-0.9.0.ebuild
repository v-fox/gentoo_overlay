# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

NEED_PYTHON=2.4

inherit distutils

MY_R="335"
DESCRIPTION="sK1 vector graphics editor"
HOMEPAGE="http://www.sk1project.org/"
SRC_URI="http://sk1project.org/downloads/sk1/${P}-rev${MY_R}.tar.gz"


LICENSE="|| ( GPL-2 LGPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""

DEPEND=">=sys-libs/glibc-2.6.1
	>=x11-libs/cairo-1.4.0
	>=media-libs/freetype-2.3.5
	x11-libs/libX11
	x11-libs/libXext
	>=dev-lang/tcl-8.5.0
	>=dev-lang/tk-8.5.0
	>=sys-libs/zlib-1.2.3-r1
	virtual/python
	dev-python/imaging
	gnome-extra/zenity
	media-libs/lcms"
RDEPEND="${DEPEND}"

pkg_setup() {
	if  ! built_with_use dev-lang/python tk; then
		eerror "This package requires dev-lang/python compiled with tk support."
		die "Please reemerge dev-lang/python with USE=\"tk\"."
	fi
	if  ! built_with_use media-libs/lcms python; then
		eerror "This package requires media-libs/lcms compiled with python support."
		die "Please reemerge media-libs/lcms with USE=\"python\"."
	fi
}


src_unpack() {
	unpack ${A}
}


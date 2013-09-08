# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils cmake-utils qt4-r2 git-2

DESCRIPTION="A PSP emulator for Android, Windows, Mac, Linux and Blackberry 10, written in C++."
HOMEPAGE="http://www.ppsspp.org/"
EGIT_REPO_URI="git://github.com/hrydgard/ppsspp.git"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="atrac qt4 sdl"

RDEPEND=""
DEPEND="sys-libs/zlib
	sdl? ( media-libs/libsdl )
	sdl? ( dev-util/cmake )
	atrac? ( media-libs/maiat3plusdec )
	qt4? ( dev-qt/qtcore )
	qt4? ( dev-qt/qtgui )
	qt4? ( dev-qt/qtmultimedia )
	qt4? ( dev-qt/qtopengl )
	qt4? ( dev-qt/qtsvg )
	qt4? ( dev-qt/qt-mobility[multimedia] )"

src_unpack() {
	git-2_src_unpack
	if use qt4 ; then
		cd "${WORKDIR}"/"${P}"/Qt
		qt4-r2_src_unpack
	else
		cmake-utils_src_unpack
	fi
}
	
src_prepare() {
	git submodule update --init
	if use qt4 ; then
		cd "${WORKDIR}"/"${P}"/Qt
		qt4-r2_src_prepare
	else
		cmake-utils_src_prepare
	fi
}

src_configure() {
	if use qt4 ; then
		cd "${WORKDIR}"/"${P}"/Qt
		qt4-r2_src_configure
		eqmake4 "${WORKDIR}"/"${P}"/Qt/PPSSPPQt.pro
	else
		cmake-utils_src_configure
	fi
	if use atrac ; then
		# If we are using a atrac+ encoder we need to patch the code
		# as PPSSPP's library autodetection does not work on linux
		cd "${WORKDIR}"/"${P}"/Core/HW
		epatch "${FILESDIR}"/atrac3plus.cpp.patch
	fi
}

src_compile() {
	if use qt4 ; then
		cd "${WORKDIR}"/"${P}"/Qt
		qt4-r2_src_compile
	else
		cmake-utils_src_compile
	fi
}

src_install() {
	if use qt4 ; then
		into "${D}"/usr/games
		dobin "${FILESDIR}"/ppssppqt
		exeinto "${D}"/usr/share/games/"${PN}"
		doexe "${WORKDIR}"/"${P}"/Qt/PPSSPPQt
	else
		into "${D}"/usr/games
		dobin "${FILESDIR}"/ppssppsdl
		exeinto "${D}"/usr/share/games/"${PN}"
		doexe "${WORKDIR}"/"${P}"_build/PPSSPPSDL
		insinto "${D}"/usr/share/games/"${PN}"
		doins -r "${WORKDIR}"/"${P}"_build/assets
		doins -r "${WORKDIR}"/"${P}"/lang
	fi
}

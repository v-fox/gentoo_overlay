# Copyright 1999-2004 Gentoo Technologies, Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit autotools eutils games

MY_PN="quake2"

DESCRIPTION="ID Software's Quake2 Port for Linux"
HOMEPAGE="http://www.quakeforge.net/"
SRC_URI="http://prdownloads.sourceforge.net/quake/quake2-${PV}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="X opengl ao alsa"
DEPEND="X? (
		x11-proto/xproto
		x11-proto/xextproto
		x11-proto/xf86dgaproto
		x11-proto/xf86vidmodeproto )
   opengl? ( virtual/opengl )
   ao? ( media-libs/libao )
   alsa? ( virtual/alsa )
   games-fps/quake2-data
   >=media-libs/libsdl-1.2.0"

S="${WORKDIR}/quake2-${PV}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	_elibtoolize --copy --force
	eautoconf
}

src_compile() {
	cd "${S}"

	egamesconf \
		$(use_with X x) \
		$(use_with alsa) \
		$(use_with opengl) \
		$(use_with ao) 
		
	emake || die
}

src_install() {
	cd ${WORKDIR}/quake2-${PV}
	make install DESTDIR=${D} || die "Install Failed."
}

pkg_postinst() {
	games_pkg_postinst
	einfo "If you own an Nvidia card and get a segfault when using OpenGL"
	einfo "and SDL/Alsa sound drivers run Quake2Forge like this:"
	einfo "quake2 +set gl_driver /usr/lib/opengl/xfree/lib/libGL.so.1 +set snddriver sdl"
	einfo "Note: If you use xorg-x11, just rename the directory in the path."
	echo
	einfo "ID Software -- Quake2"
}

# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# ***** Test audacious ******

inherit eutils flag-o-matic multilib toolchain-funcs games

DESCRIPTION="Enhanced Quake 2 engine with Gloom effects"
HOMEPAGE="http://egl.quakedev.com/
	http://qudos.quakedev.com/linux/quake2/engines/egl/"
# Takes the assets tarball from subversion, until version 0.3.2 is released
# **** Includes audacious patch ********
SRC_URI="http://qudos.quakedev.com/linux/quake2/engines/egl/EGL-SDL-source-${PV}.tar.bz2
	http://svn.quakedev.com/viewvc.cgi/egl/trunk/assets.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
# OpenAL sound is broken, so ignore openal
IUSE="audacious dedicated demo dga opengl optimize-cflags sdl textures"

UIDEPEND="audacious? ( media-sound/audacious )
	dga? ( x11-libs/libXxf86dga )
	opengl? ( virtual/opengl )
	sdl? (
		media-libs/libsdl
		x11-libs/libXxf86vm )"
# EGL works with the demo data.
# Chooses either the demo or CD data, because the engine needs data.
RDEPEND="${UIDEPEND}
	demo? ( games-fps/quake2-demodata )
	!demo? ( games-fps/quake2-data )
	textures? ( games-fps/quake2-textures )"
DEPEND="${UIDEPEND}"

S=${WORKDIR}/EGL-SDL-source-${PV}

pkg_setup() {
	games_pkg_setup

	if use opengl && ! use sdl ; then
		echo
		ewarn "The 'sdl' USE flag for this game is recommended over opengl,"
		ewarn "for reliability when e.g. changing screen resolution."
		ebeep
		epause
	fi

	if ! use sdl && ! use opengl && ! use dedicated; then
		echo
		eerror "you should choose at least one video renderer:"
		eerror "'opengl' or 'sdl'"
		eerror "OR"
		eerror "add 'dedicated' USE-flag to build server"
		echo
		epause 5
		die "no video renderer chosen"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
}

src_compile() {
	yesno() { useq $1 && echo YES || echo NO ; }

	# Prevent potential for "signal 11" abort, requested by QuDos
	filter-flags -fomit-frame-pointer

	emake -j1 \
		BUILD_CLIENT=$(yesno opengl) \
		BUILD_SDL_CLIENT=$(yesno sdl) \
		BUILD_DEDICATED=$(yesno dedicated) \
		WITH_XF86VM_EXT=$(yesno sdl) \
		WITH_DGA_MOUSE=$(yesno dga) \
		WITH_AUDACIOUS=$(yesno audacious) \
		WITH_XMMS=NO \
		LOCALBASE=/usr \
		GAMEBASE=/usr \
		DATADIR="${GAMES_DATADIR}/quake2" \
		LIBDIR="$(games_get_libdir)/${PN}" \
		OPTIMIZE=$(yesno optimize-cflags) \
		CC=$(tc-getCC) \
		WITH_DATADIR=YES \
		WITH_LIBDIR=YES \
		VERBOSE=YES \
		STRIP=NO \
		BUILD_RELEASE_DIR=release \
		release|| die "emake failed"
}

src_install() {
	use opengl && dogamesbin quake2/egl	|| "dogamesbin egl failed"
	use sdl    && dogamesbin quake2/egl-sdl	|| "dogamesbin egl-sdl failed"

	use dedicated && \
	newgamesbin quake2/eglded egl-ded 	|| die "newgamesbin eglded failed"

	use demo && games_make_wrapper ${PN}-demo "${PN} +set game demo"

	exeinto $(games_get_libdir)/${PN}/baseq2
	doexe quake2/baseq2/*.so || die "doexe *.so failed"

	insinto $(games_get_libdir)/${PN}/baseq2
	doins "${WORKDIR}"/assets/* || die
	# http://egl.quakedev.com/files/addons/
	doins -r "${WORKDIR}"/assets/addons/* || die

	dodoc "${S}"/*.txt

	prepgamesdirs
}

pkg_postinst() {
	games_pkg_postinst

	if use demo ; then
		elog "To play EGL with the demo data, run:  egl-demo"
		echo
	fi
}

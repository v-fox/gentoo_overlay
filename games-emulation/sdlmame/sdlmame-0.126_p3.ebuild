# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

inherit eutils flag-o-matic games

DESCRIPTION="Multiple Arcade Machine Emulator (SDL)"
HOMEPAGE="http://rbelmont.mameworld.info/?page_id=163"

MY_PV=${PV/.}
MY_PV=${MY_PV/_p/u}
MY_P=${PN}${MY_PV}

# Upstream doesn't allow fetching with unknown User-Agent such as wget
SRC_URI="mirror://gentoo/${MY_P}.zip
	mirror://gentoo/${PN}-manpages.tar.gz"

#SRC_URI="http://mamedev.org/downloader.php?&file=mame0126s.zip"

# Same as xmame. Should it be renamed to MAME?
LICENSE="XMAME"
SLOT="0"
KEYWORDS=""
IUSE="debug opengl X"

RDEPEND=">=media-libs/libsdl-1.2.10
	sys-libs/zlib
	dev-libs/expat
	x11-libs/libXinerama
	debug? ( >gnome-base/gconf-2
		 >=x11-libs/gtk+-2 )"

DEPEND="${RDEPEND}
	app-arch/unzip
	x11-proto/xineramaproto"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	if use opengl && ! built_with_use media-libs/libsdl opengl ; then
		die "Please emerge media-libs/libsdl with USE=opengl"
	fi
	games_pkg_setup
}

src_unpack() {
	unpack ${A}
	sed -i \
		-e '/CFLAGS += -O$(OPTIMIZE)/s:^:# :' \
		-e '/CFLAGS += -pipe/s:^:# :' \
		-e '/LDFLAGS += -s/s:^:# :' \
		-e 's:-Werror::' \
		"${S}"/makefile \
		|| die "sed failed"

	# CFLAGS and build debugging help
	#sed -i \
	#	-e "/^\(AR\|CC\|LD\|RM\) =/s:@::" \
	#	-i "${S}"/makefile
}

src_compile() {
	local make_opts

	# Don't compile zlib and expat
	einfo "Disabling embedded libraries: zlib and expat"
	make_opts="BUILD_ZLIB=0 BUILD_EXPAT=0"

	if use amd64; then
		einfo "Enabling 64-bit support"
		make_opts="PTR64=1"
	fi

	if use ppc; then
		einfo "Enabling PPC support"
		make_opts="BIGENDIAN=1"
	fi

	# This thing is driving me insane: it tries to build win32 debuging crap without permition on it
	if use debug ; then
		ewarn "Building with DEBUG support is not recommended for normal use"
		make_opts="DEBUG=1 PROFILE=1 SYMBOLS=1 DEBUGGER=1"
		else
		make_opts="DEBUG=0 PROFILE=0 SYMBOLS=0 DEBUGGER=0"
		einfo "fixing unnecessary gtk/gconf dependency"
		sed -i 	-e 's:`pkg-config --cflags gtk+-2.0` `pkg-config --cflags gconf-2.0`::' \
			-e 's:`pkg-config --libs gtk+-2.0` `pkg-config --libs gconf-2.0`::' \
			-e 's:CFLAGS += -Isrc/debug::' \
			-e 's:$(SDLOBJ)/dview.o $(SDLOBJ)/debug-sup.o $(SDLOBJ)/debug-intf.o::' \
			-e 's:$(SDLOBJ)/debugwin.o::' "${S}"/src/osd/sdl/sdl.mak || die "so bad, sooo bad..."
	fi

	use X || make_opts="${make_opts} NO_X11=1"
	use opengl || make_opts="${make_opts} NO_OPENGL=1"

	emake \
		NAME="${PN}" \
		OPT_FLAGS='-DINI_PATH=\"\$$HOME/.sdlmame\;'"${GAMES_SYSCONFDIR}/${PN}"'\"'" ${CFLAGS}" \
		SUFFIX="" \
		${make_opts} \
		|| die "emake failed"
}

src_install() {
	dogamesbin "${PN}" || die "dogamesbin "${PN}" failed"

	# Follows xmame ebuild, avoiding collision on /usr/games/bin/jedutil
	exeinto "$(games_get_libdir)/${PN}"
	local f
	for f in chdman makemeta jedutil romcmp testkeys; do
		doexe "${f}" || die "doexe ${f} failed"
	done

	insinto "${GAMES_DATADIR}/${PN}"
	doins ui.bdf || die "doins ui.bdf failed"
	doins -r keymaps || die "doins -r keymaps failed"

	insinto "${GAMES_SYSCONFDIR}/${PN}"
	doins "${FILESDIR}"/{joymap.dat,vector.ini} || die "doins joymap.dat vector.ini failed"

	sed \
		-e "s:@GAMES_SYSCONFDIR@:${GAMES_SYSCONFDIR}:" \
		-e "s:@GAMES_DATADIR@:${GAMES_DATADIR}:" \
		"${FILESDIR}"/mame.ini.in > "${D}/${GAMES_SYSCONFDIR}/${PN}/"mame.ini \
		|| die "sed failed"

	dodoc docs/{config,mame,newvideo}.txt *.txt
	doman "${WORKDIR}/${PN}-manpages"/*

	keepdir "${GAMES_DATADIR}/${PN}"/{roms,samples,artwork}
	keepdir "${GAMES_SYSCONFDIR}/${PN}"/ctrlr

	prepgamesdirs
}

pkg_postinst() {
	games_pkg_postinst

	elog "It's strongly recommended that you change either the system-wide"
	elog "mame.ini at \"${GAMES_SYSCONFDIR}/${PN}\" or use a per-user setup at \$HOME/.${PN}"

	if use opengl; then
		echo
		elog "You built ${PN} with opengl support and should set"
		elog "\"video\" to \"opengl\" in mame.ini to take advantage of that"
	fi
}

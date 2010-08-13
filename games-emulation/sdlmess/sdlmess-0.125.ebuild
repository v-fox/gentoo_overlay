# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit flag-o-matic toolchain-funcs eutils games

MY_PV=${PV/./}
MY_PV=${MY_PV/_p/u}
MY_P=${PN}${MY_PV}

DESCRIPTION="Multiple Emulator Super System for SDL"
HOMEPAGE="http://rbelmont.mameworld.info/?page_id=163"
SRC_URI="http://rbelmont.mameworld.info/${MY_P}.zip"

LICENSE="MAME"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE="+custom-cflags debug +dynarec +tools X opengl"
# Needs fetch restriction due to $HOMEPAGE blocking wget downloads
RESTRICT="fetch"

RDEPEND="dev-libs/expat
	sys-libs/zlib
	>=media-libs/libsdl-1.2.11
	opengl? ( virtual/opengl
		virtual/glu )
	X? ( 	x11-libs/libXext
		x11-libs/libXau
		x11-libs/libXdmcp )
	debug?	( >=x11-libs/gtk+-2
			  >=gnome-base/gconf-2 )"
DEPEND="${RDEPEND}
	X? ( x11-proto/xproto )
	app-arch/unzip"

S=${WORKDIR}/${MY_P}

enable_feature() {
	if use ${1} ; then
		sed -i \
			-e "/${2}.*=/s:#::" \
			makefile || die "sed makefile (${1} / ${2}) failed"
	fi
}

pkg_nofetch() {
	einfo "Please download ${SRC_URI}"
	einfo "and move it to ${DISTDIR}"
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	cp makefile.sdl makefile

	sed -i \
		-e "/PM.*=/s:^:# :" \
		-e "/MIPS3_DRC.*= 1/s:^:# :" \
		-e "/PPC_DRC.*= 1/s:^:# :" \
		makefile || die "sed makefile failed"

	if use custom-cflags ; then
		sed -i \
			-e "s:# primary targets:CFLAGS += ${CFLAGS} -Wno-error:" \
			-e "s:LDFLAGS = -Wl,--warn-common:LDFLAGS = ${LDFLAGS}:" \
			makefile || die "sed makefile custom-cflags failed"
	fi

	enable_feature amd64 AMD64
	enable_feature amd64 PTR64
	enable_feature ppc64 PTR64

	case $(get-flag march) in
		pentium3)	enable_feature x86 PM;;
		pentium-m)	enable_feature x86 PM;;
		pentium4)   enable_feature x86 P4;;
		athlon*)	enable_feature x86 ATHLON;;
		k7)			enable_feature x86 ATHLON;;
		g4)			enable_feature x86 G4;;
		g5)			enable_feature x86 G5;;
		i686)		enable_feature x86 I686;;
		pentiumpro)	enable_feature x86 I686;;
		nocona)		enable_feature x86 I686;,
	esac

	use x86 && enable_feature dynarec X86_MIPS3_DRC
	use x86 && enable_feature dynarec X86_PPC_DRC
	use x86 && enable_feature dynarec X86_VOODOO_DRC

	enable_feature debug DEBUG

	if ! use debug; then
			sed -i 	-e 's:DEFS += -DENABLE_DEBUGGER:#:' \
				-e 's:DEFS += -DMAME_DEBUG:#:' "${S}"/makefile || die
			sed -i 	-e 's:CFLAGS += -Isrc/debug:#:' \
				-e 's:`pkg-config --cflags gtk+-2.0` `pkg-config --cflags gconf-2.0`::' \
				-e 's:`pkg-config --libs gtk+-2.0` `pkg-config --libs gconf-2.0`::' \
				-e 's:$(SDLOBJ)/debugwin.o $(SDLOBJ)/dview.o $(SDLOBJ)/debug-sup.o $(SDLOBJ)/debug-intf.o::' "${S}"/src/osd/sdl/sdl.mak || die
			sed -i 	-e 's:debugwin_update_during_game();://:' "${S}"/src/osd/sdl/video.c || die
	fi
}

src_compile() {
	local target="all"
	local myconf="BUILD_EXPAT=0 BUILD_ZLIB=0 "
	use X || myconf="${myconf} NO_X11=1"
	use opengl ||myconf="${myconf} NO_OPENGL=1"
	
	emake \
		ARCH=$(get-flag -march) \
		CC=$(tc-getCC) \
		NAME=${PN} \
		${target} \
		${myconf} \
		|| die "emake failed"
}

src_install() {
	dogamesbin ${PN} || die "dogamesbin ${PN} failed"

	if use tools ; then
		exeinto "$(games_get_libdir)/${PN}"
		local f
		for f in messtest imgtool ; do
			doexe "${f}" || die "doexe ${f} failed"
		done
	fi

	dodoc docs/* *.txt

	prepgamesdirs
}

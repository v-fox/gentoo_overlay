# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

inherit eutils games flag-o-matic

DESCRIPTION="A Sega Genesis/CD/32X emulator"
HOMEPAGE="http://gens.consolemul.com/"
SRC_URI="mirror://sourceforge/project/gens/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="opengl"

RDEPEND="opengl? ( virtual/opengl )
	>=media-libs/libsdl-1.2
	>=x11-libs/gtk+-2.4
	amd64? ( app-emulation/emul-linux-x86-sdl 
		 app-emulation/emul-linux-x86-gtklibs )"
DEPEND="${RDEPEND}
	>=dev-lang/nasm-0.98"

S=${WORKDIR}/${P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-romsdir.patch
	append-ldflags -Wl,-z,noexecstack
}

src_compile() {
	use amd64 && multilib_toolchain_setup x86
	cd "${S}"
	egamesconf \
		$(use_with opengl) \
		$(use_enable x86 gtktest) \
		$(use_enable x86 sdltest) || die # shut up and eat emul-linux-x86-<some>libs
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS BUGS README gens.txt history.txt
	prepgamesdirs
}

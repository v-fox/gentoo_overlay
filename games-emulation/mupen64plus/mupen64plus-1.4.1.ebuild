# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils flag-o-matic games

MY_P="Mupen64Plus-${PV//./-}"

DESCRIPTION="A fork of dead Mupen64 Nintendo 64 (N64) emulator"
HOMEPAGE="http://code.google.com/p/mupen64plus/"
SRC_URI="http://mupen64plus.googlecode.com/files/${MY_P}-src.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="kde gtk lirc custom-flags"
RESTRICT=""

RDEPEND="sys-libs/zlib
	virtual/opengl
	media-libs/freetype:2
	media-libs/libpng
	media-libs/libsdl
	media-libs/libsamplerate
	media-libs/sdl-ttf
	lirc? ( app-misc/lirc )
	gtk? ( >=x11-libs/gtk+-2 )
	kde? ( >=kde-base/kdelibs-4 )"
DEPEND="${RDEPEND}
	>=dev-lang/yasm-0.6.2
	dev-util/pkgconfig"

S="${WORKDIR}/${MY_P}-src"

pkg_setup() {
	games_pkg_setup
}

src_unpack() {
	unpack ${A}
	cd ${S}

	einfo "fixing paths"
	sed -i 	-e '/PREFIX=/s:/usr/local:${PREFIX}:' \
		-e '/SHAREDIR=/s:${PREFIX}/share/mupen64plus:${PREFIX}/../share/games/${PN}:' \
		-e '/LIBDIR=/s:${SHAREDIR}/plugins:${PREFIX}/lib:' \
		-e '/MANDIR=/s:${PREFIX}/man/man1:${PREFIX}/../share/man/man1:' install.sh

	einfo "fixing striping options"
	sed -i -e "/STRIP/s:strip:true:" pre.mk

	use custom-flags && \
		sed -i 	-e "/CFLAGS/s:-pipe -O3 -ffast-math -funroll-loops -fexpensive-optimizations -fno-strict-aliasing:${CFLAGS}:" pre.mk || \
		sed -i 	-e "/CFLAGS/s:$: $(get-flag -march):" pre.mk
}

src_compile() {
	use lirc && LIRC="1" || LIRC="0"
	GUI="NONE"
	use gtk  && GUI="GTK2"
	use kde  && GUI="KDE4"

	make \
	      PREFIX="${GAMES_PREFIX}" \
	      LIRC="${LIRC}" \
	      GUI="${GUI}" \
	      VCR=0 \
	      all || die "make failed"
}

src_install() {
	./install.sh "${D}${GAMES_PREFIX}" || die "install.sh failed"

	newicon icons/logo.png "${PN}.png"
	if use gtk || use kde4; then
		make_desktop_entry "${GAMES_BINDIR}/${PN}" Mupen64Plus
	fi
	dodoc README RELEASE TODO
	prepgamesdirs
}

pkg_postinst() {
	games_pkg_postinst
	if use lirc;then
		echo
		elog "For lirc configuration see"
		elog "http://code.google.com/p/mupen64plus/wiki/LIRC"
		echo
	fi
}

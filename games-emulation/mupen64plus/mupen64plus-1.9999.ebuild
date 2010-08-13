# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils flag-o-matic games subversion

DESCRIPTION="A fork of dead Mupen64 Nintendo 64 (N64) emulator"
HOMEPAGE="http://code.google.com/p/mupen64plus/"
SRC_URI=""
ESVN_REPO_URI="svn://fascination.homelinux.net:7684/mupen64plus/trunk"
ESVN_PROJECT="mupen64plus"
ESVN_OPTIONS="--username mupen64 --password Dyson5632-kart"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="qt gtk lirc custom-flags debug"
RESTRICT="mirror"

RDEPEND="sys-libs/zlib
	virtual/opengl
	media-libs/freetype:2
	media-libs/libpng
	media-libs/libsdl
	media-libs/libsamplerate
	media-libs/sdl-ttf
	lirc? ( app-misc/lirc )
	gtk? ( x11-libs/gtk+:2 )
	qt? ( x11-libs/qt:4 )"
DEPEND="${RDEPEND}
	>=dev-lang/yasm-0.6.2
	dev-util/pkgconfig"

src_unpack() {
        subversion_src_unpack
	cd ${S}

	einfo "fixing paths"
	sed -i 	-e "/l_InstallDir/s:/usr/share/mupen64plus:/usr/share/games/mupen64plus:" \
		-e "/strncat(dirpath/s:plugins/:../../../games/lib:" main/main.c

	sed -i 	-e '/PREFIX/s:/usr/local:$(DESTDIR):' \
		-e '/SHAREDIR/s:$(PREFIX)/share/mupen64plus:$(DESTDIR)/../share/games/$(PN):' \
		-e '/LIBDIR/s:$(SHAREDIR)/plugins:$(DESTDIR)/lib:' \
		-e '/MANDIR/s:$(PREFIX)/man/man1:$(DESTDIR)/../share/man/man1:' \
		-e '/APPLICATIONSDIR/s:$(PREFIX)/share:$(DESTDIR)/../share:' Makefile

	sed -i 	-e '/PREFIX/s:/usr/local:$PREFIX:' \
		-e '/SHAREDIR/s:${PREFIX}/share/mupen64plus:$PREFIX/../share/games/$PN:' \
		-e '/LIBDIR/s:${SHAREDIR}/plugins:$PREFIX/lib:' \
		-e '/MANDIR/s:${PREFIX}/man/man1:$PREFIX/../share/man/man1:' \
		-e '/APPLICATIONSDIR/s:${PREFIX}/share:$PREFIX/../share:' install.sh

	einfo "fixing striping options"
	sed -i -e "/STRIP/s:strip:true:" pre.mk

	use custom-flags && \
		sed -i 	-e "/CFLAGS/s:-pipe -O3 :${CFLAGS} :" \
			-e "/LDFLAGS/s:$: $LDFLAGS :" pre.mk || \
		sed -i 	-e "/CFLAGS/s:$: $(get-flag -march):" pre.mk
}

src_compile() {
	use debug && PROFILE=1 DBGSYM=1 DBG=1 DBG_CORE=1 DBG_COUNT=1 DBG_COMPARE=1 DBG_PROFILE=1
	use lirc && LIRC="1" || LIRC="0"
	GUI="NONE"
	use gtk && GUI="GTK2"
	use qt 	&& GUI="QT4"

	if use amd64 || use ppc64; then
		BITS=64
	else
		BITS=32
	fi

	emake \
		PREFIX="${GAMES_PREFIX}" \
		VCR=0 \
		all || die "make failed"
}

src_install() {
	make DESTDIR=${D}${GAMES_PREFIX} install || or die "install.sh failed"

	newicon icons/mupen64logo.png "${PN}.png"
	make_desktop_entry "${GAMES_BINDIR}/${PN}" Mupen64Plus
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

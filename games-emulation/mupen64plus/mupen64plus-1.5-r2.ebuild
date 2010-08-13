# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# based on previous ebuilds from http://bugs.gentoo.org/215426

EAPI="2"

inherit eutils flag-o-matic games

MY_P="Mupen64Plus-${PV/./-}-src"

DESCRIPTION="A fork of Mupen64 Nintendo 64 emulator"
HOMEPAGE="http://code.google.com/p/mupen64plus/"
SRC_URI="http://mupen64plus.googlecode.com/files/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gtk qt4 lirc samplerate vcr custom-cflags sse"

# GTK+ is currently required by plugins even if no GUI support is enabled
RDEPEND="virtual/opengl
	media-libs/libsdl
	media-libs/sdl-ttf
	media-libs/libpng
	media-libs/freetype
	sys-libs/zlib
	>=x11-libs/gtk+-2
	qt4? ( x11-libs/qt-gui:4
		x11-libs/qt-core:4 )
	samplerate? ( media-libs/libsamplerate )
	lirc? ( app-misc/lirc )"
DEPEND="${RDEPEND}
	dev-lang/yasm
	dev-util/pkgconfig"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	if ! use gtk && ! use qt4; then
		ewarn "Building ${PN} without any GUI! To get one, enable USE=gtk or USE=qt4"
	elif use gtk && use qt4; then
		ewarn "Only one GUI can be built, using GTK+ one."
	fi

	games_pkg_setup
}

src_prepare() {
	epatch "${FILESDIR}"/${P}-plugindir.patch

	sed -i \
		-e "s:/usr/local/share/mupen64plus:${GAMES_DATADIR}/mupen64plus:" \
		-e "s:%PUT_PLUGIN_PATH_HERE%:$(games_get_libdir)/${PN}/plugins/:" \
		main/main.c || die "sed failed"

	MARCH="$(get-flag "-march")"
	sed -i -e "s:STRIP.*= .*$:STRIP = true:" pre.mk
	sed -i -e "s:CFLAGS += -march=.*$:CFLAGS += ${MARCH}:" pre.mk glide64/Makefile

	if use custom-cflags; then
		sed -i -e "s:CFLAGS += -pipe .*$:CFLAGS += ${CFLAGS}:" pre.mk
	fi
}

src_configure() {
	use lirc
	LIRC="LIRC=$(( ! $? ))"

	use vcr
	VCR="VCR=$(( ! $? ))"

	use sse
	NO_ASM="NO_ASM=$(( $? ))"

	if use gtk; then
		GUI="GUI=GTK2"
	elif use qt4; then
		GUI="GUI=QT4"
	else
		GUI="GUI=NONE"
	fi
}

src_compile() {
	make ${MAKEOPTS} PREFIX=${GAMES_DATADIR} \
		${LIRC} ${VCR} ${GUI} ${NO_ASM} all \
		|| die "make failed"
}

src_install() {
	./install.sh "${D}" \
		"${D}${GAMES_DATADIR}/${PN}" \
		"${D}${GAMES_BINDIR}" \
		"${D}$(games_get_libdir)/${PN}/plugins" \
		"${D}/usr/share/man/man1" \
		"${D}/usr/share/applications" \
		|| or die "install.sh failed"

	newicon icons/mupen64logo.png "${PN}.png"
	if use gtk || use qt4; then
		make_desktop_entry "${PN}" Mupen64Plus
	fi

	rm -r "${D}${GAMES_DATADIR}/${PN}/doc" # those aren't really docs
	dodoc README RELEASE TODO doc/*.txt

	prepgamesdirs
}

pkg_postinst() {
	games_pkg_postinst
	if use lirc; then
		elog "For lirc configuration see"
		elog "http://code.google.com/p/mupen64plus/wiki/LIRC"
	fi
}

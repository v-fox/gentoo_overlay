# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils autotools games flag-o-matic

MY_PN="${PN/-/}"
DESCRIPTION="PCSX-Reloaded: a fork of PCSX, the discontinued Playstation emulator"
HOMEPAGE="http://pcsxr.codeplex.com"
SRC_URI="mirror://sabayon/${CATEGORY}/${MY_PN}/${MY_PN}-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~ppc"
IUSE="alsa cdio opengl oss pulseaudio +sdl-sound"

RDEPEND="x11-libs/gtk+:2
	gnome-base/libglade
	media-libs/libsdl
	sys-libs/zlib
	app-arch/bzip2
	x11-libs/libXv
	x11-libs/libXtst
	alsa? ( media-libs/alsa-lib )
	opengl? ( virtual/opengl
	x11-libs/libXxf86vm )
	pulseaudio? ( >=media-sound/pulseaudio-0.9.16 )
	cdio? ( dev-libs/libcdio )"

DEPEND="${RDEPEND}
	!games-emulation/pcsx
	!games-emulation/pcsx-df
	!games-emulation/pcsxr
	x86? ( dev-lang/nasm )"

S="${WORKDIR}/${MY_PN}-${PV}"

pkg_setup() {
	if use sdl-sound; then
		sound_backend="sdl"
	elif use pulseaudio; then
		sound_backend="pulseaudio"
	elif use alsa; then
		sound_backend="alsa"
	elif use oss; then
		sound_backend="oss"
	else
		sound_backend="null"
	fi

	elog "Using ${sound_backend} sound"
	games_pkg_setup
}

src_prepare() {
	cd "${S}" || die
	# fix for wrong plugin path
	for i in $(grep -irl 'games/psemu' *);
	do
		einfo "Fixing plugin loading path for ${i}"
		sed -i "$i" -e "s:games/psemu:psemu:g" || die "sed failed"
	done

	# fix for icon, .desktop paths and missing include
	epatch 	"${FILESDIR}/${PN}-datadir.patch" \
		"${FILESDIR}/${PN}-include.patch"

	# fix for crashing with -O3 and -fstrict-aliasing
	append-flags -fno-strict-aliasing

	# regenerate for changes to spread
	eautoreconf
}

src_configure() {
	egamesconf \
		$(use_enable cdio libcdio) \
		$(use_enable opengl) \
		--enable-sound=${sound_backend}
}

src_install() {
	emake DESTDIR="${D}" install

	dodoc README doc/keys.txt doc/tweaks.txt ChangeLog
	prepgamesdirs
}

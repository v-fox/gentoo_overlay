# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI="2"

inherit eutils flag-o-matic games subversion

DESCRIPTION="Free and Open GameCube and Wii emulator"
HOMEPAGE="http://www.dolphin-emu.com"
SRC_URI=""
ESVN_REPO_URI="http://dolphin-emu.googlecode.com/svn/trunk/"
ESVN_PROJECT="dolphin-emu-read-only"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc ~ppc64"
IUSE="ao openal pulseaudio docs wxwidgets"
RESTRICT=""

RDEPEND="sys-libs/zlib
	media-libs/jpeg
	virtual/opengl
	>=media-libs/libsdl-1.2
	x11-libs/libXxf86vm
	x11-libs/libXext
	>=media-libs/glew-1.5
	x11-libs/cairo
	media-libs/portaudio
	media-libs/alsa-lib
	ao? ( media-libs/libao )
	|| ( net-wireless/bluez
		net-wireless/bluez-libs )
	openal? ( media-libs/openal )
	pulseaudio? ( media-sound/pulseaudio )
	wxwidgets? ( >=x11-libs/wxGTK-2.8 )"
DEPEND="${RDEPEND}
	dev-util/scons
	dev-util/pkgconfig
	media-gfx/nvidia-cg-toolkit"

# hope CMake switch is imminent
src_prepare() {
	einfo "Hacking SConstruct for our paths..."
	sed -i 	-e "/data_dir/s:/share/dolphin-emu:/../share/games/dolphin-emu:g" \
		SConstruct || die
}

src_configure() {
	ewarn "scons sucks and we have to configure in 'install' stage. skipping..."
}

src_compile() {
        ewarn "scons sucks and we have to compile in 'install' stage. skipping..."
}

src_install() {
	local myconf="nowx=$(use wxwidgets && echo 'false' || echo 'true')"
	scons verbose=true \
		shared_glew=true \
		shared_lzo=true \
		shared_sdl=true \
		shared_zlib=true \
		prefix="${GAMES_PREFIX}" \
		destdir="${D}" \
		install=global \
		"${myconf}" install || die "installation failed"

	if [[ -d "${D}${GAMES_DATADIR}/${PN}-emu" ]]; then
		eerror "install script is fixed. please, remove this crutch"
		else
		insinto "${GAMES_DATADIR}/${PN}-emu"
		doins -r Data/{Sys/*,User/*} || die
	fi

	# put bundled docs untouched
	if use docs; then
		insinto "${GAMES_DATADIR}/${PN}"
		doins -r "${S}/docs"/*
	fi
}

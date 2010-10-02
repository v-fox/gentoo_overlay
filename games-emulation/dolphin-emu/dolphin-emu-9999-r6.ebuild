# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI="3"

inherit eutils flag-o-matic games subversion

DESCRIPTION="Free. open source emulator for Nintendo GameCube and Wii"
HOMEPAGE="http://www.dolphin-emu.com/"
SRC_URI=""
ESVN_REPO_URI="http://dolphin-emu.googlecode.com/svn/trunk/"
ESVN_PROJECT="dolphin-emu-read-only"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc ~ppc64"
IUSE="ao openal opencl pulseaudio docs wxwidgets"
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
	opencl? ( || ( 	media-libs/mesa[opencl]
			x11-drivers/ati-drivers
			x11-drivers/nvidia-drivers ) )
	pulseaudio? ( media-sound/pulseaudio )
	wxwidgets? ( >=x11-libs/wxGTK-2.8 )"
DEPEND="${RDEPEND}
	dev-util/scons
	dev-util/pkgconfig
	media-gfx/nvidia-cg-toolkit"

src_prepare() {
	einfo "Fixing wxGTK bug..."
	epatch "${FILESDIR}/${P}"_fix_build.patch

	einfo "Hacking SConstruct for our paths..."
	sed -i 	-e "/data_dir/s:/share/dolphin:/../share/games/dolphin:g" \
		SConstruct || die
}

src_compile() {
	local myconf="$(echo "${MAKEOPTS}" | sed -ne "/-j/ { s/.*\(-j[[:space:]]*[0-9]\+\).*/\1/; p }")
		      nowx=$(use wxwidgets && echo 'false' || echo 'true')
		      opencl=$(use opencl && echo "true" || echo "false")"
	scons verbose=true \
		shared_glew=true \
		shared_lzo=true \
		shared_sdl=true \
		shared_zlib=true \
		prefix="${GAMES_PREFIX}" \
		destdir="${D}" \
		install=global \
		${myconf} \
		install || die "installation failed"
}

src_install() {
	scons install

	if [[ -d "${D}${GAMES_DATADIR}/${PN}" ]]; then
		eerror "installation script finally recognize shared datadir and its purpose"
		die "install script is fixed. please, remove this crutch"
		else
		insinto "${GAMES_DATADIR}/${PN}"
		doins -r Data/{Sys/*,User/*} || die
	fi

	# put bundled docs untouched
	if use docs; then
		insinto "${GAMES_DATADIR}/${PN}"
		doins -r "${S}/docs"/*
	fi
	
	# create menu entry for GUI builds
	if use wxwidgets; then
		doicon Source/Core/DolphinWX/resources/Dolphin.xpm || die
		make_desktop_entry "${PN}" "Dolphin" "Dolphin" "Game;Emulator"
	fi

	prepgamesdirs
}

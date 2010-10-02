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
IUSE="doc openal opencl +wxwidgets portaudio"
RESTRICT=""

RDEPEND="virtual/opengl
	dev-libs/lzo
	>=media-libs/glew-1.5
	media-libs/jpeg
	media-libs/libao
	>=media-libs/libsdl-1.2[joystick]
	net-wireless/bluez
	sys-libs/zlib
	x11-libs/cairo
	x11-libs/libXxf86vm
	x11-libs/libXext
	wxwidgets? ( >=x11-libs/wxGTK-2.8 )
	openal? ( media-libs/openal )
	opencl? ( || ( 	media-libs/mesa[opencl]
			x11-drivers/ati-drivers
			x11-drivers/nvidia-drivers ) )
	portaudio? ( media-libs/portaudio )"
DEPEND="${RDEPEND}
	dev-util/scons
	dev-util/pkgconfig
	media-gfx/nvidia-cg-toolkit"

src_prepare() {
	epatch "${FILESDIR}/${P}"_fix_build.patch

	# set installation paths
	sed -e "s;/share/dolphin-emu;/data;" \
		-e "s;/lib/dolphin-emu;/lib/plugins;" \
		-e "s; + '/bin';;" \
		-i "${S}/SConstruct" \
		|| die "sed path update 1 failed"

	sed -e 's;LIBS_DIR "dolphin-emu";LIBS_DIR "plugins";' \
		-i "${S}/Source/Core/Common/Src/CommonPaths.h" \
		|| die "sed path update 2 failed"
}

src_compile() {
	cd "${S}"
	# run "scons -h" to get a complete list of options
	local sconsopts=$(echo "${MAKEOPTS}" | sed -ne "/-j/ { s/.*\(-j[[:space:]]*[0-9]\+\).*/\1/; p }")
	scons ${sconsopts} \
		nowx=$(use wxwidgets && echo "false" || echo "true") \
		opencl=$(use opencl && echo "true" || echo "false") \
		install=global \
		prefix="${GAMES_DATADIR}/${PN}" \
		destdir="${D}" \
		shared_glew=true \
		shared_lzo=true \
		shared_sdl=true \
		shared_zlib=true \
		shared_sfml=false \
		shared_soil=false \
		verbose=true \
		|| die "scons build failed"

}

src_install() {
	# copy files to target installation directory
	cd "${S}"
	scons install

	# install documentation as appropriate
	dodoc Readme.txt
	if use doc; then
		doins -r docs
	fi

	# set binary name
	use wxwidgets \
		&& binary="${PN}" \
		|| binary="${PN}-nogui"
	# create bin wrapper
	games_make_wrapper "${PN}" "${GAMES_DATADIR}/${PN}/${binary}"

	# create menu entry for GUI builds
	if use wxwidgets; then
		doicon Source/Core/DolphinWX/resources/Dolphin.xpm || die
		make_desktop_entry "${binary}" "Dolphin" "Dolphin" "Game;Emulator"
	fi

	prepgamesdirs
}

pkg_postinst() {
	echo
	if ! use portaudio; then
		ewarn "If you need to use your microphone for a game, rebuild with USE=portaudio"
		echo
	fi
	if use wxwidgets; then
		ewarn "Note: It is not currently possible to configure Dolphin without the GUI."
		ewarn "Rebuild with USE=wxwidgets to enable the GUI if needed."
		echo
	fi

	games_pkg_postinst
}

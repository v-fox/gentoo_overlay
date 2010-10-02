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
IUSE="doc openal opencl pulseaudio portaudio +wxwidgets"
#RESTRICT="strip"
RESTRICT=""

RDEPEND="sys-libs/zlib
	media-libs/jpeg
	virtual/opengl
	>=media-libs/libsdl-1.2
	x11-libs/libXxf86vm
	x11-libs/libXext
	>=media-libs/glew-1.5
	x11-libs/cairo
	media-libs/libao
	media-libs/alsa-lib
	|| ( net-wireless/bluez
		net-wireless/bluez-libs )
	openal? ( media-libs/openal )
	opencl? ( || ( 	media-libs/mesa[opencl]
			x11-drivers/ati-drivers
			x11-drivers/nvidia-drivers ) )
	portaudio? ( media-libs/portaudio )
	pulseaudio? ( media-sound/pulseaudio )
	wxwidgets? ( >=x11-libs/wxGTK-2.8 )"
DEPEND="${RDEPEND}
	dev-util/scons
	dev-util/pkgconfig
	media-gfx/nvidia-cg-toolkit"

src_prepare() {
	# set installation paths
	sed -e "s;env\['prefix'\] + '/bin';'${GAMES_BINDIR}';" \
		-e "s;env\['prefix'\] + \"/share/dolphin-emu\";'${GAMES_DATADIR}/${PN}';" \
		-e "s;env\['prefix'\] + '/lib/dolphin-emu';'$(games_get_libdir)/${PN}';" \
		-e "s;env\['prefix'\] + '/lib/';'$(games_get_libdir)/';" \
		-i "${S}/SConstruct" \
		|| die "sed path update 1 failed"

	# fix wxGTK linking with --as-needed
	sed -e "s;env\['LIBS'\] + wxlibs + libs;wxlibs + env\['LIBS'\] + libs;" \
		-i "${S}/Source/Core/DolphinWX/Src/SConscript" \
		|| die "sed wxGTK link update"
	#sed -e "s;env\['LIBS'\] + wxlibs + libs;wxlibs + env\['LIBS'\] + wxlibs2 + libs;" \
	#	-e "s;wxlibs = \[ 'debwx', 'debugger_ui_util', 'inputuicommon', 'memcard' \];wxlibs = [ 'debwx' ]\n\twxlibs2 = \[ 'debugger_ui_util', 'inputuicommon', 'memcard' \];" \
	#	-i "${S}/Source/Core/DolphinWX/Src/SConscript" \
	#	|| die "sed wxGTK link update"

}

src_compile() {
	cd "${S}"
	# run "scons -h" to get a complete list of options
	local sconsopts=$(echo "${MAKEOPTS}" | sed -ne "/-j/ { s/.*\(-j[[:space:]]*[0-9]\+\).*/\1/; p }")
	scons ${sconsopts} \
		nowx=$(use wxwidgets && echo "false" || echo "true") \
		opencl=$(use opencl && echo "true" || echo "false") \
		install=global \
		prefix="/usr" \
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
	scons install || die "scons install failed"

	# set binary name
	local binary="${PN}"
	use wxwidgets || binary+="-nogui"

	# install documentation as appropriate
	dodoc Readme.txt
	if use doc; then
		doins -r docs
	fi

	# create bin wrapper
	#games_make_wrapper "${PN}" "${GAMES_DATADIR}/${PN}/${binary}"

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
	if ! use wxwidgets; then
		ewarn "Note: It is not currently possible to configure Dolphin without the GUI."
		ewarn "Rebuild with USE=wxwidgets to enable the GUI if needed."
		echo
	fi

	games_pkg_postinst
}

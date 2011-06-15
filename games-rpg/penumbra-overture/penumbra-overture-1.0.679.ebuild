# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils games

FIRST_PV="1.0.679"

DESCRIPTION="Scary first-person adventure game which focuses on story, immersion and puzzles"
HOMEPAGE="http://www.penumbra-overture.com/"
SRC_URI="PenumbraOverture-${FIRST_PV}.sh"

# See /opt/penumbra-overture/eng_license.rtf
LICENSE="as-is"
SLOT="0"
# Should work on amd64
# http://frictionalgames.com/forum/showthread.php?tid=1099
KEYWORDS="~x86 ~amd64"
IUSE="+icon"
RESTRICT="fetch strip"

DEPEND="icon? ( media-gfx/imagemagick )"
RDEPEND="dev-libs/libxml2
	x86? (
		media-libs/libsdl
		virtual/glu
		virtual/opengl
		x11-libs/libX11
		x11-libs/libXau
		x11-libs/libXdmcp
		x11-libs/libXext
		x11-libs/libXft
		x11-libs/libXrender )
	amd64? (
		app-emulation/emul-linux-x86-compat
		app-emulation/emul-linux-x86-sdl
		app-emulation/emul-linux-x86-xlibs )"

# Provided in lib directory
#	media-libs/freealut
#	virtual/jpeg
#	media-libs/libogg
#	media-libs/openal
#	media-libs/libpng
#	media-libs/libsdl
#	media-libs/sdl-image
#	media-libs/sdl-ttf
#	media-libs/libvorbis
#	x11-libs/fltk

S=${WORKDIR}/install
dir=${GAMES_PREFIX_OPT}/${PN}
INSTALL_KEY_FILE=${dir}/installkey

QA_TEXTRELS="${dir:1}/lib/libSDL-1.2.so.0.11.0
	${dir:1}/lib/libSDL-1.2.so.0"

pkg_nofetch() {
	einfo "Please buy & download PenumbraOverture-${FIRST_PV}.sh from:"
	einfo "  ${HOMEPAGE}"
	einfo "and move it to ${DISTDIR}"
	einfo
}

src_unpack() {
	mkdir "${S}" || die

	local f
	for f in PenumbraOverture-${FIRST_PV}.sh ; do
		cd "${WORKDIR}"
		unpack_makeself "${f}"

		bin/linux/x86/libc.so.6/lzma-decode instarchive_all pack.tar \
			|| die "lzma-decode"

		cd "${S}"
		unpack ./../pack.tar
		cd "${WORKDIR}"
		rm pack.tar
	done

	cd "${S}"

	# Prevent warning that chcon does not exist
	sed -i \
		-e "s:which chcon:which chcon 2>/dev/null:" \
		penumbra || die "sed penumbra"

	if use icon ; then
		convert penumbra.ico "${WORKDIR}"/penumbra.png || die "convert"
	fi
}

src_install() {
	insinto "${dir}"
	doins -r * || die "doins"

	exeinto "${dir}"
	doexe openurl.sh penumbra{,.bin} || die "doexe"

	exeinto "${dir}"/lib
	doexe lib/* || die "doexe lib"

	# Symlinks
	cd "${D}/${dir}"/lib || die
	local d f fn sym
	for f in $(find "${S}"/lib -maxdepth 1 -type l) ; do
		echo "f=${f}"
		sym=$(basename "${f}")
		echo "sym=${sym}"
		d=$(find "${S}"/lib -maxdepth 1 -name "${sym}.*")
		echo "d=${d}"
		fn=$(basename "${d}")
		if [[ -e "${fn}" ]] ; then
			# Create symlink for lib
			ln -sfn "${fn}" "${sym}" || die
		fi
	done
	# Manual exception
	ln -sfn libpng12.so.0.1.2.8 libpng.so.3 || die "ln libpng"
	cd "${S}"

	if use icon ; then
		newicon "${WORKDIR}"/penumbra.png ${PN}.png || die "newicon"
	fi

	games_make_wrapper ${PN} "./penumbra.bin" "${dir}" "${dir}"/lib
	make_desktop_entry ${PN} "Penumbra: Overture" ${PN}.png

	prepgamesdirs
}

pkg_postinst() {
	games_pkg_postinst

	echo
	if [[ -f "${INSTALL_KEY_FILE}" ]] ; then
		einfo "The installation key file already exists:  ${INSTALL_KEY_FILE}"
	else
		ewarn "You MUST run this before playing the game:"
		ewarn "  emerge --config ${PN}"
		ewarn "To enter your installation key."
	fi
	echo
}

pkg_config() {
	local key1 key2

	ewarn "Your installation key is NOT checked for validity here."
	ewarn "Make sure you type it in correctly."
	ewarn "If you CTRL+C out of this, the game will not run!"
	echo
	einfo "The key format is: XXXX-XXXX-XXXX-XXXX"
	while true ; do
		einfo "Please enter your key:"
		read key1
		if [[ -z "${key1}" ]] ; then
			echo "You entered a blank key. Try again."
			continue
		fi
		einfo "Please re-enter your key:"
		read key2
		if [[ -z "${key2}" ]] ; then
			echo "You entered a blank key. Try again."
			continue
		fi

		if [[ "${key1}" == "${key2}" ]] ; then
			echo "${key1}" | tr a-z A-Z > "${INSTALL_KEY_FILE}"
			echo -e "// Do not give this file to ANYONE.\n// Frictional Games Support will NEVER ask for this file" \
				>> "${INSTALL_KEY_FILE}"
			einfo "Thanks, created ${INSTALL_KEY_FILE}"
			break
		else
			eerror "Your installation key entries do not match. Try again."
		fi
	done
}

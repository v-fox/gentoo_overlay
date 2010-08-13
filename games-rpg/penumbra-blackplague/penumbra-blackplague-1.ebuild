# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils games

DESCRIPTION="First-person suspense adventure game sequel to Penumbra Overture"
HOMEPAGE="http://www.penumbrablackplague.com/"
SRC_URI="PenumbraBlackPlague.sh"

# See /opt/penumbra-blackplague/eng_license.rtf
LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+binlibs"
RESTRICT="fetch strip"

DEPEND=""
RDEPEND="dev-libs/libxml2
	icon? ( media-gfx/imagemagick )
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

S=${WORKDIR}/install/PenumbraBlackPlague
dir=${GAMES_PREFIX_OPT}/${PN}
INSTALL_KEY_FILE=${dir}/installkey

QA_TEXTRELS="${dir:1}/lib/libSDL-1.2.so.0.11.0
	${dir:1}/lib/libSDL-1.2.so.0"

pkg_nofetch() {
	einfo "Please download \"Penumbra: Black Plague.sh\" from:"
	einfo "  ${HOMEPAGE}"
	einfo "and move it to ${DISTDIR} as ${SRC_URI}"
	echo
}

src_unpack() {
	mkdir "${WORKDIR}/install"
	local f
	for f in ${A} ; do
		cd "${WORKDIR}"
		unpack_makeself "${f}"

		bin/linux/x86/libc.so.6/lzma-decode instarchive_all pack.tar \
			|| die "lzma-decode"

		cd "${WORKDIR}/install"
		unpack ./../pack.tar
		cd "${WORKDIR}"
		rm pack.tar
	done

	cd "${S}" || die

	# Prevent warning that chcon does not exist
	#sed -i \
	#	-e "s:which chcon:which chcon 2>/dev/null:" \
	#	blackplague || die "sed blackplague"

	mv penumbra.png blackplague.png

	# don't fuck around with our libs
	if ! use binlibs; then
		echo '#!/bin/sh' > blackplague
		echo "cd ${dir}" >> blackplague
		echo './blackplague.bin' >> blackplague
	fi
}

src_install() {
	insinto "${dir}"
	doins -r * || die "doins"

	exeinto "${dir}"
	doexe blackplague{,.bin} || die "doexe"

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

	newicon blackplague.png ${PN}.png || die "newicon"

	games_make_wrapper ${PN} "./blackplague.bin" "${dir}" "${dir}"/lib
	make_desktop_entry ${PN} "Penumbra: Black Plague" ${PN}.png

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
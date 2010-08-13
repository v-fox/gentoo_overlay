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
IUSE="bluetooth openal portaudio docs"
RESTRICT=""

RDEPEND="sys-libs/zlib
	media-libs/jpeg
	virtual/opengl
	>=x11-libs/wxGTK-2.8
	>=media-libs/libsdl-1.2
	x11-libs/libXxf86vm
	x11-libs/libXext
	>=media-libs/glew-1.5
	x11-libs/cairo
	media-libs/libao
	bluetooth? ( || ( net-wireless/bluez
			net-wireless/bluez-libs ) )
	openal? ( media-libs/openal )
	portaudio? ( media-libs/portaudio )"
DEPEND="${RDEPEND}
	dev-util/scons
	dev-util/pkgconfig
	media-gfx/nvidia-cg-toolkit"

src_setup() {
	if ! use bluetooth; then
		echo
		elog "You will not be able to use your WiiMote without bluetooth support"
		echo
	fi

	if ! use portaudio; then
		echo
		elog "You will not be able to use microphone in games without portaudio"
		echo
	fi
}

src_prepare() {
	cd "${S}"

	# using extreme prejudice to get rid of bluetooth dependency
	einfo "removing bluetooth (WiiMote) support"
	sed -i "/Externals\/WiiUseSrc\/Src/d" SConstruct
	sed -i "/Source\/Plugins\/Plugin_Wiimote\/Src/d" SConstruct

	# let's decide for ourselves on sse support
	einfo "putting our flags instead of '-msse2'-statement"
	sed -i -e 's:-msse2,:${CXXFLAGS} ${LDFLAGS}:' SConstruct
}

src_compile() {
        cd "${S}"
	## also available options are:
	# flavor= release | debug | devel | fastlog | prof
	## and true | false for:
	# verbose; lint; nowx; wxgl; sdlgl; gltest; jittest; nojit
	scons verbose=true || die
}

src_install() {
	## put it in jail until proper multi-user configuration implemented
	local name="${PN/d/D}"
	local bindir="${S}/Binary/$(uname -s)-$(uname -m)"

	# put bundled docs untouched
	if use docs; then
		insinto "/usr/share/${P}"
		doins -r "${S}/docs"/*
	fi

	# put crutches in place
	insinto "${GAMES_DATADIR}/${PN}"
	doins -r "${bindir}"/{sys,user} || die "failed to install"
	dogamesbin "${bindir}"/{${PN}-emu,dsptool} || die "failed to put binaries in place"

	insinto "$(games_get_libdir)/${PN}-emu"
	doins "${bindir}"/plugins/* || die "failed to put plugins in place"

	# make link to it
	cat <<-EOF > "${S}/${PN}"
	#!/bin/sh

	USERDIR=~/".${PN}-emu"
	[ -d \$USERDIR ]  || mkdir "\$USERDIR"

	for i in sys user; do
		cp -R "${GAMES_DATADIR}/${PN}/\$i"/* -t "\$USERDIR"/
	done

	[ -e "\$USERDIR"/plugins ] || ln -s "$(games_get_libdir)/${PN}-emu" "\$USERDIR"/plugins

	${PN}-emu \$1
	EOF

	dogamesbin "${S}/${PN}" || die

	# and fancy menu entry
	doicon "${FILESDIR}/${name}.png" || die
	make_desktop_entry "${GAMES_BINDIR}/${PN}" "${name}" "${name}.png" "Game;Emulator"
}

pkg_postinst() {
	echo
	elog "Note that proper GNU multi-user support is missing and"
	elog "binary always executes via wrapper"
	echo
}

# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit games

DESCRIPTION="32-bit high-resolution textures for enhanced Quake 2 engines"
HOMEPAGE="http://qudos.quakedev.com/
	http://www-personal.umich.edu/~jimw/q2/"
SRC_URI="http://qudos.quakedev.com/linux/quake2/textures/textures32bit-1.zip
	http://qudos.quakedev.com/linux/quake2/textures/textures32bit-2.zip
	http://www-personal.umich.edu/~jimw/q2/files/all_q2_textures_07_17_2006.zip
	http://www-personal.umich.edu/~jimw/q2/files/animated_computer_08_09_06.zip"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="jimw"

RDEPEND=""
DEPEND="app-arch/unzip"

S=${WORKDIR}

unpack_jimw() {
	einfo "Unpacking jimw textures"

	cd "${S}"
	unpack all_q2_textures_07_17_2006.zip
	cd textures/e1u1 || die
	unpack animated_computer_08_09_06.zip
	# The png files replace the tga files
	rm +{0,1,2,3,4}comp10_1.tga || die
	cd "${S}"
}

src_unpack() {
	# Always unpack both sets of textures, to include all files.
	# qudos textures are the default because they are more faithful
	# to the original game.

	if use jimw ; then
		# jimw textures take priority
		unpack textures32bit-1.zip
		unpack textures32bit-2.zip
		unpack_jimw
	else
		# qudos textures take priority
		unpack_jimw
		unpack textures32bit-1.zip
		unpack textures32bit-2.zip
	fi
}

src_install() {

	insinto ${GAMES_DATADIR}/quake2/baseq2
	# Is unzipped, so >quake2-icculus-0.16.1-r1 can read the textures
	doins -r models textures || die "doins -r failed"

	dodoc Readme.txt

	prepgamesdirs
}

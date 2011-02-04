# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI=3
inherit eutils games

DESCRIPTION="Kega Fusion is a Sega SG1000, SC3000, Master System, Game Gear, Genesis/Megadrive, SVP, Pico, SegaCD/MegaCD and 32X emulator"
HOMEPAGE="http://www.eidolons-inn.net/tiki-index.php?page=Kega"
SRC_URI="http://www.eidolons-inn.net/tiki-download_file.php?fileId=572 -> Fusion363x.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="x86 ~amd64"
IUSE="mp3"

RDEPEND="virtual/opengl
	amd64? ( alsa? ( app-emulation/emul-linux-x86-soundlibs )
		app-emulation/emul-linux-x86-baselibs )
	mp3? ( media-sound/mpg123
		amd64? ( app-emulation/emul-linux-x86-soundlibs ) )"
DEPEND="${RDEPEND}"
RESTRICT="strip"
S="${WORKDIR}/Fusion"

src_install() {
	dogamesbin Fusion || die
	dodoc Readme.txt History.txt
	prepgamesdirs
}

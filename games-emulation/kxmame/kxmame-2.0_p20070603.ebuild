# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# kde-misc/kosd-0.2 ebuild version 0.4 2008-05-30 14:30

inherit kde autotools

DESCRIPTION="A KDE frontend for sdlmame/xmame/xmess emulator"
HOMEPAGE="http://sourceforge.net/projects/kxmame/"
SRC_URI="http://downloads.sourceforge.net/${PN}/${PN}-2.0-svn-sdlmame-20070603.tar.bz2"
IUSE="+mame +mess"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
DEPEND="dev-util/pkgconfig
	dev-libs/glib"
RDEPEND="${DEPEND}
	mame? ( || ( 	games-emulation/sdlmame
			games-emulation/xmame ) )
	mess? ( || ( 	games-emulation/sdlmess
			games-emulation/xmess ) )"
RESTRICT="mirror"
S="${WORKDIR}/${PN}/trunk"

need-kde 3.2

# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils toolchain-funcs games

DESCRIPTION="Mod collection for kmquake2, for additional features in maps"
HOMEPAGE="http://qudos.quakedev.com/
	http://www.geocities.com/knightmare66/"
SRC_URI="http://qudos.quakedev.com/linux/quake2/engines/KMQuake2/KMQuake2_addons_src_unix-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="debug"

RDEPEND="games-fps/kmquake2"
DEPEND=""

S=${WORKDIR}/KMQuake2_addons_src_unix
dir=${GAMES_DATADIR}/quake2

src_compile() {
	local target="release"
	use debug && target="debug"

	local libdir=$(games_get_libdir)/kmquake2

	emake \
		DATADIR="${dir}" \
		LIBDIR="${libdir}" \
		LOCALBASE="/usr" \
		CC="$(tc-getCC)" \
		"${target}" \
		|| die "emake failed"
}

src_install() {
	local libdir=$(games_get_libdir)/kmquake2

	insinto "${libdir}"
	doins -r quake2/* || die "doins -r failed"

	prepgamesdirs
}

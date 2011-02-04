# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit games

EAPI="3"
JIMW="http://www-personal.umich.edu/~jimw/q2"
HIRES="hi-res/B@Q2"
DESCRIPTION="24-bit high-resolution textures for enhanced Quake 2 engines"
HOMEPAGE="http://www-personal.umich.edu/~jimw/q2/"

SRC_URI="kmquake2? ( 	${JIMW}/Quake2_tga_textures/q2_textures.zip 	-> kmquake2_textures.pk3
			hud? 	( ${JIMW}/kmq2_install/q2e_hud.pk3 	-> kmquake2_hud.pk3 )
			models? ( ${JIMW}/aq2_install/models.zip 	-> kmquake2_models.pk3 ) )
	!kmquake2? ( 	http://jdolan.dyndns.org/jaydolan/tmp/retexture/pak8.zip )"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86 ~amd64"
# too big
#IUSE="hires"
IUSE="hud kmquake2 models"

RDEPEND="games-fps/quake2-data"
DEPEND="${RDEPEND}
	app-arch/unzip"

S="${WORKDIR}"

src_unpack() {
	use kmquake2 || unpack "pak8.zip"
}

src_install() {
	insinto "${GAMES_DATADIR}"/quake2/baseq2

	if use kmquake2; then
		doins "${DISTDIR}"/kmquake2_textures.pk3 || die
		use hud && \
			$(doins "${DISTDIR}"/kmquake2_hud.pk3 || die)
		use models && \
			$(doins "${DISTDIR}"/kmquake2_models.pk3 || die)
	else
		doins "${S}"/pak8.pak || die
		dodoc README
	fi

	prepgamesdirs
}

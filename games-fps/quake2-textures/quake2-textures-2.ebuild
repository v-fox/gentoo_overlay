# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit games

EAPI="2"
JIMW="http://www-personal.umich.edu/~jimw/q2"
HIRES="hi-res/B@Q2"
DESCRIPTION="32-bit high-resolution textures for enhanced Quake 2 engines"
HOMEPAGE="http://www-personal.umich.edu/~jimw/q2/"

SRC_URI="kmquake2? ( 	${JIMW}/specific/kmquake2.pk3
			${JIMW}/specific/kmquake2_extras.pk3 )
	models? ( 	${JIMW}/md2_skins/kmquake2_models.pk3 	-> kmquake2_models.pk3 )
	overrides? ( 	${JIMW}/${HIRES}/small/overrides.pk2 	-> quake2_overrides_2009.03_small.pk3
			${JIMW}/${HIRES}/overrides_light-tga24.zip -> quake2_overrides_light-tga24.pk3 )
	${JIMW}/${HIRES}/grass_prlx.zip 	-> quake2_grass-prlx.zip
	${JIMW}/${HIRES}/rock_prlx.zip 		-> quake2_rock-prlx.zip
	${JIMW}/specific/textures_09-2008.zip 	-> quake2_textures_2008.09.pk3
	${JIMW}/${HIRES}/small/textures.pk2 	-> quake2_textures_2009.03_small.pk3
	${JIMW}/${HIRES}/textures_light-tga24.zip -> quake2_textures_light-tga24.pk3"
#	!hires? ( ${JIMW}/hi-res/B@Q2/small/overrides.pk2 	-> quake2_overrides_2009.03_small.pk2
#		${JIMW}/hi-res/B@Q2/small/textures.pk2 		-> quake2_textures_2009.03_small.pk2 )
#	hires? ( ${JIMW}/hi-res/B@Q2/overrides.pk2 		-> quake2_overrides_2008.08.pk2
#		${JIMW}/hi-res/B@Q2/textures.pk2 		-> quake2_textures_2008.08.pk2 )"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86 ~amd64"
# too big
#IUSE="hires"
IUSE="models kmquake2 overrides"

RDEPEND="games-fps/quake2-data"
DEPEND="${RDEPEND}
	app-arch/unzip"

S=${WORKDIR}

src_unpack() {
	unpack quake2_grass-prlx.zip
	unpack quake2_rock-prlx.zip
}

src_prepare() {
	use models 	|| rm -rf "${WORKDIR}"/player
	use overrides 	|| rm -rf "${WORKDIR}"/overrides
}

src_install() {
	insinto "${GAMES_DATADIR}"/quake2/baseq2
	doins -r "${WORKDIR}"/*
	doins "${DISTDIR}"/quake2_textures_{2008.09,2009.03_small,light-tga24}.pk3
	use models 	&& doins "${DISTDIR}"/kmquake2_models.pk3
	use kmquake2 	&& doins "${DISTDIR}"/kmquake2{,_extras}.pk3
	use overrides 	&& doins "${DISTDIR}"/quake2_overrides_{2009.03_small,light-tga24}.pk3

	prepgamesdirs
}

# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="git://gitorious.org/goldendict/goldendict.git"
	inherit eutils qt4-r2 git
	SRC_URI=""
	KEYWORDS=""
else
	inherit eutils qt4-r2
	SRC_URI="mirror://sourceforge/${PN}/${P}-src.tar.bz2 -> ${P}.tar.bz2"
	KEYWORDS="amd64 x86 ~amd64 ~x86 ~x86-fbsd"
	S="${WORKDIR}"
fi

RUPACK="enruen-content"
RUPACK_V="1.1"
MORPH_V="1.0"

inherit qt4
DESCRIPTION="GoldenDict is a feature-rich dictionary lookup program."
HOMEPAGE="http://goldendict.org"
LICENSE="GPL-3"
SLOT="0"

LANGS="af ar bg ca cs cy da de el en eo es et fo fr ga gl he hr hu ia id it ku lt lv mi mk ms nb nl nn pl pt ro ru sk sl sv sw tn uk vi zh zu"
LANGSLONG="ar_SA bg_BG cs_CZ de_DE el_GR it_IT lt_LT ru_RU uk_UA vi_VN zh_CN"
IUSE="kde +addons"
for i in ${LANGS}; do
	IUSE="${IUSE} linguas_${i}"
done

# let's have some dictionaries, english-pronouncing pack and updated morphology
SRC_URI="${SRC_URI} addons? ( linguas_ru? ( mirror://sourceforge/"${PN}/${RUPACK}-${RUPACK_V}".tar.bz2 ) )"
RDEPEND="sys-libs/zlib
	>=dev-libs/libzip-0.9
	>=app-text/hunspell-1.2
	media-libs/libogg
	media-libs/libvorbis
	x11-libs/libXtst
	>=x11-libs/qt-core-4.5:4[exceptions]
	>=x11-libs/qt-gui-4.5:4[exceptions]
	>=x11-libs/qt-webkit-4.5:4[exceptions]
	!kde? ( || (
		>=x11-libs/qt-phonon-4.5:4[exceptions]
		media-libs/phonon ) )
	kde? ( media-libs/phonon )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"
for i in ${LANGS}; do
	RDEPEND="${RDEPEND}
		linguas_${i}? ( app-dicts/myspell-${i} )"
	[ ${i} == "de" ] && RDEPEND="${RDEPEND} linguas_${i}? ( app-dicts/myspell-${i}-alt )"
done

src_unpack() {
	if [[ ${PV} == "9999" ]] ; then
		git_src_unpack
	else
		unpack "${P}.tar.bz2"
	fi
}

src_prepare() {
	qt4-r2_src_prepare

	# linguas
	for x in ${LANGSLONG}; do
		if use !linguas_${x%_*}; then
			sed -e "s,locale/${x}.ts,," \
				-i ${PN}.pro || die
		fi
	done

	# do not install duplicates
	sed -e '/[icon,desktop]s2/d' \
		-i ${PN}.pro || die

	if use addons; then
		# get en<->ru funny pack
		if use linguas_ru; then
			mkdir "${WORKDIR}"/addons || die
			cd "${WORKDIR}"/addons
			unpack "${RUPACK}-${RUPACK_V}.tar.bz2"
		fi
	fi
}

src_configure() {
	PREFIX="${EPREFIX}"/usr eqmake4
}

src_install() {
	qt4-r2_src_install

	# install translations
	insinto /usr/share/apps/${PN}/locale
	for x in ${LANGSLONG}; do
		if use linguas_${x%_*}; then
			doins locale/${x}.qm || die
		fi
	done

	if use addons; then
		insinto "/usr/share/apps/${PN}"
		doins -r "${WORKDIR}"/addons/content/* || die
	fi
}

pkg_postinst() {
	elog "add '/usr/share/myspell' to ${PN} \"Morphology\" source"

	if use addons; then
		elog "add '/usr/share/apps/goldendict' to ${PN}"
		elog "\"Dictionaries\" and \"Sound\" sources"
		elog "and '/usr/share/apps/goldendict/morphology' to ${PN}"
		elog "\"Morphology\" sources if there are addons for you"
	fi
}

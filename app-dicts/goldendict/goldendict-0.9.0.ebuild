# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

if [[ ${PV} == "9999" ]] ; then
	ESVN_REPO_URI="svn://svn.berlios.de/goldendict/trunk/src"
	ESVN_PROJECT="goldendict"
	inherit subversion
	SRC_URI=""
	KEYWORDS=""
else
	inherit eutils
	SRC_URI="mirror://berlios/${PN}/${P}-src-x11.tar.bz2 -> ${P}.tar.bz2"
	KEYWORDS="~amd64 ~x86 ~x86-fbsd"
	S="${WORKDIR}/${P}-src"
fi

RUPACK="enruen-content"
RUPACK_V="1.1"
MORPH_V="1.0"

inherit qt4
DESCRIPTION="GoldenDict is a feature-rich dictionary lookup program."
HOMEPAGE="http://goldendict.berlios.de/"
LICENSE="GPL-3"
SLOT="0"

LANGS="af bg ca cs cy da de el en eo es et fo fr ga gl he hr hu ia id it ku lt lv mi mk ms nb nl nn pl pt ro ru sk sl sv sw tn uk zu"
IUSE="+addons"
for i in ${LANGS}; do
	IUSE="${IUSE} linguas_${i}"
done

# let's have some dictionaries, english-pronouncing pack and updated morphology
SRC_URI="${SRC_URI} addons? (
	linguas_en? ( mirror://berlios//"${PN}/en_US_${MORPH_V}".zip -> morphology_dict-en_US_"${MORPH_V}".zip
		      linguas_ru? ( mirror://berlios//"${PN}/${RUPACK}-${RUPACK_V}".tar.bz2 ) )
	linguas_es? ( mirror://berlios//"${PN}/es_ES_${MORPH_V}".zip -> morphology_dict-es_ES_"${MORPH_V}".zip )
	linguas_de? ( mirror://berlios//"${PN}/de_DE_${MORPH_V}".zip -> morphology_dict-de_DE_"${MORPH_V}".zip )
	linguas_fr? ( mirror://berlios//"${PN}/fr_FR_${MORPH_V}".zip -> morphology_dict-fr_FR_"${MORPH_V}".zip )
	linguas_it? ( mirror://berlios//"${PN}/it_IT_${MORPH_V}".zip -> morphology_dict-it_IT_"${MORPH_V}".zip )
	linguas_pt? ( mirror://berlios//"${PN}/pt_BR_${MORPH_V}".zip -> morphology_dict-pt_BR_"${MORPH_V}".zip )
	linguas_ru? ( mirror://berlios//"${PN}/ru_RU_${MORPH_V}".zip -> morphology_dict-ru_RU_"${MORPH_V}".zip )
	)"
RDEPEND="sys-libs/zlib
	>=dev-libs/libzip-0.9
	>=app-text/hunspell-1.2
	media-libs/libogg
	media-libs/libvorbis
	>=x11-libs/qt-core-4.5
	>=x11-libs/qt-webkit-4.5"
DEPEND="${RDEPEND}"
for i in ${LANGS}; do
	RDEPEND="${RDEPEND}
		linguas_${i}? ( app-dicts/myspell-${i} )"
	[ ${i} == "de" ] && RDEPEND="${RDEPEND} linguas_${i}? ( app-dicts/myspell-${i}-alt )"
done

src_unpack() {
	if [[ ${PV} == "9999" ]] ; then
		subversion_src_unpack
	else
		unpack "${P}.tar.bz2"
	fi

	if use addons; then
		[ -d addons ] || mkdir -p "${WORKDIR}"/addons/content/morphology
		# get en<->ru funny pack
		if use linguas_en && use linguas_ru; then
			cd "${WORKDIR}"/addons
			unpack "${RUPACK}-${RUPACK_V}.tar.bz2"
		fi
		# get updated morphology
		cd "${WORKDIR}"/addons/content/morphology || die
		for i in en de ru; do
			local I=$(echo ${i}|tr a-z A-Z)
			[ ${I} == "EN" ] && I="US"
			use linguas_${i} && unpack morphology_dict-${i}_${I}_"${MORPH_V}".zip
		done
	fi
}

src_prepare() {
	# fixing gcc >=4.4 issue
	epatch "${FILESDIR}"/gcc-4.4-fix.patch
}

src_compile() {
	PREFIX=/usr eqmake4 || die "qmake failed"
	emake || die "emake failed"
}

src_install() {
	emake INSTALL_ROOT="${D}" install || die "emake install filed"
	# install locales
	insinto /usr/share/apps/${PN}/locale
	for i in $LANGS; do
		if use linguas_${i}; then
			[ -f "locale/${i}.qm" ] && doins "locale/${i}.qm" || \
				ewarn "couldn't find $i translation"
		fi
	done

	# what is that ? not for us
	rm -r "${D}/usr/share/app-install" || die "couldn't delete useless stuff"

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

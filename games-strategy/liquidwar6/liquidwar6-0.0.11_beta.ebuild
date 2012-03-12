# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit autotools eutils games versionator

MY_PN="${PN/6/}"
MY_PV=$(version_format_string '$1.$2.$3$4')
MY_P="${PN}-${MY_PV}"

DESCRIPTION="unique multiplayer wargame"
HOMEPAGE="http://www.gnu.org/software/liquidwar6/"
SRC_URI="http://www.ufoot.org/download/${MY_PN}/v6/${MY_PV}/${PN}-${MY_PV}.tar.gz maps? ( http://www.ufoot.org/download/${MY_PN}/v6/${MY_PV}/${PN}-extra-maps-${MY_PV}.tar.gz )"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64"
IUSE="+allinone doc gtk http iconv +intl +maps nls ogg opengl openmp linguas_fr linguas_nn linguas_ru readline"

RDEPEND="dev-db/sqlite:3
	dev-lang/perl
	dev-libs/expat
	dev-scheme/guile
	media-libs/sdl-mixer
	sys-libs/zlib
	iconv? ( virtual/libiconv )
	intl? ( virtual/libintl )
	ogg? ( media-libs/libvorbis
		media-libs/libogg )
	opengl? ( gtk? ( x11-libs/gtk+:2 )
		media-libs/freetype:2 
		media-libs/libpng
		media-libs/mesa
		media-libs/sdl-ttf
		media-libs/sdl-image
		virtual/jpeg )
	readline? ( sys-libs/ncurses
		sys-libs/readline )
	net-misc/curl"
DEPEND="${RDEPEND}
	openmp? ( sys-devel/gcc[openmp] )
	sys-devel/libtool"

S=${WORKDIR}/${MY_P}

src_prepare() {
	# @see https://savannah.gnu.org/bugs/index.php?34614
	epatch "${FILESDIR}"/${PN}-libpng-1.5.patch
	eautoconf
}

src_configure() {
	myconf="--disable-mod-csound" # csound not available
	myconf="$(use_enable allinone)"
	myconf="${myconf} $(use_enable nls)"
	myconf="${myconf} $(use_enable openmp)"
	myconf="${myconf} $(use_enable http mod-http)"
	myconf="${myconf} $(use_enable readline console)"
	myconf="${myconf} $(use_with intl libintl-prefix)"
	myconf="${myconf} $(use_with iconv libiconv-prefix)"

	if ! use allinone; then
		myconf="${myconf} --disable-static"
	else
		myconf="${myconf} --disable-shared"
	fi

	myconf="${myconf} $(use_enable ogg mod-ogg)"
	if ! use ogg; then
		myconf="${myconf} --enable-silent"
	fi

	myconf="${myconf} $(use_enable opengl mod-gl)"
	if use opengl; then
		myconf="${myconf} $(use_enable gtk)"
	else
		myconf="${myconf} --disable-gtk"
		myconf="${myconf} --enable-headless"
	fi

	egamesconf ${myconf} || die "Cannot configure game"

	if use maps; then
		cd ${WORKDIR}/${PN}-extra-maps-${MY_PV} || "Cannot access extra maps directory"
		egamesconf || die "Cannot configure maps"
		cd ${S}
	fi
}

src_compile() {
	games_src_compile

	if use doc; then
		emake html
	fi

	if use maps; then
		cd ${WORKDIR}/${PN}-extra-maps-${MY_PV} || "Cannot access extra maps directory"
		emake || die "Cannot compile maps"
		cd ${S}
	fi
}

src_install() {
	dogamesbin src/liquidwar6

	# Epurate source tree
	find data/ map/ music/ script/ doc/example/ doc/dtd/ -name "Makefile*" -o -name README | xargs rm
	rm data/gfx/gl/utils/font/CREDITS data/gfx/gl/utils/font/AUTHORS

	# Set games datas
	insinto ${GAMES_DATADIR}/${MY_P}
	doins -r data/
	doins -r map/
	doins -r music/
	doins -r script/


	if use maps; then
		cd ${WORKDIR}/${PN}-extra-maps-${MY_PV} || "Cannot access extra maps directory"
		find -name README -exec rm '{}' ';'
		emake DESTDIR=${D} install || die "Cannot install maps"
		cd ${S}
	fi

	# Documentation
	if use doc; then dohtml doc/liquidwar6.html/*; fi
	dodoc NEWS README
	docinto dtd
	dodoc doc/dtd/*
	docinto example
	dodoc doc/example/*

	mv doc/${PN}.man doc/${PN}.6
	doman doc/${PN}.6
	doinfo doc/${PN}.info*

	# Prepare desktop
	doicon data/icon/${PN}.xpm
	make_desktop_entry ${PN} "Liquid War 6" ${PN}

	# Set locales
	localedir=/usr/games/share/locale
	if use nls; then
		for localename in fr nn ru
		do
			if use linguas_${localename}; then
				# How to use domo ?
				insinto ${localedir}/${localename}/LC_MESSAGES
				newins po/${localename}.gmo ${PN}.mo
			fi
		done
	fi

	if ! use allinone; then
		# Set active protocols list
		protocols="tcp udp"
		if use http; then protocols="http ${protocols}"; fi

		# AI list
		ai="brute follow idiot random"

		# Set headers to be exported
		all_header="bot cfg cli cns cnx dat def dsp dyn glb gui hlp img ker ldr map msg net nod p2p pil scm srv sys tsk vox"
		for mod in ${protocol}; do
			all_header="${all_header} cli/mod-${mod} srv/mod-${mod}d"
		done

		for mod in ${ai}; do
			all_header="${all_header} bot/mod-${mod}"
		done

		if use ogg; then all_header="${all_header} snd snd/mod-ogg"; fi
		if use opengl; then all_header="${all_header} gfx gfx/mod-gl"; fi

		# Install includes
		for header in ${all_header}
		do
			insinto "${GAMES_PREFIX}"/include/${PN}/${header}
			doins src/lib/${header}/$(basename ${header}).h
		done
		insinto "${GAMES_PREFIX}"/include/${PN}/sys
		doins src/lib/sys/sys-gettext.h
		insinto "${GAMES_PREFIX}"/include/${PN}/
		doins src/lib/${PN}.h

		libdir=$(games_get_libdir)

		insinto ${libdir}
		doins src/lib/.libs/lib${PN}.la
		doins src/lib/.libs/lib${PN}-${MY_PV}.so
		dosym ${libdir}/lib${PN}-${MY_PV}.so ${libdir}/lib${PN}.so

		curdir=bot
		insdir=${libdir}/${MY_P}/${curdir}
		insinto ${insdir}
		for mod in ${ai}; do
			doins src/lib/${curdir}/mod-${mod}/.libs/libmod_${mod}.la
			doins src/lib/${curdir}/mod-${mod}/.libs/libmod_${mod}-${MY_PV}.so
			dosym ${insdir}/libmod_${mod}-${MY_PV}.so ${insdir}/libmod_${mod}.so
		done

		curdir=cli
		insdir=${libdir}/${MY_P}/${curdir}
		insinto ${insdir}
		for mod in ${protocols}; do
			doins src/lib/${curdir}/mod-${mod}/.libs/libmod_${mod}.la
			doins src/lib/${curdir}/mod-${mod}/.libs/libmod_${mod}-${MY_PV}.so
			dosym ${insdir}/libmod_${mod}-${MY_PV}.so ${insdir}/libmod_${mod}.so
		done

		if use opengl; then
			mod=gl
			curdir=gfx
			insdir=${libdir}/${MY_P}/${curdir}
			insinto ${insdir}
			doins src/lib/${curdir}/mod-${mod}/.libs/libmod_${mod}.la
			doins src/lib/${curdir}/mod-${mod}/.libs/libmod_${mod}-${MY_PV}.so
			dosym ${insdir}/libmod_${mod}-${MY_PV}.so ${insdir}/libmod_${mod}.so
		fi

		if use ogg; then
			mod=ogg
			curdir=snd
			insdir=${libdir}/${MY_P}/${curdir}
			insinto ${insdir}
			doins src/lib/${curdir}/mod-${mod}/.libs/libmod_${mod}.la
			doins src/lib/${curdir}/mod-${mod}/.libs/libmod_${mod}-${MY_PV}.so
			dosym ${insdir}/libmod_${mod}-${MY_PV}.so ${insdir}/libmod_${mod}.so
		fi

		curdir=srv
		insdir=${libdir}/${MY_P}/${curdir}
		insinto ${insdir}
		for mod in ${protocols}; do
			doins src/lib/${curdir}/mod-${mod}d/.libs/libmod_${mod}d.la
			doins src/lib/${curdir}/mod-${mod}d/.libs/libmod_${mod}d-${MY_PV}.so
			dosym ${insdir}/libmod_${mod}d-${MY_PV}.so ${insdir}/libmod_${mod}d.so
		done
	fi

	prepgamesdirs
}

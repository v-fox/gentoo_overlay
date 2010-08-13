# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

inherit rpm toolchain-funcs

DESCRIPTION="gfxboot allows you to create gfx menus for bootmanagers."
HOMEPAGE="http://suse.com"
# We need find better place for src and repack it, but now...
SRC_URI="http://download.opensuse.org/distribution/openSUSE-stable/repo/src-oss/suse/src/gfxboot-${PV}-2.src.rpm"

LICENSE="GPL-2"
SLOT="3"
KEYWORDS="~x86 ~amd64"

IUSE_LINGUAS="linguas_af
	linguas_ar
	linguas_bg
	linguas_ca
	linguas_cs
	linguas_da
	linguas_de
	linguas_el
	linguas_en
	linguas_es
	linguas_et
	linguas_fi
	linguas_fr
	linguas_gu
	linguas_hi
	linguas_hr
	linguas_hu
	linguas_id
	linguas_it
	linguas_ja
	linguas_lt
	linguas_mr
	linguas_nb
	linguas_nl
	linguas_pa
	linguas_pl
	linguas_pt_BR
	linguas_pt
	linguas_ro
	linguas_ru
	linguas_sk
	linguas_sl
	linguas_sr
	linguas_sv
	linguas_ta
	linguas_tr
	linguas_uk
	linguas_wa
	linguas_xh
	linguas_zh_CN
	linguas_zh_TW
	linguas_zu"
IUSE="themes doc ${IUSE_LINGUAS}"

DEPEND="dev-lang/nasm
	>=media-libs/freetype-2
	themes? ( dev-libs/fribidi )
	doc? (	app-text/xmlto
		dev-perl/HTML-Parser )"
RESTRICT="mirror"

src_unpack () {
	rpm_src_unpack ${A}
	mv "${WORKDIR}/themes" "${S}/"
	cd "${S}"

	# going Gentoo-way
	sed -i	-e 's:^CFLAGS):#:' \
		-e 's:$(CFLAGS): -Wno-pointer-sign :' \
		-e 's:sbin:bin:g' Makefile

	if use themes; then
		[[ -n $LINGUAS ]] && LINGUAS="${LINGUAS/da/dk} en" || LINGUAS=en
		# We want to see penguins, many penguins... all the time
		sed -i "/penguin=/s:0:100:" `find . -type f -name gfxboot.cfg`

		# We want our native language by default
		sed -i "/DEFAULT_LANG =/s:$: `echo $LINGUAS|cut -f1 -d\ `:" \
			`find . -type f -name Makefile`

		# We want _only_ our favorite languages...
		for i in `find themes/* -type f -name languages`; do
			cp $i $i-
			locale -a >> $i-
			sort $i-|uniq -d > $i
			rm $i-
		done

		# ...and nothing else
		for i in `find . -path "./themes/*/help-*" -type f -name "*.html"; \
			find . -path "./themes/*" -type f -name "*.po"`;do
			if has `basename "$i" .po` "$LINGUAS" || has `basename "$i" .html` "$LINGUAS"; then
				einfo "keeping $i"
				else	rm "$i"
			fi
		done
	fi
}

src_compile() {
	emake -j1 || die "Make failed!"

	if use themes; then
		for i in `find themes -mindepth 1 -maxdepth 1 -type d`;do
			cd "$i"
			einfo "preparing $i"
			make prep
			cd "${S}"
		done
		einfo "all themes prepared; making..."
		emake -j1 themes || die "Make themes failed!"
	fi

	if use doc; then
		einfo "making nice docs"
		emake -j1 doc || die "Make doc failed!"
	fi
}

src_install() {
	dobin mkblfont || die
	dobin mkbootmsg || die
	if use themes; then
		cd themes
		for i in *;do
			insinto "/etc/bootsplash/$i"
			einfo "installing $i theme"
			doins "$i/boot/message"
		done
		cd "${S}"
	fi
	if use doc; then
		dodoc Changelog gfxboot
		dohtml doc/gfxboot.html
	fi
}

pkg_postinst() {
	if use themes; then
		einfo "To use gfxboot themes on your machine do following:"
		echo
		einfo "1) Pick up one of build-in themes in /etc/bootsplash"
		einfo "   or one from kde-look.org or similar site"
		einfo "2) Patch your grub_legacy to use gfxmenu or use grub2"
		einfo "   or lilo"
		einfo "3) copy 'message' to /boot/ [aka root of boot partition]"
		einfo "4) Set up gfxmenu in bootloader, as example"
		einfo "   'gfxmenu /message' line if your root=boot partition"
		einfo "   in grub_legacy"
	fi
}

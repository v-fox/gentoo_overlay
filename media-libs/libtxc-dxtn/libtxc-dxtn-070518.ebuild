# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit flag-o-matic

MY_PN=${PN/-/_}
MY_P=${MY_PN}${PV/-/_}
DESCRIPTION="Supports precompressed textures with hardware decompression"
HOMEPAGE="http://homepage.hispeed.ch/rscheidegger/dri_experimental/s3tc_index.html"
SRC_URI="http://homepage.hispeed.ch/rscheidegger/dri_experimental/${MY_P}.tar.gz"
LICENSE=""
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RDEPEND=""
DEPEND="${RDEPEND}"
S="${WORKDIR}/${MY_PN}"

src_unpack() {
	if use multilib; then
		unpack ${A}
		mkdir 32
		mv "${MY_PN}" 32/ || die
		sed -i -e "s:lib$:lib32:g" "32/${MY_PN}/Makefile" || die
	fi

	unpack ${A}
}

src_compile() {
	emake OPT_CFLAGS="${CFLAGS}" || die

	if use multilib; then
		cd "${WORKDIR}/32/${MY_PN}" || die
		multilib_toolchain_setup x86
		emake OPT_CFLAGS="${CFLAGS}" || die "making 32bit lib failed"
	fi
}

src_install() {
	if use multilib; then
		cd "${WORKDIR}/32/${MY_PN}" || die
		emake DESTDIR="${D}" install || die "emake install for 32bit lib failed"
		cd "${S}"
	fi

	emake DESTDIR="${D}" install || die "emake install failed"
}

pkg_info() {
	elog "Depending on where you live, you might need a valid license for s3tc"
	elog "in order to be legally allowed to use the external library."
	elog "Redistribution in binary form might also be problematic."
	elog "Ask your lawyer, the patent is supposedly held by VIA. It is your"
	elog "responsibility to comply with the laws of your country."
}

pkg_postinst() {
	pkg_info
}

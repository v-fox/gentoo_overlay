# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit base multilib toolchain-funcs

DESCRIPTION="Helper library for	S3TC texture (de)compression"
HOMEPAGE="http://people.freedesktop.org/~mareko/"
SRC_URI="http://cgit.freedesktop.org/~mareko/libtxc_dxtn/snapshot/${P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT=""

pkg_setup() {
	ewarn "Please notice that if you live in patent racket-encumbered country, you might need"
	ewarn "a valid license for s3tc in order to be legally allowed to use the external library."
}

src_compile() {
	local ABI

	tc-export CC
	for ABI in $(get_all_abis); do
		einfo "Building for ${ABI} ..."
		multilib_toolchain_setup ${ABI}
		mkdir ${ABI} || die
		emake || die
		mv -v ${PN}*.so *.o ${ABI}/ || die
	done
}

src_install() {
	local ABI

	for ABI in $(get_all_abis); do
		dolib ${ABI}/${PN}*.so || die
	done
}

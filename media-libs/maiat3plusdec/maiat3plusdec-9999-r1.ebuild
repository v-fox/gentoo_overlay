# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI=5

# Enable Bash strictness.
set -e

inherit eutils git-2

DESCRIPTION="PSP Audio Decoder"
HOMEPAGE="http://sourceforge.net/projects/maiat3plusdec/"
EGIT_REPO_URI="https://github.com/emulibraries/maiatrac3plus.git"

LICENSE="LGPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""
REQUIRED_USE=""

RDEPEND=""
DEPEND="${RDEPEND}"

src_unpack() {
	[[ -d "${EGIT_STORE_DIR}/${PN}" ]] ||
		einfo 'Cloning may take up to several minutes on slow connections.'
	git-2_src_unpack
}

src_compile() {
	cd "${S}"/MaiAT3PlusDecoder/src/
	emake
}

src_install() {
	doheader "${S}"/MaiAT3PlusDecoder/include/*
	dolib.so "${S}"/MaiAT3PlusDecoder/output/libat3plusdecoder.so
}

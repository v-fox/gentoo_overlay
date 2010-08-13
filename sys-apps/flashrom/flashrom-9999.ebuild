# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit subversion eutils

DESCRIPTION="Flash rom chips"
HOMEPAGE="http://linuxbios.org/Flashrom"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

SRC_URI=""
ESVN_REPO_URI="svn://linuxbios.org/repos/trunk/util/${PN}"

RDEPEND="sys-apps/pciutils
	sys-libs/zlib"

S=${WORKDIR}/${PN}


src_unpack() {
	subversion_src_unpack
	cd ${S}
	sed -i \
		-e "s|-Os -Wall -Werror -DDISABLE_DOC|${CFLAGS}|" \
		-e "s|STRIP_ARGS = |STRIP_ARGS = ${PORTAGE_STRIP_FLAGS}|" \
		-e "s|-lpci -lz -static|-lpci -lz ${LDFLAGS}|" \
		Makefile || die "sed"
}

src_compile() {
	emake
}

src_install() {
	dosbin flashrom
	doman *.8
}

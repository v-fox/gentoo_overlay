# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EGIT_REPO_URI="git://projects.reactivated.net/~dsd/fprint_demo.git"

inherit git eutils autotools

DESCRIPTION="fprint_demo"
HOMEPAGE="http://www.reactivated.net/fprint/wiki/Fprint_demo"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="=media-libs/libfprint-9999
	>=x11-libs/gtk+-2"

src_unpack() {
	git_src_unpack
	cd "${S}"
	eautoreconf
}

src_compile() {
	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || "emake install failed"
}

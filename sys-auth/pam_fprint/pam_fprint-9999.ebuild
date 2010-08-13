# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EGIT_REPO_URI="git://projects.reactivated.net/~dsd/pam_fprint.git"

inherit git eutils autotools

DESCRIPTION="pam_fprint"
HOMEPAGE="http://www.reactivated.net/fprint/wiki/Pam_fprint"
SRC_URI=""

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="=media-libs/libfprint-9999
	sys-libs/pam"

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

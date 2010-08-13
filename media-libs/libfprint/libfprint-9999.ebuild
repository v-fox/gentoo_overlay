# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit git eutils autotools

EGIT_REPO_URI="git://projects.reactivated.net/~dsd/libfprint.git"
#EGIT_BRANCH="libusb-1.0"
#EGIT_TREE="libusb-1.0"


DESCRIPTION="libfprint"
HOMEPAGE="http://www.reactivated.net/fprint/wiki/Libfprint"
SRC_URI=""

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS=""

DEPEND="media-gfx/imagemagick
	dev-libs/libusb"

src_unpack() {
	git_src_unpack
	cd ${S}

	eautoreconf
}

src_compile() {
	econf || die "econf died"
	emake || die "emake died"
}

src_install() {
	emake DESTDIR="${D}" install || "emake install failed"
}

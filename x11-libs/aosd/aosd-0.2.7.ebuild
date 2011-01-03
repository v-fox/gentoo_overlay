# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils

MY_P="lib${P}"
DESCRIPTION="An advanced on screen display (OSD) library"
HOMEPAGE="http://atheme.org/project/libaosd"
SRC_URI="http://distfiles.atheme.org/${MY_P}.tgz"
SLOT="0"
LICENSE="MIT"
KEYWORDS="x86 amd64 ~x86 ~amd64 ~ia64"
RDEPEND="dev-libs/glib:2
	x11-libs/cairo[X]
	x11-libs/pango[X]"
DEPEND="${RDEPEND}"
S="${WORKDIR}/${MY_P}"

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}


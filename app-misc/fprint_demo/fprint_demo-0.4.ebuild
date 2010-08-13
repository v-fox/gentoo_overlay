# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="fprint_demo"
HOMEPAGE="http://www.reactivated.net/fprint/wiki/Fprint_demo"
SRC_URI="mirror://sourceforge/fprint/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="media-libs/libfprint
	>=x11-libs/gtk+-2"

src_install() {
	emake DESTDIR="${D}" install
}


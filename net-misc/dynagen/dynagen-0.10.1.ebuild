# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Text-based frontend to Dynamips Cisco router emulator."
HOMEPAGE="http://www.dynagen.org/"
SRC_URI="mirror://sourceforge/dyna-gen/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND="app-emulation/dynamips
	>=dev-lang/python-2.5.1-r2"
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd ${S}
}

src_install() {
	
	insinto /usr/lib/dynagen
	doins *.py
	exeinto /usr/lib/dynagen
	doexe dynagen

	insinto /etc
	doins dynagen.ini

	dodir /usr/share/dynagen
	insinto /usr/share/dynagen
	doins configspec

	dodoc README.txt COPYING
	
	insinto /usr/share/doc/${P}
	doins -r sample_labs
	dohtml -r docs/*
	
	dosym /usr/lib/dynagen/dynagen /usr/bin/dynagen || die "Install failed!"
}

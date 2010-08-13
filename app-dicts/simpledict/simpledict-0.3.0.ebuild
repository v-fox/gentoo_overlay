# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils qt4
DESCRIPTION="Freeware Crossplatform Multiformat Dictionary (based on Qt4). It currently supports SDB, XDXF, DSL, MOVA formats."
HOMEPAGE="http://simpledict.sourceforge.net/"
SRC_URI="mirror://sourceforge/${P}-src.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ia64 ~ppc"
IUSE=""
RDEPEND=">=x11-libs/qt-core-4.3
	 >=x11-libs/qt-gui-4.3
	 >=dev-libs/glib-2.0"
DEPEND="${RDEPEND}"
PROVIDE="virtual/stardict"
S="${WORKDIR}/${P}-src"

src_unpack() {
	unpack "${A}"
	cd "${S}"
	# we do not want "Simpledict"-dir in our home, are we ?
	epatch "${FILESDIR}/${P}-modest_homepath.patch"
}

src_compile() {
	eqmake4 SimpleDict.pro || die "qmake failed"
	emake || die "emake failed"
}

src_install() {
	emake INSTALL_ROOT="${D}" install || die "emake install filed"

	rm -rf "${D}/usr/share/app-install" || die "failed to remove garbage"
}


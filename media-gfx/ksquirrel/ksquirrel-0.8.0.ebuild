# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit kde

MY_P="${PN}-${PV}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="An image viewer for KDE implementing OpenGL"
HOMEPAGE="http://ksquirrel.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.bz2"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
IUSE="kdeenablefinal kipi kexif"

DEPEND="=media-libs/ksquirrel-libs-${PV}
	kipi? ( media-libs/libkipi )
	kexif? ( media-libs/libkexif )"
RDEPEND="${DEPEND}"

need-kde 3.3

src_compile() {
	epatch "${FILESDIR}/ksquirrel-0.8.0-gcc43.patch"
	kde_src_compile
}

src_install() {
	kde_src_install
	dodoc fmt_filters_README
}

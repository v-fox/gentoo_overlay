# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Media Tag Tools - a mp3/ogg/flac tagger"
HOMEPAGE="http://mediatagtools.berlios.de"
SRC_URI="http://download.berlios.de/${PN}/${P}.tar.bz2"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~amd64 ~mips ~ppc ~sparc x86"
RESTRICT="nomirror"
IUSE=""

RDEPEND="=x11-libs/qt-3*
	>=media-libs/taglib-1.4"

DEPEND="${RDEPEND}"

src_compile() {
	cd "${S}"
	PATH="${QTDIR}/bin:${PATH}"
	echo "${D}/usr/" | qmake || die "qmake failed"
	emake || die "emake failed"
}

src_install() {
	emake install INSTALL_ROOT="${D}/usr/" || die "emake install failed"
}

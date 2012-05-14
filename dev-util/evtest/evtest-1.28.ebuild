# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
inherit autotools

DESCRIPTION="Displays information about input devices and monitors generated
events."
HOMEPAGE="http://cgit.freedesktop.org/evtest/"
SRC_URI="http://cgit.freedesktop.org/evtest/snapshot/${P}.tar.bz2"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="xml"

DEPEND="dev-libs/libxml2
	app-text/asciidoc
	app-text/xmlto"
RDEPEND="${DEPEND}
	dev-libs/libxslt"

src_unpack() {
	unpack ${A}
	cd ${S}

	eautoreconf
}

src_prepare() {
	epatch "${FILESDIR}/force-feedback-info-1.28.patch"
}

src_install() {
	emake DESTDIR="${D}" install || die
}

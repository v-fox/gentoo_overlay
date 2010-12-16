# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: 

EAPI="2"

inherit eutils autotools

IUSE=""
DESCRIPTION="Stardict tools"
HOMEPAGE="http://stardict.sourceforge.net/"
SRC_URI="mirror://sourceforge/stardict/${P}.tar.bz2"

RESTRICT="test"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 sparc ~x86"

RDEPEND="sys-libs/zlib
	dev-libs/libsigc++
	>=x11-libs/gtk+-2.12"

DEPEND="${RDEPEND}
	>=dev-util/intltool-0.22
	dev-util/pkgconfig"

src_install() {
	emake DESTDIR="${D}" install || die "failed to install"
}

# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="PPC binary codecs for video and audio playback support"
SRC_URI="mirror://mplayer/releases/codecs/all-ppc-${PV}.tar.bz2"
HOMEPAGE="http://www.mplayerhq.hu/"
LICENSE="as-is"
SLOT="0"
KEYWORDS="~ppc ~ppc64"
IUSE=""

S="${WORKDIR}/all-ppc-${PV}"

RESTRICT="strip"

QA_TEXTRELS="opt/${PN}/vid_*.xa"

src_install() {
	cd ${S}
	dodir /opt/${PN}
	insinto /opt/${PN}
	doins *.so *so.6.0 *.xa
	dodoc README
}

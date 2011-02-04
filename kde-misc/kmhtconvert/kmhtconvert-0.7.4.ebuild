# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit kde

DESCRIPTION="Convert Miscrosoft web archives (*.mht) int KDE web archives (*.war)"
HOMEPAGE="http://members.hellug.gr/sng/kmhtconvert/"
SRC_URI="http://members.hellug.gr/sng/kmhtconvert/${PN}.tgz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RESTRICT=""
DEPEND="|| ( >=kde-base/kdebase-kioslaves-3.5.7 >=kde-base/kdebase-3.5.7 )"
RDEPEND="${DEPEND}"

need-kde 3.5

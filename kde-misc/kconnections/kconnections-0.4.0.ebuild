# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: 

inherit kde

DESCRIPTION="This is small wrapper for netstat for KDE"
HOMEPAGE="http://kde-apps.org/content/show.php/KConnections?content=71204"
SRC_URI="http://downloads.sourceforge.net/ksquirrel/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc64 x86"
IUSE=""

need-kde 3.5

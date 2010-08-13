# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2 or later
# $Header: $

inherit kde

DESCRIPTION="Simple dock applet for KDE which is a front-end to a Perl script that is a front-end to mpg123"
HOMEPAGE="http://www.somekool.net/HTML/smk2k3/index.php?did=7"
SRC_URI="http://www.somekool.net/HTML/smk2k3/stuff/${P}.tar.gz"
RESTRICT="nomirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-sound/mpg123"

need-kde 3.2

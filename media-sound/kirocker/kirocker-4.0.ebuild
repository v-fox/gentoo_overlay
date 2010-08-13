# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2 or later
# $Header: $

inherit kde versionator

MY_PV="${PV/_b/B}"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="Make your Kicker (the KDE main panel) rock with your music."
HOMEPAGE="http://www.kde-apps.org/content/show.php?content=52869"
SRC_URI="http://slaout.linux62.org/kirocker/downloads/${MY_P}.tar.gz"
RESTRICT="nomirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-sound/amarok"

need-kde 3.2

S=${WORKDIR}/${MY_P}

PATCHES="${FILESDIR}/${PF}-wheel_volume_control.patch"

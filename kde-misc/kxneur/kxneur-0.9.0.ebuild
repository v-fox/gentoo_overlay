# Copyright 1999-2007 Gentoo Foundation

inherit kde

DESCRIPTION="KDE front-end for XNeur keybord layout switcher"
SRC_URI="http://dists.xneur.ru/release-${PV}/tgz/${P}.tar.bz2"
HOMEPAGE="http://www.xneur.ru"
LICENSE="GPL-2"

KEYWORDS="sparc x86 amd64"
IUSE=""

DEPEND=">=x11-apps/xneur-0.6.2"

need-kde 3.4

# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-misc/krecipes/krecipes-0.8.1.ebuild,v 1.1 2005/07/31 23:10:14 carlo Exp $

inherit kde

DESCRIPTION="A KDE front-end to MAME"
HOMEPAGE="http://kxmame.sourceforge.net"
SRC_URI="mirror://sourceforge/kxmame/${P}.tar.bz2"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~x86 ~amd64"

RDEPEND="${DEPEND}
	dev-util/pkgconfig
	dev-libs/glib"

need-kde 3.2


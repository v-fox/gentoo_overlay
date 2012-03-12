# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-misc/kwatersaver4/kwatersaver4-0.7.ebuild,v 1.1 2010/02/21 14:06:44 sb Exp $

EAPI="4"

OPENGL_REQUIRED="always"

inherit kde4-base

HOMEPAGE="http://kwatersaver.c0n.de/"
DESCRIPTION="OpenGL KDE4 screensaver - put your desktop under water"
SRC_URI="http://kwatersaver.c0n.de/downloads/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
RESTRICT="nomirror"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="${DEPEND}
	>=kde-base/kscreensaver-4.1.4[opengl]
	virtual/opengl"
RDEPEND="${DEPEND}"

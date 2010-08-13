# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# kde-misc/kosd-0.2 ebuild version 0.4 2008-05-30 14:30

inherit kde

KLV=81457
DESCRIPTION="Displays a configurable OSD for certain button events (like volume changes) for KDE"
HOMEPAGE="http://kde-apps.org/content/show.php/KOSD?content=${KLV}"
SRC_URI="http://kde-apps.org/CONTENT/content-files/${KLV}-KOSD-${PV}.tar.bz2"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc ~x86"
RESTRICT="nomirror ${RESTRICT}"

need-kde 3.2

S="${WORKDIR}/KOSD"

src_unpack() {
	
	unpack "${A}"
	cd "${S}"
	
}

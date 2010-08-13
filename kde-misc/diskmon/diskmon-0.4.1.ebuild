# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit kde

DESCRIPTION=" Kicker Applet of KDE that monitors free space of some disks"
HOMEPAGE="http://kde-apps.org/content/show.php/DiskMonitor?content=45015"
SRC_URI="http://kde-apps.org/CONTENT/content-files/45015-${PN}itor-${PV}.tar.gz"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

S="${WORKDIR}/${PN}itor-${PV}"

src_unpack() {
	unpack ${A}
	cd ${S}
}
src_compile() {
	econf $(use_with arts) --prefix=$(kde-config --prefix)
	make || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}

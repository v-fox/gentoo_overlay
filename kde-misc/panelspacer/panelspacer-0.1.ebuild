# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="1"

NEED_KDE="4.1"
inherit kde4-base

DESCRIPTION="A KDE4 Plasma Applet let you put some blank space between the other applets located in a panel"
KEYWORDS="amd64 x86"
HOME_PAGE="http://www.kde-look.org/content/show.php/Panel+Spacer?content=89304"
IUSE=""
SRC_URI="http://www.kde-look.org/CONTENT/content-files/89304-${PN}${PV}.tar.gz"
SLOT="4.1"

DEPEND="kde-base/libplasma"

S=${WORKDIR}/plasmaspacer_0.1

src_compile()
{
	kde4-base_src_compile
}

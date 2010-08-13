# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: 

inherit kde

DESCRIPTION="Kde Image Menu"
HOMEPAGE="http://kde-apps.org/content/show.php/Kim+(Kde+Image+Menu)?content=11505"
SRC_URI="http://bouveyron.free.fr/${PN}/release/${P}.tar.gz"
RESTRICT="mirror"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE=""

RDEPEND="media-gfx/imagemagick
	media-video/mpeg-tools"
DEPEND=""

S="${WORKDIR}/${PN}"

need-kde 3.3

src_compile() {
	einfo "We are script and have nothing to configure"
	sed -i 	-e 's:`kde-config --prefix`:$1:' \
		-e 's:mkdir:mkdir -p:g' install.sh || die
}

src_install() {
	mkdir -p ${D}${KDEDIR}/share/apps/konqueror/servicemenus/
	mkdir -p ${D}${KDEDIR}/bin
	./install.sh ${D}${KDEDIR}
}

# Copyright 2008 [v-fox] ftp://dfx.homeftp.net/services/GENTOO/v-fox
# Distributed under the terms of the GNU General Public License v2 or later

inherit

DESCRIPTION="Front-end to http://www.opensubtitles.org"
HOMEPAGE="http://code.google.com/p/subdownloader"

SRC_URI="http://subdownloader.googlecode.com/files/sources.${PV}.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="app-arch/unzip"
RDEPEND=">=dev-lang/python-2.5
	>=dev-python/wxpython-2.8
	dev-python/imdbpy
	dev-python/mmpython"

S="${WORKDIR}"

src_unpack() {
	unpack ${A}
	# Cleaning up bad stuff (it's all bad, actually)
	rm Makefile
	#Making wrapper
	echo -e "#!/bin/sh\\ncd '/opt/subdownloader'\\n./SubDownloader.py" > \
	"subdownloader"
}

src_install() {
	dodoc README.txt TODO.txt tips.txt credits.txt
	insinto "/usr/bin"
	doins "subdownloader"
	insinto /opt/subdownloader
	doins ${S}/*
	# Fixing exe-bit
	chmod +x "${D}/usr/bin/subdownloader"
	chmod +x "${D}/opt/subdownloader/SubDownloader.py"
}

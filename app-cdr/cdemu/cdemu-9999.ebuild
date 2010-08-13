# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/cdemu/cdemu-0.8.ebuild,v 1.3 2007/01/14 15:35:42 vapier Exp $

inherit linux-mod python eutils subversion

DESCRIPTION="mount bin/cue cd images"
HOMEPAGE="http://cdemu.sourceforge.net/"

LICENSE="GPL-2"
KEYWORDS="amd64 hppa ppc x86"
IUSE=""
RESTRICT="test" #158556

DEPEND="virtual/linux-sources"
RDEPEND="dev-lang/python"

MODULE_NAMES="cdemu(block:${S})"
#BUILD_TARGETS="clean default"

SRC_URI=""

ESVN_REPO_URI="${ESVN_AUTH:-https}://${PN}.svn.sourceforge.net/svnroot/${PN}"
ESVN_MODULE="${PN}"

ARCH=$(uname -m)

S="${WORKDIR}/${PN}"

src_compile() {
	cd ${S}/trunk/cdemu
        emake
}

src_install() {
	cd ${S}/trunk/cdemu
	emake install || die
	dodoc AUTHORS ChangeLog README TODO
}

pkg_postinst() {
	python_mod_compile /usr/lib*/python*/site-packages/libcdemu.py
	linux-mod_pkg_postinst
}

pkg_postrm() {
	python_mod_cleanup
	linux-mod_pkg_postrm
}

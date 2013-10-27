# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI=5

# Enable Bash strictness.
set -e

inherit git-2

DESCRIPTION="Patched kernel containing the latest nouveau sources"
HOMEPAGE="nouveau.freedesktop.org"
EGIT_REPO_URI="git://anongit.freedesktop.org/nouveau/linux-2.6"
EGIT_BRANCH="drm-nouveau-next"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~amd64"

IUSE=""
REQUIRED_USE=""

src_unpack() {
	[[ -d "${EGIT_STORE_DIR}/${PN}" ]] ||
		einfo 'Cloning may take up to several minutes on slow connections.'
	git-2_src_unpack
}

src_compile() {
	einfo 'No compilation required'
}

src_install() {
	mkdir -p ${D}/usr/src/
	cp -R ${S} ${D}/usr/src/  || die "emake install failed"
}

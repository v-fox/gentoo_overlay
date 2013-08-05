# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI=5

# Enable Bash strictness.
set -e

inherit git-2

DESCRIPTION="Lacewing networking library"
HOMEPAGE="http://lacewing-project.org"
EGIT_REPO_URI="https://github.com/udp/lacewing.git"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="openssl"
REQUIRED_USE=""

RDEPEND="openssl? ( dev-libs/openssl )"
DEPEND="${RDEPEND}"

src_unpack() {
	[[ -d "${EGIT_STORE_DIR}/${PN}" ]] ||
		einfo 'Cloning may take up to several minutes on slow connections.'
	git-2_src_unpack
}

src_compile() {
	econf $(use_enable openssl ) || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}

# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/hwdata-redhat/hwdata-redhat-0.217.ebuild,v 1.1 2008/07/15 17:05:57 darkside Exp $

EAPI="3"
inherit flag-o-matic

DESCRIPTION="Hardware identification and configuration data"
HOMEPAGE="https://admin.fedoraproject.org/pkgdb/packages/name/hwdata"
SRC_URI="https://fedorahosted.org/releases/h/w/hwdata/${PV}.tar.bz2"
LICENSE="GPL-2 MIT"
SLOT="0"
KEYWORDS="~ppc ~ppc64 ~x86 ~amd64"
IUSE="test"
RDEPEND=">=sys-apps/module-init-tools-3.2
	!sys-apps/hwdata-gentoo"
DEPEND="${RDEPEND}
	test? ( sys-apps/pciutils )"

src_prepare() {
	sed -i -e "s:\(/sbin\/lspci\):/usr\1:g" Makefile || die
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	# Don't let it overwrite a udev-installed file
	rm -rf "${D}"/etc/ || die
}

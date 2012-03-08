# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/kudzu/kudzu-1.2.83.ebuild,v 1.4 2008/07/20 06:28:48 mr_bones_ Exp $

EAPI="3"
inherit eutils python multilib toolchain-funcs

DESCRIPTION="Red Hat Hardware detection tools"
SRC_URI="https://fedorahosted.org/releases/k/u/kudzu/${P}.tar.bz2"
HOMEPAGE="https://admin.fedoraproject.org/pkgdb/packages/name/kudzu"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE=""

RDEPEND="dev-libs/popt
	sys-apps/hwdata-redhat
	!sys-apps/kudzu"
DEPEND="dev-libs/popt
	>=sys-apps/pciutils-2.2.4"

src_compile() {
	emake \
		all \
		CC=$(tc-getCC) \
		AR=$(tc-getAR) \
		RANLIB=$(tc-getRANLIB) \
		RPM_OPT_FLAGS="${CFLAGS}" \
		LDFLAGS="${LDFLAGS}" \
		|| die "emake failed"
}

src_install() {
	emake \
		install \
		install-program \
		DESTDIR="${D}" \
		libdir="${D}/usr/$(get_libdir)" \
		CC=$(tc-getCC) \
		|| die "install failed"

	# don't install incompatible init scripts
	rm -rf \
		"${D}"/etc/rc.d \
		|| die "removing rc.d files failed"
}

pkg_postinst() {
	python_version

	python_mod_compile \
		/usr/$(get_libdir)/python${PYVER}/site-packages/kudzu.py
}

pkg_postrm() {
	python_mod_cleanup
}

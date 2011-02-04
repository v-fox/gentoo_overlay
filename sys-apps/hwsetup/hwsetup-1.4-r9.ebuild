# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/hwsetup/hwsetup-1.2-r1.ebuild,v 1.5 2009/06/16 12:04:11 flameeyes Exp $

EAPI="3"
inherit eutils toolchain-funcs flag-o-matic

DESCRIPTION="Hardware setup program from Knoppix - used only on LiveCD"
HOMEPAGE="http://www.knopper.net/"
SRC_URI="http://debian-knoppix.alioth.debian.org/sources/${P/-/_}-${PR/r/}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 ia64 -mips ppc ppc64 sparc x86"
IUSE="zlib"

COMMON_DEPEND="zlib? ( sys-apps/pciutils[zlib] )
	!zlib? ( sys-apps/pciutils[-zlib] )"
DEPEND="${COMMON_DEPEND}
	sys-libs/libkudzu"
RDEPEND="${COMMON_DEPEND}
	sys-apps/hwdata-gentoo"
S="${WORKDIR}/${P/-/_}-${PR/r/}"

pkg_preinst() {
	ewarn "This package is designed for use on the LiveCD only and will do "
	ewarn "unspeakably horrible and unexpected things on a normal system."
	ewarn "YOU HAVE BEEN WARNED!!!"
}

src_prepare() {
	epatch \
		"${FILESDIR}"/1.2-7-dyn_blacklist.patch \
		"${FILESDIR}"/1.2-3-fastprobe.patch \
		"${FILESDIR}"/1.2-7-gentoo.patch \
		"${FILESDIR}"/1.2-strip.patch
}

src_compile() {
	emake LDFLAGS="${LDFLAGS}" OPT="${CFLAGS}" CC="$(tc-getCC)" || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die
	keepdir /etc/sysconfig
}

pkg_postinst() {
	ewarn "This package is intended for usage on the Gentoo release media.  If"
	ewarn "you are not building a CD, remove this package.  It will not work"
	ewarn "properly on a running system, as Gentoo does not use any of the"
	ewarn "Knoppix-style detection except for CD builds."
}

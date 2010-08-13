# Copyright 1999-2008 Gentoo Foundation
# [v-fox] ftp://dfx.homeftp.net/services/GENTOO/v-fox
# $Header: /var/cvsroot/gentoo-x86/dev-libs/lzo/lzo-2.02-r1.ebuild,v 1.18 2008/02/12 13:07:41 flameeyes Exp $

inherit eutils libtool flag-o-matic multilib

DESCRIPTION="An extremely fast compression and decompression library"
HOMEPAGE="http://www.oberhumer.com/opensource/lzo/"
SRC_URI="http://www.oberhumer.com/opensource/lzo/download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE="examples multilib"

DEPEND=""
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-exec-stack.patch

	elibtoolize
}

src_compile() {
	if use amd64; then
		mkdir libs32
		einfo "making ${P} for 32bit environment"
		multilib_toolchain_setup x86
		LIB32=/usr/$(get_libdir)
		econf	--enable-static=yes \
			--enable-shared=no || die
		emake || die
		for i in `find src -type f -name "liblzo2.*a"`; do
			einfo "keeping 32bit library `basename $i`"
			mv "$i" libs32/
		done
		emake distclean
		einfo "making ${P} for system"
		multilib_toolchain_setup amd64
		econf --enable-shared || die
		emake || die
	else
		econf --enable-shared || die
		emake || die
	fi
}

src_install() {
	if use amd64; then
		make DESTDIR="${D}" install || die
		insinto "$LIB32"
		for i in `find libs32 -type f -name "*"`;do
			einfo "installing 32bit library: $i"
			doins "$i"
		done
	else
		make DESTDIR="${D}" install || die
	fi
	dodoc AUTHORS BUGS ChangeLog NEWS README THANKS doc/LZO*
	if use examples ; then
		docinto examples
		dodoc examples/*.c examples/Makefile
	fi
}

# Copyright 1999-2008 Gentoo Foundation
# [v-fox] ftp://dfx.homeftp.net/services/GENTOO/v-fox
# Distributed under the terms of the GNU General Public License v2

inherit eutils flag-o-matic subversion

DESCRIPTION="Multi-platform & multi-targets cpu emulator and dynamic translator"
HOMEPAGE="http://fabrice.bellard.free.fr/qemu/
	http://savannah.nongnu.org"
ESVN_REPO_URI="svn://svn.savannah.nongnu.org/qemu/trunk"
ESVN_PROJECT="qemu"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="custom-flags static" 
RESTRICT="test"

DEPEND="virtual/libc
	app-text/texi2html
	!<=app-emulation/qemu-0.7.0"
RDEPEND=""

QA_TEXTRELS="usr/bin/qemu-armeb
	usr/bin/qemu-i386
	usr/bin/qemu-mips
	usr/bin/qemu-arm
	usr/bin/qemu-ppc"

src_unpack() {
        subversion_src_unpack
        cd "${S}"

	# Alter target makefiles to accept CFLAGS set via flag-o.
	sed -i 's/^\(C\|OP_C\|HELPER_C\)FLAGS=/\1FLAGS+=/' \
		Makefile Makefile.target tests/Makefile
	# avoid strip
	sed -i 's/ -s / /g' Makefile Makefile.target

	if use custom-flags; then
		sed -i	-e "/CFLAGS/s:-Wall -O2 -g -fno-strict-aliasing::g" \
			-e "/LDFLAGS/s:-g::g" configure
	fi
}

src_compile() {
	if ! use custom-flags; then
		unset CFLAGS
		strip-ldflags
	fi

	# Switch off hardened tech
	filter-flags -fpie -fstack-protector

	myconf="--disable-gcc-check"
	./configure \
		--prefix=/usr \
		--enable-linux-user \
		--disable-system \
		${myconf} \
		|| die "could not configure"

	emake || die "make failed"
}

src_install() {
	einstall docdir="${D}/usr/share/doc/${P}" || die

	rm -fR "${D}/usr/share/{man,qemu}"
	rm -fR "${D}/usr/bin/qemu-img"
}

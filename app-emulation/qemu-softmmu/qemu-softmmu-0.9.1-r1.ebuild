# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/qemu-softmmu/qemu-softmmu-0.9.1-r1.ebuild,v 1.2 2008/03/09 15:11:59 lu_zero Exp $

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="Multi-platform & multi-targets cpu emulator and dynamic translator"
HOMEPAGE="http://fabrice.bellard.free.fr/qemu/"
SRC_URI="${HOMEPAGE}${P/-softmmu/}.tar.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="-alpha ~amd64 ppc -sparc ~x86"
IUSE="sdl kqemu gnutls alsa custom-flags"
RESTRICT="binchecks test"

DEPEND="virtual/libc
	sys-libs/zlib
	sdl? ( media-libs/libsdl )
	!<=app-emulation/qemu-0.7.0
	kqemu? ( >=app-emulation/kqemu-1.3.0_pre10 )
	gnutls? (
		dev-util/pkgconfig
		net-libs/gnutls
	)
	app-text/texi2html"
RDEPEND="sys-libs/zlib
	sdl? ( media-libs/libsdl )
	gnutls? ( net-libs/gnutls )
	alsa? ( media-libs/alsa-lib )"

S="${WORKDIR}/${P/-softmmu/}"

src_unpack() {
	unpack ${A}

	cd "${S}"
	# Fix CVE-2008-0928
	epatch "${FILESDIR}/${P}-block-device-address-range.patch"
	# No way for static SDL
	epatch "${FILESDIR}/${P}-no_way_static_SDL.patch"
	# Workaround for gcc4
	#epatch "${FILESDIR}/${P}-gcc4.patch"
	# Alter target makefiles to accept CFLAGS set via flag-o.
	sed -i 's/^\(C\|OP_C\|HELPER_C\)FLAGS=/\1FLAGS+=/' \
		Makefile Makefile.target tests/Makefile
	# Ensure mprotect restrictions are relaxed for emulator binaries
	[[ -x /sbin/paxctl ]] && \
		sed -i 's/^VL_LDFLAGS=$/VL_LDFLAGS=-Wl,-z,execheap/' \
			Makefile.target
	# Prevent install of kernel module by qemu's makefile
	sed -i 's/\(.\/install.sh\)/#\1/' Makefile
	# avoid strip
	sed -i 's:$(INSTALL) -m 755 -s:$(INSTALL) -m 755:' Makefile Makefile.target
}

src_compile() {
	
	! use custom-flags && \
	unset CFLAGS CXXFLAGS LDFLAGS

	# Switch off hardened tech
	filter-flags -fpie -fstack-protector

		myconf="--disable-gcc-check"
	if use alsa; then
		myconf="$myconf --enable-alsa"
	fi
	if ! use gnutls; then
		myconf="$myconf --disable-vnc-tls"
	fi
	if ! use kqemu; then
		myconf="$myconf --disable-kqemu"
	fi
	if ! use sdl ; then
		myconf="$myconf --disable-sdl --disable-gfx-check"
	fi

	./configure \
		--prefix=/usr \
		--enable-adlib \
		--cc=$(tc-getCC) \
		--host-cc=$(tc-getCC) \
		--disable-linux-user \
		--enable-system \
		--disable-gcc-check \
		--disable-gfx-check \
		$myconf \
		|| die "could not configure"

	CFLAGS=$CFLAGS emake || die "make failed"
}

src_install() {
	make install \
		prefix="${D}/usr" \
		bindir="${D}/usr/bin" \
		datadir="${D}/usr/share/qemu" \
		docdir="${D}/usr/share/doc/${P}" \
		mandir="${D}/usr/share/man" || die

	chmod -x "${D}/usr/share/man/*/*"
}

pkg_postinst() {
	einfo "You will need the Universal TUN/TAP driver compiled into"
	einfo "kernel or as a module to use the virtual network device."
}

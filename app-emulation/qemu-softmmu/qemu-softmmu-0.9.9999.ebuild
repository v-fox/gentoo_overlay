# Copyright 1999-2008 Gentoo Foundation
# [v-fox] ftp://dfx.homeftp.net/services/GENTOO/v-fox
# Distributed under the terms of the GNU General Public License v2

inherit eutils flag-o-matic toolchain-funcs subversion

DESCRIPTION="Multi-platform & multi-targets cpu emulator and dynamic translator"
HOMEPAGE="http://fabrice.bellard.free.fr/qemu/
	http://savannah.nongnu.org"
ESVN_REPO_URI="svn://svn.savannah.nongnu.org/qemu/trunk"
ESVN_PROJECT="qemu"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="-alpha ~amd64 ppc -sparc ~x86"
IUSE="sdl kqemu gnutls ac97 adlib gus fmod alsa esd ncurses custom-flags oss static accessibility"
RESTRICT="binchecks test"

DEPEND="virtual/libc
	sys-libs/zlib
	sys-libs/ncurses
	sdl?	( media-libs/libsdl )
	!<=app-emulation/qemu-0.7.0
	kqemu?	( >=app-emulation/kqemu-1.3.0_pre10 )
	gnutls?	( dev-util/pkgconfig
		  net-libs/gnutls )
	fmod?	( >media-libs/fmod-4.0.0 )
	alsa?	( media-libs/alsa-lib )
	oss?	( media-libs/alsa-oss )
	esd?	( media-sound/esound )
	app-text/texi2html"
RDEPEND="${DEPEND}"

pkg_setup() {
	if ! use alsa && ! use esd && ! use sdl && ! use oss && ! use fmod; then
		ewarn "You have no audio output selected"
		ewarn "Your options here are: alsa oss fmod esd sdl"
		epause 5
	else
		if ! use ac97 && ! use adlib && ! use gus; then
			ewarn "You have audio output but have no audio emulation"
			ewarn "If you want sound - choose between 'ac97', 'adlib', 'gus'"
			ewarn "or use them altogether"
			epause 5
		fi
	fi

	if ! use sdl && ! use ncurses; then
		ewarn "You have no video output selected"
		ewarn "Try 'sdl' or 'ncurses' flags"
		ebeep
		epause 8
	fi
}

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

	local myconf="--disable-gcc-check --disable-werror --enable-mixemu"
	use static	&& myconf="$myconf --static"

	# New ugly way to choose audio output
	myconf="$myconf --audio-drv-list=$(for i in alsa oss fmod esd sdl;do use "$i" && echo -n "$i ";done)"

	# Mew ugly way to choose emulated cards
	myconf="$myconf --audio-card-list=$(for i in ac97 adlib gus;do use $i && echo -n "$i ";done)"

	use fmod	&& myconf="$myconf --enable-fmod \
			--fmod-inc=/usr/include/fmodex \
			--fmod-lib=/usr/lib/libfmodex.so"

	use accessibility	|| myconf="$myconf --disable-brlapi"
	use ncurses		|| myconf="$myconf --disable-curses"
	use gnutls		|| myconf="$myconf --disable-vnc-tls"
	use kqemu		|| myconf="$myconf --disable-kqemu"
	use sdl			|| myconf="$myconf --disable-sdl"

	echo $myconf

	./configure \
		--prefix=/usr \
		--cc=$(tc-getCC) \
		--host-cc=$(tc-getCC) \
		--disable-linux-user \
		--enable-system \
		--enable-profiler \
		$myconf \
		|| die "could not configure"

	emake || die "make failed"
}

src_install() {
	make install \
		prefix="${D}/usr" \
		bindir="${D}/usr/bin" \
		datadir="${D}/usr/share/qemu" \
		docdir="${D}/usr/share/doc/${P}" \
		mandir="${D}/usr/share/man" || die
	# Installing script for easy use [ugly `yet]
	dobin "${FILESDIR}/qemu_exec"
}

pkg_postinst() {
	einfo "You will need the Universal TUN/TAP driver compiled into"
	einfo "kernel or as a module to use the virtual network device."
	elog "Try to use \"qemu_exec\" script"
}

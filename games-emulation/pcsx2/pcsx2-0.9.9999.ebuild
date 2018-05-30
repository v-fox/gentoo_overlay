# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# [v-fox] ftp://dfx.homeftp.net/services/GENTOO/v-fox
# $Header: $

EAPI="3"
inherit autotools eutils flag-o-matic subversion

DESCRIPTION="PlayStation2 emulator"
HOMEPAGE="http://www.pcsx2.net/"
# "Old" repository
#ESVN_REPO_URI="https://pcsx2.svn.sourceforge.net/svnroot/pcsx2"
#ESVN_PROJECT="pcsx2"
ESVN_REPO_URI="http://pcsx2.googlecode.com/svn/trunk"
ESVN_PROJECT="pcsx2-read-only"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="debug oss mmx sse +sse2 sse3 sse4 +standalone custom-cflags"

PLUGINS="games-emulation/ps2emu-cddvdlinuz
	games-emulation/ps2emu-cdvdiso
	games-emulation/ps2emu-dev9null
	games-emulation/ps2emu-gssoft
	games-emulation/ps2emu-padxwin
	games-emulation/ps2emu-spu2null
	games-emulation/ps2emu-usbnull"

CDEPEND="app-arch/p7zip
	x86? (  sys-libs/zlib
		>=x11-libs/gtk+-2 )
	amd64? ( app-emulation/emul-linux-x86-baselibs
		 app-emulation/emul-linux-x86-gtklibs )
	virtual/libintl
	oss? ( media-libs/alsa-oss )"
RDEPEND="${CDEPEND}
	standalone? ( 	media-libs/glew
			media-gfx/nvidia-cg-toolkit )"
DEPEND="${CDEPEND}
	x11-proto/xproto"

# all plugins are build from same git if using standalone-flag
for i in ${PLUGINS}; do
	use standalone 	&& RDEPEND+=" ${i}" \
			|| RDEPEND+=" !${i}"
done

pkg_setup() {
	local x

	if ! use sse2; then
		ewarn "at least SSE2 support required for GL video plugin to run correctly"
		ewarn "Please, make sure you have appropriate CPU and enable 'sse2' flag"
	fi

	if use amd64 && ! has_multilib_profile; then
		eerror "You must be on a multilib profile to use pcsx2!"
		die "No multilib profile."
	fi

	# workaround for stupid 32bit-only asm code
	use amd64 && multilib_toolchain_setup x86
}

src_prepare() {
	cd "${S}/pcsx2"

	sed -i -e "s:-m32::g" configure.ac

	eautoreconf -v --install || die

	# never give up !
	for i in $(find .. -iname "build.sh"); do
		chmod +x "$i"
		sed -i -e "s/exit/echo/g" "$i"
	done
}

src_configure() {
	export PCSX2PLUGINS="${S}/bin/plugins"

	cd "${S}/pcsx2"

	use custom-cflags && PCSX2OPTIONS="--enable-customcflags"
	PCSX2OPTIONS="${PCSX2OPTIONS} --prefix=${S}"

	append-ldflags -Wl,-z,noexecstack

	if ! use x86 && ! use amd64; then
		ewarn "Recompiler not supported on this architecture. Disabling."
		PCSX2OPTIONS+=" --disable-recbuild"
	fi

	if ! use mmx && ! use sse && ! use sse2 && ! use sse3 && ! use sse4; then
		ewarn "Recompiler not supported with mmx and sse disabled|unsupported."
		PCSX2OPTIONS+=" --disable-recbuild"
	fi

	if use debug; then
		for i in PCSX2OPTIONS ZEROGSOPTIONS ZEROSPU2OPTIONS; do
			$i+=" --enable-devbuild --enable-debug"
		done
	else
		PCSX2OPTIONS+=" --enable-memcpyfast"
	fi

	# Optimisations
	for i in sse{3,4} ;do
		PCSX2OPTIONS="${PCSX2OPTIONS} $(use_enable $i)"
	done
	export ZEROSPU2OPTIONS=${ZEROSPU2OPTIONS}
	export ZEROGSOPTIONS+=" $(use_enable sse2)"

	./configure ${PCSX2OPTIONS} || die
}

src_compile() {
	cd "${S}/pcsx2"
	emake || die "making pcsx2 failed"

	if use standalone; then
		cd ../plugins
		einfo "building plugins"
		./build.sh all || die "making plugins failed"
		ewarn "building additional plugins"
		cd ${S}/plugins/spu2-x/src/Linux || die
		make || ewarn "spu2-x is windows-only indeed"
		find ../.. -type f -iname "*.so" -exec mv "{}" ${PCSX2PLUGINS}/ \;
		find ../.. -type f -iname "cfg*" -exec mv "{}" ${PCSX2PLUGINS}/ \;
	fi
}

src_install() {

	if use standalone; then
	# fetch the idiot
		cd "${S}/pcsx2"
		make install

	# this ugly stuff do not deserve place in /usr
		local DESTDIR=/opt/pcsx2
		cd "${S}/bin"
		# set permissions
		find . -type d -exec chgrp games "{}" \;
		find . -type d -exec chmod 775 "{}" \;

		find . -type f -exec chgrp games "{}" \;
		find . -type f -exec chmod 664 "{}" \;

		chmod +x plugins/* pcsx2
		# move it
		cd ..
		dodir /opt
		mv -fT bin ${D}${DESTDIR} || die "installation failed"
	else
		cd "${S}/pcsx2"
		local x
		dodoc Docs/*.txt || die "dodoc failed"
		newgamesbin Linux/${PN} ${PN}.bin || die

		sed \
			-e "s:\"GAMES_BINDIR\":${GAMES_BINDIR}:g" \
			-e "s:\"GAMES_DATADIR\":${GAMES_DATADIR}:g" \
			-e "s:\"GAMES_LIBDIR\":`games_get_libdir`:g" \
			-e "s:\"PN\":${PN}:g" \
			"${FILESDIR}/${PN}" > "${D}${GAMES_BINDIR}/${PN}" || die
	fi

}

pkg_postinst() {
	if ! use debug; then
		ewarn "If this package exhibits random crashes, recompile ${PN}"
		ewarn "with the 'debug' use flag enabled. If that fixes it, file a bug."
		echo
	fi
}

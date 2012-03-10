# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/nas/nas-1.9.2.ebuild,v 1.1 2009/07/16 11:41:06 ssuominen Exp $

inherit eutils toolchain-funcs multilib

DESCRIPTION="Network Audio System"
HOMEPAGE="http://radscan.com/nas.html"
SRC_URI="mirror://sourceforge/${PN}/${P}.src.tar.gz"

LICENSE="as-is MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="doc static-libs"

RDEPEND="x11-libs/libX11
	x11-libs/libXau
	x11-libs/libXaw
	x11-libs/libXp
	x11-libs/libXres
	x11-libs/libXt
	x11-libs/libXTrap"
DEPEND="${RDEPEND}
	app-text/rman
	x11-misc/gccmakedep
	x11-misc/imake
	x11-proto/xproto"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch \
		"${FILESDIR}"/${PN}-1.9.2-asneeded.patch \
		"${FILESDIR}"/${PN}-1.9.2-implicit-inet_ntoa-amd64.patch

	if use multilib; then
		cd "${WORKDIR}"
		mkdir 32
		mv -v "${P}" 32/ || die
		unpack ${A}
		cd "${S}"
		epatch \
		"${FILESDIR}"/${PN}-1.9.2-asneeded.patch \
		"${FILESDIR}"/${PN}-1.9.2-implicit-inet_ntoa-amd64.patch
	fi
}

src_compile() {
	xmkmf -a || die "xmkmf failed"
	emake \
		AR="$(tc-getAR) clq" \
		AS="$(tc-getAS)" \
		CC="$(tc-getCC)" \
		CDEBUGFLAGS="${CFLAGS}" \
		CXX="$(tc-getCXX)" \
		CXXDEBUFLAGS="${CXXFLAGS}" \
		EXTRA_LDOPTIONS="${LDFLAGS}" \
		LD="$(tc-getLD)" \
		MAKE="${MAKE:-gmake}" \
		RANLIB="$(tc-getRANLIB)" \
		SHLIBGLOBALSFLAGS="${LDFLAGS}" \
		World || die "emake World failed"

	if use multilib; then
		cd "${WORKDIR}/32/${P}" || die
		multilib_toolchain_setup x86
		xmkmf -a || die "xmkmf failed"
		emake \
		AR="$(tc-getAR) clq" \
		AS="$(tc-getAS)" \
		CC="$(tc-getCC)" \
		CDEBUGFLAGS="${CFLAGS}" \
		CXX="$(tc-getCXX)" \
		CXXDEBUFLAGS="${CXXFLAGS}" \
		EXTRA_LDOPTIONS="${LDFLAGS}" \
		LD="$(tc-getLD)" \
		MAKE="${MAKE:-gmake}" \
		RANLIB="$(tc-getRANLIB)" \
		SHLIBGLOBALSFLAGS="${LDFLAGS}" \
		World || die "emake World failed"
		multilib_toolchain_setup amd64
		cd ${S}
	fi
}

src_install () {
	if use multilib; then
		insinto /usr/lib32
		doins "${WORKDIR}/32/${P}"/lib/audio/libaudio.so.?.?
	fi

	emake DESTDIR="${D}" install install.man || die "emake install failed"
	dodoc BUILDNOTES FAQ HISTORY README RELEASE TODO

	if use doc; then
		docinto doc
		dodoc doc/{actions,protocol.txt,README}
		docinto pdf
		dodoc doc/pdf/*.pdf
	fi


	mv -vf "${D}"/etc/nas/nasd.conf{.eg,} || die

	newconfd "${FILESDIR}"/nas.conf.d nas || die
	newinitd "${FILESDIR}"/nas.init.d nas || die

	use static-libs || rm -f "${D}"/usr/lib*/libaudio.a

	[[ -e ${D}/usr/bin/nasd ]] || \
		die "Missing nasd executable in the destination directory. Exiting." #314631
}

pkg_postinst() {
	elog "To enable NAS on boot you will have to add it to the"
	elog "default profile, issue the following command as root:"
	elog "# rc-update add nas default"
}

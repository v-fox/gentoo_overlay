# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit eutils multilib toolchain-funcs

DESCRIPTION="The OpenGL Extension Wrangler Library"
HOMEPAGE="http://glew.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tgz"

LICENSE="BSD MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="virtual/opengl
	virtual/glu
	x11-libs/libXmu
	x11-libs/libXi
	x11-libs/libXext
	x11-libs/libX11"

src_unpack() {
	unpack ${A}
	cd "${S}"
	edos2unix config/config.guess
	sed -i -e 's:-s\b::g' Makefile || die "sed failed."
}

src_compile(){
	if use amd64 && use multilib; then
		cd "${WORKDIR}"
		mkdir 32bit 64bit
		cp -r "${P}" 32bit/
		cp -r "${P}" 64bit/
		S="${WORKDIR}"
		cd 32bit/${P}
		pwd
		multilib_toolchain_setup x86
		emake LD="$(tc-getCC) ${LDFLAGS}" CC="$(tc-getCC)" \
			POPT="${CFLAGS}" M_ARCH="" AR="$(tc-getAR)" \
			|| die "emake failed."
		multilib_toolchain_setup amd64
		cd "${WORKDIR}/64bit/${P}"
	fi
	emake LD="$(tc-getCC) ${LDFLAGS}" CC="$(tc-getCC)" \
		POPT="${CFLAGS}" M_ARCH="" AR="$(tc-getAR)" \
		|| die "emake failed."
}

src_install() {
	if use amd64 && use multilib; then
		cd "${WORKDIR}/32bit/${P}"
		multilib_toolchain_setup x86
		emake GLEW_DEST="${D}/usr" LIBDIR="${D}/usr/$(get_libdir)" \
			M_ARCH="" install || die "emake install failed."
		multilib_toolchain_setup amd64
		cd "${WORKDIR}/64bit/${P}"
	fi
	emake GLEW_DEST="${D}/usr" LIBDIR="${D}/usr/$(get_libdir)" \
		M_ARCH="" install || die "emake install failed."

	dodoc doc/*.txt README.txt TODO.txt
	dohtml doc/*.{html,css,png,jpg}
}

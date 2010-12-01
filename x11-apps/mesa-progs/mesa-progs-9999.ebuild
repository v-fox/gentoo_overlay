# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

EGIT_REPO_URI="git://anongit.freedesktop.org/mesa/demos"

if [[ ${PV} = 9999* ]]; then
	    GIT_ECLASS="git"
fi

inherit autotools toolchain-funcs ${GIT_ECLASS}

MY_PN="${PN/-progs/-demos}"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Mesa's OpenGL utility and demo programs (glxgears, glxinfo, eglinfo and more)"
HOMEPAGE="http://mesa3d.sourceforge.net/"
if [[ ${PV} == 9999* ]]; then
	SRC_URI=""
else
	SRC_URI="ftp://ftp.freedesktop.org/pub/mesa/demos/${PV}/${MY_P}.tar.bz2"
fi

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS=""
IUSE="all +egl direct3d gallium gles +glsl openvg"

RDEPEND="virtual/opengl
	egl? ( media-libs/mesa[egl] )
	gles? ( media-libs/mesa[egl,gles] )
	direct3d? ( media-libs/mesa[egl,direct3d] )
	openvg? ( || ( media-libs/mesa[egl,openvg]
			media-libs/shivavg ) )"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	if use all; then
		ewarn "Warning ! You are using 'all' use-flag which will override all other flags"
		ewarn "and will install everything from mesa-demos package ! It is highly untested."
		ewarn "Make sure that you know what you are doing."
	fi
}

src_prepare() {
	eautoreconf
}

src_compile() {
	if use all; then
		emake || die "building failed"
	else
		tc-export CC

		emake -C src/xdemos glthreads glsync glxgears{,_pixmap} glxinfo glxswapcontrol  || die

		if use egl || use gles || use direct3d || use openvg; then
			emake -C src/egl/eglut || die
		fi

		if use glsl; then
			emake -C src/util || die
			emake -C src/glsl convolutions multitex vert-or-frag-only || die
			for i in fpglsl vpglsl slang; do
				emake -C "src/$i" || die
			done
		fi

		if use egl; then
			emake -C src/egl/opengl xeglthreads {p,x}eglgears eglgears{_screen,_x11} eglinfo || die
		fi

		if use gles; then
			emake -C src/egl/opengles1 gears{_screen,_x11} es1_info || die
			emake -C src/egl/opengles2 es2gears || die
		fi

		if use direct3d; then
			ewarn "nothing here yet"
		fi

		if use openvg; then
			emake -C src/egl/openvg lion{_screen,_x11} sp{_screen,_x11} text || die
		fi
	fi
}

src_install() {
	if use all; then
		emake DESTDIR="${D}" install || die "installation failed"
	else
		dobin src/xdemos/{glthreads,glsync,glxgears{,_pixmap},glxinfo,glxswapcontrol} || die

		if use glsl; then
			newbin src/fpglsl/fp-tri glsltest_fp-tri || die
			newbin src/vpglsl/vp-tris glsltest_vp-tri || die

			for i in convolutions multitex vert-or-frag-only; do
				newbin src/glsl/"$i" glsltest_"$i" || die
			done

			for i in {cl,so,vs}test; do
				newbin src/slang/"$i" slang_"$i" || die
			done
		fi

		if use egl; then
			dobin src/egl/opengl/{{p,x}eglgears,eglgears{_screen,_x11},eglinfo,xeglthreads} || die
		fi

		if use gles; then
			newbin src/egl/opengles1/es1_info glesinfo || die
			newbin src/egl/opengles1/gears_screen gles1gears_screen || die
			newbin src/egl/opengles1/gears_x11 gles1gears_x11 || die
			newbin src/egl/opengles2/es2gears gles2gears || die
		fi

		if use direct3d; then
			ewarn "nothing here yet"
		fi

		if use openvg; then
			newbin src/egl/openvg/lion_screen openvgtest_lion_screen || die
			newbin src/egl/openvg/lion_x11 openvgtest_lion_x11 || die
			newbin src/egl/openvg/sp_screen openvgtest_sp_screen || die
			newbin src/egl/openvg/sp_x11 openvgtest_sp_x11 || die
			newbin src/egl/openvg/text openvgtest_text || die
		fi
	fi
}

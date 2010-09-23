# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/mesa/mesa-7.0.2.ebuild,v 1.6 2007/11/16 18:16:30 dberkholz Exp $

EAPI="2"

EGIT_REPO_URI="git://anongit.freedesktop.org/mesa/mesa"

inherit autotools multilib flag-o-matic git portability versionator

OPENGL_DIR="xorg-x11"

MY_PN="${PN/m/M}"
MY_P="${MY_PN}-${PV//_}"
MY_SRC_P="${MY_PN}Lib-${PV/_/-}"
MY_PV="$(get_version_component_range 1-2)"
DESCRIPTION="GPU acceleration libraries for OpenGL, OpenVG, Direct3D and much more"
HOMEPAGE="http://mesa3d.sourceforge.net/"
if [[ $PV = *_rc* ]]; then
	SRC_URI="http://www.mesa3d.org/beta/${MY_SRC_P}.tar.gz"
elif [[ $PV = 9999 ]]; then
	SRC_URI=""
else
	SRC_URI="ftp://ftp.freedesktop.org/pub/mesa/${MY_PV}/${MY_SRC_P}.tar.bz2
		mirror://sourceforge/mesa3d/${MY_SRC_P}.tar.bz2"
fi
LICENSE="LGPL-2"
SLOT="0"
KEYWORDS=""
IUSE_VIDEO_CARDS="
	video_cards_fbdev
	video_cards_intel
	video_cards_mach64
	video_cards_mga
	video_cards_none
	video_cards_nouveau
	video_cards_r128
	video_cards_radeon
	video_cards_savage
	video_cards_sis
	video_cards_tdfx
	video_cards_vga
	video_cards_vmware
	video_cards_via"
IUSE="${IUSE_VIDEO_CARDS}
	debug
	doc
	direct3d
	+dri
	+egl
	+gallium
	gles
	+glu
	+glw
	llvm
	+kms
	+opengl
	openvg
	osmesa
	pic
	+motif
	nptl
	selinux
	static
	X
	+xcb
	kernel_FreeBSD"

RDEPEND="app-admin/eselect-opengl
	dev-libs/expat
	sys-libs/talloc
	direct3d? ( app-emulation/wine )
	X? 	( x11-libs/libX11
		  x11-libs/libXext
		  >=x11-libs/libXxf86vm-1.1
		  x11-libs/libXi
		  x11-libs/libXt
		  x11-libs/libXmu
		  x11-libs/libXdamage
		  x11-libs/libdrm
		  x11-libs/libICE )
	xcb? 	( x11-libs/libX11[xcb] )
	llvm? 	( sys-devel/llvm )
	motif? 	( x11-libs/openmotif )
	doc? 	( app-doc/opengl-manpages )"
DEPEND="${RDEPEND}
	!<=x11-proto/xf86driproto-2.0.3
	>=x11-proto/glproto-1.4.11
	>=x11-proto/dri2proto-2.2
	X? ( x11-misc/makedepend
		x11-proto/inputproto
		x11-proto/xextproto
		!hppa? ( x11-proto/xf86driproto )
		>=x11-proto/xf86vidmodeproto-2.3
		>=x11-proto/glproto-1.4.8 )
	dev-util/pkgconfig
	motif? ( x11-proto/printproto )"

S="${WORKDIR}/${MY_P}"

QA_EXECSTACK="usr/lib*/opengl/xorg-x11/lib/libGL.so*"
QA_WX_LOAD="usr/lib*/opengl/xorg-x11/lib/libGL.so*"

# Think about: ggi, svga, fbcon, no-X configs

pkg_setup() {
	if use gles && ! use gallium && ! use xcb; then
		eerror "for use of gles you should enable gallium or xcb"
		die "gles requested without gallium or xcb"
	fi

	if ! use egl; then
		ewarn "egl support is disabled ! egl is really must-have for modern systems"
		ewarn "it will be better to enable it"
		use openvg 	&& die "openvg can't work without egl. failing..."
		use direct3d 	&& die "direct3d can't work without egl. failing..."
	fi

	if use debug; then
		append-flags -g
	fi

	# gcc 4.2 has buggy ivopts
	if [[ $(gcc-version) = "4.2" ]]; then
		append-flags -fno-ivopts
	fi

	# recommended by upstream
	append-flags -ffast-math

	# Filter LDFLAGS that cause symbol lookup problem
	if use gallium; then
		append-ldflags -Wl,-z,lazy
		filter-ldflags -Wl,-z,now
	fi
}

src_prepare() {
	# FreeBSD 6.* doesn't have posix_memalign().
	[[ ${CHOST} == *-freebsd6.* ]] && sed -i -e "s/-DHAVE_POSIX_MEMALIGN//" configure.ac

	# Don't compile debug code with USE=-debug - bug #125004
	if ! use debug; then
	   einfo "Removing DO_DEBUG defs in dri drivers..."
	   find src/mesa/drivers/dri -name *.[hc] -exec egrep -l "\#define\W+DO_DEBUG\W+1" {} \; | xargs sed -i -re "s/\#define\W+DO_DEBUG\W+1/\#define DO_DEBUG 0/" ;
	fi

	eautoreconf

	# remove glew headers. We preffer to use system ones
	rm -f "${S}"/include/GL/{wglew,wglext,glut}.h \
		|| die "Removing glew includes failed."
}

src_configure() {
	local myconf

	myconf+=" $(use_enable debug)"

	# Do we want thread-local storage (TLS)?
	myconf+=" $(use_enable nptl glx-tls)"

	# Configurable DRI drivers
	driver_enable swrast
	driver_enable video_cards_intel i810 i915 i965
	driver_enable video_cards_mach64 mach64
	driver_enable video_cards_mga mga
	driver_enable video_cards_r128 r128
	driver_enable video_cards_radeon radeon r200 r300 r600
	driver_enable video_cards_savage savage
	driver_enable video_cards_sis sis
	driver_enable video_cards_tdfx tdfx
	driver_enable video_cards_via unichrome

	# This is where we might later change to build xlib/osmesa
	local DRIVER="osmesa"
	use X 			&& DRIVER="xlib"
	use dri 		&& DRIVER="dri"

	myconf+=" --with-driver=${DRIVER}"

	if [[ $DRIVER = osmesa ]]; then
		myconf+=" --with-osmesa-bits=32"
	fi

	if [[ $DRIVER != osmesa ]]; then
		# build & use osmesa even with GL
		use osmesa && myconf+=" --enable-gl-osmesa"
	fi

	myconf+=" $(use_enable egl)
		  $(use_enable glu)
		  $(use_enable glw)"
	if use egl; then
		myconf+=" --with-egl-platforms="
		use X 			&& myconf+=",x11"
		use kms 		&& myconf+=",drm"
		use direct3d 		&& myconf+=",gdi"
		use video_cards_fbdev 	&& myconf+=",fbdev"
	fi
	use glw && myconf+=" $(use_enable motif)"

	myconf+=" $(use_with X x)"
	use X && myconf+=" $(use_enable xcb)"

	# support of OpenGL for Embedded Systems
	if use xcb; then
		myconf+=" $(use_enable gles gles1)
			  $(use_enable gles gles2)"
	fi

	# Set drivers to everything on which we ran driver_enable()
	use dri && myconf+=" --with-dri-drivers=${DRI_DRIVERS}"

	# configure gallium support
	if use gallium; then
		# state trackers
		myconf+=" --enable-gallium-swrast --with-state-trackers="
		use opengl 	&& myconf+=",glx"
		use egl 	&& myconf+=",egl"
		use direct3d 	&& myconf+=",d3d1x"
		use dri 	&& myconf+=",dri"
		use openvg 	&& myconf+=",vega"
		use X 		&& myconf+=",xorg"

		# gles for gallium
		use gles 	&& myconf+=" --enable-gles-overlay"

		# drivers
		myconf+=" \
			$(use_enable video_cards_vmware gallium-svga)
			$(use_enable video_cards_intel gallium-i915)
			$(use_enable video_cards_intel gallium-i965)
			$(use_enable video_cards_radeon gallium-radeon)
			$(use_enable video_cards_radeon gallium-r600)
			$(use_enable video_cards_nouveau gallium-nouveau)
			$(use_enable llvm gallium-llvm)"
	else
		myconf+=" --disable-gallium"
	fi

	# Get rid of glut includes
	rm -f "${S}"/include/GL/glut*h
	myconf+=" --disable-glut"

	use selinux && myconf+=" --enable-selinux"
	use static && myconf+=" --enable-static"
	use multilib && myconf+=" --enable-32-bit --enable-64-bit"

	econf ${myconf} || die
}

src_compile() {
	emake -j1 || die
}

src_install() {
	dodir /usr

	emake \
		DESTDIR="${D}" \
		install || die "Installation failed"

	# Don't install private headers
	rm -f "${D}"/usr/include/GL/GLw*P.h || die

	fix_opengl_symlinks
	dynamic_libgl_install

	# Install libtool archives
	insinto /usr/$(get_libdir)
	# (#67729) Needs to be lib, not $(get_libdir)
	doins "${FILESDIR}"/lib/libGLU.la
	sed -e "s:\${libdir}:$(get_libdir):g" "${FILESDIR}"/lib/libGL.la \
		> "${D}"/usr/$(get_libdir)/opengl/xorg-x11/lib/libGL.la

	# On *BSD libcs dlopen() and similar functions are present directly in
	# libc.so and does not require linking to libdl. portability eclass takes
	# care of finding the needed library (if needed) witht the dlopen_lib
	# function.
	sed -i -e 's:-ldl:'$(dlopen_lib)':g' \
		"${D}"/usr/$(get_libdir)/libGLU.la \
		"${D}"/usr/$(get_libdir)/opengl/xorg-x11/lib/libGL.la

	# libGLU doesn't get the plain .so symlink either
	#dosym libGLU.so.1 /usr/$(get_libdir)/libGLU.so

	# Figure out why libGL.so.1.5 is built (directfb), and why it's linked to
	# as the default libGL.so.1
}

pkg_postinst() {
	switch_opengl_implem
}

fix_opengl_symlinks() {
	# Remove invalid symlinks
	local LINK
	for LINK in $(find "${D}"/usr/$(get_libdir) \
		-name libGL\.* -type l); do
		rm -f ${LINK}
	done
	# Create required symlinks
	if [[ ${CHOST} == *-freebsd* ]]; then
		# FreeBSD doesn't use major.minor versioning, so the library is only
		# libGL.so.1 and no libGL.so.1.2 is ever used there, thus only create
		# libGL.so symlink and leave libGL.so.1 being the real thing
		dosym libGL.so.1 /usr/$(get_libdir)/libGL.so
	else
		dosym libGL.so.1.2 /usr/$(get_libdir)/libGL.so
		dosym libGL.so.1.2 /usr/$(get_libdir)/libGL.so.1
	fi
}

dynamic_libgl_install() {
	# next section is to setup the dynamic libGL stuff
	ebegin "Moving libGL and friends for dynamic switching"
		dodir /usr/$(get_libdir)/opengl/${OPENGL_DIR}/{lib,extensions,include}
		local x=""
		for x in "${D}"/usr/$(get_libdir)/libGL.so* \
			"${D}"/usr/$(get_libdir)/libGL.la \
			"${D}"/usr/$(get_libdir)/libGL.a; do
			if [ -f ${x} -o -L ${x} ]; then
				# libGL.a cause problems with tuxracer, etc
				mv -f ${x} "${D}"/usr/$(get_libdir)/opengl/${OPENGL_DIR}/lib
			fi
		done
		# glext.h added for #54984
		for x in "${D}"/usr/include/GL/{gl.h,glx.h,glext.h,glxext.h}; do
			if [ -f ${x} -o -L ${x} ]; then
				mv -f ${x} "${D}"/usr/$(get_libdir)/opengl/${OPENGL_DIR}/include
			fi
		done
	eend 0
}

switch_opengl_implem() {
		# Switch to the xorg implementation.
		# Use new opengl-update that will not reset user selected
		# OpenGL interface ...
		echo
		eselect opengl set --use-old ${OPENGL_DIR}
}

# $1 - VIDEO_CARDS flag
# other args - names of DRI drivers to enable
driver_enable() {
	case $# in
		# for enabling unconditionally
		1)
			DRI_DRIVERS="${DRI_DRIVERS},$1"
			;;
		*)
			if use $1; then
				shift
				for i in $@; do
					DRI_DRIVERS="${DRI_DRIVERS},${i}"
				done
			fi
			;;
	esac
}

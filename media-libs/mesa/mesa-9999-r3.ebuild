# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/mesa/mesa-7.0.2.ebuild,v 1.6 2007/11/16 18:16:30 dberkholz Exp $

EAPI=2

EGIT_REPO_URI="git://anongit.freedesktop.org/mesa/mesa"

if [[ ${PV} = 9999* ]]; then
	GIT_ECLASS="git"
	EXPERIMENTAL="true"
fi

inherit base autotools multilib flag-o-matic toolchain-funcs versionator ${GIT_ECLASS}

OPENGL_DIR="xorg-x11"

MY_PN="${PN/m/M}"
MY_P="${MY_PN}-${PV/_/-}"
MY_SRC_P="${MY_PN}Lib-${PV/_/-}"

FOLDER=$(get_version_component_range 1-3)
[[ ${PV/_rc*/} == ${PV} ]] || FOLDER+="/RC"

DESCRIPTION="OpenGL-like graphic library for Linux"
HOMEPAGE="http://mesa3d.sourceforge.net/"

#SRC_PATCHES="mirror://gentoo/${P}-gentoo-patches-01.tar.bz2"
if [[ $PV = 9999* ]]; then
	SRC_URI="${SRC_PATCHES}"
else
	SRC_URI="ftp://ftp.freedesktop.org/pub/mesa/${FOLDER}/${MY_SRC_P}.tar.bz2
		 mirror://sourceforge/mesa3d/${MY_SRC_P}.tar.bz2
		${SRC_PATCHES}"
fi

DESCRIPTION="GPU acceleration libraries for OpenGL, OpenVG, Direct3D and much more"
LICENSE="LGPL-2"
SLOT="0"
KEYWORDS=""

INTEL_CARDS="i810 i915 i965 intel"
RADEON_CARDS="r100 r200 r300 r600 radeon"
VIDEO_CARDS="${INTEL_CARDS} ${RADEON_CARDS} fbdev mach64 mga nouveau r128 savage sis vmware tdfx via"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done

IUSE="${IUSE_VIDEO_CARDS}
	debug doc direct3d gles llvm openvg osmesa pic motif selinux static X kernel_FreeBSD
	+classic +dri +egl +gallium +glu +drm +nptl +opengl +xcb"

LIBDRM_DEPSTRING=">=x11-libs/libdrm-2.4.21"
# keep correct libdrm and dri2proto dep
# keep blocks in rdepend for binpkg
RDEPEND=">=app-admin/eselect-opengl-1.1.1-r2
	dev-libs/expat
	sys-libs/talloc
	direct3d? ( app-emulation/wine )
	X? 	( !<x11-base/xorg-server-1.7
		  !<=x11-proto/xf86driproto-2.0.3
		  x11-libs/libX11
		  x11-libs/libXext
		  >=x11-libs/libXxf86vm-1.1
		  x11-libs/libXi
		  x11-libs/libXt
		  x11-libs/libXmu
		  x11-libs/libXdamage
		  x11-libs/libdrm
		  x11-libs/libICE )
	xcb? 	( x11-libs/libX11[xcb] )
	llvm? 	( sys-devel/llvm
		  x86? ( dev-libs/udis86 )
		  amd64? ( dev-libs/udis86[pic] ) )
	motif? 	( x11-libs/openmotif )
	doc? 	( dev-libs/libxml2[python]
		  app-doc/opengl-manpages )
	${LIBDRM_DEPSTRING}[video_cards_nouveau?,video_cards_vmware?]"

for card in ${INTEL_CARDS}; do
	RDEPEND="${RDEPEND}
		video_cards_${card}? ( ${LIBDRM_DEPSTRING}[video_cards_intel] )"
done
for card in ${RADEON_CARDS}; do
	RDEPEND="${RDEPEND}
		video_cards_${card}? ( ${LIBDRM_DEPSTRING}[video_cards_radeon] )"
done

DEPEND="${RDEPEND}
	!<=x11-proto/xf86driproto-2.0.3
	x11-misc/makedepend
	>=x11-proto/glproto-1.4.11
	>=x11-proto/dri2proto-2.2
	X? ( x11-proto/inputproto
		x11-proto/xextproto
		!hppa? ( x11-proto/xf86driproto )
		>=x11-proto/xf86vidmodeproto-2.3
		>=x11-proto/glproto-1.4.8 )
	dev-util/pkgconfig
	motif? ( x11-proto/printproto )"

S="${WORKDIR}/${MY_P}"

# It is slow without texrels, if someone wants slow
# mesa without texrels +pic use is worth the shot
QA_EXECSTACK="usr/lib*/opengl/xorg-x11/lib/libGL.so*"
QA_WX_LOAD="usr/lib*/opengl/xorg-x11/lib/libGL.so*"
QA_EXECSTACK="usr/lib*/libOpenVG.so*"
QA_WX_LOAD="usr/lib*/libOpenVG.so*"

MAKEOPTS="${MAKEOPTS/-j?/-j1}"

pkg_setup() {
	if use classic && ! use dri; then
		eerror "classic drivers stack are in need of dri"
		die "classic drivers requsted without dri"
	fi

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

	if use opengl && ! use classic && ! use gallium; then
		eerror "opengl support can be supplied via gallium state tracker or custom code in classic mesa driver"
		eerror "neither of them is selected"
		die "gallium or classic stuff is needed"
	fi

	if ! use gallium  && $(use openvg || use direct3d); then
		eerror "openvg or direct3d state tracker was requested without actual gallium"
		die "gallium missing"
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

src_unpack() {
	[[ $PV = 9999* ]] && git_src_unpack || base_src_unpack
}

src_prepare() {
	# apply patches
	if [[ ${PV} != 9999* && -n ${SRC_PATCHES} ]]; then
		EPATCH_FORCE="yes" \
		EPATCH_SOURCE="${WORKDIR}/patches" \
		EPATCH_SUFFIX="patch" \
		epatch
	fi
	# FreeBSD 6.* doesn't have posix_memalign().
	if [[ ${CHOST} == *-freebsd6.* ]]; then
		sed -i \
			-e "s/-DHAVE_POSIX_MEMALIGN//" \
			configure.ac || die
	fi

	# In order for mesa to complete it's build process we need to use a tool
	# that it compiles. When we cross compile this clearly does not work
	# so we require mesa to be built on the host system first. -solar
	if tc-is-cross-compiler; then
		sed -i -e "s#^GLSL_CL = .*\$#GLSL_CL = glsl_compiler#g" \
			"${S}"/src/mesa/shader/slang/library/Makefile || die
	fi

	[[ $PV = 9999* ]] && git_src_prepare
	base_src_prepare
	eautoreconf

	# remove glew headers. We preffer to use system ones
	rm -f "${S}"/include/GL/{wglew,glut}.h \
		|| die "Removing glew includes failed."
}

src_configure() {
	local myconf

	local DRIVER="osmesa"
	use X 			&& DRIVER="xlib"
	use dri 		&& DRIVER="dri"
	myconf+=" --with-driver=${DRIVER}"

	if [[ $DRIVER = osmesa ]]; then
		myconf+=" --with-osmesa-bits=32"
	fi

	if use classic && use dri; then
		# Configurable DRI drivers
		driver_enable swrast

		# Intel code
		driver_enable video_cards_i810 i810
		driver_enable video_cards_i915 i915
		driver_enable video_cards_i965 i965
		if ! use video_cards_i810 && ! use video_cards_i915 && ! use video_cards_i965; then
			driver_enable video_cards_intel i810 i915 i965
		fi

		# Nouveau code
		driver_enable video_cards_nouveau nouveau

		# ATI code
		driver_enable video_cards_mach64 mach64
		driver_enable video_cards_mga mga
		driver_enable video_cards_r128 r128

		driver_enable video_cards_r100 radeon
		driver_enable video_cards_r200 r200
		driver_enable video_cards_r300 r300
		driver_enable video_cards_r600 r600
		if ! use video_cards_r100 && ! use video_cards_r200 && ! use video_cards_r300 && ! use video_cards_r600; then
			driver_enable video_cards_radeon radeon r200 r300 r600
		fi

		driver_enable video_cards_savage savage
		driver_enable video_cards_sis sis
		driver_enable video_cards_tdfx tdfx
		driver_enable video_cards_via unichrome

		# Set drivers to everything on which we ran driver_enable()
		use dri && myconf+=" --with-dri-drivers=${DRI_DRIVERS}"

		# support of OpenGL for Embedded Systems via classic stuff
		if use xcb; then
			myconf+=" $(use_enable gles gles1)
				  $(use_enable gles gles2)"
		fi

		if [[ $DRIVER != osmesa ]] && use classic; then
			# build & use osmesa even with GL
			use osmesa && myconf+=" --enable-gl-osmesa"
		fi
	else
		use dri && myconf+=" --with-dri-drivers="
	fi

	# configure gallium support
	myconf="${myconf} $(use_enable gallium)"
	if use gallium; then
		elog "You have enabled gallium infrastructure."
		elog "This infrastructure currently support these drivers:"
		elog "    Swrast: Old Software renderer (always enabled)"
		elog "    LLVMpipe: New Software renderer"
		elog "    Intel: works only i915 and i965 somehow"
		elog "    Nouveau: Support for nVidia NV30 and later cards"
		elog "    Radeon: Newest implementation of r{300-500} and r{600-800} drivers"
		elog "    Svga: VMWare Virtual GPU driver"
		# state trackers
		myconf+=" --enable-gallium-swrast --with-state-trackers="
		use opengl 	&& myconf+=",glx"
		use egl 	&& myconf+=",egl"
		use direct3d 	&& myconf+=",d3d1x"
		use dri 	&& myconf+=",dri"
		use openvg 	&& myconf+=",vega"
		use X 		&& myconf+=",xorg"

		# support of OpenGL for Embedded Systems via gallium
		use gles 	&& myconf+=" --enable-gles-overlay"

		# drivers
		myconf+=" $(use_enable llvm gallium-llvm)
			  $(use_enable video_cards_vmware gallium-svga)
			  $(use_enable video_cards_nouveau gallium-nouveau)"
			if use video_cards_i915 || use video_cards_intel; then
				myconf="${myconf} --enable-gallium-i915"
				else
				myconf="${myconf} --disable-gallium-i915"
			fi
			if use video_cards_i965 || use video_cards_intel; then
				myconf="${myconf} --enable-gallium-i965"
				else
				myconf="${myconf} --disable-gallium-i965"
			fi
			if use video_cards_r300 || use video_cards_radeon; then
				myconf="${myconf} --enable-gallium-radeon"
			else
				myconf="${myconf} --disable-gallium-radeon"
			fi
			if use video_cards_r600 || use video_cards_radeon; then
				myconf="${myconf} --enable-gallium-r600"
				else
				myconf="${myconf} --disable-gallium-r600"
			fi
	else
		if use video_cards_nouveau || use video_cards_vmware; then
			elog "SVGA and nouveau drivers are available only via gallium interface."
			elog "Enable gallium useflag if you want to use them."
		fi
	fi

	if use egl; then
		myconf+=" --with-egl-platforms="
		use X 			&& myconf+=",x11"
		use drm 		&& myconf+=",drm"
		use direct3d 		&& myconf+=",gdi"
		use video_cards_fbdev 	&& myconf+=",fbdev"
	fi

	# Get rid of glut includes
	rm -f "${S}"/include/GL/glut*h
	myconf+=" --disable-glut"

	# cheat for x86_64 systems
	use multilib && myconf+=" --enable-32-bit --enable-64-bit"

	econf $(use_with X x) \
	      $(use_enable debug) \
	      $(use_enable selinux) \
	      $(use_enable static) \
	      $(use_enable nptl glx-tls) \
	      $(use_enable xcb) \
	      $(use_enable motif glw) \
	      $(use_enable motif) \
	      $(use_enable !pic asm) \
	      $(use_enable egl) \
	      $(use_enable glu) \
	      ${myconf} || die
}

src_install() {
	base_src_install

	# Save the glsl-compiler for later use
	if ! tc-is-cross-compiler; then
		dobin "${S}"/src/glsl/glsl_compiler || die
	fi
	# Remove redundant headers
	# GLUT thing
	rm -f "${D}"/usr/include/GL/glut*.h || die "Removing glut include failed."
	# Glew includes
	rm -f "${D}"/usr/include/GL/{glew,glxew,wglew}.h \
		|| die "Removing glew includes failed."

	# Move libGL and others from /usr/lib to /usr/lib/opengl/blah/lib
	# because user can eselect desired GL provider.
	ebegin "Moving libGL and friends for dynamic switching"
		dodir /usr/$(get_libdir)/opengl/${OPENGL_DIR}/{lib,extensions,include}
		local x
		for x in "${D}"/usr/$(get_libdir)/libGL.{la,a,so*}; do
			if [ -f ${x} -o -L ${x} ]; then
				mv -f "${x}" "${D}"/usr/$(get_libdir)/opengl/${OPENGL_DIR}/lib \
					|| die "Failed to move ${x}"
			fi
		done
		for x in "${D}"/usr/include/GL/{gl.h,glx.h,glext.h,glxext.h}; do
			if [ -f ${x} -o -L ${x} ]; then
				mv -f "${x}" "${D}"/usr/$(get_libdir)/opengl/${OPENGL_DIR}/include \
					|| die "Failed to move ${x}"
			fi
		done
	eend $?
}

pkg_postinst() {
	# Switch to the xorg implementation.
	echo
	eselect opengl set --use-old ${OPENGL_DIR}
	# Select classic/gallium drivers
	#eselect mesa set --auto
}

# $1 - VIDEO_CARDS flag
# other args - names of DRI drivers to enable
driver_enable() {
	case $# in
		# for enabling unconditionally
		1)
			DRI_DRIVERS+=",$1"
			;;
		*)
			if use $1; then
				shift
				for i in $@; do
					DRI_DRIVERS+=",${i}"
				done
			fi
			;;
	esac
}

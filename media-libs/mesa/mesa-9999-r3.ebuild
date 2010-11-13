# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/mesa/mesa-7.0.2.ebuild,v 1.6 2007/11/16 18:16:30 dberkholz Exp $

EAPI=3

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
	debug ddx doc direct3d gles gles1 gles2 glut llvm openvg osmesa pic motif selinux static X kernel_FreeBSD
	+classic +dri +egl +gallium +glu +drm +nptl +opengl +xcb"

LIBDRM_DEPSTRING=">=x11-libs/libdrm-2.4.22"
# keep correct libdrm and dri2proto dep
# keep blocks in rdepend for binpkg
RDEPEND=">=app-admin/eselect-opengl-1.1.1-r2
	dev-libs/expat
	sys-libs/talloc
	glut? ( !media-libs/freeglut )
	direct3d? ( app-emulation/wine )
	X? 	( !<x11-base/xorg-server-1.7
		  !<=x11-proto/xf86driproto-2.0.3
		  ddx? ( video_cards_r300? ( !x11-drivers/xf86-video-ati )
			video_cards_r600? ( !x11-drivers/xf86-video-ati )
			video_cards_radeon? ( !x11-drivers/xf86-video-ati )
			video_cards_nouveau? ( !x11-drivers/xf86-video-nouveau )
			video_cards_i915? ( !x11-drivers/xf86-video-intel )
			video_cards_i965? ( !x11-drivers/xf86-video-intel )
			video_cards_intel? ( !x11-drivers/xf86-video-intel ) )
		  x11-libs/libX11
		  x11-libs/libXext
		  >=x11-libs/libXxf86vm-1.1
		  x11-libs/libXi
		  x11-libs/libXt
		  x11-libs/libXmu
		  x11-libs/libXdamage
		  x11-libs/libdrm
		  x11-libs/libICE )
	xcb? 	( || ( <=x11-libs/libX11-1.3.99[xcb]
		      >=x11-libs/libX11-1.3.99 ) )
	llvm? 	( sys-devel/llvm
		  x86? ( dev-libs/udis86 )
		  amd64? ( dev-libs/udis86[pic] ) )
	motif? 	( x11-libs/openmotif )
	doc? 	( app-doc/opengl-manpages )
	${LIBDRM_DEPSTRING}[video_cards_nouveau?,video_cards_vmware?]"

for card in ${INTEL_CARDS} ${RADEON_CARDS}; do
	RDEPEND="${RDEPEND}
		video_cards_${card}? ( ${LIBDRM_DEPSTRING}[video_cards_${card}] )"
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
	dev-libs/libxml2[python]
	dev-util/pkgconfig
	motif? ( x11-proto/printproto )"

S="${WORKDIR}/${MY_P}"

# It is slow without texrels, if someone wants slow
# mesa without texrels +pic use is worth the shot
QA_EXECSTACK="usr/lib*/opengl/xorg-x11/lib/libGL.so*
		usr/lib*/libOpenVG.so*
		usr/lib*/libGLESv1*.so*
		usr/lib*/libGLESv2.so*"
QA_WX_LOAD="usr/lib*/opengl/xorg-x11/lib/libGL.so*
		usr/lib*/libOpenVG.so*
		usr/lib*/libGLESv1*.so*
		usr/lib*/libGLESv2.so"

dynamic_libgl_install() {
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

remove_headers() {
	local uheaders="glew glxew wglew"
	use glut || uheaders+=" glut glutf90"

	ebegin "removing unnecessary headers from $1"
	for i in ${uheaders}; do
			einfo "header removal: ${i}.h"
			rm -f "${1}"/include/GL/"${i}".h
			eend $?
	done
	eend
}

pkg_setup() {
	if ! use classic && use osmesa; then
		eerror "osmesa can be only built with classic stack and with or without dri"
		die "osmesa requested without old graphic stack"
	fi

	if use gles && ! use gallium && ! use egl; then
		eerror "for use of gles with gallium you must have egl support"
		die "gles requested with gallium but without egl"
	fi

	if use gles && ! use gles1 && ! use gles2; then
		eerror "gles libraries need gles1 or gles2 API selected"
		die "gles support enabled but no gles API selected"
	fi

	if use ! gles && use gles1 && use gles2; then
		eerror "gles1 or gles2 API selected but gles support is not"
		die "gles API selected but gles support is not enabled"
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

	if use ddx  && $(! use drm || ! use gallium || ! use X); then
		eerror "you have requested gallium state tracker-based ddx replacement for classical X ddx"
		eerror "but failed to enable drm, actual gallium or select X support"
		die "gallium and X needed for use of this ddx"
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
	cd "${S}"

	if use multilib; then
		cd "${WORKDIR}"
		mkdir 32
		mv "${MY_P}" 32/ || die
		cd "${WORKDIR}"
		[[ $PV = 9999* ]] && EGIT_OFFLINE=1 git_src_unpack || base_src_unpack
	fi
}

src_prepare() {
	if use multilib; then
		cd "${WORKDIR}"/32/${MY_P} || die
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
				"${WORKDIR}/32/${MY_P}"/src/mesa/shader/slang/library/Makefile || die
		fi

		[[ $PV = 9999* ]] && git_src_prepare
		base_src_prepare
		eautoreconf

		# remove unnecessary headers. We preffer to use system ones
		remove_headers "${WORKDIR}/32/${MY_P}" || die "Removing glew includes failed."
		cd "${S}"
	fi

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

	# remove unnecessary headers. We preffer to use system ones
	remove_headers "${S}" || die "Removing glew includes failed."
}

src_configure() {
	local myconf="$(use_enable opengl)
		      $(use_enable openvg)"

	# support of OpenGL for Embedded Systems
	if use gles; then
		myconf+="$(use_enable gles1)
			 $(use_enable gles2)"
	fi

	if use classic; then
		local DRIVER="osmesa"
		use X 			&& DRIVER="xlib"
		use dri 		&& DRIVER="dri"
		myconf+=" --with-driver=${DRIVER}"
	fi

	if use classic && use dri; then
		# Configurable DRI drivers
		dri_driver_enable swrast

		# Intel code
		dri_driver_enable video_cards_i810 i810
		dri_driver_enable video_cards_i915 i915
		dri_driver_enable video_cards_i965 i965
		if ! use video_cards_i810 && ! use video_cards_i915 && ! use video_cards_i965; then
			dri_driver_enable video_cards_intel i810 i915 i965
		fi

		# Nouveau code
		dri_driver_enable video_cards_nouveau nouveau

		# ATI code
		dri_driver_enable video_cards_mach64 mach64
		dri_driver_enable video_cards_mga mga
		dri_driver_enable video_cards_r128 r128

		dri_driver_enable video_cards_r100 radeon
		dri_driver_enable video_cards_r200 r200
		dri_driver_enable video_cards_r300 r300
		dri_driver_enable video_cards_r600 r600
		if ! use video_cards_r100 && ! use video_cards_r200 && ! use video_cards_r300 && ! use video_cards_r600; then
			dri_driver_enable video_cards_radeon radeon r200 r300 r600
		fi

		dri_driver_enable video_cards_savage savage
		dri_driver_enable video_cards_sis sis
		dri_driver_enable video_cards_tdfx tdfx
		dri_driver_enable video_cards_via unichrome

		# Set drivers to everything on which we ran driver_enable()
		use dri && myconf+=" --with-dri-drivers=${DRI_DRIVERS}"

		if [[ $DRIVER != osmesa ]] && use classic; then
			# build & use osmesa even with GL
			use osmesa && myconf+=" --enable-gl-osmesa"
		fi
	else
		use dri && myconf+=" --with-dri-drivers="
	fi

	# configure gallium support
	myconf="${myconf} $(use_enable gallium)
		$(use_enable egl gallium-egl)
		$(use_enable gles gles-overlay)"
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
		use ddx 	&& myconf+=",xorg"

		# drivers
		local gallium_i915 gallium_i965 gallium_r300 gallium_r600
		use video_cards_i915 && gallium_i915="1"
		use video_cards_i965 && gallium_i965="1"
		if ! use video_cards_i915 && ! use video_cards_i965 && use video_cards_intel; then
			gallium_i915="1"
			gallium_i965="1"
		fi
		use video_cards_r300 && gallium_radeon="1"
		use video_cards_r600 && gallium_r600="1"
		if ! use video_cards_r300 && ! use video_cards_r600 && use video_cards_radeon; then
			gallium_r300="1"
			gallium_r600="1"
		fi

		myconf+=" $(use_enable llvm gallium-llvm)
			  $(use_enable video_cards_vmware gallium-svga)
			  $(use_enable video_cards_nouveau gallium-nouveau)"
		for i in i915 i965 radeon r600; do
			local current="gallium_$i"
			eval current="\$$current"
			[ ! -z "$current" ] && \
				myconf+=" --enable-gallium-$i" || \
				myconf+=" --disable-gallium-$i"
		done
	else
		if use video_cards_nouveau || use video_cards_vmware; then
			elog "SVGA/wmware, LLVM and nouveau drivers are available only via gallium interface."
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

	if use multilib; then
		multilib_toolchain_setup x86
		cd "${WORKDIR}/32/${MY_P}"
		econf 	--enable-32-bit \
			--disable-64-bit \
			$(use_with X x) \
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
			$(use_enable glut) \
			${myconf} \
			--disable-gallium-llvm || die "doing 32bit stuff failed"
		multilib_toolchain_setup amd64
		myconf+=" --enable-64-bit --disable-32-bit"
		cd "${S}"
	fi

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
	      $(use_enable glut) \
	      ${myconf} || die
}

src_compile() {
	if use multilib; then
		multilib_toolchain_setup x86
		cd "${WORKDIR}/32/${MY_P}"
		emake || die "doing 32bit stuff failed"
		multilib_toolchain_setup amd64
	fi

	cd "${S}"
	emake || die
}

src_install() {
	if use multilib; then
		cd "${WORKDIR}/32/${MY_P}"
		multilib_toolchain_setup x86
		emake \
			DESTDIR="${D}" \
			install || die "Installation of 32bit stuff failed"
		dynamic_libgl_install
		multilib_toolchain_setup amd64
		cd "${S}"
	fi

	base_src_install
	dynamic_libgl_install

	# Save the glsl-compiler for later use
	if ! tc-is-cross-compiler; then
		dobin "${S}"/src/glsl/glsl_compiler || die
	fi
	# Remove redundant headers
	# Glew includes
	rm -f "${D}"/usr/include/GL/{glew,glxew,wglew}.h \
		|| die "Removing glew includes failed."
}

pkg_postinst() {
	# Switch to the xorg implementation.
	eselect opengl set --use-old ${OPENGL_DIR}
}

# $1 - VIDEO_CARDS flag
# other args - names of DRI drivers to enable
dri_driver_enable() {
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

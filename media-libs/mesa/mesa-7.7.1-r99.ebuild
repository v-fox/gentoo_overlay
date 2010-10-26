# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/mesa/mesa-7.0.2.ebuild,v 1.6 2007/11/16 18:16:30 dberkholz Exp $

EGIT_REPO_URI="git://anongit.freedesktop.org/mesa/mesa"

inherit autotools multilib flag-o-matic git portability versionator

OPENGL_DIR="xorg-x11"

MY_PN="${PN/m/M}"
MY_PV="${PV/rc*/devel}"
MY_P="${MY_PN}-${MY_PV/_/-}"
MY_SRC_P="${MY_PN}Lib-${PV/_/-}"
MY_PV="$(get_version_component_range 1-2)"
DESCRIPTION="OpenGL-like graphic library for Linux"
HOMEPAGE="http://mesa3d.sourceforge.net/"
if [[ $PV = *_rc* ]]; then
	SRC_URI="ftp://ftp.freedesktop.org/pub/mesa/${PV/_rc*/}/${MY_SRC_P}.tar.bz2"
elif [[ $PV = 9999 ]]; then
	SRC_URI=""
else
	SRC_URI="ftp://ftp.freedesktop.org/pub/mesa/${MY_PV}/${MY_SRC_P}.tar.bz2
		mirror://sourceforge/mesa3d/${MY_SRC_P}.tar.bz2"
fi
LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE_VIDEO_CARDS="
	video_cards_intel
	video_cards_mach64
	video_cards_mga
	video_cards_none
	video_cards_fbdev
	video_cards_nouveau
	video_cards_r128
	video_cards_radeon
	video_cards_savage
	video_cards_sis
	video_cards_sunffb
	video_cards_svga
	video_cards_tdfx
	video_cards_vga
	video_cards_via"
IUSE="${IUSE_VIDEO_CARDS}
	debug
	demo
	doc
	+dri
	+gallium
	gallium-force
	pic
	motif
	nptl
	selinux
	static
	X
	xcb
	kernel_FreeBSD"

RDEPEND="app-admin/eselect-opengl
	dev-libs/expat
	X? ( x11-libs/libX11
		x11-libs/libXext
		x11-libs/libXxf86vm
		x11-libs/libXi
		x11-libs/libXt
		x11-libs/libXmu
		x11-libs/libXdamage
		x11-libs/libdrm
		x11-libs/libICE )
	!<=x11-base/xorg-x11-6.9
	motif? ( x11-libs/openmotif )"
DEPEND="${RDEPEND}
	!<=x11-proto/xf86driproto-2.0.3
	x11-proto/glproto
	x11-proto/dri2proto
	X? ( x11-misc/makedepend
		x11-proto/inputproto
		x11-proto/xextproto
		!hppa? ( x11-proto/xf86driproto )
		x11-proto/xf86vidmodeproto
		>=x11-proto/glproto-1.4.8 )
	dev-util/pkgconfig
	motif? ( x11-proto/printproto )"

S="${WORKDIR}/${MY_P}"

# Think about: ggi, svga, fbcon, no-X configs

pkg_setup() {
	if use xcb; then
		if ! built_with_use x11-libs/libX11 xcb; then
			msg="You must build libX11 with xcb enabled."
			eerror ${msg}
			die ${msg}
		fi
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
}

src_unpack() {
	if [[ $PV = 9999 ]]; then
		git_src_unpack
	else
		unpack "${A}"
	fi
	cd "${S}"

	if use multilib; then
		multilib_toolchain_setup x86
		cd "${WORKDIR}"
		mkdir 32
		mv "${MY_P}" 32/
		cd "${WORKDIR}"/32/${MY_P} || die
		[[ ${CHOST} == *-freebsd6.* ]] && \
			sed -i -e "s/-DHAVE_POSIX_MEMALIGN//" configure.ac
		if ! use debug; then
			einfo "Removing DO_DEBUG defs in dri drivers..."
			find src/mesa/drivers/dri -name *.[hc] -exec egrep -l "\#define\W+DO_DEBUG\W+1" {} \; | xargs sed -i -re "s/\#define\W+DO_DEBUG\W+1/\#define DO_DEBUG 0/" ;
		fi
		eautoreconf
		cd "${WORKDIR}"
		multilib_toolchain_setup amd64
		if [[ $PV = 9999 ]]; then
			EGIT_OFFLINE=1 git_src_unpack
		else
			unpack "${A}"
		fi
		cd "${S}"
	fi

	# FreeBSD 6.* doesn't have posix_memalign().
	[[ ${CHOST} == *-freebsd6.* ]] && sed -i -e "s/-DHAVE_POSIX_MEMALIGN//" configure.ac

	# Don't compile debug code with USE=-debug - bug #125004
	if ! use debug; then
	   einfo "Removing DO_DEBUG defs in dri drivers..."
	   find src/mesa/drivers/dri -name *.[hc] -exec egrep -l "\#define\W+DO_DEBUG\W+1" {} \; | xargs sed -i -re "s/\#define\W+DO_DEBUG\W+1/\#define DO_DEBUG 0/" ;
	fi

	eautoreconf
}

src_compile() {
	local myconf

	myconf="${myconf} $(use_enable debug)"

	# Do we want thread-local storage (TLS)?
	myconf="${myconf} $(use_enable nptl glx-tls)"

	# Configurable DRI drivers
	driver_enable swrast
	driver_enable video_cards_fbdev ffb
	driver_enable video_cards_intel i810 i915 i965
	driver_enable video_cards_mach64 mach64
	driver_enable video_cards_mga mga
	driver_enable video_cards_r128 r128
	driver_enable video_cards_radeon radeon r200 r300
	driver_enable video_cards_savage savage
	driver_enable video_cards_sis sis
	driver_enable video_cards_sunffb ffb
	driver_enable video_cards_tdfx tdfx
	driver_enable video_cards_via unichrome

	# This is where we might later change to build xlib/osmesa
	local DRIVER="osmesa"
	use X 			&& DRIVER="xlib"
	use dri 		&& DRIVER="dri"

	myconf="${myconf} --with-driver=${DRIVER}"

	use X 	&& myconf="${myconf} --with-x" \
		|| myconf="${myconf} --without-x --disable-glw"

	# Set drivers to everything on which we ran driver_enable()
	myconf="${myconf} --with-dri-drivers=${DRI_DRIVERS}"

	# configure gallium support
	if use gallium; then
		# state trackers
		if use gallium-force; then
			myconf="${myconf} --with-state-trackers=glx,egl"
			use dri 	&& myconf="${myconf},dri"
			use X 		&& myconf="${myconf},xorg"
		fi

		use video_cards_svga && myconf="${myconf} --enable-gallium-svga"
		use video_cards_intel || myconf="${myconf} --disable-gallium-intel"
		use video_cards_radeon && myconf="${myconf} --enable-gallium-radeon"
		use video_cards_nouveau && myconf="${myconf} --enable-gallium-nouveau"
	else
		myconf="${myconf} --disable-gallium"
	fi

	# Sparc assembly code is not working
	if use sparc; then
		myconf="${myconf} --disable-asm"
	fi

	use demo && myconf="${myconf} --with-demos" \
		 || myconf="${myconf} --without-demos"

	# Get rid of glut includes
	rm -f "${S}"/include/GL/glut*h
	myconf="${myconf} --disable-glut"

	use selinux && myconf="${myconf} --enable-selinux"
	use static && myconf="${myconf} --enable-static"

	if use multilib; then
		multilib_toolchain_setup x86
		cd "${WORKDIR}/32/${MY_P}"
		econf $(use_with X x && echo "--with-x-libraries=/usr/$(get_libdir)") \
			--enable-32-bit \
			--disable-64-bit \
			$(use_enable xcb) \
			$(use_enable motif) \
			${myconf} || die "doing 32bit stuff failed"
		emake || die "doing 32bit stuff failed"
		multilib_toolchain_setup amd64
		myconf="${myconf} --enable-64-bit --disable-32-bit"
		cd "${S}"
	fi

	econf \
		$(use_with X x) \
		$(use_enable xcb) \
		$(use_enable motif) \
		${myconf} || die
	emake || die
}

src_install() {
	dodir /usr

	if use multilib; then
		cd "${WORKDIR}/32/${MY_P}"
		multilib_toolchain_setup x86
		emake \
			DESTDIR="${D}" \
			install || die "Installation of 32bit stuff failed"
		fix_opengl_symlinks
		dynamic_libgl_install
		multilib_toolchain_setup amd64
		cd "${S}"
	fi

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

	# We need the outer check, because xorg-server may not be installed
	# first, and built_with_use() dies if the package isn't installed.
	if has_version x11-base/xorg-server; then
		if built_with_use x11-base/xorg-server nptl; then
			ewarn "Rebuild x11-base/xorg-server without USE=nptl"
			ewarn "or AIGLX (compiz, etc.) will not work."
			ewarn "This is because of a bug in the Mesa NPTL assembly code"
			ewarn "in all Mesa 7.0.x versions (Mesa 6.x is OK)."
		fi
	fi
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

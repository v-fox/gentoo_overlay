# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libxcb/libxcb-1.1.ebuild,v 1.3 2007/11/07 08:40:01 dberkholz Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X C-language Bindings library"
HOMEPAGE="http://xcb.freedesktop.org/"
SRC_URI="http://xcb.freedesktop.org/dist/${P}.tar.bz2"
LICENSE="X11"
KEYWORDS="amd64 ~amd64"
IUSE="doc selinux"
RDEPEND="x11-libs/libXau
	x11-libs/libXdmcp
	dev-libs/libpthread-stubs"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	dev-libs/libxslt
	>=x11-proto/xcb-proto-1.2"

CONFIGURE_OPTIONS="$(use_enable doc build-docs)
		$(use_enable selinux xselinux)
		--enable-xinput"

pkg_postinst() {
	x-modular_pkg_postinst

	elog "libxcb-1.1 adds the LIBXCB_ALLOW_SLOPPY_LOCK variable to allow"
	elog "broken applications to keep running instead of being aborted."
	elog "Set this variable if you need to use broken packages such as Java"
	elog "(for example, add LIBXCB_ALLOW_SLOPPY_LOCK=1 to /etc/env.d/00local"
	elog "and run env-update)."
}

x-modular_unpack_source() {
	if [[ -n ${GIT_ECLASS} ]]; then
		git_src_unpack
	else
		if use multilib; then
			cd "${WORKDIR}"
			mkdir 32
			unpack ${A}
			mv "${P}" 32/
		fi
		unpack ${A}
	fi
	cd ${S}

	if [[ -n ${FONT_OPTIONS} ]]; then
		einfo "Detected font directory: ${FONT_DIR}"
	fi
}

x-modular_src_configure() {
	if use multilib; then
		multilib_toolchain_setup x86
		cd "${WORKDIR}/32/${P}"
		x-modular_font_configure
		x-modular_debug_setup
		[[ -n ${CONFIGURE_OPTIONS} ]]
		if [[ -x ${ECONF_SOURCE:-.}/configure ]]; then
			econf --prefix=${XDIR} \
				--datadir=${XDIR}/share \
				${FONT_OPTIONS} \
				${DRIVER_OPTIONS} \
				${CONFIGURE_OPTIONS}
		fi
		multilib_toolchain_setup amd64
		cd "${S}"
	fi

	x-modular_font_configure
	x-modular_debug_setup

# @VARIABLE: CONFIGURE_OPTIONS
# @DESCRIPTION:
# Any options to pass to configure
[[ -n ${CONFIGURE_OPTIONS} ]]

	# If prefix isn't set here, .pc files cause problems
	if [[ -x ${ECONF_SOURCE:-.}/configure ]]; then
		econf --prefix=${XDIR} \
			--datadir=${XDIR}/share \
			${FONT_OPTIONS} \
			${DRIVER_OPTIONS} \
			${CONFIGURE_OPTIONS}
	fi
}

x-modular_src_make() {
	if use multilib; then
		multilib_toolchain_setup x86
		cd "${WORKDIR}/32/${P}"
		emake || die "emake failed"
		multilib_toolchain_setup amd64
		cd "${S}"
	fi
	emake || die "emake failed"
}

x-modular_src_compile() {
	if use multilib; then
		multilib_toolchain_setup x86
		cd "${WORKDIR}/32/${P}"
		x-modular_src_configure
		x-modular_src_make
		multilib_toolchain_setup amd64
		cd "${S}"
	fi

	x-modular_src_configure
	x-modular_src_make
}

x-modular_src_install() {
	if use multilib; then
		cd "${WORKDIR}/32/${P}"
		multilib_toolchain_setup x86
		emake \
			DESTDIR="${D}" \
			install || die "Installation of 32bit stuff failed"
		multilib_toolchain_setup amd64
		cd "${S}"
	fi

	# Install everything to ${XDIR}
	make \
		DESTDIR="${D}" \
		install
# Shouldn't be necessary in XDIR=/usr
# einstall forces datadir, so we need to re-force it
#		datadir=${XDIR}/share \
#		mandir=${XDIR}/share/man \

	if [[ -n ${GIT_ECLASS} ]]; then
		pushd "${EGIT_STORE_DIR}/${EGIT_CLONE_DIR}"
		git log ${GIT_TREE} > "${S}"/ChangeLog
		popd
	fi

	if [[ -e ${S}/ChangeLog ]]; then
		dodoc ${S}/ChangeLog
	fi
# @VARIABLE: DOCS
# @DESCRIPTION:
# Any documentation to install
	[[ -n ${DOCS} ]] && dodoc ${DOCS}

	# Make sure docs get compressed
	prepalldocs

	# Don't install libtool archives for server modules
	if [[ -e ${D}/usr/$(get_libdir)/xorg/modules ]]; then
		find ${D}/usr/$(get_libdir)/xorg/modules -name '*.la' \
			| xargs rm -f
	fi

	if [[ -n "${FONT}" ]]; then
		remove_font_metadata
	fi

	if [[ -n "${DRIVER}" ]]; then
		install_driver_hwdata
	fi
}

x-modular_reconf_source() {
	if [[ "${SNAPSHOT}" = "yes" ]]
	then
		# If possible, generate configure if it doesn't exist
		if [ -f "./configure.ac" ]
		then
			if use multilib; then
				multilib_toolchain_setup x86
				cd "${WORKDIR}/32/${P}"
				eautoreconf
				elibtoolize
				multilib_toolchain_setup amd64
				cd "${S}"
			fi
			eautoreconf
		fi
	fi

	# Joshua Baergen - October 23, 2005
	# Fix shared lib issues on MIPS, FBSD, etc etc
	elibtoolize
}

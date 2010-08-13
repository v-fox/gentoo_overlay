# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libX11/libX11-1.1.4.ebuild,v 1.10 2008/07/03 01:58:04 mr_bones_ Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular toolchain-funcs flag-o-matic

DESCRIPTION="X.Org X11 library"

KEYWORDS=""
IUSE="ipv6 xcb"
RDEPEND=">=x11-libs/xtrans-1.0.1
	x11-libs/libXau
	x11-libs/libXdmcp
	x11-proto/kbproto
	>=x11-proto/xproto-9999
	xcb? ( >=x11-libs/libxcb-9999 )"
DEPEND="${RDEPEND}
	x11-proto/xf86bigfontproto
	x11-proto/bigreqsproto
	x11-proto/inputproto
	x11-proto/xextproto
	x11-proto/xcmiscproto
	>=x11-misc/util-macros-0.99.0_p20051007"

#PATCHES="${FILESDIR}/xlib-*.patch"

CONFIGURE_OPTIONS="$(use_enable ipv6)
	$(use_with xcb)"
# xorg really doesn't like xlocale disabled.
# $(use_enable nls xlocale)

src_unpack() {
	x-modular_specs_check
	x-modular_dri_check

	if use amd64; then
		cd "${WORKDIR}"
		mkdir 32
		git_src_unpack
		cd "${WORKDIR}"
		mv "${P}" 32/ || die
		cd "${WORKDIR}/32/${P}" || die
		x-modular_patch_source
		x-modular_reconf_source
	fi

	git_src_unpack
	cd ${S}
	x-modular_patch_source
	x-modular_reconf_source
}

x-modular_src_configure() {
	if use amd64; then
		multilib_toolchain_setup x86
		cd "${WORKDIR}/32/${P}"
		econf --prefix=${XDIR} \
		--datadir=${XDIR}/share \
		${FONT_OPTIONS} \
		${DRIVER_OPTIONS} \
		${CONFIGURE_OPTIONS}
		multilib_toolchain_setup amd64
		cd "${S}"
	fi

	econf --prefix=${XDIR} \
	--datadir=${XDIR}/share \
	${FONT_OPTIONS} \
	${DRIVER_OPTIONS} \
	${CONFIGURE_OPTIONS}
}

x-modular_src_make() {
	if use amd64; then
		multilib_toolchain_setup x86
		cd "${WORKDIR}/32/${P}"
		emake || die "emake 32bit stuff failed"
		multilib_toolchain_setup amd64
		cd "${S}"
	fi
	emake || die "emake failed"
}

x-modular_src_compile() {
	x-modular_src_configure
	x-modular_src_make
}

x-modular_src_install() {
	if use amd64; then
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
			eautoreconf
		fi
	fi

	# Joshua Baergen - October 23, 2005
	# Fix shared lib issues on MIPS, FBSD, etc etc
	elibtoolize
}

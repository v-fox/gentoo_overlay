# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libX11/libX11-1.1.4.ebuild,v 1.10 2008/07/03 01:58:04 mr_bones_ Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

EAPI="2"
inherit x-modular toolchain-funcs flag-o-matic

DESCRIPTION="X.Org X11 library"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="lint ipv6 nls xcb +threads +local +tcp +unix +secure-rpc"
RDEPEND=">=x11-libs/xtrans-1.0.1
	x11-libs/libXau
	x11-libs/libXdmcp
	x11-proto/kbproto
	>=x11-proto/xproto-7.0.6
	xcb? ( >=x11-libs/libxcb-1.0 )"
DEPEND="${RDEPEND}
	x11-proto/xf86bigfontproto
	x11-proto/bigreqsproto
	x11-proto/inputproto
	x11-proto/xextproto
	x11-proto/xcmiscproto
	>=x11-misc/util-macros-0.99.0_p20051007"

CONFIGURE_OPTIONS="$(use_enable lint lint-library)
		$(use_enable ipv6)
		$(use_enable xcb)
		$(use_enable nls xlocale)
		$(use_enable nls loadable-i18n)
		$(use_enable threads xthreads)
		$(use_enable local local-transport)
		$(use_enable tcp tcp-transport)
		$(use_enable unix unix-transport)
		$(use_enable secure-rpc)"

src_prepare() {
	if use amd64; then
		multilib_toolchain_setup x86
		cd "${WORKDIR}/32/${P}"
		eautoreconf
		elibtoolize
		multilib_toolchain_setup amd64
		cd "${S}"
	fi

	eautoreconf
	elibtoolize
}

src_unpack() {
	x-modular_specs_check
	x-modular_dri_check

	unpack ${A}
	cd ${S}
	x-modular_reconf_source

	if use amd64; then
		cd "${WORKDIR}"
		mkdir 32
		mv "${P}" 32/ || die
		unpack ${A}
		cd ${S}
		x-modular_reconf_source
	fi
}

src_configure() {
	econf --prefix=${XDIR} \
	--datadir=${XDIR}/share \
	${FONT_OPTIONS} \
	${DRIVER_OPTIONS} \
	${CONFIGURE_OPTIONS}

	if use amd64; then
		multilib_toolchain_setup x86
		cd "${WORKDIR}/32/${P}" || die
		econf --prefix=${XDIR} \
		--datadir=${XDIR}/share \
		--libdir="/usr/lib32" \
		${FONT_OPTIONS} \
		${DRIVER_OPTIONS} \
		${CONFIGURE_OPTIONS}
		multilib_toolchain_setup amd64
		cd "${S}"
	fi
}

src_compile() {
	emake || die "emake failed"

	if use amd64; then
		multilib_toolchain_setup x86
		cd "${WORKDIR}/32/${P}"
		emake || die "emake 32bit stuff failed"
		multilib_toolchain_setup amd64
	fi
}

src_install() {
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


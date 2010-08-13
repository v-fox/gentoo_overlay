# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libdrm/libdrm-2.3.0.ebuild,v 1.8 2007/05/20 20:47:52 jer Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit autotools x-modular git

EGIT_REPO_URI="git://anongit.freedesktop.org/git/mesa/drm"
EGIT_BOOTSTRAP="eautoreconf"

DESCRIPTION="X.Org libdrm library"
HOMEPAGE="http://dri.freedesktop.org/"
SRC_URI=""
IUSE_VIDEO_CARDS="video_cards_nouveau video_cards_radeon video_cards_intel video_cards_vmware"
IUSE="${IUSE_VIDEO_CARDS} +kms +udev"

KEYWORDS=""

RDEPEND=""
DEPEND="${RDEPEND}"

CONFIGURE_OPTIONS="$(use_enable kms libkms)
		   $(use_enable udev)
		   $(use_enable video_cards_nouveau nouveau-experimental-api)
		   $(use_enable video_cards_radeon radeon)
		   $(use_enable video_cards_intel intel)
		   $(use_enable video_cards_vmware vmwgfx-experimental-api)"

x-modular_src_make() {
	if use amd64; then
		multilib_toolchain_setup x86
		cd "${WORKDIR}/32/${P}" || die
		LDPATH="/lib32:/usr/lib32:/usr/local/lib32:${LDPATH}" \
		emake || die "emake 32bit stuff failed"
		multilib_toolchain_setup amd64
		cd "${S}"
	fi
	emake || die "emake failed"
}

x-modular_src_compile() {
	if use amd64; then
		multilib_toolchain_setup x86
		cd "${WORKDIR}/32/${P}" || die
		x-modular_src_configure
		x-modular_src_make
		multilib_toolchain_setup amd64
		cd "${S}"
	fi

	x-modular_src_configure
	x-modular_src_make
}

src_unpack () {
	git_src_unpack

	if use amd64; then
		cd "${WORKDIR}"
		mkdir 32
		mv "${P}" 32/ || die
		cd ${WORKDIR}/32/${P} || die
		sed -i 	-e 's:UDEV=$enableval:UDEV=no:' \
			-e 's:HAVE_LIBUDEV=yes:HAVE_LIBUDEV=no:g' configure || die "not hacked"
		EGIT_OFFLINE=1 git_src_unpack
	fi
}

x-modular_src_configure() {
	if use amd64; then
		multilib_toolchain_setup x86
		cd "${WORKDIR}/32/${P}" || die
		x-modular_font_configure
		x-modular_debug_setup
		[[ -n ${CONFIGURE_OPTIONS} ]]
		if [[ -x ${ECONF_SOURCE:-.}/configure ]]; then
			X11_LIBS=/usr/lib32 \
			LDPATH="/lib32:/usr/lib32:/usr/local/lib32:${LDPATH}" \
			econf --prefix=${XDIR} \
			--datadir=${XDIR}/share \
			${FONT_OPTIONS} \
			${DRIVER_OPTIONS} \
			${CONFIGURE_OPTIONS} \
			--with-x-libraries=/usr/lib32
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
			if use amd64; then
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


pkg_preinst() {
	x-modular_pkg_preinst

	if [[ -e ${ROOT}/usr/$(get_libdir)/libdrm.so.1 ]] ; then
		cp -pPR "${ROOT}"/usr/$(get_libdir)/libdrm.so.{1,1.0.0} "${D}"/usr/$(get_libdir)/
	fi
}

pkg_postinst() {
	x-modular_pkg_postinst

	if [[ -e ${ROOT}/usr/$(get_libdir)/libdrm.so.1 ]] ; then
		elog "You must re-compile all packages that are linked against"
		elog "libdrm 1 by using revdep-rebuild from gentoolkit:"
		elog "# revdep-rebuild --library libdrm.so.1"
		elog "After this, you can delete /usr/$(get_libdir)/libdrm.so.1"
		elog "and /usr/$(get_libdir)/libdrm.so.1.0.0 ."
		epause
	fi
}

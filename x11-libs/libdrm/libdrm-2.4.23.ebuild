# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libdrm/libdrm-2.3.0.ebuild,v 1.8 2007/05/20 20:47:52 jer Exp $

# Must be before x-modular eclass is inherited
EAPI="2"
inherit x-modular

EGIT_REPO_URI="git://anongit.freedesktop.org/git/mesa/drm"

DESCRIPTION="X.Org libdrm library"
HOMEPAGE="http://dri.freedesktop.org/"
if [[ ${PV} = 9999* ]]; then
	SRC_URI=""
	KEYWORDS=""
else
	SRC_URI="http://dri.freedesktop.org/${PN}/${P}.tar.bz2"
	KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
fi
VIDEO_CARDS="i915 i965 intel nouveau r300 r600 radeon vmware"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done
IUSE="${IUSE_VIDEO_CARDS} +kms +udev"

RESTRICT="test" # see bug #236845

RDEPEND="dev-libs/libpthread-stubs"
DEPEND="${RDEPEND}"

CONFIGURE_OPTIONS="$(use_enable kms libkms)
		   $(use_enable udev)
		   $(use_enable video_cards_nouveau nouveau-experimental-api)
		   $(use_enable video_cards_vmware vmwgfx-experimental-api)"

if use video_cards_r300 || use video_cards_r600 || use video_cards_radeon; then
	CONFIGURE_OPTIONS+=" --enable-radeon"
else
	CONFIGURE_OPTIONS+=" --disable-radeon"
fi
if use video_cards_i915 || use video_cards_i965 || use video_cards_intel; then
	CONFIGURE_OPTIONS+=" --enable-intel"
else
	CONFIGURE_OPTIONS+=" --disable-intel"
fi

src_unpack() {
	if [[ ${PV} = 9999* ]]; then
		git_src_unpack
	else
		unpack "${A}"
	fi

	if use amd64; then
		cd "${WORKDIR}"
		mkdir 32
		mv "${P}" 32/ || die
		if [[ ${PV} = 9999* ]]; then
			EGIT_OFFLINE=1 git_src_unpack
		else
			unpack "${A}"
		fi
	fi
}

src_prepare() {
	if [[ ${PV} = 9999* ]]; then
		# If possible, generate configure if it doesn't exist
		if [ -f "./configure.ac" ]
		then
			if use amd64; then
				multilib_toolchain_setup x86
				cd "${WORKDIR}/32/${P}"
				eautoreconf
				elibtoolize
				sed -i 	-e 's:UDEV=$enableval:UDEV=no:' \
					-e 's:HAVE_LIBUDEV=yes:HAVE_LIBUDEV=no:g' configure || die "not hacked"
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

src_configure() {
	if use amd64; then
		multilib_toolchain_setup x86
		cd "${WORKDIR}/32/${P}" || die
		if [[ -x ${ECONF_SOURCE:-.}/configure ]]; then
			X11_LIBS=/usr/lib32 \
			LDPATH="/lib32:/usr/lib32:/usr/local/lib32:${LDPATH}" \
			econf --prefix=${XDIR} \
			--datadir=${XDIR}/share \
			${CONFIGURE_OPTIONS}
		fi
		multilib_toolchain_setup amd64
		cd "${S}"
	fi

	# If prefix isn't set here, .pc files cause problems
	if [[ -x ${ECONF_SOURCE:-.}/configure ]]; then
			econf --prefix=${XDIR} \
			--datadir=${XDIR}/share \
			${CONFIGURE_OPTIONS}
	fi
}

src_compile() {
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

pkg_postinst() {
	xorg-2_pkg_postinst

	ewarn "libdrm's ABI may have changed without change in library name"
	ewarn "Please rebuild media-libs/mesa, x11-base/xorg-server and"
	ewarn "your video drivers in x11-drivers/*."
}

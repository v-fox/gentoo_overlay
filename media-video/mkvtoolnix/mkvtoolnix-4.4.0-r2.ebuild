# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/mkvtoolnix/mkvtoolnix-4.4.0.ebuild,v 1.2 2011/01/21 17:51:38 spatz Exp $

EAPI=3

WX_GTK_VER="2.8"

inherit wxwidgets autotools

DESCRIPTION="Tools to create, alter, and inspect Matroska files"
HOMEPAGE="http://www.bunkus.org/videotools/mkvtoolnix"
SRC_URI="http://www.bunkus.org/videotools/mkvtoolnix/sources/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86 ~x86-fbsd"
IUSE="bzip2 debug lzo pch wxwidgets qt"

RDEPEND=">=dev-libs/libebml-1.0.0
	>=media-libs/libmatroska-1.0.0
	dev-libs/boost
	dev-libs/expat
	media-libs/flac
	media-libs/libogg
	media-libs/libvorbis
	sys-apps/file
	sys-libs/zlib
	bzip2? ( app-arch/bzip2 )
	lzo? ( dev-libs/lzo )
	wxwidgets? ( x11-libs/wxGTK:2.8[X] )
	qt? ( x11-libs/qt-gui )"
DEPEND="${RDEPEND}
	qt? ( dev-ruby/rake )"

pkg_setup() {
	if use qt; then
		ewarn "Warning! building qt gui with shipped drake is broken"
		ewarn "so system rake will be used. but it's not supporting"
		ewarn "multiple building jobs"
	fi
}

src_prepare() {
	eautoreconf
}

src_configure() {
	local myconf

	use pch       || myconf="${myconf} --disable-precompiled-headers"
	use wxwidgets && myconf="${myconf} --with-wx-config=${WX_CONFIG}"

	econf \
		$(use_enable lzo) \
		$(use_enable bzip2 bz2) \
		$(use_enable wxwidgets) \
		$(use_enable debug) \
		$(use_enable qt) \
		${myconf} \
		--with-boost-regex=boost_regex \
		--with-boost-filesystem=boost_filesystem \
		--with-boost-system=boost_system
}

src_compile() {
	if ! use qt; then
		einfo "using drake..."
		./drake "${MAKEOPTS}" || die "drake failed"
	else
		einfo "broken qt support selected. using system rake..."
		rake || die "rake failed"
	fi
}

src_install() {
	# Don't run strip while installing stuff, leave to portage the job.
	cd "${S}"
	DESTDIR="${D}" ./drake install || die

	dodoc AUTHORS ChangeLog README TODO || die
	doman doc/man/*.1 || die
}

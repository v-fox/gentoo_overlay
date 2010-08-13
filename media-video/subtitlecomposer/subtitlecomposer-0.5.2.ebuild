# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

KDE_LINGUAS="el es pl sr"
inherit kde4-base

DESCRIPTION="Text-based subtitles editor."
HOMEPAGE="http://sourceforge.net/projects/subcomposer/"
SRC_URI="mirror://sourceforge/subcomposer/${P}.tar.bz2"

SLOT="4"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
IUSE="gstreamer xcb xine"
RESTRICT=""

DEPEND="!kdeprefix? ( !media-video/subtitlecomposer:0 )
		gstreamer? ( media-libs/gstreamer )
        xine? ( media-libs/xine-lib )"
RDEPEND="${DEPEND}"

src_configure() {
	mycmakeargs="${mycmakeargs}
		$(cmake-utils_use_with gstreamer GStreamer)
		$(cmake-utils_use_with xcb XCB)
		$(cmake-utils_use_with xine Xine)
	"
	kde4-base_src_configure
}

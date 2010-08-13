# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ARTS_REQUIRED="never"

inherit kde kde-functions

DESCRIPTION="Text-based subtitles editor."
HOMEPAGE="http://www.sourceforge.net/projects/${PN}"
SRC_URI="mirror://sourceforge/subcomposer/${P}.tar.bz2"

LICENSE="GPL-2"

SLOT="3.5"
KEYWORDS="amd64 x86"
IUSE="gstreamer xine mplayer"
RESTRICT="nomirror"

DEPEND="|| ( kde-base/kate kde-base/kdebase )
        gstreamer? ( media-libs/gstreamer )
        xine? ( media-libs/xine-lib )
        mplayer? ( media-video/mplayer )"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${P}

need-kde 3.5

src_compile() {
	local myconf="$(use_with gstreamer) $(use_with xine) $(use_with mplayer)"

	kde_src_compile
}

src_install() {
	kde_src_install
}

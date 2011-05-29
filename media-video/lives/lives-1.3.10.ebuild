# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/lives/lives-1.0.0.ebuild,v 1.1 2009/09/05 15:22:35 lu_zero Exp $

EAPI="3"

inherit eutils

MY_P="LiVES-${PV}"
DESCRIPTION="LiVES is a Video Editing System"
HOMEPAGE="http://lives.sf.net"
SRC_URI="http://www.xs4all.nl/~salsaman/lives/current/${MY_P}.tar.bz2"
# sf.net only has rpms for this version
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE="jack matroska ogg pulseaudio theora libvisual nls"
#sdl dv

RDEPEND=">=media-video/mplayer-0.90-r2
		>=media-gfx/imagemagick-5.5.6
		>=dev-lang/perl-5.8.0-r12
		>=x11-libs/gtk+-2.18.0
		media-libs/libsdl
		>=media-video/ffmpeg-0.5
		>=virtual/jpeg-6b-r9
		>=media-sound/sox-14.3.0
		virtual/cdrtools
		jack? ( media-sound/jack-audio-connection-kit )
		theora? ( media-libs/libtheora )
		>=dev-lang/python-2.3.4
		matroska? ( media-video/mkvtoolnix
		media-libs/libmatroska )
		ogg? ( media-sound/ogmtools )
		pulseaudio? ( media-sound/pulseaudio )
		>=media-video/mjpegtools-1.8.0
		libvisual? ( media-libs/libvisual )
		sys-libs/libavc1394"
DEPEND="${RDEPEND}"

src_configure() {
	econf \
		$(use_enable libvisual) \
		$(use_enable nls)

	if use !jack; then
		myconf+=" --disable-jack"
	else
		myconf="{myconf}"
	fi

	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS FEATURES GETTING.STARTED README
}

# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: 

inherit kde

DESCRIPTION="Small utility to easily
convert from OGG, MP3, AAC, M4A, FLAC, WMA, RealAudio, Musepack,
Wavpack, WAV and movies to MP3, OGG, M4A, WAV and FLAC."
HOMEPAGE="http://kde-apps.org/content/show.php/audiokonverter?content=12608"
SRC_URI="http://kde-apps.org/CONTENT/content-files/12608-${P}.tar.bz2"
RESTRICT="mirror"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="+tag d3lphin"

RDEPEND="media-video/mplayer
	media-video/ffmpeg
	media-sound/lame
	media-sound/vorbis-tools
	media-libs/faac
	media-libs/faad2
	media-sound/mppdec
	media-sound/wavpack
	tag? ( 	media-libs/id3lib
		media-sound/apetag
		media-sound/id3v2 )"
DEPEND=""

need-kde 3.2

src_compile() {
	einfo "We are script and have nothing to configure"
}

src_install() {
	for i in DESKTOPFILES MIMEFILES SCRIPTS; do
		# getting names of our files for installation...
		eval local $(cat install.sh|grep -m1 ${i})
	done

	if use d3lphin; then
		mkdir -p ${D}${KDEDIR}/share/apps/d3lphin/servicemenus/
		install -m 644 $DESKTOPFILES ${D}${KDEDIR}/share/apps/d3lphin/servicemenus/
	fi
	mkdir -p ${D}${KDEDIR}/share/apps/konqueror/servicemenus/
	mkdir -p ${D}${KDEDIR}/share/mimelnk/audio/
	mkdir -p ${D}${KDEDIR}/bin/
	install -m 644 $DESKTOPFILES ${D}${KDEDIR}/share/apps/konqueror/servicemenus/
	install -m 644 $MIMEFILES ${D}${KDEDIR}/share/mimelnk/audio/
	install -m 755 $SCRIPTS ${D}${KDEDIR}/bin/
}

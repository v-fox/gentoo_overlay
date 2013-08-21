# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="5"

NEED_KDE="4.1"
KDE_LINGUAS="af ar bg br bs ca cs cy da de el en_GB es et eu fa fi fr ga gl he hi hu is it ja ka lt mk ms nb nds nl nn pa pl pt pt_BR ru rw se sk sr sr@Latn sv ta tr uk uz zh_CN zh_TW"
inherit kde4-base eutils subversion cmake-utils

DESCRIPTION="K3b, KDE CD Writing Software"
HOMEPAGE="http://www.k3b.org/"
SRC_URI=""
ESVN_REPO_URI="svn://anonsvn.kde.org/home/kde/trunk/extragear/multimedia/k3b"
ESVN_PROJECT="multimedia/k3b"

LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86 ~x86-fbsd"
IUSE="encode ffmpeg flac mp3 musepack musicbrainz sndfile vorbis"

DEPEND="sys-apps/hal
	media-libs/libsamplerate
	media-libs/taglib
	>=media-sound/cdparanoia-3.9.8
	sndfile? ( media-libs/libsndfile )
	ffmpeg? ( >=media-video/ffmpeg-0.4.9_p20080326 )
	flac? ( media-libs/flac )
	mp3? ( media-libs/libmad )
	musepack? ( media-libs/libmpcdec )
	vorbis? ( media-libs/libvorbis )
	musicbrainz? ( =media-libs/musicbrainz-2* )
	encode? ( media-sound/lame )
	media-libs/libdvdread"

RDEPEND="${DEPEND}
	virtual/cdrtools
	>=app-cdr/cdrdao-1.1.7-r3
	media-sound/normalize
	>=app-cdr/dvd+rw-tools-7.0
	media-libs/libdvdcss
	encode? ( media-sound/sox
		  media-video/transcode )"

DEPEND="${DEPEND}
	dev-util/pkgconfig"

S="${WORKDIR}/${PN}"

pkg_setup() {
	if use flac && ! built_with_use --missing true media-libs/flac cxx; then
		ewarn "To build ${PN} with flac++ support you need the C++ bindings for flac."
		ewarn "Please enable the cxx USE flag for media-libs/flac"
	fi
}

src_configure() {
	local mycmakeargs

	mycmakeargs="${mycmakeargs}
		-DCMAKE_INSTALL_PREFIX=${PREFIX}
		$(cmake-utils_use_with ffmpeg FFmpeg)
		$(cmake-utils_use_with flac Flac)
		$(built_with_use --missing true media-libs/flac cxx && \
			$(cmake-utils_use_with flac Flac++))
		$(cmake-utils_use_with encode Lame)
		$(cmake-utils_use_with mp3 Mad)
		$(cmake-utils_use_with musepack Muse)
		$(cmake-utils_use_with musicbrainz MusicBrainz)
		$(cmake-utils_use_with vorbis OggVorbis)
		$(cmake-utils_use_with sndfile Sndfile)
		-DWITH_Samplerate=ON"
	kde4-base_src_configure
}

src_unpack() {
		subversion_src_unpack
}


src_install() {
	cmake-utils_src_install
}

pkg_postinst() {
	echo
	elog "We don't install k3bsetup anymore because Gentoo doesn't need it."
	elog "If you get warnings on start-up, uncheck the \"Check system"
	elog "configuration\" option in the \"Misc\" settings window."
	echo

	local group=cdrom
	use kernel_linux || group=operator
	elog "Make sure you have proper read/write permissions on the cdrom device(s)."
	elog "Usually, it is sufficient to be in the ${group} group."
	echo
}

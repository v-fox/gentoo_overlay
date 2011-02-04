# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/clementine/clementine-0.4.2.ebuild,v 1.2 2010/08/20 11:14:13 ssuominen Exp $

EAPI=3

LANGS=" ar bg ca cs da de el en_CA en_GB es fi fr gl hu it kk lt nb nl oc pl pt_BR pt ro ru sk sl sr sv tr uk zh_CN zh_TW"

inherit cmake-utils gnome2-utils flag-o-matic

MY_PV="${PV/_rc?/}"
DESCRIPTION="A modern music player and library organizer based on Amarok 1.4 and Qt4"
HOMEPAGE="http://code.google.com/p/clementine-player/"
SRC_URI="http://clementine-player.googlecode.com/files/${PN}-${MY_PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+gstreamer gnome iphone ipod mtp projectm xine vlc wiimote system-qxt"
IUSE+="${LANGS// / linguas_}"

COMMON_DEPEND="
	x11-libs/qt-gui:4[dbus]
	x11-libs/qt-opengl:4
	x11-libs/qt-sql:4[sqlite]
	dev-db/sqlite[fts3]
	>=media-libs/taglib-1.6
	media-libs/liblastfm
	>=dev-libs/glib-2.24.1-r1:2
	dev-libs/libxml2
	ipod? (
		>=media-libs/libgpod-0.7.92
		iphone? (
			app-pda/libplist
			>=app-pda/libimobiledevice-1.0
			app-pda/usbmuxd
		)
	 )
	gstreamer? ( >=media-libs/gstreamer-0.10
		  >=media-libs/gst-plugins-base-0.10 )
	mtp? ( media-libs/libmtp )
	projectm? ( media-libs/glew )
	xine? ( media-libs/xine-lib )
	vlc? ( media-video/vlc )
	system-qxt? ( x11-libs/libqxt )"
RDEPEND="${COMMON_DEPEND}
	gstreamer? ( >=media-plugins/gst-plugins-meta-0.10
		>=media-plugins/gst-plugins-gio-0.10
		>=media-plugins/gst-plugins-soup-0.10 )
	projectm? ( >=media-libs/libprojectm-1.2.0 )
	mtp? ( gnome-base/gvfs )"
DEPEND="${COMMON_DEPEND}
	>=dev-libs/boost-1.39
	dev-util/pkgconfig
	sys-devel/gettext
	x11-libs/qt-test:4"
S="${WORKDIR}/${PN}-${MY_PV}"

DOCS="Changelog TODO"

MAKEOPTS="${MAKEOPTS} -j1"

src_prepare() {
	echo "" > pig.txt

	if ! use xine && ! use gstreamer; then
		eerror "both xine and gstreamer output is disabled"
		die "either 'xine' or 'gstreamer' flag must be set"
	fi
}

src_configure() {
	# linguas
	local langs x
	for x in ${LANGS}; do
		use linguas_${x} && langs+=" ${x}"
	done

	# Upstream supports only gstreamer engine, other engines are unstable and lacking features.
	mycmakeargs=(
		$(cmake-utils_use gstreamer ENGINE_GSTREAMER_ENABLED)
		$(cmake-utils_use gstreamer ENABLE_GIO)
		$(cmake-utils_use gnome ENABLE_SOUNDMENU)
		$(cmake-utils_use vlc ENGINE_LIBVLC_ENABLED)
		$(cmake-utils_use xine ENGINE_LIBXINE_ENABLED)
		-DLINGUAS="${langs}"
		$(cmake-utils_use ipod ENABLE_LIBGPOD)
		$(cmake-utils_use iphone ENABLE_IMOBILEDEVICE)
		$(cmake-utils_use mtp ENABLE_LIBMTP)
		$(cmake-utils_use wiimote ENABLE_WIIMOTEDEV)
		$(cmake-utils_use projectm ENABLE_VISUALISATIONS)
		$(cmake-utils_use system-qxt USE_SYSTEM_QXT)
		"-DSTATIC_SQLITE=OFF"
		"-DENGINE_QT_PHONON_ENABLED=OFF"
		"-DBUNDLE_PROJECTM_PRESETS=OFF"
		)

	cmake-utils_src_configure
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}

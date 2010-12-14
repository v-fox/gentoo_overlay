# Distributed under the terms of the GNU General Public License v2

EAPI=2
inherit eutils games

DESCRIPTION="Steel Storm Episode I"
HOMEPAGE="http://www.steel-storm.com/"
RESTRICT="mirror"
SRC_URI="http://download2.steel-storm.com/${PN}-ep1-v${PV}.tar.gz"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="alsa +client dedicated +sdl"

CDEPEND="sys-libs/zlib
	>=media-libs/libsdl-1.2
	>=media-libs/freetype-2.3.11
	>=media-libs/libogg-1.1.4
	>=media-libs/libvorbis-1.2.3
	>=net-misc/curl-7.19.7
	>=media-libs/libmodplug-0.8.7
	media-libs/libpng
	virtual/jpeg
	virtual/opengl"
RDEPEND="${CDEPEND}
	=games-arcade/steelstorm-data-${PV}"
DEPEND="${CDEPEND}
	app-arch/unzip"
S="${WORKDIR}/${PN}/engine_source"

src_setup() {
	if ! use client && ! use dedicated; then
		eerror "client, server or both must be enabled"
		die "client and dedicated server both has been disabled"
	fi

	if ! use client && use sdl; then
		eerror "sdl client build needs 'sdl' flag"
		die "sdl support selected but client is not enabled"
	fi
}

src_unpack() {
	unpack ${PN}-ep1-v${PV}.tar.gz
	cd "${WORKDIR}/${PN}" || die
	unzip engine_source.zip || die
}

src_prepare() {
	sed -i \
		-e "/^CC=/d" \
		-e "s:-O2:${CFLAGS}:" \
		-e "s:-O3:${CFLAGS}:" \
		-e "/-lm/s:$: ${LDFLAGS}:" \
		-e '/^STRIP/s/strip/true/' \
		-e "s/darkplaces-dedicated/${PN}-dedicated/" \
		-e "s/darkplaces-sdl/${PN}/" \
		-e "s/darkplaces-glx/${PN}-glx/" \
		-e "s:/usr/X11R6/:/usr/:g" \
			makefile.inc || die "sed failed"

	sed -i \
		-e '1i DP_LINK_TO_LIBJPEG=1' \
		-e "s:ifdef DP_FS_.*:DP_FS_BASEDIR=${GAMES_DATADIR}/${PN}\n&:" \
		-e "s:/usr/X11R6/:/usr/:g" \
			makefile || die "sed failed"

	if ! use alsa ; then
		sed -i \
			-e "/DEFAULT_SNDAPI/s:ALSA:OSS:" \
			makefile || die "sed failed"
	fi

	# proper DGA header
	sed -i \
		-e 's/xf86dga.h/Xxf86dga.h/' \
			vid_glx.c || die "s/xf86dga.h/Xxf86dga.h/ failed"
}

src_compile() {
	use client && \
		$(emake cl-release || die "emake sdl-release failed")

	use sdl && \
		$(emake sdl-release || die "emake sdl-release failed")

	use dedicated && \
		$(emake sv-release || die "emake sv-release failed")
}

src_install() {
	dodoc ../{README.txt,changelog.txt}

	if use client; then
		dogamesbin ${PN}-glx || die "dogamesbin ${PN}-glx failed"
		use sdl && \
			$(dogamesbin ${PN} || die "dogamesbin ${PN} failed")

		newicon ../icons/steelstorm_icon_128x128.png "${PN}.png"
		insinto "${GAMES_DATADIR}/${PN}/gamedata"
		doins ../"key_0.d0pk" || die

		use sdl && \
			make_desktop_entry "${PN}" "SteelStorm Ep1: Dark places [SDL]" "${PN}" || \
			make_desktop_entry "${PN}-glx" "SteelStorm Ep1: Dark places [GLX]" "${PN}"
	fi

	use dedicated && \
		$(dogamesbin ${PN}-dedicated || die "dogamesbin ${PN}-dedicated failed")
}

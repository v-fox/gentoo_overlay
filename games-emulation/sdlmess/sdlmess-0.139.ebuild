# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils flag-o-matic games

DESCRIPTION="Multi Emulator Super System"
HOMEPAGE="http://rbelmont.mameworld.info/?page_id=163 http://www.mess.org"

MY_PV="${PV/.}"
MY_PV="${MY_PV/_p/u}"
MY_P="${PN/sdl/}${MY_PV}"

# Upstream doesn't allow fetching with unknown User-Agent such as wget
SRC_URI="http://mamedev.org/downloader.php?&file=mame${MY_PV}s.zip -> mame${MY_PV}s.zip
	http://www.mess.org/files/${MY_P}s.zip
	http://mess.redump.net/_media/downloads:${MY_P}s.zip -> ${MY_P}s.zip"

# Same as xmame. Should it be renamed to MAME?
LICENSE="XMAME"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="debug opengl"

RESTRICT="fetch"

RDEPEND=">=media-libs/libsdl-1.2.10[opengl?]
	sys-libs/zlib
	dev-libs/expat
	x11-libs/libXinerama
	>gnome-base/gconf-2
	>=x11-libs/gtk+-2"

DEPEND="${RDEPEND}
	app-arch/unzip
	x11-proto/xineramaproto"

S="${WORKDIR}"

pkg_nofetch() {
	einfo "Please download ${MY_P}.zip"
	einfo "from ${HOMEPAGE}"
	einfo "and move it to ${DISTDIR}"
}

# Function to disable a makefile option
disable_feature() {
	sed -i \
		-e "/$1.*=/s:^:# :" \
		"${S}"/makefile \
		|| die "sed failed"
}

# Function to enable a makefile option
enable_feature() {
	sed -i \
		-e "/^#.*$1.*=/s:^# ::"  \
		"${S}"/makefile \
		|| die "sed failed"
}

src_prepare() {
	sed -i \
		-e '/CFLAGS += -O$(OPTIMIZE)/s:^:# :' \
		-e '/CFLAGS += -pipe/s:^:# :' \
		-e '/LDFLAGS += -s/s:^:# :' \
		-e 's:-Werror::' \
		-e '/SUFFIX64/s: 64::g' \
		-e '/SUFFIXDEBUG/s: d::g' \
		-e '/SUFFIXPROFILE/s: p::g' \
		-e '/FULLNAME/s:$(PREFIX)$(PREFIXSDL)$(NAME)$(SUFFIX)$(SUFFIX64)$(SUFFIXDEBUG)$(SUFFIXPROFILE):$(PREFIX)$(PREFIXSDL)$(NAME):' \
		"${S}"/makefile \
		|| die "sed failed"

	# CFLAGS and build debugging help
	#sed -i \
	#	-e "/^\(AR\|CC\|LD\|RM\) =/s:@::" \
	#	-i "${S}"/makefile

	# Don't compile zlib and expat
	einfo "Disabling embedded libraries: zlib and expat"
	disable_feature BUILD_ZLIB
	disable_feature BUILD_EXPAT

	if use amd64; then
		einfo "Enabling 64-bit support"
		enable_feature PTR64
	fi

	if use ppc; then
		einfo "Enabling PPC support"
		enable_feature BIGENDIAN
	fi

	if use debug ; then
		ewarn "Building with DEBUG support is not recommended for normal use"
		enable_feature DEBUG
		enable_feature PROFILE
		enable_feature SYMBOLS
		enable_feature DEBUGGER
	fi

}

src_unpack() {
	unpack mame${MY_PV}s.zip
	unzip mame.zip && rm -v mame.zip || die
	unpack ${MY_P}s.zip
}

src_compile() {
	local make_opts
	use opengl || make_opts="${make_opts} NO_OPENGL=1"

	emake \
		NAME="${PN}" \
		OPT_FLAGS='-DINI_PATH=\"\$$HOME/.sdlmess\;'"${GAMES_SYSCONFDIR}/${PN}"'\"'" ${CFLAGS}" \
		SUFFIX="" \
		${make_opts} \
		-f makefile \
		|| die "emake failed"
}

src_install() {
	dogamesbin "${PN}"* || die "dogamesbin ${PN} failed"

	insinto "${GAMES_DATADIR}/${PN}"
	doins sysinfo.dat || die "doins sysinfo.dat failed"

	insinto "${GAMES_SYSCONFDIR}/${PN}"
	doins "${FILESDIR}"/joymap.dat || die "doins joymap.dat vector.ini failed"


	for i in mess vector; do
		einfo "installing specially crafted global ${i}"
		sed \
			-e "s:@GAMES_SYSCONFDIR@:${GAMES_SYSCONFDIR}:" \
			-e "s:@GAMES_DATADIR@:${GAMES_DATADIR}:" \
			-e "s:@PN@:${PN}:" \
			-e "s:@VIDEO@:$(use opengl && echo 'opengl' || echo 'soft'):" \
			-e "s:@GLSL@:$(use opengl && echo '1' || echo '0'):" \
			"${FILESDIR}/${i}".ini.in > "${D}/${GAMES_SYSCONFDIR}/${PN}/${i}".ini \
				|| die "sed failed"
	done

	dodoc docs/{config,mame,newvideo}.txt *.txt

	keepdir "${GAMES_DATADIR}/${PN}"/{roms,samples,artwork}
	keepdir "${GAMES_SYSCONFDIR}/${PN}"/ctrlr

	prepgamesdirs
}

pkg_postinst() {
	games_pkg_postinst

	elog "It's strongly recommended that you change either the system-wide"
	elog "mess.ini at \"${GAMES_SYSCONFDIR}/${PN}\" or use a per-user setup at \$HOME/.${PN}"

	if use opengl; then
		elog ""
		elog "You built ${PN} with opengl support and should set"
		elog "\"video\" to \"opengl\" in mess.ini to take advantage of that"
	fi
}

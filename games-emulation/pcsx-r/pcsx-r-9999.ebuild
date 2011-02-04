# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI=3

inherit eutils games autotools subversion

DESCRIPTION="GNU/Linux fork of the discontinued PlayStation emulator PCSX"
HOMEPAGE="http://pcsxr.codeplex.com"
SRC_URI=""
ESVN_REPO_URI="https://pcsxr.svn.codeplex.com/svn/pcsxr"
ESVN_PROJECT="pcsxr"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="alsa opengl"

DEPEND="x11-libs/gtk+:2
	x11-proto/videoproto
	gnome-base/libglade
	dev-lang/nasm
	alsa? ( media-libs/alsa-lib )
	virtual/libintl
	opengl? ( virtual/opengl
		  x11-libs/libXxf86vm )"
RDEPEND="${DEPEND}
	!games-emulation/pcsx
	!games-emulation/pcsx-df
	sys-devel/gettext"
RESTRICT=""

src_prepare() {
	cd "${S}"
	eautoheader
	eautoreconf

	# set up our paths
	einfo "setting up our loading path for plug-ins"
	sed -i -e "s:/usr/lib/games/psemu/:$(games_get_libdir)/psemu/:g" gui/LnxMain.c
	for i in $(grep -iRl '${libdir}/games/psemu' *);do
		einfo "fixing paths in ${i}"
		sed -i -e "s:\${libdir}/games/psemu:$(games_get_libdir)/psemu/:g" "${i}"
	done
}

src_configure() {
	egamesconf --datadir="${GAMES_DATADIR}" \
		$(use_enable alsa) \
		$(use_enable opengl opengl) \
		|| die
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	# who would think that it would be nice and easy ?
	emake DESTDIR="${D}" install || die "emake install failed"

	# put our shit together
	local libdir=$(games_get_libdir)
	einfo "relocating libs from redundant dir enclosure"
	mv "${D}${libdir}"/games/psemu "${D}${libdir}"/
	einfo "relocating share stuff to global DATADIR"
	mv "${D}${GAMES_DATADIR}"/locale "${D}${GAMES_DATADIR_BASE}"
	mv "${D}${GAMES_DATADIR}"/{applications,pixmaps} \
		-t "${D}${GAMES_DATADIR_BASE}" || die

	dodoc README doc/keys.txt doc/tweaks.txt ChangeLog
	prepgamesdirs
}

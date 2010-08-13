# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI=2

inherit eutils games autotools

MY_PN="${PN/-/}"
DESCRIPTION="GNU/Linux fork of the discontinued PlayStation emulator PCSX"
HOMEPAGE="http://pcsxr.codeplex.com"
# still damn codeplex and MS with their "opensource effort"
SRC_URI="http://download.codeplex.com/Project/Download/FileDownload.aspx?ProjectName=pcsxr&DownloadId=98581&FileTime=129064504645100000&Build=16135 -> pcsxr-1.9.91.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc"
IUSE="alsa opengl nls"

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
S="${WORKDIR}/${MY_PN}-${PV}"

src_prepare() {
	# set up our paths
	einfo "setting up our loading path for plug-ins"
	for i in $(grep -iRl '${libdir}/games/psemu' *);do
		einfo "fixing paths in ${i}"
		sed -i -e "s:\${libdir}/games/psemu:$(games_get_libdir)/psemu/:g" "${i}"
	done
	sed -i -e "s:\${datadir}/pixmaps/:/usr/share/pixmaps/:g" gui/Makefile.am
	
	eautoheader
	eautoreconf
}

src_configure() {
	egamesconf \
		$(use_enable alsa) \
		$(use_enable opengl) \
		$(use_enable nls) \
		|| die
}

src_install() {
	# who would think that it would be nice and easy ?
	emake DESTDIR="${D}" install || die "emake install failed"

	# put our shit together
	local libdir=$(games_get_libdir)

	einfo "relocating libs from redundant dir enclosure"
	mv "${D}${libdir}"/games/psemu "${D}${libdir}"/

	einfo "relocating share stuff to global DATADIR"
	use nls && \
		mv "${D}${GAMES_DATADIR}"/locale "${D}${GAMES_DATADIR_BASE}"
	mv "${D}${GAMES_DATADIR}"/{applications,pixmaps} \
		-t "${D}${GAMES_DATADIR_BASE}" || die

	dodoc README doc/keys.txt doc/tweaks.txt ChangeLog
	prepgamesdirs
}

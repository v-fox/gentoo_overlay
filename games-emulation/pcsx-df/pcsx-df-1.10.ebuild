# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils games

DESCRIPTION="GNU/Linux fork of the discontinued PlayStation emulator PCSX"
HOMEPAGE="http://pcsx-df.sourceforge.net/"
SRC_URI="http://downloads.sourceforge.net/pcsx-df/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc"
IUSE="alsa nls bin_image opengl gnome"

DEPEND="x11-libs/gtk+
	x11-proto/videoproto
	gnome-base/libglade
	dev-lang/nasm
	alsa? ( media-libs/alsa-lib )
	nls? ( virtual/libintl )
	bin_image? ( media-libs/portaudio
		     <x11-libs/fltk-2 )
	opengl? ( virtual/opengl
		  x11-libs/libXxf86vm )
	gnome? ( gnome-extra/nautilus-cd-burner )"
RDEPEND="${DEPEND}
	!games-emulation/pcsx
	nls? ( sys-devel/gettext )"

RESTRICT="mirror"

src_unpack() {
	unpack ${A}
	cd "${S}"

	sed -i \
		-e "s:/lib/games/psemu/:/lib/psemu/plugins/:" \
		-e 's:^icondir = .*:icondir = "/usr/share/pixmaps":' \
		-e 's:-DPIXMAPDIR=\\"${datadir}/pixmaps/\\":-DPIXMAPDIR=\\"/usr/share/pixmaps/\\":' \
		-e 's:-DLOCALE_DIR=\\"${datadir}/locale/\\":-DLOCALE_DIR=\\"/usr/share/locale/\\":' \
		-e "s:^localedir = .*:localedir = /usr/share/locale/:" \
		-e "s:^gnulocaledir = .*:gnulocaledir = /usr/share/locale/:" \
		-e 's:^desktopdir = .*:desktopdir = /usr/share/applications:' \
		$(find . -name "*.in") \
		|| die "sed failed"

	#set some gentoo specific stuff so we'll see other psemu plugins
	sed -i \
		-e "s:/usr/lib/games/psemu/:$(games_get_libdir)/psemu/plugins:" \
		-e "s:/usr/local/lib/games/psemu/:$(games_get_libdir)/psemu/cfg:" \
		-e "s:filename, \".*\\.so$\":filename, \"lib.*\":" \
		gui/Gtk2Gui.c \
		|| die "sed failed"
	sed -i \
		-e "s:/usr/games/lib\(/psemu/plugins\):$(games_get_libdir)\1:" \
		-e "s:/usr/games/lib\(/psemu/pluginsconfig/\):$(games_get_libdir)\1:" \
		gui/LnxMain.c \
		|| die "sed failed"
}

src_compile() {
	egamesconf --enable-shared=yes --enable-static=no \
		$(use_enable alsa) \
		$(use_enable bin_image dfbinimage) \
		$(use_enable nls) \
		$(use_enable gnome nautilusburn ) || die
	emake || die "emake failed"

	if use opengl ; then
		emake -C plugins/dfOpenGL || die "emake failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc README doc/keys.txt doc/tweaks.txt ChangeLog
	prepgamesdirs
}

pkg_postinst() {
	games_pkg_postinst
	elog "There may be some problems configuring plugins "
	elog "when you run pcsx for the first time."
	elog "So just close it and launch again."
}

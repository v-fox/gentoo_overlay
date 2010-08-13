# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="1"

inherit eutils flag-o-matic multilib versionator

DESCRIPTION="free implementation of Windows(tm) on Unix"
HOMEPAGE="http://www.winehq.org/"
SRC_URI="http://ibiblio.org/pub/linux/system/emulators/${PN}/${P}.tar.bz2
	mirror://sourceforge/${PN}/${P}.tar.bz2
	gecko? ( mirror://sourceforge/wine/wine_gecko-0.1.0.cab )"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86 ~x86-fbsd"
IUSE="alsa capi cups dbus esd +gecko glu gphoto hal jack jpeg lcms ldap nas ncurses opengl openssl oss png samba scanner truetype xml X +win16 win64"
RESTRICT="test" #72375

RDEPEND="media-fonts/corefonts
	media-libs/fontconfig
	truetype? 	( >=media-libs/freetype-2.0.0 )
	ncurses? 	( >=sys-libs/ncurses-5.2 )
	jack? 		( media-sound/jack-audio-connection-kit )
	dbus? 		( sys-apps/dbus )
	hal? 		( sys-apps/hal )
	X? 	(
			x11-libs/libSM
			x11-libs/libXcomposite
			x11-libs/libXcursor
			x11-libs/libXrandr
			x11-libs/libXi
			x11-libs/libXinerama
			x11-libs/libXmu
			x11-libs/libXrender
			x11-libs/libXxf86vm
			x11-apps/xmessage
		)
	alsa? 	( media-libs/alsa-lib )
	capi? 	( net-dialup/capisuite )
	esd? 	( media-sound/esound )
	nas? 	( media-libs/nas )
	cups? 	( net-print/cups )
	glu? 	( virtual/glu )
	gphoto? ( media-libs/libgphoto2 )
	opengl? ( virtual/opengl )
	openssl? ( dev-libs/openssl )
	jpeg? 	( media-libs/jpeg )
	ldap? 	( net-nds/openldap )
	lcms? 	( media-libs/lcms )
	png? 	( media-libs/libpng )
	samba? 	( >=net-fs/samba-3.0.25 )
	xml? 	( dev-libs/libxml2 dev-libs/libxslt )
	scanner? ( media-gfx/sane-backends )
	amd64? (
		X? 	( >=app-emulation/emul-linux-x86-xlibs-2.1 )
		alsa? 	( >=app-emulation/emul-linux-x86-soundlibs-2.1 )
		oss? 	( >=app-emulation/emul-linux-x86-soundlibs-2.1 )
		>=sys-kernel/linux-headers-2.6
	)"
DEPEND="${RDEPEND}
	X? (
		x11-proto/inputproto
		x11-proto/xextproto
		x11-proto/xf86vidmodeproto
		x11-proto/xineramaproto
		x11-proto/renderproto
	)
	dev-util/pkgconfig
	sys-devel/bison
	sys-devel/flex"

pkg_setup() {
	use alsa || return 0
	if ! built_with_use --missing true media-libs/alsa-lib midi ; then
		eerror "You must build media-libs/alsa-lib with USE=midi"
		die "please re-emerge media-libs/alsa-lib with USE=midi"
	fi

	if use win64; then
		if use amd64 || use ppc64; then
			ewarn "64 bit wine cannot run ordinary 32bit or 16bit code"
			elog "if you want run 16 or 32bit code - reemerge wine without 'win64'-flag"
		else
			ewarn "it seems there is no use for 64bit wine on your architecture"
		fi
	fi
}

src_unpack() {
	unpack wine-${P}.tar.bz2
	cd "${S}"

	sed -i '/^UPDATE_DESKTOP_DATABASE/s:=.*:=true:' tools/Makefile.in
	epatch "${FILESDIR}"/wine-gentoo-no-ssp.patch #66002
	sed -i '/^MimeType/d' tools/wine.desktop || die #117785
}

src_compile() {
	if use amd64 && ! use win64; then
		multilib_toolchain_setup x86
	fi

	filter-ldflags -Wl,--as-needed # fix autodetection bugs

	econf \
		--sysconfdir=/etc/wine \
		--with-fontconfig \
		$(use_enable win16) \
		$(use_enable win64) \
		$(use_with ncurses curses) \
		$(use_with opengl) \
		$(use_with X x) \
		$(use X && for i in composite cursor inerama input \
			randr render; do echo -n " --with-x${i} "; done) \
		$(use_with alsa) \
		$(use_with capi) \
		$(use_with cups) \
		$(use_with dbus) \
		$(use_with esd) \
		$(use_with glu) \
		$(use_with gphoto) \
		$(use_with jack) \
		$(use_with jpeg) \
		$(use_with lcms cms) \
		$(use_with ldap) \
		$(use_with hal) \
		$(use_with oss) \
		$(use_with openssl) \
		$(use_with nas) \
		$(use_with scanner sane) \
		$(use_with truetype freetype) \
		$(use_with xml) \
		$(use_with xml xslt) \
		|| die "configure failed"

	emake -j1 depend || die "depend"
	emake all || die "all"
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc ANNOUNCE AUTHORS ChangeLog DEVELOPERS-HINTS README
	if use gecko ; then
		insinto /usr/share/wine/gecko
		doins "${DISTDIR}"/wine_gecko-*.cab || die
	fi
}

pkg_postinst() {
	elog "~/.wine/config is now deprecated.  For configuration either use"
	elog "winecfg or regedit HKCU\\Software\\Wine"
}

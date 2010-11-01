# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="2"

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="git://source.winehq.org/git/wine.git"
	inherit git
	SRC_URI=""
	KEYWORDS=""
else
	inherit eutils
	MY_P="${PN}-${PV/_/-}"
	SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.bz2
		http://ibiblio.org/pub/linux/system/emulators/${PN}/${MY_P}.tar.bz2"
	KEYWORDS="-* ~amd64 ~x86 ~x86-fbsd"
	S=${WORKDIR}/${MY_P}
fi

GV="1.1.0"
DESCRIPTION="free implementation of Windows(tm) on Unix"
HOMEPAGE="http://www.winehq.org/"
SRC_URI="${SRC_URI}
	gecko? (
		!win64? ( mirror://sourceforge/wine/wine_gecko-${GV}-x86.cab )
		win64? ( mirror://sourceforge/wine/wine_gecko-${GV}-x86_64.cab ) )"

LICENSE="LGPL-2.1"
SLOT="0"
IUSE="alsa capi cups dbus esd +gecko glu gphoto gsm gstreamer hal icns jack jpeg cms ldap mp3 nas ncurses +openal opengl ssl oss perl png +pthread samba scanner gnutls tiff truetype xml v4l2 X +win16 win64 newdib"
RESTRICT="test" #72375

CDEPEND="media-fonts/corefonts
	media-libs/fontconfig
	truetype? 	( >=media-libs/freetype-2.0.0
			media-fonts/corefonts )
	ncurses? 	( >=sys-libs/ncurses-5.2 )
	jack? 		( media-sound/jack-audio-connection-kit )
	dbus? 	( sys-apps/dbus
		hal? ( sys-apps/hal ) )
	X? (	x11-libs/libSM
		x11-libs/libXcomposite
		x11-libs/libXcursor
		x11-libs/libXrandr
		x11-libs/libXi
		x11-libs/libXmu
		x11-libs/libXrender
		x11-libs/libXxf86vm
		x11-apps/xmessage )
	alsa? 	( media-libs/alsa-lib )
	capi? 	( net-dialup/capisuite )
	esd? 	( media-sound/esound )
	nas? 	( media-libs/nas )
	cups? 	( net-print/cups )
	glu? 	( virtual/glu )
	gphoto? ( media-libs/libgphoto2 )
	gsm?	( media-sound/gsm )
	gstreamer? ( media-libs/gstreamer )
	openal? ( media-libs/openal )
	opengl? ( virtual/opengl )
	mp3? 	( media-sound/mpg123 )
	ssl? 	( dev-libs/openssl )
	jpeg? 	( media-libs/jpeg )
	icns? 	( media-libs/libicns )
	ldap? 	( net-nds/openldap )
	cms? 	( media-libs/lcms )
	png? 	( media-libs/libpng )
	samba? 	( >=net-fs/samba-3.0.25 )
	gnutls?	( net-libs/gnutls )
	xml? 	( dev-libs/libxml2 dev-libs/libxslt )
	scanner? ( media-gfx/sane-backends )
	tiff? 	( media-libs/tiff )
	v4l2? 	( media-libs/libv4l )
	win64? ( >=sys-devel/gcc-4.4_alpha )
	amd64? ( >=sys-kernel/linux-headers-2.6
		app-emulation/emul-linux-x86-baselibs
		truetype? 	( >=app-emulation/emul-linux-x86-xlibs-20100611 )
		X? 		( >=app-emulation/emul-linux-x86-xlibs-20100611 )
		alsa? 		( >=app-emulation/emul-linux-x86-soundlibs-20100611 )
		gstreamer? 	( >=app-emulation/emul-linux-x86-soundlibs-20100611 )
		mp3? 		( >=app-emulation/emul-linux-x86-soundlibs-20100611 )
		openal? 	( media-libs/openal[multilib] )
		opengl? 	( || ( >=app-emulation/emul-linux-x86-xlibs-20100611
					media-libs/mesa[multilib] ) ) )"

RDEPEND="${CDEPEND}
	perl? 	( dev-lang/perl
		dev-perl/XML-Simple )"

DEPEND="${CDEPEND}
	X? (
		x11-proto/inputproto
		x11-proto/xextproto
		x11-proto/xf86vidmodeproto
		x11-proto/renderproto
	)
	dev-util/pkgconfig
	sys-devel/bison
	sys-devel/flex"

pkg_setup() {
	if ! use perl; then
		ewarn "you can not run winemaker with 'perl'-flag disabled"
	fi

	if use win64; then
		if use amd64 || use ppc64; then
			ewarn "64 bit wine cannot run ordinary 32bit or 16bit code"
			elog "if you want run 16 or 32bit code - reemerge wine without 'win64'-flag"
		else
			ewarn "it seems there is no use for 64bit wine on your architecture"
		fi
	fi

	if use newdib; then
		elog "you are about to patch your wine source with experimental DIB Engine patches from"
		elog "http://bugs.winehq.org/show_bug.cgi?id=421"
		ewarn "they may fail. if they are, try without 'newdib'-flag"
	fi
}

src_unpack() {
	if [[ ${PV} == "9999" ]] ; then
		git_src_unpack
	else
		unpack ${MY_P}.tar.bz2
	fi
}

src_prepare() {
	sed -i '/^UPDATE_DESKTOP_DATABASE/s:=.*:=true:' tools/Makefile.in || die
	sed -i '/^MimeType/d' tools/wine.desktop || die #117785

	cd "${S}"

	if use newdib; then
		# full DIB engine
		einfo "Integration full-blown DIB engine..."
		[ -f "${FILESDIR}/dib/series" ] || die
		for i in `echo -n $(cat "${FILESDIR}/dib/series"|grep -v \#)`; do
			epatch "${FILESDIR}/dib/${i}"
		done
	fi

	# DInput via XI2 !
	epatch "${FILESDIR}/dinput_xi2_1.3.6.patch"
}

src_configure() {

	econf \
		--sysconfdir=/etc/wine \
		--with-fontconfig \
		$(use_enable win16) \
		$(use_enable win64) \
		$(use_with ncurses curses) \
		$(use_with openal) \
		$(use_with opengl) \
		$(use_with X x) \
		$(use_with alsa) \
		$(use_with capi) \
		$(use_with cups) \
		$(use_with esd) \
		$(use_with glu) \
		$(use_with gphoto) \
		$(use_with gsm) \
		$(use_with gstreamer) \
		$(use_with mp3 mpg123) \
		$(use_with jack) \
		$(use_with jpeg) \
		$(use_with cms) \
		$(use_with ldap) \
		$(! use dbus && echo --without-hal || use_with hal) \
		$(use_with oss) \
		$(use_with png) \
		$(use_with ssl openssl) \
		$(use_with nas) \
		$(use_with pthread) \
		$(use_with scanner sane) \
		$(use_with tiff) \
		$(use_with truetype freetype) \
		$(use_with gnutls) \
		$(use_with xml) \
		$(use_with xml xslt) \
		$(use_with v4l2 v4l) \
		|| die "configure failed"

	emake -j1 depend || die "depend"
}

src_compile() {
	emake all || die "all"
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc ANNOUNCE AUTHORS README
	if use gecko ; then
		insinto /usr/share/wine/gecko
		if ! use win64; then
			doins "${DISTDIR}/wine_gecko-${GV}-x86.cab" || die
		else
			doins "${DISTDIR}/wine_gecko-${GV}-x86_64.cab" || die
		fi
	fi
}

pkg_postinst() {
	elog "if fonts seem ugly to you try putting this:"
	elog
	elog "REGEDIT4"
	elog "[HKEY_CURRENT_USER\Control Panel\Desktop]"
	elog "\"FontSmoothing\"=\"2\""
	elog "\"FontSmoothingType\"=dword:00000002"
	elog "\"FontSmoothingGamma\"=dword:00000578"
	elog "\"FontSmoothingOrientation\"=dword:00000001"
	elog
	elog "into temporary file, say \"~/wine_fontsmoothing.reg\""
	elog "and adding it to registry by 'regedit ~/wine_fontsmoothing.reg' command"
}

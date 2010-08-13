# Copyright 1999-2008 Gentoo Foundation
# [v-fox] ftp://dfx.homeftp.net/services/GENTOO/v-fox

EAPI="1"

inherit eutils flag-o-matic multilib

if [[ ${PV} == "1.0_rc9999" ]] ; then
	inherit subversion
	ESVN_REPO_URI="svn://svn.mplayerhq.hu/mplayer/trunk"
	ESVN_PROJECT="mplayer"
	SRC_URI=""
	KEYWORDS=""
else
	MPLAYER_REVISION=29040
	SRC_URI="mirror://gentoo/${P}.tar.bz2"
	KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
fi

RESTRICT=""
IUSE="3dnow 3dnowext a52 aalib alsa altivec amrnb amrwb arts aac +ass bidi bl bindist
cddb cdio cdparanoia cpudetection custom-cflags debug dga dirac doc dts dvb directfb
dvd dv enca encode esd fbcon ffmpeg ftp gif ggi gtk iconv ipv6 jack joystick jpeg
kernel_linux ladspa libcaca lirc live livecd lzo mad md5sum mmx mmxext mp2 mp3
musepack nas nemesi nls unicode vorbis opengl openal oss png pnm profile pulseaudio
quicktime radio rar real rtc samba sdl +shm speex +srt sse sse2 ssse3 static svga
teletext tga theora tivo truetype v4l v4l2 vdpau vidix win32codecs X x264 xanim xinerama
xscreensaver xv xvid xvmc zoran"

VIDEO_CARDS="cyberblade ivtv mach64 mga_crtc2 pm2 pm3 radeon rage128 s3 sis s3virge mga tdfx vesa fbdev nvidia unichrome"

for x in ${VIDEO_CARDS}; do
	IUSE="${IUSE} video_cards_${x}"
done

BLUV="1.7"
SVGV="1.9.17"
AMR_URI="http://www.3gpp.org/ftp/Specs/archive"
SRC_URI="${SRC_URI}
	!truetype? ( mirror://mplayer/releases/fonts/font-arial-iso-8859-1.tar.bz2
				 mirror://mplayer/releases/fonts/font-arial-iso-8859-2.tar.bz2
				 mirror://mplayer/releases/fonts/font-arial-cp1250.tar.bz2 )
	!iconv? ( mirror://mplayer/releases/fonts/font-arial-iso-8859-1.tar.bz2
			  mirror://mplayer/releases/fonts/font-arial-iso-8859-2.tar.bz2
			  mirror://mplayer/releases/fonts/font-arial-cp1250.tar.bz2 )
	gtk? ( mirror://mplayer/Skin/productive-1.0.tar.bz2 )
	svga? ( http://www.mplayerhq.hu/MPlayer/contrib/svgalib/svgalib_helper-${SVGV}-mplayer.tar.bz2 )"

DESCRIPTION="Media Player for Linux"
HOMEPAGE="http://www.mplayerhq.hu/"

RDEPEND="sys-libs/ncurses
	!static? (
		media-libs/faad2
		a52? ( media-libs/a52dec )
		amrnb? ( media-libs/amrnb )
		amrwb? ( media-libs/amrwb )
		dvd? ( media-libs/libdvdcss
			media-libs/libdvdnav
			media-libs/libdvdread )
		ffmpeg? ( media-video/ffmpeg
			dirac? ( media-video/dirac
				media-libs/schroedinger
				)
			mp3? ( media-sound/lame )
			xvid? ( media-libs/xvid )
			)
		)
	!bindist? (
		x86? (
			win32codecs? ( media-libs/win32codecs )
			)
	)

	aalib? ( media-libs/aalib )
	alsa? ( media-libs/alsa-lib )
	arts? ( kde-base/arts )
	openal? ( media-libs/openal )
	bidi? ( dev-libs/fribidi )
	cdio? ( dev-libs/libcdio )
	cdparanoia? ( media-sound/cdparanoia )
	directfb? ( dev-libs/DirectFB )
	dga? ( x11-libs/libXxf86dga  )
	dts? ( media-libs/libdca )
	dv? ( media-libs/libdv )
	dvb? ( media-tv/linuxtv-dvb-headers )
	encode? (
		aac? ( media-libs/faac )
		dv? ( media-libs/libdv )
		mp2? ( media-sound/twolame )
		mp3? ( media-sound/lame )
		x264? ( media-libs/x264 )
		xvid? ( media-libs/xvid )
		)
	esd? ( media-sound/esound )
	enca? ( app-i18n/enca )
	gif? ( media-libs/giflib )
	ggi? ( media-libs/libggi
		media-libs/libggiwmh )
	gtk? ( media-libs/libpng
		x11-libs/libXxf86vm
		x11-libs/libXext
		x11-libs/libXi
		x11-libs/gtk+:2 )
	jpeg? ( media-libs/jpeg )
	ladspa? ( media-libs/ladspa-sdk )
	libcaca? ( media-libs/libcaca )
	lirc? ( app-misc/lirc )
	lzo? ( dev-libs/lzo:2 )
	mad? ( media-libs/libmad )
	musepack? ( >=media-libs/libmpcdec-1.2.2 )
	nas? ( media-libs/nas )
	nls? ( virtual/libintl )
	opengl? ( virtual/opengl )
	png? ( media-libs/libpng )
	pnm? ( media-libs/netpbm )
	pulseaudio? ( media-sound/pulseaudio )
	samba? ( net-fs/samba )
	sdl? ( media-libs/libsdl )
	speex? ( >=media-libs/speex-1.1.7 )
	srt? ( >=media-libs/freetype-2.1
		media-libs/fontconfig )
	svga? ( media-libs/svgalib )
	theora? ( media-libs/libtheora )
	live? ( >=media-plugins/live-2007.02.20 )
	truetype? ( >=media-libs/freetype-2.1
		media-libs/fontconfig )
	video_cards_nvidia? ( vdpau? ( >=x11-drivers/nvidia-drivers-180.06 ) )
	vidix? ( x11-libs/libXxf86vm
			 x11-libs/libXext )
	xanim? ( media-video/xanim )
	xinerama? ( x11-libs/libXinerama
		x11-libs/libXxf86vm
		x11-libs/libXext )
	xscreensaver? ( x11-libs/libXScrnSaver )
	xv? ( x11-libs/libXv
		x11-libs/libXxf86vm
		x11-libs/libXext
		xvmc? ( || ( x11-libs/libXvMC x11-drivers/nvidia-drivers ) ) )
	X? ( x11-libs/libXxf86vm
		x11-libs/libXext )"

DEPEND="${RDEPEND}
	app-arch/unzip
	doc? ( >=app-text/docbook-sgml-dtd-4.1.2
		app-text/docbook-xml-dtd
		>=app-text/docbook-xml-simple-dtd-1.50.0
		dev-libs/libxslt )
	dga? ( x11-proto/xf86dgaproto )
	nls? ( sys-devel/gettext )
	xinerama? ( x11-proto/xineramaproto )
	xv? ( x11-proto/videoproto
		  x11-proto/xf86vidmodeproto )
	X? ( x11-proto/xextproto
		 x11-proto/xf86vidmodeproto )
	xscreensaver? ( x11-proto/scrnsaverproto )
	iconv? ( virtual/libiconv )"
# Make sure the assembler USE flags are unmasked on amd64
# Remove this once default-linux/amd64/2006.1 is deprecated
DEPEND="${DEPEND} amd64? ( >=sys-apps/portage-2.1.2 )
	mp2? ( >=sys-apps/portage-2.1.2 )"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS=""

pkg_setup() {
	if [[ -n ${LINGUAS} ]]; then
		elog "For MPlayer's language support, the configuration will"
		elog "use your LINGUAS variable from /etc/make.conf.  If you have more"
		elog "than one language enabled, then the first one in the list will"
		elog "be used to output the messages, if a translation is available."
		elog "man pages will be created for all languages where translations"
		elog "are also available."
	fi

	if use cpudetection; then
		ewarn ""
		ewarn "You've enabled the cpudetection flag.  This feature is"
		ewarn "included mainly for people who want to use the same"
		ewarn "binary on another system with a different CPU architecture."
		ewarn "MPlayer will already detect your CPU settings by default at"
		ewarn "buildtime; this flag is used for runtime detection."
		ewarn "You won't need this turned on if you are only building"
		ewarn "mplayer for this system.  Also, if your compile fails, try"
		ewarn "disabling this use flag."
	fi

	if use static; then
		ewarn "Beware ! mencoder was broken with glibc 2.7 and static linking."
		ewarn "If you not want to challenge your luck then"
		ewarn "STOP it and try build without 'static' USE-flag"
		ewarn "or try some separate mplayer\mencoder ebuilds"
		ebeep 3
		epause 10
		einfo "as you wish, master..."
	fi

	if use custom-cflags; then
		ewarn ""
		ewarn "You've enabled the custom-cflags USE flag, which overrides"
		ewarn "mplayer's recommended behavior, making this build unsupported."
		ewarn ""
		ewarn "Re-emerge mplayer without this flag before filing bugs."
	fi

	if use custom-cpuopts; then
		ewarn ""
		ewarn "You are using the custom-cpuopts flag which will"
		ewarn "specifically allow you to enable / disable certain"
		ewarn "CPU optimizations."
		ewarn ""
		ewarn "Most desktop users won't need this functionality, but it"
		ewarn "is included for corner cases like cross-compiling and"
		ewarn "certain profiles.  If unsure, disable this flag and MPlayer"
		ewarn "will automatically detect and use your available CPU"
		ewarn "optimizations."
		ewarn ""
		ewarn "Using this flag means your build is unsupported, so"
		ewarn "please make sure your CPU optimization use flags (3dnow"
		ewarn "3dnowext mmx mmxext sse sse2 ssse3) are properly set."
	fi
}

src_unpack() {
	if [[ ${PV} == "1.0_rc9999" ]] ; then
        	subversion_src_unpack
	else
		unpack "${P}.tar.bz2"
		# Set version #
		sed -i s/UNKNOWN/${MPLAYER_REVISION}/ "${S}/version.sh"
	fi

	if ! use truetype ; then
		unpack font-arial-iso-8859-1.tar.bz2 \
			font-arial-iso-8859-2.tar.bz2 \
			font-arial-cp1250.tar.bz2
	fi

	use gtk && unpack "productive-1.0.tar.bz2"
	use svga && unpack "svgalib_helper-${SVGV}-mplayer.tar.bz2"

	if use svga; then
		echo
		einfo "Enabling vidix non-root mode."
		einfo "(You need a proper svgalib_helper.o module for your kernel"
		einfo "to actually use this)"
		echo

		mv "${WORKDIR}/svgalib_helper" "${S}/libdha"
	fi

	# Fix manuals
        cd "${S}"
	sed -i 's:$$i:$$lang:g' Makefile
}

src_compile() {
	local myconf

	# broken upstream, won't work with recent kernels
	# myconf="${myconf} --disable-ivtv --disable-pvr"

	# MPlayer reads in the LINGUAS variable from make.conf, and sets
	# the languages accordingly.  Some will have to be altered to match
	# upstream's naming scheme.
	[[ -n $LINGUAS ]] && LINGUAS=${LINGUAS/da/dk} || LINGUAS=en

	################
	#Optional features#
	###############
	use xscreensaver || myconf="${myconf} --disable-xss"
	use bidi || myconf="${myconf} --disable-fribidi"
	use bl && myconf="${myconf} --enable-bl"
	use enca || myconf="${myconf} --disable-enca"
	use ftp || myconf="${myconf} --disable-ftp"
	use nemesi || myconf="${myconf} --disable-nemesi"
	use tivo || myconf="${myconf} --disable-vstream"

	# libcdio support: prefer libcdio over cdparanoia
	# don't check for cddb w/cdio
	if use cdio; then
		myconf="${myconf} --disable-cdparanoia"
	else
		myconf="${myconf} --disable-libcdio"
		use cdparanoia || myconf="${myconf} --disable-cdparanoia"
		use cddb || myconf="${myconf} --disable-cddb"
	fi

	if ! use dvd; then
		myconf="${myconf} --disable-dvdnav --disable-dvdread"
		use a52 || myconf="${myconf} --disable-liba52"
	fi

	if use encode; then
		use aac || myconf="${myconf} --disable-faac"
		use dv || myconf="${myconf} --disable-libdv"
		use x264 || myconf="${myconf} --disable-x264"
	else
		myconf="${myconf} --disable-mencoder \
		--disable-libdv --disable-x264 --disable-faac"
	fi

	# SRT (subtitles) requires freetype support
	# freetype support requires iconv
	# iconv optionally can use unicode
	if ! use srt; then
		! use ass && myconf="${myconf} --disable-ass"
		if ! use truetype; then
			myconf="${myconf} --disable-freetype"
			if ! use iconv; then
				myconf="${myconf} --disable-iconv --charset=noconv"
			fi
		fi
	fi
	use iconv && use unicode && myconf="${myconf} --charset=UTF-8"

	use lirc || myconf="${myconf} --disable-lirc --disable-lircc"
	myconf="${myconf} $(use_enable joystick)"
	use ipv6 || myconf="${myconf} --disable-inet6"
	use rar || myconf="${myconf} --disable-unrarexec"
	use rtc || myconf="${myconf} --disable-rtc"
	use samba || myconf="${myconf} --disable-smb"

	# DVB / Video4Linux / Radio support
	if { use dvb || use v4l || use v4l2 || use radio; }; then
		use dvb || myconf="${myconf} --disable-dvb --disable-dvbhead"
		use v4l	|| myconf="${myconf} --disable-tv-v4l1"
		use v4l2 || myconf="${myconf} --disable-tv-v4l2"
		use teletext || myconf="${myconf} --disable-tv-teletext"
		if use radio && { use dvb || use v4l || use v4l2; }; then
			myconf="${myconf} --enable-radio $(use_enable encode radio-capture)"
		else
			myconf="${myconf} --disable-radio-v4l2 --disable-radio-bsdbt848"
		fi
	else
		myconf="${myconf} --disable-tv --disable-tv-v4l1 --disable-tv-v4l2 \
			--disable-radio --disable-radio-v4l2 --disable-radio-bsdbt848 \
			--disable-dvb --disable-dvbhead --disable-tv-teletext"
	fi

	#########
	# Codecs #
	########
	for x in gif jpeg live mad musepack pnm speex tga theora xanim xvid; do
		myconf="${myconf} $(use_enable ${x})"
	done
	use amrnb || myconf="${myconf} --disable-libamr_nb"
	use amrwb || myconf="${myconf} --disable-libamr_wb"
	use dts || myconf="${myconf} --disable-libdca"
	! use png && ! use gtk && myconf="${myconf} --disable-png"
	use lzo || myconf="${myconf} --disable-liblzo"
	use encode && use mp2 || myconf="${myconf} --disable-twolame \
		--disable-toolame"
	use mp3 || myconf="${myconf} --disable-mp3lib"
	use quicktime || myconf="${myconf} --disable-qtx"
	use vorbis --enable-dvbhead
	use xanim && myconf="${myconf} --xanimcodecsdir=/usr/lib/xanim/mods"
	use real || myconf="${myconf} --disable-real"
	if use x86; then
		if ! use livecd && ! use bindist; then
			myconf="${myconf} $(use_enable win32codecs win32dll)"
		fi
	fi

	#############
	# Video Output #
	#############
	for x in directfb ggi md5sum sdl xinerama; do
		use ${x} || myconf="${myconf} --disable-${x}"
	done
	use aalib || myconf="${myconf} --disable-aa"
	use dga || myconf="${myconf} --disable-dga1 --disable-dga2"
	use libcaca || myconf="${myconf} --disable-caca"
	use opengl || myconf="${myconf} --disable-gl"
	use video_cards_vesa || myconf="${myconf} --disable-vesa"
	use video_cards_tdfx && myconf="${myconf}  --enable-tdfxvid" || \
		 myconf="${myconf}  --disable-3dfx"
	use zoran || myconf="${myconf} --disable-zr"

	if use fbcon; then
		use video_cards_fbdev && myconf="${myconf} --enable-fbdev"
		use video_cards_s3virge && myconf="${myconf} --enable-s3fb"
		use video_cards_tdfx && myconf="${myconf} --enable-tdfxfb"
		else
		myconf="${myconf} --disable-fbdev --disable-s3fb --disable-tdfxfb"
	fi

	if use vidix; then
		myconf="${myconf} --enable-vidix"
		local VDRIVERS
		for CARD in cyberblade ivtv mach64 mga mga_crtc2 nvidia pm2 pm3 radeon rage128 s3 sis unichrome; do
			use video_cards_$CARD && ${VDRIVERS}="${VDRIVERS},$CARD"
		done
		[ -n VDRIVERS ] && myconf="${myconf} --with-vidix-drivers=${VDRIVERS}"
		use svga && \
			myconf="${myconf} --enable-svgalib_helper" || \
			myconf="${myconf} --enable-dhahelper"
		else
		myconf="${myconf} --disable-vidix --disable-vidix-pcidb"
	fi

	# GTK gmplayer gui
	myconf="${myconf} $(use_enable gtk gui)"

	if use xv; then
		if use xvmc; then
			myconf="${myconf} --enable-xvmc"
			use video_cards_nvidia && \
			myconf="${myconf} --with-xvmclib=XvMCNVIDIA" || \
			myconf="${myconf} --with-xvmclib=XvMCW"
		else
			myconf="${myconf} --disable-xvmc"
		fi
	else
		myconf="${myconf} --disable-xv --disable-xvmc"
	fi

	# nvidia vdpau
	if use vdpau; then
		if use video_cards_nvidia; then
			myconf="${myconf} --enable-vdpau"
		else
			ewarn "You don't have vdpau-compatible hardware."
			ewarn "This is nvidia's proprietary technology"
		fi
	fi

	if ! use kernel_linux && ! use video_cards_mga; then
		 myconf="${myconf} --disable-mga --disable-xmga"
	fi

	#############
	# Audio Output #
	#############
	for x in alsa arts esd jack ladspa nas openal; do
		myconf="${myconf} $(use_enable ${x})"
	done
	use pulseaudio || myconf="${myconf} --disable-pulse"
	if ! use radio; then
		use oss || myconf="${myconf} --disable-ossaudio"
	fi
	#################
	# Advanced Options #
	#################
	# Platform specific flags, hardcoded on amd64 (see below)
	if use x86 || use amd64 || use ppc; then
		if use livecd || use bindist; then
			use cpudetection && myconf="${myconf} --enable-runtime-cpudetection"
			for i in 3dnow 3dnowext mmx mmxext shm sse sse2 ssse3; do
				myconf="${myconf} --enable-${i}"
			done
		else
			for i in 3dnow 3dnowext mmx mmxext shm sse sse2 ssse3; do
				myconf="${myconf} $(use_enable ${i})"
			done
		fi
	fi

	use debug && myconf="${myconf} --enable-debug=3"

	myconf="${myconf} $(use_enable altivec)"
	use profile || myconf="${myconf} --enable-profile"

	if use custom-cflags; then
		#fixing stupid "Checking for CFLAGS" function which breakes mplayer with -O2 flag
		einfo "changing O2 to O3 due danger of errors"
		sed -i -e 's:O2:O3:g' ./configure || die
		append-flags -D__STDC_LIMIT_MACROS
	else
		strip-flags
		# Mplayer has own ld policies too and it's strict
		unset LDFLAGS
	fi

	# DVD support
	# dvdread and libdvdcss are internal libs
	# http://www.mplayerhq.hu/DOCS/HTML/en/dvd.html
	# You can optionally use external dvdread support, but against
	# upstream's suggestion.  We don't.

	if use static; then
		myconf="${myconf} --enable-static"
		else
		myconf="${myconf} --enable-rpath --enable-dynamic-plugins"
		use a52 && myconf="${myconf} --disable-liba52-internal"
		use dvd && \
			myconf="${myconf} --disable-dvdread-internal \
			--with-dvdread-config=/usr/bin/dvdread-config \
			--with-dvdnav-config=/usr/bin/dvdnav-config \
			--disable-libdvdcss-internal"
		if use ffmpeg; then
			myconf="${myconf} \
				--disable-libavutil_a --disable-libavcodec_a \
				--disable-libavformat_a --disable-libpostproc_a \
				--disable-faac-lavc --disable-libswscale_a"
			use dirac && myconf="${myconf} --disable-libdirac-lavc\
							--disable-libschroedinger-lavc"
			use mp3 && myconf="${myconf} --disable-mp3lame-lavc"
			use xvid && myconf="${myconf} --disable-xvid-lavc"
		fi
		myconf="${myconf} --disable-faad-internal --enable-faad"
	fi

	myconf="--cc=$(tc-getCC) \
		--host-cc=$(tc-getBUILD_CC) \
		--prefix=/usr \
		--confdir=/etc/mplayer \
		--datadir=/usr/share/mplayer \
		--libdir=/usr/$(get_libdir) \
		--enable-menu \
		--enable-network \
		${myconf}"

	# avoiding linking bugs with openal and xvid
	use xvid && append-ldflags "-Wl,-lxvidcore"
	use openal && append-ldflags "-Wl,-lopenal"

	cd "${S}"
	echo "./configure ${myconf}"
	./configure ${myconf} || die "configure died"

	if [[ ${PV} == "1.0_rc9999" ]] ; then
		# For Version Branding (we are not have svn entries in $WORKDIR)
		cd "${ESVN_STORE_DIR}/${ESVN_CO_DIR}/${ESVN_PROJECT}/${ESVN_REPO_URI##*/}"
		./version.sh
		mv version.h "${S}"/ || die "versionization failed"
		cd ${S}
	fi

	emake || die "Failed to build MPlayer!"

	use doc && \
		for i in $LINGUAS; do
			make -C DOCS/xml html-chunked-${i} && \
			einfo "HTML chunked docs for \"${i}\" language are builded correctly" || \
			eerror "Making docs for \"${i}\" language failed. Check if it supported"
		done
}

src_install() {

	emake -j1 prefix="${D}/usr" \
		 BINDIR="${D}/usr/bin" \
		 LIBDIR="${D}/usr/$(get_libdir)" \
		 CONFDIR="${D}/etc/mplayer" \
		 DATADIR="${D}/usr/share/mplayer" \
		 MANDIR="${D}/usr/share/man" \
		 install || die "Failed to install MPlayer!"

	dodoc AUTHORS Changelog README
	# Install the documentation; DOCS is all mixed up not just html
	if use doc ; then
		find "${S}/DOCS" -type d | xargs -- chmod 0755
		find "${S}/DOCS" -type f | xargs -- chmod 0644
		for i in $LINGUAS; do
			cp -r "${S}/DOCS/HTML/$i" "${D}/usr/share/doc/${PF}/";
		done;
	fi

	if use vdpau; then
		dodoc "${FILESDIR}"/README-vdpau.txt
	fi

	# Copy misc tools to documentation path, as they're not installed directly
	# and yes, we are nuking the +x bit.
	find "${S}/TOOLS" -type d | xargs -- chmod 0755
	find "${S}/TOOLS" -type f | xargs -- chmod 0644
	cp -r "${S}/TOOLS" "${D}/usr/share/${PN}/" || die "cp docs died"

	# Install the default Skin and Gnome menu entry
	if use gtk; then
		dodir /usr/share/mplayer/skins
		cp -r "${WORKDIR}/productive" "${D}"/usr/share/mplayer/skins/default || die "cp skin died"
		# Fix the symlink
		rm -rf "${D}/usr/bin/gmplayer"
		dosym mplayer /usr/bin/gmplayer

		insinto /usr/share/pixmaps
		newins "${S}"/gui/mplayer/pixmaps/logo.xpm mplayer.xpm
		insinto /usr/share/applications
		doins "${FILESDIR}/mplayer.desktop"
	fi

	if ! use srt && ! use truetype; then
		dodir /usr/share/mplayer/fonts
		local x=
		# Do this generic, as the mplayer people like to change the structure
		# of their zips ...
		for x in $(find "${WORKDIR}/" -type d -name 'font-arial-*')
		do
			cp -pPR "${x}" "${D}/usr/share/mplayer/fonts"
		done
		# Fix the font symlink ...
		rm -rf "${D}/usr/share/mplayer/font"
		dosym fonts/font-arial-14-iso-8859-1 /usr/share/mplayer/font
	fi

	insinto /etc/mplayer
	newins "${S}/etc/example.conf" mplayer.conf

	if use srt || use truetype;	then
		cat >> "${D}/etc/mplayer/mplayer.conf" << EOT
fontconfig=1
subfont-osd-scale=4
subfont-text-scale=3
EOT
	fi

	dosym ../../../etc/mplayer/mplayer.conf /usr/share/mplayer/mplayer.conf

	dobin "${D}/usr/share/${PN}/midentify.sh"

	insinto /usr/share/mplayer
	doins "${S}/etc/input.conf"
	doins "${S}/etc/menu.conf"
}

pkg_preinst() {

	if [[ -d ${ROOT}/usr/share/mplayer/Skin/default ]]
	then
		rm -rf "${ROOT}/usr/share/mplayer/Skin/default"
	fi

}

pkg_postrm() {

	# Cleanup stale symlinks
	if [ -L "${ROOT}/usr/share/mplayer/font" -a \
		 ! -e "${ROOT}/usr/share/mplayer/font" ]
	then
		rm -f "${ROOT}/usr/share/mplayer/font"
	fi

	if [ -L "${ROOT}/usr/share/mplayer/subfont.ttf" -a \
		 ! -e "${ROOT}/usr/share/mplayer/subfont.ttf" ]
	then
		rm -f "${ROOT}/usr/share/mplayer/subfont.ttf"
	fi
}

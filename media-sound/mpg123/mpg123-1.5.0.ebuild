# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/mpg123/mpg123-1.5.0.ebuild,v 1.1 2008/08/08 08:00:04 aballier Exp $

DESCRIPTION="a realtime MPEG 1.0/2.0/2.5 audio player for layers 1, 2 and 3."
HOMEPAGE="http://www.mpg123.org"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="3dnow 3dnowext alsa altivec arts esd ipv6 jack mmx nas network oss portaudio pulseaudio sdl sse"

RDEPEND="alsa? ( media-libs/alsa-lib )
	esd? ( media-sound/esound )
	jack? ( media-sound/jack-audio-connection-kit )
	nas? ( media-libs/nas )
	portaudio? ( media-libs/portaudio )
	pulseaudio? ( media-sound/pulseaudio )
	sdl? ( media-libs/libsdl )
	arts? ( kde-base/arts )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	sed -i -e 's:-faltivec::' "${S}"/configure || die "sed failed."
}

src_compile() {
	local myaudio

	use alsa && myaudio="${myaudio} alsa"
	use esd && myaudio="${myaudio} esd"
	use jack && myaudio="${myaudio} jack"
	use nas && myaudio="${myaudio} nas"
	use oss && myaudio="${myaudio} oss"
	use portaudio && myaudio="${myaudio} portaudio"
	use pulseaudio && myaudio="${myaudio} pulse"
	use sdl && myaudio="${myaudio} sdl"
	use arts && myaudio="${myaudio} arts"

	local mycpu

	if use x86 || use amd64;then
		if ! use mmx && ! use 3dnow && ! use 3dnowext && ! use sse; then
			mycpu="--with-cpu=generic_fpu"
			else
			use mmx && mycpu="--with-cpu=mmx"
			use 3dnow && mycpu="--with-cpu=3dnow"
			use 3dnowext && mycpu="--with-cpu=3dnowext"
			use sse && mycpu="--with-cpu=sse"
		fi
		if use x86; then
			 use mmx && use 3dnow && use 3dnowext && use sse \
				&& mycpu="--with-cpu=x86"
		fi
		else
		use arm && mycpu="--with-cpu=generic_nofpu"
		use altivec && mycpu="--with-cpu=altivec"
	fi

	econf 	--enable-modules=yes \
		--disable-dependency-tracking \
		${mycpu} \
		--with-audio="${myaudio}" \
		$(use_enable network) \
		$(use_enable ipv6)

	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS* README
}

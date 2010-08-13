# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

DESCRIPTION="Replacement for Punto Switcher"
HOMEPAGE="http://www.xneur.ru/"
SRC_URI="http://dists.xneur.ru/release-${PV}/tgz/${P}.tar.bz2"
LICENSE="GPL-2"
IUSE="alsa spell pcre gstreamer openal xpm X"
SLOT="0"

KEYWORDS="~x86 ~amd64"
DEPEND="X? ( x11-libs/libX11 )
	alsa? ( media-sound/alsa-utils )
	gstreamer? ( media-libs/gstreamer )
	openal? ( media-libs/openal
		  media-libs/freealut )
	pcre? ( dev-libs/libpcre )
	spell? ( app-text/aspell )
	xpm? ( x11-libs/libXpm )
	dev-util/pkgconfig"
RDEPEND="${DEPEND}"

RESTRICT="mirror"

pkg_setup() {
	if ! use gstreamer && ! use openal && ! use alsa; then
		ewarn "You have no audio output selected"
		ewarn "Your options here are: alsa gstreamer openal"
	fi
}

src_compile() {
	# They start using some crazy audio-selector, just like qemu-svn guys,
	# better solution required
	local SOUND="no"
	use gstreamer 	&& SOUND="gstreamer"
	use openal 	&& SOUND="openal"
	use alsa 	&& SOUND="aplay"
	if use gstreamer && use openal && use alsa; then
		SOUND="yes"
	fi

	econf --with-sound="${SOUND}" \
	$(use_with spell aspell) \
	$(use_with pcre) \
	$(use_with xpm) \
	$(use_with X x) \
	|| die "configure failed"
	emake || die "emake failed"
}

src_install() {
	make install DESTDIR="${D}" || die "emake install failed"
}

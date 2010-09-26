# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit xorg-2

DESCRIPTION="ATI video driver"

KEYWORDS=""
IUSE="+exa +dri +kms"

RDEPEND=">=x11-base/xorg-server-1.7[-minimal]
	dri? ( >=x11-libs/libdrm-2.4.17[video_cards_radeon] )
	kms? ( >=x11-libs/libdrm-2.4.17[kms] )"
DEPEND="${RDEPEND}
	x11-proto/fontsproto
	x11-proto/randrproto
	x11-proto/videoproto
	x11-proto/xextproto
	x11-proto/xf86miscproto
	x11-proto/xproto
	dri? ( x11-proto/glproto
		x11-proto/xf86driproto )
	kms? ( x11-proto/dri2proto )"

pkg_setup() {
	xorg-2_pkg_setup
	CONFIGURE_OPTIONS="$(use_enable exa)
			   $(use_enable dri)
			   $(use_enable kms)"
}

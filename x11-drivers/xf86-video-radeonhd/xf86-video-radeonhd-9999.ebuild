# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EGIT_REPO_URI="git://anongit.freedesktop.org/git/xorg/driver/xf86-video-radeonhd"
EGIT_BRANCH="master" #according to L.Wang
EGIT_BOOTSTRAP="./autogen.sh"

XDPVER=-1
inherit git x-modular

DESCRIPTION="Experimental Radeon HD video driver."
HOMEPAGE="http://wiki.x.org/wiki/radeonhd"

SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=x11-base/xorg-server-1.3.0"

DEPEND="${RDEPEND}
        x11-proto/xextproto
        x11-proto/xproto"
 

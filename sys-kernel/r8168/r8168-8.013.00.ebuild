# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI=2

inherit linux-mod

DESCRIPTION="Realtek RTL8111B/RTL8168B NIC drivers"
HOMEPAGE="http://www.realtek.com.tw/downloads/downloadsView.aspx?Langid=1&PNid=13&PFid=5&Level=5&Conn=4&DownTypeID=3&GetDown=false"
SRC_URI="http://www.realtek.com.tw/downloads/RedirectFTPSite.aspx?SiteID=1&DownTypeID=3&DownID=332&PFid=5&Conn=4 -> r8168-8.013.00.tar.bz2"
RESTRICT="mirror distcc"
LICENSE="GPL2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

MODULE_NAMES="src/r8168(kernel/drivers/net:${S}:${S})"
BUILD_TARGETS="modules"

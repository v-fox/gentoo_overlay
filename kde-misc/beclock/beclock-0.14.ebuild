# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

KDE_MINIMAL="4.3"
inherit kde4-base

OPENGL_REQUIRED=always
KDE_HANDBOOK=optional

MY_PV="${PV/0./}"
DESCRIPTION="A simple clock, implemented as KWin Effect"
HOMEPAGE="http://kde-look.org/content/show.php/BeClock?content=117542"
SRC_URI="http://kde-look.org/CONTENT/content-files/117542-beclock-kwin-fx-${MY_PV}.txz -> ${P}.tar.xz"
DEPEND="${DEPEND}
	xrandr? ( kde-base/kephal )"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+xrandr debug"

S="${WORKDIR}"/"beclock-kwin-fx"
mycmakeargs+="$(cmake-utils_use_enable xrandr KEPHAL)"

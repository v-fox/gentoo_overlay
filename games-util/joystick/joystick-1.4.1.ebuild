# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
inherit eutils toolchain-funcs

DESCRIPTION="Joystick testing utilities"
HOMEPAGE="http://sourceforge.net/projects/linuxconsole/"
SRC_URI="mirror://sourceforge/project/linuxconsole/linuxconsoletools-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="media-libs/libsdl[video]
	!x11-libs/tslib"

S="${WORKDIR}/linuxconsoletools-${PV}"

src_prepare() {
	sed -i -e '/^CC/d' Makefile
	sed -i -e '/^CC/d' -e '/^CFLAGS/d' utils/Makefile
	epatch ${FILESDIR}/linuxconsoletools-1.4.1-ldflags.patch
}

src_install() {
	emake PREFIX=/usr DESTDIR="${D}" install || die
	dodoc README
}

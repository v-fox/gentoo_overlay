# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
inherit eutils

DESCRIPTION="Sixaxis Joystick Manager"
HOMEPAGE="http://qtsixa.sourceforge.net/"
SRC_URI="http://sourceforge.net/projects/qtsixa/files/QtSixA%201.2.1/QtSixA-1.2.1-src.tar.gz"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64"
IUSE="qt hal doc"
DEPEND="
	>=dev-libs/libusb-1.0.8
	>=net-wireless/bluez-4.82"
RDEPEND="${DEPEND}
	qt? (
		net-wireless/bluez-hcidump
		>=dev-python/PyQt4-4.8.1
		>=dev-python/dbus-python-0.83.2
		x11-drivers/xf86-input-joystick
    	>=x11-libs/libnotify-0.4.5
		>=x11-misc/xdg-utils-1.0.2_p20100618
	)"

src_prepare() {
	epatch "${FILESDIR}/Makefile-DESTDIR-1.2.1.patch"
}

src_install() {
	cd sixad
	emake DESTDIR="${D}" install-system || die "emake install failed"
	cd ..
	if ! use hal; then
		rm -r $D/usr/share/hal/
	fi
	if use qt; then
		cd qtsixa
		emake DESTDIR="${D}" install || die "emake install failed"
		cd ..
	fi
	if ! use doc; then
		rm -r $D/usr/share/doc/
	fi
}

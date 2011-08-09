# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit eutils

DESCRIPTION="Sixaxis Joystick Manager"
HOMEPAGE="http://qtsixa.sourceforge.net/"
SRC_URI="mirror://sourceforge/project/${PN}/QtSixA%201.5.0%20Beta/${P}.tar.gz"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS=""
IUSE="qt hal jack doc"
DEPEND="
	>=dev-libs/libusb-1.0.8
	>=net-wireless/bluez-4.93"
RDEPEND="${DEPEND}
	qt? (
		net-wireless/bluez-hcidump
		>=dev-python/PyQt4-4.8.4
		>=dev-python/dbus-python-0.83.2
		x11-drivers/xf86-input-joystick
	jack? ( media-sound/jack )
    	>=x11-libs/libnotify-0.7.2
		>=x11-misc/xdg-utils-1.1.0_rc1-r1
	)"
S="${WORKDIR}/${PN}-1.5.0"

src_prepare() {
	epatch "${FILESDIR}/utils-FLAGS-1.4.96.patch"
	use jack || \
		epatch "${FILESDIR}/utils-disable-jack-1.4.96.patch"
	epatch "${FILESDIR}/sixad-FLAGS-1.4.96.patch"
	epatch "${FILESDIR}/sixad-users-group-1.4.96.patch"
}

src_compile() {
	emake -C utils
	emake -C sixad
	use qt && \
		emake -C qtsixa
}

src_install() {
	cd utils
	emake DESTDIR="${D}" install
	cd "${S}"

	cd sixad
	emake DESTDIR="${D}" install
	emake DESTDIR="${D}" install-system
	cd "${S}"
	if ! use hal; then
		rm -rv $D/usr/share/hal/
	fi
	if use qt; then
		cd qtsixa
		emake DESTDIR="${D}" install
		cd "${S}"
	fi
	if ! use doc; then
		rm -rv $D/usr/share/doc/
	fi
}

# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit eutils

MY_P="QtSixA-${PV}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="Sixaxis Joystick Manager"
HOMEPAGE="http://qtsixa.sourceforge.net/"
SRC_URI="http://sourceforge.net/projects/qtsixa/files/${MY_P/-/%20}/${MY_P}-src.tar.gz"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64"
IUSE="jack qt4"

DEPEND="virtual/libusb:1
	>=net-wireless/bluez-4.96
	dev-lang/python:2.7
	jack? ( media-sound/jack-audio-connection-kit )
	qt4? ( dev-python/PyQt4 )"

RDEPEND="${DEPEND}
	dev-python/dbus-python
	qt4? (
		net-wireless/bluez-hcidump
		x11-libs/libnotify
		x11-misc/xdg-utils
	)"

src_prepare() {
	epatch "${FILESDIR}/sixad-${PV}-shared.h.patch"

	for i in "${S}/qtsixa/qtsixa" "${S}/sixad/sixad-dbus-blocker" `find ${S}/qtsixa/gui -name "*.py"`; do
		einfo "Fixing python version for ${i}"
		sed -i 	-e 's/python/python2/g' "${i}" || die "'sed' failed"
	done
}

src_compile() {
	use qt4 && emake -C qtsixa
	emake -C utils WANT_JACK=$(use jack && echo true)
	emake -C sixad
}

src_install() {
	use qt4 && emake -C qtsixa install DESTDIR="${D}"
	emake -C utils install DESTDIR="${D}" WANT_JACK=$(use jack && echo true)
	emake -C sixad install DESTDIR="${D}"

	dodoc INSTALL manual.pdf README TODO
	rm "${D}etc/init.d/sixad" || die # TODO: Write a Gentoo version.
}

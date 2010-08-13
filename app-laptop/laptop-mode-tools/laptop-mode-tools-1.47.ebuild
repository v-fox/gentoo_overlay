# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-laptop/laptop-mode-tools/laptop-mode-tools-1.34.ebuild,v 1.2 2008/06/03 22:45:17 darkside Exp $

inherit eutils

MY_P="${PN}_${PV}"

DESCRIPTION="Linux kernel laptop_mode user-space utilities"
HOMEPAGE="http://www.samwel.tk/laptop_mode/"
SRC_URI="http://www.samwel.tk/laptop_mode/tools/downloads/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

IUSE="acpi apm pmu bluetooth hal scsi"

DEPEND="sys-apps/ethtool
		acpi? ( sys-power/acpid )
		apm? ( sys-apps/apmd )
		pmu? ( sys-power/pm-utils )
		bluetooth? (
			|| (
				net-wireless/bluez
				net-wireless/bluez-utils
			)
		)
		hal? ( sys-apps/hal )
		scsi? ( sys-apps/sdparm )"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-install.patch"
}

src_compile() {
	:
}

src_install() {
	DESTDIR="${D}" \
		MAN_D="/usr/share/man" \
		INIT_D="none" \
		APM="$(use apm && echo force || echo disabled)" \
		ACPI="$(use acpi && echo force || echo disabled)" \
		PMU="$(false && echo force || echo disabled)" \
		./install.sh

	dodoc Documentation/laptop-mode.txt README
	newinitd "${FILESDIR}"/laptop_mode.init-1.4 laptop_mode
}

pkg_postinst() {
	if ! use acpi && ! use apm; then
		ewarn
		ewarn "Without USE=\"acpi\" or USE=\"apm\" ${PN} can not"
		ewarn "automatically disable laptop_mode on low battery."
		ewarn
		ewarn "This means you can lose up to 10 minutes of work if running"
		ewarn "out of battery while laptop_mode is enabled."
		ewarn
		ewarn "Please see /usr/share/doc/${PF}/laptop-mode.txt.gz for further"
		ewarn "information."
		ewarn
	fi
}

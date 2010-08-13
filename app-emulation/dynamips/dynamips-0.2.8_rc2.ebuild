# 
# Distributed under the terms of the GNU General Public License v2
# $Header: Exp $

inherit eutils
inherit flag-o-matic

# Custom has to be set because dynamips-0.2.8-rc2 is not proper Portage syntax
CUSTOM_P="dynamips-0.2.8-RC2"

DESCRIPTION="dynamips a Cisco 7200/3600 Simulator"
HOMEPAGE="http://www.ipflow.utc.fr/index.php/Cisco_7200_Simulator"
SRC_URI="http://www.ipflow.utc.fr/dynamips/${CUSTOM_P}.tar.gz"
S="${WORKDIR}/${CUSTOM_P}"

LICENSE="GPL-2"
SLOT=0
KEYWORDS="~x86 ~amd64"
IUSE=""
MAKEOPTS=""
DEPEND="net-libs/libpcap
	|| ( dev-libs/libelf dev-libs/elfutils )"
QA_EXECSTACK="usr/sbin/dynamips"

src_unpack() {
	unpack ${A} 
	cd ${S}
	sed -i -e 's:PCAP_LIB=\/:#PCAP:g' Makefile || die
	sed -i -e 's:#PCAP_LIB=-lpcap:PCAP_LIB=-lpcap:g' Makefile || die
	if use amd64; then
		sed -i -e 's:DYNAMIPS_ARCH?=x86:DYNAMIPS_ARCH?=amd64:g' Makefile || die
	fi
}

src_compile() {
	cd ${S}
	emake || die "emake ${P} failed"
}

src_install () {
	dobin nvram_export dynamips || die
	doman dynamips.1 hypervisor_mode.7 nvram_export.1 
	dodoc COPYING ChangeLog TODO README README.hypervisor
}

pkg_postinst(){
		einfo "Please enjoy Cisco 7200 Simulator and "
	    einfo "always obtain IOS from Cisco web site."
}


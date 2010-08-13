# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-boot/grub/grub-9999.ebuild,v 1.9 2009/05/15 03:42:21 vapier Exp $

inherit autotools mount-boot eutils flag-o-matic toolchain-funcs

EAPI=2
if [[ ${PV} == "9999" ]] ; then
	ESVN_REPO_URI="svn://svn.sv.gnu.org/grub/trunk/grub2"
	inherit subversion
	SRC_URI=""
else
	SRC_URI="mirror://gentoo/${P}-${PR}.tar.lzma
		http://grub.gibibit.com/files/overlay_2009-01-19.tar.gz -> grub_overlay_2009-01-19.tar.gz
		http://non7top.googlecode.com/files/gentoo.tar.bz2 -> grub_gentoo-theme.tar.bz2"
	S="${WORKDIR}/${P}-${PR}"
fi

DESCRIPTION="GNU GRUB 2 boot loader"
HOMEPAGE="http://www.gnu.org/software/grub/"

LICENSE="GPL-3"
use multislot && SLOT="2" || SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="custom-cflags static debug"

RDEPEND=">=sys-libs/ncurses-5.2-r5
	dev-libs/lzo"
DEPEND="${RDEPEND}
	dev-lang/ruby
	media-fonts/unifont"
PROVIDE="virtual/bootloader"

export STRIP_MASK="*/grub/*/*.mod"
QA_EXECSTACK="sbin/grub-probe sbin/grub-setup"

src_setup() {
	use custom-cflags || unset CFLAGS CPPFLAGS LDFLAGS
	use static && append-ldflags -static
}

src_unpack() {
	if [[ ${PV} == "9999" ]] ; then
		subversion_src_unpack
	else
		unpack ${A}
		mv "${WORKDIR}"/gentoo "${WORKDIR}"/overlay_2009-01-19/boot/grub/themes/ || die
	fi
}

src_prepare() {
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.96-genkernel.patch #256335

	# epic gfxmenu, at last
	epatch "${FILESDIR}"/gfxmenu_2009-06-15.patch

	sed -i 's:-Werror::' conf/*.rmk || die #269887

	# autogen.sh does more than just run autotools
	sed -i -e 's:^auto:eauto:' autogen.sh
	(. ./autogen.sh) || die
}

src_configure() {
	local grub_opts="--enable-grub-mkfont --enable-grub-pe2elf"

	use amd64 && grub_opts="$grub_opts --enable-efiemu"

	if use debug; then
		grub_opts="${grub_opts} --enable-mm-debug --enable-grub-emu-usb --enable-grub-fstest"
	fi

	econf \
		--sbindir=/sbin \
		--bindir=/bin \
		--libdir=/$(get_libdir) \
		${grub_opts} || die "econf failed"
}

src_compile() {
	emake -j1 || die "making regular stuff"
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO
	cat <<-EOF >> "${D}"/lib*/grub/grub-mkconfig_lib
	GRUB_DISTRIBUTOR="Gentoo"
	EOF

	sed -i s:grub-install:grub2-install: "${D}"/sbin/grub-install
	mv "${D}"/sbin/grub{,2}-install || die
	mv "${D}"/usr/share/man/man8/grub{,2}-install.8 || die

	if [[ ! -d "${ROOT}"boot/${PN}/themes ]]; then
		einfo "Installing graphical themes"
		insinto "${ROOT}"boot/${PN}
		doins -r "${WORKDIR}"/overlay_2009-01-19/boot/grub/*
	fi
}

setup_boot_dir() {
	local boot_dir=$1
	local dir=${boot_dir}/grub

	if [[ ! -e ${dir}/unifont.pf2 ]]; then
		einfo "Making up unifont for gfxmenu"
		hex2bdf < /usr/share/unifont/unifont.hex > /tmp/unifont.bdf
		grub-mkfont --output="${dir}/unifont.pf2" /tmp/unifont.bdf
		rm /tmp/unifont.bdf
	fi

	if [[ ! -e ${dir}/grub.cfg ]]; then
		einfo "Running: grub-mkconfig -o ${dir}/grub.cfg"
		grub-mkconfig -o "${dir}/grub.cfg"
	fi
}

pkg_postinst() {
	elog "grub2 install binary is named grub2-install."

	setup_boot_dir "${ROOT}"boot
}

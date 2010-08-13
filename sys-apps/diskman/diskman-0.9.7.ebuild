# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit kde

DESCRIPTION="partitioning tool for KDE based on parted"
HOMEPAGE="http://www.kde-apps.org/content/show.php/Disk+Manager?content=70149"
SRC_URI="http://www.darkstarlinux.ro/files/diskman-0.9.7.tar.bz2"
LICENSE="GPL"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="jfs ntfs reiserfs xfs arts"

DEPEND="
	sys-apps/hwinfo
	>=sys-apps/parted-1.6.7
	>=sys-fs/e2fsprogs-1.33
	jfs? ( >=sys-fs/jfsutils-1.1.2 )
	ntfs? ( >=sys-fs/ntfsprogs-1.7.1 )
	reiserfs? ( sys-fs/progsreiserfs )
	xfs? ( >=sys-fs/xfsprogs-2.3.9 )"
need-kde 3.5

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/alice_xhelper.patch
	epatch ${FILESDIR}/diskman-gcc43.patch
	epatch ${FILESDIR}/diskman-fix-realpath.patch
}
src_compile() {
	econf $(use_with arts)
	make || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}

# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-emulation/fceultra/fceultra-0.98.12.ebuild,v 1.7 2007/08/13 16:52:11 mr_bones_ Exp $

inherit autotools eutils games

DESCRIPTION="A portable NES/Famicom emulator"
HOMEPAGE="http://fceultra.sourceforge.net"
SRC_URI="http://downloads.sourceforge.net/fceultra/fceu-${PV}-src.7z"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~ppc x86"
IUSE="opengl"

RDEPEND=">=media-libs/libsdl-1.2.0
	opengl? ( virtual/opengl )
	sys-libs/zlib"
# Because of code generation bugs, FCEUltra now depends on a version
# of gcc greater than or equal to GCC 3.2.2.
DEPEND="${RDEPEND}
	>=sys-devel/gcc-3.2.2
	>=app-arch/p7zip-4.0"

S="${WORKDIR}/fceu-${PV}-src"

src_unpack() {
	unpack ${A}
	cd "${S}"
	chmod a-x Documentation/tech/exp/*
	chmod +x configure
	rm missing
	eautoreconf
}

src_compile() {
	egamesconf \
		--disable-dependency-tracking \
		$(use_with opengl) || die
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
	dodoc Documentation/*.txt AUTHORS README NEWS TODO ChangeLog
	cp -r Documentation/tech "${D}/usr/share/doc/${PF}/" || die "cp failed"
	prepalldocs
	dohtml Documentation/*
	prepgamesdirs
}

# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: 
inherit autotools eutils games

DESCRIPTION="Reincarnation of FCEUltra"
HOMEPAGE="http://fceux.com"
SRC_URI="http://prdownloads.sourceforge.net/fceultra/${P}.src.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~ppc x86"
IUSE="doc debug opengl gnome gtk"

RDEPEND=">=media-libs/libsdl-1.2.0
	gnome? ( gnome-extra/zenity )
	gtk? ( dev-lang/python
		dev-python/pygtk )
	opengl? ( virtual/opengl )
	dev-lang/lua
	sys-libs/zlib
	x11-libs/libX11"
DEPEND="${RDEPEND}
	dev-util/scons
	>=sys-devel/gcc-3.2.2
	>=app-arch/p7zip-4.0
	!games-emulation/fceultra"

S="${WORKDIR}/fceu"

src_unpack() {
	unpack ${A}
	cd "${S}"
	# WTF are they thinking ?!
	sed -i 	-e "s:raw_input:#:" \
		-e "s:/usr/local/bin/:${GAMES_BINDIR}:g" SConstruct || die
}

src_compile() {
	scons $(use debug && echo "debug=1") \
		${MAKEOPTS/-j/-j } || die
}

src_install() {
	dogamesbin "bin/fceux" || die "dogamesbin bin/fceux failed"
	dodoc AUTHORS README NEWS TODO ChangeLog
	if use doc; then
		cd documentation
		dodoc*.txt faq todo
		cp -r tech "${D}/usr/share/doc/${PF}/" || die "cp failed"
		cd ${S}
	fi
	prepalldocs
	dohtml Documentation/*
	prepgamesdirs

	if use gtk; then
		cd ../g${PN}
		./setup.py install --prefix="${D}${GAMES_PREFIX}" || die
	fi
}

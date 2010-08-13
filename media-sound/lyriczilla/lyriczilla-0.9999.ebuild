# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit subversion autotools

DESCRIPTION="Lyrics plugin for audacious, amarok, banshee, listen and rhythmbox"
HOMEPAGE="http://code.google.com/p/lyriczilla"
SRC_URI=""
ESVN_REPO_URI="http://lyriczilla.googlecode.com/svn/trunk"
ESVN_PROJECT="lyriczilla-read-only"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=""
RDEPEND="|| ( media-sound/audacious
	      media-sound/amarok
	      media-sound/banshee
	      media-sound/listen
	      media-sound/rhythmbox
	    )
	>=dev-lang/python-2.5
	dev-python/dbus-python"

S="${WORKDIR}/${PN}-read-only"

src_unpack() {
	subversion_src_unpack || die
	cd ${S}
	eautoreconf
}

src_compile() {
	econf || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
}

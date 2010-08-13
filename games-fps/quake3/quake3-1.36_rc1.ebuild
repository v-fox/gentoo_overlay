# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-fps/quake3/quake3-1.34_rc3.ebuild,v 1.8 2008/01/12 02:53:11 mr_bones_ Exp $

inherit flag-o-matic toolchain-funcs eutils games

MY_PV="1.36_SVN1496M"
MY_P=io${PN}-${MY_PV}
SRC_URI="http://ioquake3.org/files/${MY_P}.tar.bz2"
S=${WORKDIR}/${MY_P}

DESCRIPTION="Quake III Arena - 3rd installment of the classic id 3D first-person shooter"
HOMEPAGE="http://ioquake3.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86 ~x86-fbsd"
IUSE="curl dedicated openal opengl smp teamarena vorbis"

UIDEPEND="virtual/opengl
	media-libs/openal
	vorbis? ( media-libs/libogg media-libs/libvorbis )
	media-libs/libsdl"
DEPEND="opengl? ( ${UIDEPEND} )
	!dedicated? ( ${UIDEPEND} )"
RDEPEND="${DEPEND}
	games-fps/quake3-data
	teamarena? ( games-fps/quake3-teamarena )
	curl? ( net-misc/curl )"

src_compile() {
	filter-flags -mfpmath=sse
	buildit() { use $1 && echo 1 || echo 0 ; }
	emake \
		BUILD_SERVER=$(buildit dedicated) \
		BUILD_CLIENT=$(( $(buildit opengl) | $(buildit !dedicated) )) \
		BUILD_CLIENT_SMP=$(buildit smp) \
		USE_OPENAL=$(buildit openal) \
		USE_CURL=$(buildit curl) \
		USE_CODEC_VORBIS=$(buildit vorbis) \
		TEMPDIR="${T}" \
		CC="$(tc-getCC)" \
		ARCH=$(tc-arch-kernel) \
		OPTIMIZE="${CFLAGS}" \
		DEFAULT_BASEDIR="${GAMES_DATADIR}/quake3" \
		DEFAULT_LIBDIR="$(games_get_libdir)/quake3" \
		|| die
}

src_install() {
	dodoc TODO README BUGS ChangeLog

	if use opengl ; then
	doicon quake3.png
		if use smp; then
			make_desktop_entry quake3-smp "Quake III Arena (SMP)"
		else
		make_desktop_entry quake3 "Quake III Arena"
		fi
	fi

	cd build/release*
	local old_x x
	for old_x in ioq* ; do
		x=${old_x%.*}
		newgamesbin ${old_x} ${x} || die "newgamesbin ${x}"
		dosym ${x} "${GAMES_BINDIR}"/${x/io}
	done
	exeinto "$(games_get_libdir)"/${PN}/baseq3
	doexe baseq3/*.so || die "baseq3 .so"
	exeinto "$(games_get_libdir)"/${PN}/missionpack
	doexe missionpack/*.so || die "missionpack .so"

	prepgamesdirs
}

pkg_postinst() {
	games_pkg_postinst
	ewarn "The source version of Quake 3 will not work with Punk Buster."
	ewarn "If you need pb support, then use the quake3-bin package."
	echo
}

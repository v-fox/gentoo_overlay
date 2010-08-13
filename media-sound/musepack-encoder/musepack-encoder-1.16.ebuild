# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/musepack-tools/musepack-tools-1.15v.ebuild,v 1.9 2006/06/09 02:36:36 metalgod Exp $

IUSE="static 16bit esd"

inherit eutils flag-o-matic flag-o-matic

S="${WORKDIR}/mppenc-${PV}"

DESCRIPTION="Musepack audio encoder"
HOMEPAGE="http://www.musepack.net"
SRC_URI="http://files.musepack.net/source/mppenc-${PV}.tar.bz2"

SLOT="0"
LICENSE="LGPL-2.1"
KEYWORDS="amd64 x86 ~x86-fbsd"

RDEPEND="esd? ( media-sound/esound )
	 media-libs/id3lib"

DEPEND="${RDEPEND}
	x86? ( dev-lang/nasm )
	x86-fbsd? ( dev-lang/nasm )
	amd64? ( dev-lang/nasm )
	>=dev-util/cmake-2.2.0"

src_unpack() {
	unpack ${A}
	cd "${S}"
	
	cmake . || die

	# patches are relative to source and already existed
	cd "${S}/src"

	sed -i 's/#define USE_IRIX_AUDIO/#undef USE_IRIX_AUDIO/' mpp.h

	if use esd; then
		sed -i -e 's^//#define USE_ESD_AUDIO^#define USE_ESD_AUDIO^' mpp.h
	fi
	
	if [[ $(tc-arch) != "x86" ]] ; then
		sed -i 's/#define USE_ASM/#undef USE_ASM/' mpp.h
	fi

	use 16bit && sed -i 's|//#define MAKE_16BIT|#define MAKE_16BIT|' mpp.h

	cd "${S}"
}

src_compile() {
	filter-flags "-fprefetch-loop-arrays"
	filter-flags "-mfpmath=sse" "-mfpmath=sse,387"
	use static && export BLD_STATIC=1

	append-flags -I${S}
	
	emake || die
}

src_install() {
	dodoc Changelog
	DESTDIR="${D}" make install || die
}

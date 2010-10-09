# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI=2
inherit cmake-utils eutils toolchain-funcs

MY_P=${PN}-soft-${PV}

DESCRIPTION="A software implementation of the OpenAL 3D audio API"
HOMEPAGE="http://kcat.strangesoft.net/openal.html"
SRC_URI="http://kcat.strangesoft.net/openal-releases/${MY_P}.tar.bz2"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 ~arm hppa ~ia64 ~mips ~ppc ppc64 ~sparc x86 ~x86-fbsd"
IUSE="alsa debug oss portaudio pulseaudio"

RDEPEND="alsa? ( media-libs/alsa-lib )
	portaudio? ( >=media-libs/portaudio-19_pre )
	pulseaudio? ( media-sound/pulseaudio )"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}
DOCS="alsoftrc.sample"
PATCHES=""

switch_to32() {
	cd "${WORKDIR}"
	einfo "switching sources to 32-bit building environment"
	for i in '' _build;do

		mv "${MY_P}${i}" "${MY_P}${i}_64"
		mv "${MY_P}${i}_32" "${MY_P}${i}"
	done
}

switch_to64() {
	cd "${WORKDIR}"
	einfo "switching sources to 64-bit building environment"
	for i in '' _build;do
		mv "${MY_P}${i}" "${MY_P}${i}_32"
		mv "${MY_P}${i}_64" "${MY_P}${i}"
	done
}

patching() {
	if [ -z $PATCHES ]; then
		einfo "Nothing to patch, skipping patching..."
		else
		for i in $PATCHES; do
			epatch "${i}"
		done
	fi
}

src_unpack() {
	unpack "${A}"

	if use multilib; then
		cd "${WORKDIR}"
		mv "${MY_P}${i}" "${MY_P}${i}_32"
		unpack "${A}"
	fi
}

src_prepare() {
	cd "${S}"
	patching

	if use multilib; then
		cd "${WORKDIR}/${MY_P}_32"
		patching
	fi
}

src_configure() {
	local mycmakeargs="$(cmake-utils_use alsa ALSA)
		$(cmake-utils_use oss OSS)
		$(cmake-utils_use portaudio PORTAUDIO)
		$(cmake-utils_use pulseaudio PULSEAUDIO)"

	use debug && mycmakeargs+=" -DCMAKE_BUILD_TYPE=Debug"

	cmake-utils_src_configure

	if use multilib; then
		switch_to32
		multilib_toolchain_setup x86
		cmake-utils_src_configure
		multilib_toolchain_setup amd64
		switch_to64
	fi
}

src_compile() {
	cmake-utils_src_compile

	if use multilib; then
		switch_to32
		multilib_toolchain_setup x86
		cmake-utils_src_compile
		multilib_toolchain_setup amd64
		switch_to64
	fi
}

src_install() {
	cmake-utils_src_install

	if use multilib; then
		switch_to32
		multilib_toolchain_setup x86
		cd "${S}"
		cmake-utils_src_install
		multilib_toolchain_setup amd64
		switch_to64
	fi
}

pkg_postinst() {
	elog "If you have performance problems using this library, then"
	elog "try add these lines to your ~/.alsoftrc config file:"
	elog "[alsa]"
	elog "mmap = off"
}

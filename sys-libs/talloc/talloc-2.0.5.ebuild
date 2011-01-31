# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/talloc/talloc-2.0.1-r1.ebuild,v 1.7 2010/08/12 01:24:10 josejx Exp $

EAPI="3"

inherit waf-utils

DESCRIPTION="Samba talloc library"
HOMEPAGE="http://talloc.samba.org/"
SRC_URI="http://samba.org/ftp/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="compat python"

RDEPEND=""
DEPEND="dev-libs/libxslt"

WAF_BINARY="${S}/buildtools/bin/waf"

src_unpack() {
        unpack "${A}"
        cd "${S}"

        if use multilib; then
                cd "${WORKDIR}"
                mkdir 32
                mv "${P}" 32/ || die
                cd "${WORKDIR}"
                unpack "${A}"
        fi
}

src_configure() {
	local extra_opts=""
	use compat && extra_opts+=" --enable-talloc-compat1"
	use python || extra_opts+=" --disable-python"

        if use multilib; then
                multilib_toolchain_setup x86
                cd "${WORKDIR}/32/${P}"
		WAF_BINARY="${WORKDIR}/32/${P}/buildtools/bin/waf"
		waf-utils_src_configure ${extra_opts}
	        multilib_toolchain_setup amd64
                cd "${S}"
        fi

	WAF_BINARY="${S}/buildtools/bin/waf"
	waf-utils_src_configure ${extra_opts}
}

src_compile() {
        if use multilib; then
                multilib_toolchain_setup x86
                cd "${WORKDIR}/32/${P}"
                emake || die "32 bit emake shared-build failed"
                multilib_toolchain_setup amd64
		cd "${S}"
        fi

	emake || die "emake shared-build failed"
}

src_install() {
        if use multilib; then
                cd "${WORKDIR}/32/${P}"
                multilib_toolchain_setup x86
		emake DESTDIR="${D}" install || die "32 bit emake install failed"
                multilib_toolchain_setup amd64
                cd "${S}"
	fi

	emake DESTDIR="${D}" install || die "emake install failed"
}

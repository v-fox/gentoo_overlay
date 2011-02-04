# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/talloc/talloc-2.0.1-r1.ebuild,v 1.7 2010/08/12 01:24:10 josejx Exp $

EAPI="3"

inherit eutils autotools

DESCRIPTION="Samba talloc library"
HOMEPAGE="http://talloc.samba.org/"
SRC_URI="http://samba.org/ftp/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 s390 sh sparc x86"
IUSE="compat doc static-libs swig"

RDEPEND=""
DEPEND="doc? ( app-text/docbook-xml-dtd:4.2
		dev-libs/libxslt )
	swig? ( dev-lang/swig )
	!<net-fs/samba-libs-3.4
	!<net-fs/samba-3.3"

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

src_prepare() {
        cd "${S}"
        if use multilib; then
                cd "${WORKDIR}"/32/${P} || die
		epatch "${FILESDIR}/${PN}-2.0.0-without-doc.patch"
		epatch "${FILESDIR}/${P}-respect-ldflags.patch"
		eautoconf -Ilibreplace
		sed -i \
			-e 's:$(SHLD_FLAGS) :$(SHLD_FLAGS) $(LDFLAGS) :' \
			Makefile.in
		cd "${S}"
	fi

	epatch "${FILESDIR}/${PN}-2.0.0-without-doc.patch"
	epatch "${FILESDIR}/${P}-respect-ldflags.patch"
	eautoconf -Ilibreplace
	sed -i \
		-e 's:$(SHLD_FLAGS) :$(SHLD_FLAGS) $(LDFLAGS) :' \
		Makefile.in
}

src_configure() {
        if use multilib; then
                multilib_toolchain_setup x86
                cd "${WORKDIR}/32/${P}"
		if ! use swig ; then
			sed -i \
				-e '/swig/d' \
				talloc.mk || die "sed failed"
		fi
		if ! use static-libs ; then
			sed -i \
				-e 's|:: $(TALLOC_STLIB)|::|' \
				-e '/$(TALLOC_STLIB) /d' \
				-e '/libtalloc.a/d' \
				talloc.mk Makefile.in || die "sed failed"
		fi
		econf \
			--sysconfdir=/etc/samba \
			--localstatedir=/var \
			$(use_enable compat talloc-compat1) \
			$(use_with doc)
	        multilib_toolchain_setup amd64
                cd "${S}"
        fi

        if ! use swig ; then
                sed -i \
                        -e '/swig/d' \
                        talloc.mk || die "sed failed"
        fi

        if ! use static-libs ; then
                sed -i \
                        -e 's|:: $(TALLOC_STLIB)|::|' \
                        -e '/$(TALLOC_STLIB) /d' \
                        -e '/libtalloc.a/d' \
                        talloc.mk Makefile.in || die "sed failed"
        fi

        econf \
                --sysconfdir=/etc/samba \
                --localstatedir=/var \
                $(use_enable compat talloc-compat1) \
                $(use_with doc)
}

src_compile() {
        if use multilib; then
                multilib_toolchain_setup x86
                cd "${WORKDIR}/32/${P}"
                emake shared-build || die "32 bit emake shared-build failed"
                multilib_toolchain_setup amd64
		cd "${S}"
        fi

	emake shared-build || die "emake shared-build failed"
}

src_install() {
        if use multilib; then
                cd "${WORKDIR}/32/${P}"
                multilib_toolchain_setup x86
		emake DESTDIR="${D}" install || die "32 bit emake install failed"
		dolib.so sharedbuild/lib/libtalloc.so
                multilib_toolchain_setup amd64
                cd "${S}"
	fi

	emake DESTDIR="${D}" install || die "emake install failed"

	use doc && dohtml *.html

	# installs missing symlink
	dolib.so sharedbuild/lib/libtalloc.so
}

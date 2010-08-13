# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils/binutils-2.20.ebuild,v 1.1 2009/10/19 07:33:19 vapier Exp $

PATCHVER="1.0"
ELF2FLT_VER=""
inherit toolchain-binutils

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"

toolchain-binutils_src_compile() {
        # prevent makeinfo from running in releases.  it may not always be
        # installed, and older binutils may fail with newer texinfo.
        # besides, we never patch the doc files anyways, so regenerating
        # in the first place is useless. #193364
        find . '(' -name '*.info' -o -name '*.texi' ')' -print0 | xargs -0 touch -r .

        # make sure we filter $LINGUAS so that only ones that
        # actually work make it through #42033
        strip-linguas -u */po

        # keep things sane
        strip-flags

        local x
        echo
        for x in CATEGORY CBUILD CHOST CTARGET CFLAGS LDFLAGS ; do
                einfo "$(printf '%10s' ${x}:) ${!x}"
        done
        echo

        cd "${MY_BUILDDIR}"
        local myconf="--enable-plugins"
        use nls \
                && myconf="${myconf} --without-included-gettext" \
                || myconf="${myconf} --disable-nls"
        use multitarget && myconf="${myconf} --enable-targets=all"
        [[ -n ${CBUILD} ]] && myconf="${myconf} --build=${CBUILD}"
        is_cross && myconf="${myconf} --with-sysroot=/usr/${CTARGET}"
        # glibc-2.3.6 lacks support for this ... so rather than force glibc-2.5+
        # on everyone in alpha (for now), we'll just enable it when possible
        has_version ">=${CATEGORY}/glibc-2.5" && myconf="${myconf} --enable-secureplt"
        has_version ">=sys-libs/glibc-2.5" && myconf="${myconf} --enable-secureplt"
        myconf="--prefix=/usr \
                --host=${CHOST} \
                --target=${CTARGET} \
                --datadir=${DATAPATH} \
                --infodir=${DATAPATH}/info \
                --mandir=${DATAPATH}/man \
                --bindir=${BINPATH} \
                --libdir=${LIBPATH} \
                --libexecdir=${LIBPATH} \
                --includedir=${INCPATH} \
                --enable-64-bit-bfd \
                --enable-shared \
                --disable-werror \
                $(use_enable gold) \
                ${myconf} ${EXTRA_ECONF}"
        echo ./configure ${myconf}
        "${S}"/configure ${myconf} || die "configure failed"

        emake all || die "emake failed"

        # only build info pages if we user wants them, and if
        # we have makeinfo (may not exist when we bootstrap)
        if ! has noinfo ${FEATURES} ; then
                if type -p makeinfo > /dev/null ; then
                        make info || die "make info failed"
                fi
        fi
        # we nuke the manpages when we're left with junk
        # (like when we bootstrap, no perl -> no manpages)
        find . -name '*.1' -a -size 0 | xargs rm -f

        # elf2flt only works on some arches / targets
        if [[ -n ${ELF2FLT_VER} ]] && [[ ${CTARGET} == *linux* || ${CTARGET} == *-elf* ]] ; then
                cd "${WORKDIR}"/elf2flt-${ELF2FLT_VER}

                local x supported_arches=$(sed -n '/defined(TARGET_/{s:^.*TARGET_::;s:)::;p}' elf2flt.c | sort -u)
                for x in ${supported_arches} UNSUPPORTED ; do
                        [[ ${CTARGET} == ${x}* ]] && break
                done

                if [[ ${x} != "UNSUPPORTED" ]] ; then
                        append-flags -I"${S}"/include
                        myconf="--with-bfd-include-dir=${MY_BUILDDIR}/bfd \
                                --with-libbfd=${MY_BUILDDIR}/bfd/libbfd.a \
                                --with-libiberty=${MY_BUILDDIR}/libiberty/libiberty.a \
                                --with-binutils-ldscript-dir=${LIBPATH}/ldscripts \
                                ${myconf}"
                        echo ./configure ${myconf}
                        ./configure ${myconf} || die "configure elf2flt failed"
                        emake || die "make elf2flt failed"
                fi
        fi
}

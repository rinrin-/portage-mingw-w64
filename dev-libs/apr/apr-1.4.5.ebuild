# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/apr/apr-1.4.5.ebuild,v 1.8 2011/11/11 19:17:50 hwoarang Exp $

EAPI="4"

inherit autotools eutils libtool multilib

DESCRIPTION="Apache Portable Runtime Library"
HOMEPAGE="http://apr.apache.org/"
SRC_URI="mirror://apache/apr/${P}.tar.bz2"

LICENSE="Apache-2.0"
SLOT="1"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="doc elibc_FreeBSD older-kernels-compatibility static-libs urandom uuid"

RDEPEND="uuid? ( !elibc_FreeBSD? ( >=sys-apps/util-linux-2.16 ) )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

DOCS=(CHANGES NOTICE README)

# testmmap fail caused by APR_EOL_STR
# testtime fail with testall -v testtime
RESTRICT="test"

src_prepare() {
	# Ensure that system libtool is used.
	#sed -e 's:${installbuilddir}/libtool:/usr/bin/libtool:' -i apr-config.in || die "sed failed"
	#sed -e 's:@LIBTOOL@:$(SHELL) /usr/bin/libtool:' -i build/apr_rules.mk.in || die "sed failed"

    epatch "${FILESDIR}/${P}-mingw64-size_t.patch"
    epatch "${FILESDIR}/${P}-mingw64-wtypes.patch"
    epatch "${FILESDIR}/${P}-mingw64-strtoi64.patch"
    epatch "${FILESDIR}/${P}-mingw-no-undefined.patch"
    _elibtoolize --copy --force --install
	AT_M4DIR="build" eautoreconf

	epatch "${FILESDIR}/config.layout.patch"
}

src_configure() {
	local myconf

	if use older-kernels-compatibility; then
		local apr_cv_accept4 apr_cv_dup3 apr_cv_epoll_create1 apr_cv_sock_cloexec
		export apr_cv_accept4="no"
		export apr_cv_dup3="no"
		export apr_cv_epoll_create1="no"
		export apr_cv_sock_cloexec="no"
	fi

	if use urandom; then
		myconf+=" --with-devrandom=/dev/urandom"
	#else
	#	myconf+=" --with-devrandom=/dev/random"
	fi

	if ! use uuid; then
		local apr_cv_osuuid
		export apr_cv_osuuid="no"
	fi

	econf \
	    --enable-threads \
		--enable-layout=gentoo \
		--enable-nonportable-atomics \
		${myconf}
		

	#rm -f libtool
}

src_compile() {
	emake

	if use doc; then
		emake dox
	fi
}

src_install() {
	default

	find "${ED}" -name "*.la" -exec rm -f {} +

	if use doc; then
		dohtml -r docs/dox/html/*
	fi

	if ! use static-libs; then
		find "${ED}" -name \*[^dll].a -exec rm -f {} +
	fi

	# This file is only used on AIX systems, which Gentoo is not,
	# and causes collisions between the SLOTs, so remove it.
	rm -f "${ED}usr/$(get_libdir)/apr.exp"
}

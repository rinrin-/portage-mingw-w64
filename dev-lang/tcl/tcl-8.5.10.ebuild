# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/tcl/tcl-8.5.10.ebuild,v 1.3 2012/01/04 20:44:37 ranger Exp $

EAPI="3"

inherit autotools eutils flag-o-matic multilib toolchain-funcs

MY_P="${PN}${PV/_beta/b}"

DESCRIPTION="Tool Command Language"
HOMEPAGE="http://www.tcl.tk/"
SRC_URI="mirror://sourceforge/tcl/${MY_P}-src.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x86-solaris"
IUSE="debug threads"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	if use threads ; then
		ewarn ""
		ewarn "PLEASE NOTE: You are compiling ${P} with"
		ewarn "threading enabled."
		ewarn "Threading is not supported by all applications"
		ewarn "that compile against tcl. You use threading at"
		ewarn "your own discretion."
		ewarn ""
	fi
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-8.5_alpha6-multilib.patch

	# Bug 125971
	epatch "${FILESDIR}"/${PN}-8.5_alpha6-tclm4-soname.patch

	# Bug 354067
	epatch "${FILESDIR}"/${PN}-8.5.9-gentoo-fbsd.patch

    if [[ ${CHOST} == *-mingw* ]]; then
        epatch "${FILESDIR}"/${P}-mingw-proper-implibs-for-shared-build.patch
        epatch "${FILESDIR}"/${P}-mingw-fix-forbidden-colon-in-paths.patch
        epatch "${FILESDIR}"/${P}-mingw-install-man.patch
        epatch "${FILESDIR}"/${P}-mingw-multilib.patch
        cd "${S}"/win
        eautoreconf
    else
    	cd "${S}"/unix
	    eautoreconf
    fi
}

src_configure() {
	# workaround stack check issues, bug #280934
	if use hppa; then
		append-cflags "-DTCL_NO_STACK_CHECK=1"
	fi

	tc-export CC

    if [[ ${CHOST} == *-mingw* ]]; then
        cd "${S}"/win
    else
	    cd "${S}"/unix
	fi
	
	econf \
		$(use_enable threads) \
		$(use_enable debug symbols)
}

src_compile() {
    if [[ ${CHOST} == *-mingw* ]]; then
        cd "${S}"/win
    else
	    cd "${S}"/unix
	fi
	emake || die
}

src_test() {
    if [[ ${CHOST} == *-mingw* ]]; then
        cd "${S}"/win
        S= emake test || die
    else
	    cd "${S}"/unix
	    S= emake test || die
	fi
}

src_install() {
	#short version number
	local v1
	v1=${PV%.*}

    if [[ ${CHOST} == *-mingw* ]]; then
        cd "${S}"/win
        S= emake INSTALL_ROOT="${D}" install || die
    else
	    cd "${S}"/unix
	    S= emake DESTDIR="${D}" install || die
	fi

	# fix the tclConfig.sh to eliminate refs to the build directory
	local mylibdir=$(get_libdir) ; mylibdir=${mylibdir//\/}
	if [[ ${CHOST} == *-mingw* ]]; then
		    sed -i \
		    -e "s,^TCL_BUILD_LIB_SPEC='-L.*/win,TCL_BUILD_LIB_SPEC='-L${EPREFIX}/usr/${mylibdir}," \
		    -e "s,^TCL_SRC_DIR='.*',TCL_SRC_DIR='${EPREFIX}/usr/${mylibdir}/tcl${v1}/include'," \
		    -e "s,^TCL_BUILD_STUB_LIB_SPEC='-L.*/win,TCL_BUILD_STUB_LIB_SPEC='-L${EPREFIX}/usr/${mylibdir}," \
		    -e "s,^TCL_BUILD_STUB_LIB_PATH='.*/win,TCL_BUILD_STUB_LIB_PATH='${EPREFIX}/usr/${mylibdir}," \
		    -e "s,^TCL_LIB_FILE='libtcl${v1}..TCL_DBGX..so',TCL_LIB_FILE=\"libtcl${v1}\$\{TCL_DBGX\}.so\"," \
		    "${ED}"/usr/${mylibdir}/tclConfig.sh || die
	else
	    sed -i \
		    -e "s,^TCL_BUILD_LIB_SPEC='-L.*/unix,TCL_BUILD_LIB_SPEC='-L${EPREFIX}/usr/${mylibdir}," \
		    -e "s,^TCL_SRC_DIR='.*',TCL_SRC_DIR='${EPREFIX}/usr/${mylibdir}/tcl${v1}/include'," \
		    -e "s,^TCL_BUILD_STUB_LIB_SPEC='-L.*/unix,TCL_BUILD_STUB_LIB_SPEC='-L${EPREFIX}/usr/${mylibdir}," \
		    -e "s,^TCL_BUILD_STUB_LIB_PATH='.*/unix,TCL_BUILD_STUB_LIB_PATH='${EPREFIX}/usr/${mylibdir}," \
		    -e "s,^TCL_LIB_FILE='libtcl${v1}..TCL_DBGX..so',TCL_LIB_FILE=\"libtcl${v1}\$\{TCL_DBGX\}.so\"," \
		    "${ED}"/usr/${mylibdir}/tclConfig.sh || die
	fi
	[[ ${CHOST} != *-darwin* && ${CHOST} != *-mint* ]] && sed -i \
		-e "s,^TCL_CC_SEARCH_FLAGS='\(.*\)',TCL_CC_SEARCH_FLAGS='\1:${EPREFIX}/usr/${mylibdir}'," \
		-e "s,^TCL_LD_SEARCH_FLAGS='\(.*\)',TCL_LD_SEARCH_FLAGS='\1:${EPREFIX}/usr/${mylibdir}'," \
		"${ED}"/usr/${mylibdir}/tclConfig.sh

	# install private headers
	if [[ ${CHOST} == *-mingw* ]]; then
		insinto /usr/${mylibdir}/tcl${v1}/include/win
	    doins "${S}"/win/*.h || die
	    doins "${S}"/win/cat.c || die
	else
	    insinto /usr/${mylibdir}/tcl${v1}/include/unix
	    doins "${S}"/unix/*.h || die
	fi
	insinto /usr/${mylibdir}/tcl${v1}/include/generic
	doins "${S}"/generic/*.h || die
	rm -f "${ED}"/usr/${mylibdir}/tcl${v1}/include/generic/tcl.h
	rm -f "${ED}"/usr/${mylibdir}/tcl${v1}/include/generic/tclDecls.h
	rm -f "${ED}"/usr/${mylibdir}/tcl${v1}/include/generic/tclPlatDecls.h

	# install symlink for libraries
	if [[ ${CHOST} != *-mingw* ]]; then
	    dosym libtcl${v1}$(get_libname) /usr/${mylibdir}/libtcl$(get_libname) || die
	    dosym tclsh${v1} /usr/bin/tclsh || die
	fi
	dosym libtclstub${v1}.a /usr/${mylibdir}/libtclstub.a || die

	cd "${S}"
	dodoc ChangeLog* README changes || die
	
	mkdir -p ${D}etc/env.d
    echo "TCL_LIBRARY=${EPREFIX}/usr/$(get_libdir)/tcl${PV%.*}" >>"${D}etc/env.d/00tcl"
}

pkg_postinst() {
	ewarn
	ewarn "If you're upgrading from <dev-lang/tcl-8.5, you must recompile the other"
	ewarn "packages on your system that link with tcl after the upgrade"
	ewarn "completes.  To perform this action, please run revdep-rebuild"
	ewarn "in package app-portage/gentoolkit."
	ewarn "If you have dev-lang/tk and dev-tcltk/tclx installed you should"
	ewarn "upgrade them before this recompilation, too,"
	ewarn
}

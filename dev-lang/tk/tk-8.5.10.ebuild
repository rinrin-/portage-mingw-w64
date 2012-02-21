# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/tk/tk-8.5.10.ebuild,v 1.1 2011/10/04 17:08:05 jlec Exp $

EAPI="3"

inherit autotools eutils multilib toolchain-funcs prefix

MY_P="${PN}${PV/_beta/b}"

DESCRIPTION="Tk Widget Set"
HOMEPAGE="http://www.tcl.tk/"
SRC_URI="mirror://sourceforge/tcl/${MY_P}-src.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="debug threads truetype aqua xscreensaver"

RDEPEND="~dev-lang/tcl-${PV}"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-8.4.11-multilib.patch

	epatch "${FILESDIR}"/${PN}-8.4.15-aqua.patch
	eprefixify unix/Makefile.in

	# Bug 125971
	epatch "${FILESDIR}"/${PN}-8.5_alpha6-tclm4-soname.patch

    if [[ ${CHOST} == *-mingw* ]]; then
        epatch "${FILESDIR}"/${P}-mingw-proper-implibs-for-shared-build.patch
        epatch "${FILESDIR}"/${P}-mingw-fix-forbidden-colon-in-paths.patch
        epatch "${FILESDIR}"/${P}-mingw-install-man.patch
        epatch "${FILESDIR}"/${P}-mingw-tcl-library.patch
        epatch "${FILESDIR}"/${P}-mingw-multilib.patch
        cd "${S}"/win
        eautoreconf
    else
    	sed -i 's/FT_New_Face/XftFontOpen/g' unix/configure.in || die
	    cd "${S}"/unix
	    eautoreconf
    fi
}

src_configure() {
	tc-export CC
	
	if [[ ${CHOST} == *-mingw* ]]; then
        cd "${S}"/win
    else
	    cd "${S}"/unix
	fi

	local mylibdir=$(get_libdir) ; mylibdir=${mylibdir//\/}

	econf \
		--with-tcl="${EPREFIX}/usr/${mylibdir}" \
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

	# normalize $S path, bug #280766 (pkgcore)
	local nS="$(cd "${S}"; pwd)"

	# fix the tkConfig.sh to eliminate refs to the build directory
	local mylibdir=$(get_libdir) ; mylibdir=${mylibdir//\/}
	if [[ ${CHOST} == *-mingw* ]]; then
		    sed -i \
		    -e "s,^\(TK_BUILD_LIB_SPEC='-L\)${nS}/win,\1${EPREFIX}/usr/${mylibdir}," \
		    -e "s,^\(TK_SRC_DIR='\)${nS}',\1${EPREFIX}/usr/${mylibdir}/tk${v1}/include'," \
		    -e "s,^\(TK_BUILD_STUB_LIB_SPEC='-L\)${nS}/win,\1${EPREFIX}/usr/${mylibdir}," \
		    -e "s,^\(TK_BUILD_STUB_LIB_PATH='\)${nS}/win,\1${EPREFIX}/usr/${mylibdir}," \
		    "${D}${EPREFIX}"/usr/${mylibdir}/tkConfig.sh || die
	else
	    sed -i \
		    -e "s,^\(TK_BUILD_LIB_SPEC='-L\)${nS}/unix,\1${EPREFIX}/usr/${mylibdir}," \
		    -e "s,^\(TK_SRC_DIR='\)${nS}',\1${EPREFIX}/usr/${mylibdir}/tk${v1}/include'," \
		    -e "s,^\(TK_BUILD_STUB_LIB_SPEC='-L\)${nS}/unix,\1${EPREFIX}/usr/${mylibdir}," \
		    -e "s,^\(TK_BUILD_STUB_LIB_PATH='\)${nS}/unix,\1${EPREFIX}/usr/${mylibdir}," \
		    "${D}${EPREFIX}"/usr/${mylibdir}/tkConfig.sh || die
	fi

	if [[ ${CHOST} != *-darwin* ]]; then
		sed -i \
				-e "s,^\(TK_CC_SEARCH_FLAGS='.*\)',\1:${EPREFIX}/usr/${mylibdir}'," \
				-e "s,^\(TK_LD_SEARCH_FLAGS='.*\)',\1:${EPREFIX}/usr/${mylibdir}'," \
				"${D}${EPREFIX}"/usr/${mylibdir}/tkConfig.sh || die
	fi

	# install private headers
	if [[ ${CHOST} == *-mingw* ]]; then
		insinto ${EPREFIX}/usr/${mylibdir}/tk${v1}/include/win
	    doins "${S}"/win/*.h || die
	else
	    insinto ${EPREFIX}/usr/${mylibdir}/tk${v1}/include/unix
	    doins "${S}"/unix/*.h || die
	fi
	insinto ${EPREFIX}/usr/${mylibdir}/tk${v1}/include/generic
	doins "${S}"/generic/*.h || die
	rm -f "${D}${EPREFIX}"/usr/${mylibdir}/tk${v1}/include/generic/tk.h
	rm -f "${D}${EPREFIX}"/usr/${mylibdir}/tk${v1}/include/generic/tkDecls.h
	rm -f "${D}${EPREFIX}"/usr/${mylibdir}/tk${v1}/include/generic/tkPlatDecls.h

	# install symlink for libraries
	if [[ ${CHOST} != *-mingw* ]]; then
	    #dosym libtk${v1}.a ${EPREFIX}/usr/${mylibdir}/libtk.a
	    dosym libtk${v1}$(get_libname) ${EPREFIX}/usr/${mylibdir}/libtk$(get_libname) || die
	    dosym wish${v1} ${EPREFIX}/usr/bin/wish || die
	fi
	dosym libtkstub${v1}.a ${EPREFIX}/usr/${mylibdir}/libtkstub.a || die

    if [[ ${CHOST} == *-mingw* ]]; then
        rm -fr "${D}${EPREFIX}"/usr/lib
        rm -fr "${D}${EPREFIX}"/usr/include/X11
    fi

	cd "${S}"
	dodoc ChangeLog* README changes || die
}

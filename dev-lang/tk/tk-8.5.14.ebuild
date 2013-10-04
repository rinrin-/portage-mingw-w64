# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/tk/tk-8.5.14.ebuild,v 1.1 2013/05/02 10:37:42 jlec Exp $

EAPI="3"

inherit autotools eutils multilib toolchain-funcs prefix

MY_P="${PN}${PV/_beta/b}"

DESCRIPTION="Tk Widget Set"
HOMEPAGE="http://www.tcl.tk/"
SRC_URI="mirror://sourceforge/tcl/${MY_P}-src.tar.gz"

LICENSE="tcltk"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="debug threads"

RDEPEND="~dev-lang/tcl-${PV}"
DEPEND="${RDEPEND}"

SPARENT="${WORKDIR}/${MY_P}"
S="${SPARENT}"

src_prepare() {
	epatch \
		"${FILESDIR}"/${PN}-8.5.11-fedora-xft.patch \
		"${FILESDIR}"/${PN}-8.5.13-multilib.patch

	epatch "${FILESDIR}"/${PN}-8.4.15-aqua.patch
	eprefixify unix/Makefile.in

	# Bug 125971
	epatch "${FILESDIR}"/${P}-conf.patch

    if [[ ${CHOST} == *-mingw* ]]; then
        epatch "${FILESDIR}"/${PN}-8.5.10-mingw-proper-implibs-for-shared-build.patch
        epatch "${FILESDIR}"/${PN}-8.5.10-mingw-fix-forbidden-colon-in-paths.patch
        epatch "${FILESDIR}"/${PN}-8.5.10-mingw-install-man.patch
        epatch "${FILESDIR}"/${PN}-8.5.10-mingw-tcl-library.patch
        epatch "${FILESDIR}"/${PN}-8.5.10-mingw-multilib.patch
	epatch "${FILESDIR}"/${PN}-8.5.14-mingw-seh-def-fix.patch
        cd "${S}"/win
        eautoreconf
    else
	# Bug 354067 : the same applies to tcl, since the patch is about tcl.m4, just
	# copy the tcl patch
	epatch "${FILESDIR}"/tcl-8.5.9-gentoo-fbsd.patch

	# Make sure we use the right pkg-config, and link against fontconfig
	# (since the code base uses Fc* functions).
	    cd "${S}"/unix
	sed \
		-e 's/FT_New_Face/XftFontOpen/g' \
		-e "s:\<pkg-config\>:$(tc-getPKG_CONFIG):" \
		-e 's:xft freetype2:xft freetype2 fontconfig:' \
		-i configure.in || die
	rm -f configure || die

	tc-export CC

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
	local v1=$(get_version_component_range 1-2)
	local mylibdir=$(get_libdir)

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
		    "${ED}"/usr/${mylibdir}/tkConfig.sh || die
	else
	    sed -i \
		    -e "s,^\(TK_BUILD_LIB_SPEC='-L\)${nS}/unix,\1${EPREFIX}/usr/${mylibdir}," \
		    -e "s,^\(TK_SRC_DIR='\)${nS}',\1${EPREFIX}/usr/${mylibdir}/tk${v1}/include'," \
		    -e "s,^\(TK_BUILD_STUB_LIB_SPEC='-L\)${nS}/unix,\1${EPREFIX}/usr/${mylibdir}," \
		    -e "s,^\(TK_BUILD_STUB_LIB_PATH='\)${nS}/unix,\1${EPREFIX}/usr/${mylibdir}," \
		    "${ED}"/usr/${mylibdir}/tkConfig.sh || die
	fi

	if [[ ${CHOST} != *-darwin* ]]; then
		sed -i \
				-e "s,^\(TK_CC_SEARCH_FLAGS='.*\)',\1:${EPREFIX}/usr/${mylibdir}'," \
				-e "s,^\(TK_LD_SEARCH_FLAGS='.*\)',\1:${EPREFIX}/usr/${mylibdir}'," \
				"${ED}"/usr/${mylibdir}/tkConfig.sh || die
	fi

	# install private headers
	if [[ ${CHOST} == *-mingw* ]]; then
		insinto /usr/${mylibdir}/tk${v1}/include/win
	    doins "${S}"/win/*.h || die
	else
	    insinto /usr/${mylibdir}/tk${v1}/include/unix
	    doins "${S}"/unix/*.h || die
	fi
	insinto /usr/${mylibdir}/tk${v1}/include/generic
	doins "${S}"/generic/*.h || die
	rm -f "${ED}"/usr/${mylibdir}/tk${v1}/include/generic/tk.h
	rm -f "${ED}"/usr/${mylibdir}/tk${v1}/include/generic/tkDecls.h
	rm -f "${ED}"/usr/${mylibdir}/tk${v1}/include/generic/tkPlatDecls.h

	# install symlink for libraries
	if [[ ${CHOST} == *-mingw* ]]; then
	    #dosym libtk85.a /usr/${mylibdir}/libtk.a
	    dosym libtk85.dll.a /usr/${mylibdir}/libtk.dll.a || die
	    dosym wish85.exe /usr/bin/wish.exe || die
	    dosym libtkstub85.a /usr/${mylibdir}/libtkstub.a || die
        else
	dosym libtk${v1}$(get_libname) /usr/${mylibdir}/libtk$(get_libname)
	dosym libtkstub${v1}.a /usr/${mylibdir}/libtkstub.a

	dosym wish${v1} /usr/bin/wish
	fi

    if [[ ${CHOST} == *-mingw* ]]; then
        rm -fr "${ED}"/usr/lib
        rm -fr "${ED}"/usr/include/X11
    fi

	cd "${S}"
	dodoc ChangeLog* README changes || die
}

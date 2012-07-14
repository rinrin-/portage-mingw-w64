# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/zlib/zlib-1.2.5.1-r2.ebuild,v 1.3 2011/09/23 17:52:32 jlec Exp $

inherit autotools eutils toolchain-funcs

DESCRIPTION="Standard (de)compression library"
HOMEPAGE="http://www.zlib.net/"
SRC_URI="http://www.gzip.org/zlib/${P}.tar.gz
	http://www.zlib.net/current/beta/${P}.tar.gz"

EAPI="3"
LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~amd64"
IUSE="minizip static-libs"

RDEPEND="!<dev-libs/libxml2-2.7.7" #309623

src_unpack() {
	unpack ${A}
	cd "${S}"
	# trust exit status of the compiler rather than stderr #55434
	# -if test "`(...) 2>&1`" = ""; then
	# +if (...) 2>/dev/null; then
	sed -i 's|\<test "`\([^"]*\) 2>&1`" = ""|\1 2>/dev/null|' configure || die

	epatch "${FILESDIR}"/${P}-version.patch
	epatch "${FILESDIR}"/${P}-symlinks.patch
	EPATCH_OPTS=-p1 epatch "${FILESDIR}"/${PN}-1.2.4-minizip-autotools.patch
}

src_configure() {
	if use minizip ; then
		cd contrib/minizip
		sed -i "s:@ZLIB_VER@:${PV}:" configure.ac || die
		ln -s ../../minigzip.c || die
		eautoreconf
	fi
}

usex() { use $1 && echo ${2:-yes} || echo ${3:-no} ; }
echoit() { echo "$@"; "$@"; }
src_compile() {
	case ${CHOST} in
	*-mingw*|mingw*)
	  sed -i -e 's|LIBRARY|LIBRARY zlib1|g' win32/zlib.def || die
	  sed -i -e 's|-o $@ win32/zlib.def $(OBJS) $(OBJA) zlibrc.o|-o $@ $(OBJS) $(OBJA) zlibrc.o|g' \
		  win32/Makefile.gcc || die
		emake -f win32/Makefile.gcc STRIP=true PREFIX=${CHOST}- || die
		sed \
			-e 's|@prefix@|"${EPREFIX}"/usr|g' \
			-e 's|@exec_prefix@|${prefix}|g' \
			-e 's|@libdir@|${exec_prefix}/'$(get_libdir)'|g' \
			-e 's|@sharedlibdir@|${exec_prefix}/'$(get_libdir)'|g' \
			-e 's|@includedir@|${prefix}/include|g' \
			-e 's|@VERSION@|'${PV}'|g' \
			zlib.pc.in > zlib.pc || die
		;;
	*)	# not an autoconf script, so can't use econf
		echoit ./configure --shared --prefix="${EPREFIX}"/usr --libdir="${EPREFIX}"/usr/$(get_libdir) || die
		emake || die
		;;
	esac
	if use minizip ; then
		cd contrib/minizip
		econf $(use_enable static-libs static)
		emake || die
	fi
}

sed_macros() {
	# clean up namespace a little #383179
	# we do it here so we only have to tweak 2 files
	sed -i -r 's:\<(O[FN])\>:_Z_\1:g' "$@" || die
}
src_install() {
	case ${CHOST} in
	*-mingw*|mingw*)
		emake -f win32/Makefile.gcc install \
			BINARY_PATH="${ED}/usr/bin" \
			LIBRARY_PATH="${ED}/usr/$(get_libdir)" \
			INCLUDE_PATH="${ED}/usr/include" \
			SHARED_MODE=1 \
			|| die
		insinto /usr/share/pkgconfig
		doins zlib.pc || die
		;;

	*)
		emake install DESTDIR="${D}" LDCONFIG=: || die
		gen_usr_ldscript -a z
		sed_macros "${ED}"/usr/include/*.h
		;;
	esac

	dodoc FAQ README ChangeLog doc/*.txt

	if use minizip ; then
		cd contrib/minizip
		emake install DESTDIR="${D}" || die
		sed_macros "${ED}"/usr/include/minizip/*.h
		dodoc *.txt
	fi

}

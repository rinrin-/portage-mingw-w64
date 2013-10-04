# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gettext/gettext-0.18.3.1.ebuild,v 1.1 2013/08/25 01:14:18 vapier Exp $

EAPI="3"

inherit flag-o-matic eutils multilib toolchain-funcs libtool autotools

DESCRIPTION="GNU locale utilities"
HOMEPAGE="http://www.gnu.org/software/gettext/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-3 LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd"
IUSE="acl -cvs doc emacs git java nls +cxx openmp static-libs elibc_glibc"

DEPEND="virtual/libiconv
	dev-libs/libxml2
	dev-libs/pdcurses
	dev-libs/expat
	acl? ( virtual/acl )
	java? ( >=virtual/jdk-1.4 )"
RDEPEND="${DEPEND}
	git? ( dev-vcs/git )
	java? ( >=virtual/jre-1.4 )"
PDEPEND="emacs? ( app-emacs/po-mode )"

RESTRICT="test"

src_prepare() {
	use java && java-pkg-opt-2_src_prepare
	#elibtoolize
	#epatch "${FILESDIR}"/${P}-uclibc-sched_param-def.patch
	#epatch "${FILESDIR}"/${PN}-0.18.1.1-mingw-import.patch
	#epatch "${FILESDIR}"/${PN}-0.18.1.1-mingw-nul.patch
	#eautoreconf
	epunt_cxx
	elibtoolize
}

src_configure() {
	local myconf=""
	# Build with --without-included-gettext (on glibc systems)
	if use elibc_glibc ; then
		myconf="${myconf} --without-included-gettext $(use_enable nls)"
	else
		myconf="${myconf} --with-included-gettext --enable-nls"
	fi
	use cxx || export CXX=$(tc-getCC)
	
	if [[ ${CHOST} == *-mingw* ]]; then
		export CXX=x86_64-w64-mingw32-g++
	    export ac_cv_func_snprintf=yes
	    export ac_cv_func_vsnprintf=yes
	    export gl_cv_func_memchr_works=yes
	    export ac_cv_func_strnlen_working=yes
        myconf="${myconf} --enable-relocatable --enable-threads=win32 --disable-rpath"
    fi

	# --without-emacs: Emacs support is now in a separate package
	# --with-included-glib: glib depends on us so avoid circular deps
	# --with-included-libcroco: libcroco depends on glib which ... ^^^
	#
	# --with-included-libunistring will _disable_ libunistring (since
	# --it's not bundled), see bug #326477
	econf \
		--cache-file="${S}"/config.cache \
		--docdir="${EPREFIX}/usr/share/doc/${PF}" \
		--without-emacs \
		--without-lispdir \
		$(use_enable java) \
		--with-included-glib \
		--with-included-libcroco \
		--with-included-libunistring \
		$(use_enable acl) \
		$(use_enable openmp) \
		$(use_enable static-libs static) \
		$(use_with git) \
		$(usex git --without-cvs $(use_with cvs)) \
		${myconf}
}

src_install() {
	emake install DESTDIR="${D}" || die "install failed"
	use nls || rm -r "${ED}"/usr/share/locale
	use static-libs || rm -f "${ED}"/usr/lib*/*.la
	dosym msgfmt.exe /usr/bin/gmsgfmt.exe #43435
	dobin gettext-tools/misc/gettextize || die "gettextize"

	# remove stuff that glibc handles
	if use elibc_glibc ; then
		rm -f "${ED}"/usr/include/libintl.h
		rm -f "${ED}"/usr/$(get_libdir)/libintl.*
	fi
	rm -f "${ED}"/usr/share/locale/locale.alias "${D}"/usr/lib/charset.alias

	[[ ${USERLAND} == "BSD" ]] && gen_usr_ldscript -a intl

	if use java ; then
		java-pkg_dojar "${ED}"/usr/share/${PN}/*.jar
		rm -f "${ED}"/usr/share/${PN}/*.jar
		rm -f "${ED}"/usr/share/${PN}/*.class
		if use doc ; then
			java-pkg_dojavadoc "${ED}"/usr/share/doc/${PF}/javadoc2
			rm -rf "${ED}"/usr/share/doc/${PF}/javadoc2
		fi
	fi

	if use doc ; then
		dohtml "${ED}"/usr/share/doc/${PF}/*.html
	else
		rm -rf "${ED}"/usr/share/doc/${PF}/{csharpdoc,examples,javadoc2,javadoc1}
	fi
	rm -f "${ED}"/usr/share/doc/${PF}/*.html

	dodoc AUTHORS ChangeLog NEWS README THANKS
}

pkg_preinst() {
	# older gettext's sometimes installed libintl ...
	# need to keep the linked version or the system
	# could die (things like sed link against it :/)
	#preserve_old_lib /{,usr/}$(get_libdir)/libintl$(get_libname 7)

	#java-pkg-opt-2_pkg_preinst
}

pkg_postinst() {
	#preserve_old_lib_notify /{,usr/}$(get_libdir)/libintl$(get_libname 7)
}

# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libiconv/libiconv-1.14.ebuild,v 1.1 2011/11/10 11:49:35 naota Exp $

inherit eutils multilib flag-o-matic libtool toolchain-funcs

DESCRIPTION="GNU charset conversion library for libc which doesn't implement it"
HOMEPAGE="http://www.gnu.org/software/libiconv/"
SRC_URI="mirror://gnu/libiconv/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
EAPI="3"

DEPEND="!sys-libs/glibc
	!sys-apps/man-pages
	!dev-libs/win-iconv"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"

    if [[ ${CHOST} == *-mingw* ]]; then
        epatch "${FILESDIR}/${P}-mingw-no-utf8-subst-checking.patch"
    fi
	# Make sure that libtool support is updated to link "the linux way" on
	# FreeBSD.
	elibtoolize
}

src_compile() {
	# Install in /lib as utils installed in /lib like gnutar
	# can depend on this

	# Disable NLS support because that creates a circular dependency
	# between libiconv and gettext

	econf \
		--disable-nls \
		--enable-shared \
		--enable-static \
		--enable-extra-encodings \
		--disable-rpath \
		 || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" docdir="${EPREFIX}/usr/share/doc/${PF}/html" install || die "make install failed"

	# Move static libs and creates ldscripts into /usr/lib
	#dodir /$(get_libdir)
	#mv "${ED}"/usr/$(get_libdir)/lib{iconv,charset}*$(get_libname)* "${ED}/$(get_libdir)" || die
	#gen_usr_ldscript libiconv$(get_libname)
	#gen_usr_ldscript libcharset$(get_libname)
}

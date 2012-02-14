# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/mpc/mpc-0.9-r1.ebuild,v 1.2 2011/12/01 16:44:02 darkside Exp $

EAPI="3"

inherit autotools eutils libtool

DESCRIPTION="A library for multiprecision complex arithmetic with exact rounding."
HOMEPAGE="http://mpc.multiprecision.org/"
SRC_URI="http://www.multiprecision.org/mpc/download/${P}.tar.gz
	mirror://gentoo/${P}-configure.patch.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="static-libs"

DEPEND=">=dev-libs/gmp-4.3.2
	>=dev-libs/mpfr-2.4.2
	elibc_SunOS? ( >=sys-devel/gcc-4.5 )"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${WORKDIR}"/${P}-configure.patch
    if [[ ${CHOST} == *-mingw* ]]; then
        epatch "${FILESDIR}"/${P}-mingw-shared.patch
    fi
	eautoreconf
}

src_compile() {
	econf $(use_enable static-libs static) || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	use static-libs || rm "${D}${EPREFIX}"/usr/$(get_libdir)/libmpc.la
	dodoc ChangeLog NEWS README TODO
}

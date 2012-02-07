# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit eutils multilib libtool toolchain-funcs

DESCRIPTION="iconv implementation using Win32 API to convert."
HOMEPAGE="http://code.google.com/p/win-iconv/"
SRC_URI="http://win-iconv.googlecode.com/files/${P}.tar.bz2"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="!sys-libs/glibc
	!sys-apps/man-pages"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Make sure that libtool support is updated to link "the linux way" on
	# FreeBSD.
	elibtoolize
}

src_compile() {
	emake CC=${CHOST}-gcc STRIP=${CHOST}-strip \
	      AR=${CHOST}-ar RANLIB=${CHOST}-ranlib \
	      DLLTOOL=${CHOST}-dlltool DLLWRAP=${CHOST}-dllwrap || die "emake failed"
}

src_test() {
	emake CC=${CHOST}-gcc test || die "emake test failed"
}

src_install() {
  insinto "${EPREFIX}/usr/include" && doins "${WORKDIR}/${P}/iconv.h"
  insinto "${EPREFIX}/usr/bin" && doins "${WORKDIR}/${P}/iconv.dll"
  insopts -m0755 && insinto "${EPREFIX}/usr/bin" && doins "${WORKDIR}/${P}/win_iconv.exe"
  insinto "${EPREFIX}/usr/lib64" && doins "${WORKDIR}/${P}/libiconv.a"
}

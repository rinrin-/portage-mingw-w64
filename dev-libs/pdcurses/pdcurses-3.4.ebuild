# Copyright 2011 Rinrin
# Distributed under the terms of the GNU General Public License v2

EAPI=3
inherit eutils toolchain-funcs

DESCRIPTION="public domain curses library for DOS, OS/2, Win32, X11 and SDL"
HOMEPAGE="http://pdcurses.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${PV}/PDCurses-${PV}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=!sys-libs/glibc
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/${P}-win32.patch
}

src_configure() {
  rm -f configure
}

src_compile() {
  cd win32
	emake CC=${CHOST}-gcc STRIP=${CHOST}-strip \
	      AR=${CHOST}-ar LINK=${CHOST}-gcc \
	      -f gccwin32.mak DLL=Y WIDE=Y || die "emake failed"
	 cd ../doc && emake CC=${CHOST}-gcc || die "emake failed"
}

src_install() {
  insinto "${EPREFIX}/usr/include"
  doins "${WORKDIR}/${P}/curses.h" && doins "${WORKDIR}/${P}/panel.h"
  insinto "${EPREFIX}/usr/bin" && doins "${WORKDIR}/${P}/win32/pdcurses.dll"
  insinto "${EPREFIX}/usr/lib64" && doins "${WORKDIR}/${P}/win32/libcurses.a"
  dodoc doc/PDCurses.txt
}

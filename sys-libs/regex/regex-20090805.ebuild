# Copyright 2011 Rinrin
# Distributed under the terms of the GNU General Public License v2

EAPI=3
inherit autotools eutils

DESCRIPTION="A library exposing the GNULIB implementation of the regex module"
HOMEPAGE="http://www.mingw.org/"
SRC_URI="mirror://sourceforge/mingw/regex-1.20090805-2-msys-1.0.13-src.tar.lzma"


LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
RESTRICT="test"

src_unpack() {
	unpack regex-1.20090805-2-msys-1.0.13-src.tar.lzma
	cd ${WORKDIR}
	tar axf ${P}.tar.xz
}

src_prepare() {
	eautoreconf
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
  emake DESTDIR="${D}" install
  find "${ED}" -name "*.la" -exec rm -f {} +
}

# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libunistring/libunistring-0.9.3-r1.ebuild,v 1.1 2010/10/06 04:22:11 chiiph Exp $

EAPI="3"

inherit eutils autotools

DESCRIPTION="Library for manipulating Unicode strings and C strings according to the Unicode standard"
HOMEPAGE="http://www.gnu.org/software/libunistring/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="LGPL-3 GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

# win-iconv does not support some conversions
RESTRICT="test"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-nodocs.patch
	epatch "${FILESDIR}"/${P}-mingw-import.patch
	eautoreconf
}

src_configure() {
	local myconf

    if [[ ${CHOST} == *-mingw* ]]; then
        myconf=" --enable-threads=win32"
    fi
	econf ${myconf}
}

src_install() {
	dodoc AUTHORS README ChangeLog || die "dodoc failed"
	if use doc; then
		dohtml doc/*.html || die "dohtml failed"
		doinfo doc/*.info || die "doinfo failed"
	fi

	emake DESTDIR="${D}" install || die "Install failed"
	find "${ED}" -name "*.la" -exec rm -f {} +
}

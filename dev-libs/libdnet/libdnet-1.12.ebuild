# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libdnet/libdnet-1.11-r1.ebuild,v 1.11 2010/07/19 21:35:59 maekke Exp $

#WANT_AUTOMAKE=1.6
inherit eutils autotools

DESCRIPTION="simplified, portable interface to several low-level networking routines"
HOMEPAGE="http://code.google.com/p/libdnet/"
SRC_URI="http://libdnet.googlecode.com/files/${P}.tgz"

EAPI="3"
LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 ~arm hppa ia64 ppc ppc64 sparc x86"
IUSE="python"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i 's/suite_free(s);//' test/check/*.c || die "sed failed"
	epatch "${FILESDIR}"/${P}-mingw-special.patch
	AT_M4DIR="config"
	eautoreconf
}

src_configure () {
    #some cflags(-mms-bitfields) will cause ICE
    export CFLAGS="-O2"
    # just a hint for iphlpapi.h header presence
    export ac_cv_header_iphlpapi_h=yes
	econf \
	--with-wpdpack=${EPREFIX}/usr \
	$(use_with python) \
	|| die "econf failed"
}

src_compile () {
    emake || die "emake failed"
}

src_test() {
	einfo "self test fails with permission problems"
}

src_install () {
	emake DESTDIR="${D}" install || die "make install failed"
	find "${ED}" -name '*.la' -exec rm -f {} +
	dodoc README THANKS TODO
}

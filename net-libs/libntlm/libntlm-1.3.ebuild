# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libntlm/libntlm-1.3.ebuild,v 1.11 2012/10/20 15:31:53 pinkbyte Exp $

EAPI=3

DESCRIPTION="Microsoft's NTLM authentication (libntlm) library"
HOMEPAGE="http://www.nongnu.org/libntlm/"
SRC_URI="http://www.nongnu.org/${PN}/releases/${P}.tar.gz"

SLOT="0"
LICENSE="LGPL-2"
KEYWORDS="~amd64"
IUSE=""

src_configure() {
	econf --disable-valgrind-tests
}

src_install () {
	emake DESTDIR="${D}" install
	dodoc AUTHORS ChangeLog NEWS README
}

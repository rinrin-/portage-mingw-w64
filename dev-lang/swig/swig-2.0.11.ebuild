# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/swig/swig-2.0.11.ebuild,v 1.1 2013/09/27 19:36:37 radhermit Exp $

EAPI=3

DESCRIPTION="Simplified Wrapper and Interface Generator"
HOMEPAGE="http://www.swig.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-3+ BSD BSD-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~amd64-fbsd ~x86-fbsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="ccache doc pcre"
RESTRICT="test"

DEPEND="pcre? ( dev-libs/libpcre )
	ccache? ( sys-libs/zlib )"
RDEPEND="${DEPEND}"

DOCS=( ANNOUNCE CHANGES CHANGES.current README TODO )

src_configure() {
	econf \
		$(use_enable ccache) \
		$(use_with pcre)
}

src_install() {
	emake DESTDIR="${D}" install || die

	if use doc ; then
		dohtml -r Doc/{Devel,Manual}
	fi
}

# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-dns/libidn/libidn-1.28.ebuild,v 1.11 2013/09/30 17:13:38 ago Exp $

EAPI=3

inherit autotools

DESCRIPTION="Internationalized Domain Names (IDN) implementation"
HOMEPAGE="http://www.gnu.org/software/libidn/"
SRC_URI="mirror://gnu/libidn/${P}.tar.gz"

LICENSE="GPL-2 GPL-3 LGPL-3 java? ( Apache-2.0 )"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc emacs java mono nls static-libs"
#testing failed on setenv, need investigation
RESTRICT="test"

DOCS=( AUTHORS ChangeLog FAQ NEWS README THANKS TODO )
COMMON_DEPEND="
	emacs? ( virtual/emacs )
	mono? ( >=dev-lang/mono-0.95 )
"
DEPEND="${COMMON_DEPEND}
	nls? ( >=sys-devel/gettext-0.17 )
	java? (
		>=virtual/jdk-1.5
		doc? ( dev-java/gjdoc )
	)
"
RDEPEND="${COMMON_DEPEND}
	nls? ( virtual/libintl )
	java? ( >=virtual/jre-1.5 )
"



src_prepare() {
	# bundled, with wrong bytecode
	rm "${S}/java/${P}.jar" || die
}

src_configure() {
	econf \
		$(use_enable java) \
		$(use_enable mono csharp mono) \
		$(use_enable nls) \
		$(use_enable static-libs static) \
		--disable-silent-rules \
		--disable-valgrind-tests \
		--with-lispdir="${EPREFIX}/usr/share/emacs/${PN}" \
		--with-packager-bug-reports="https://bugs.gentoo.org" \
		--with-packager-version="r${PR}" \
		--with-packager="Gentoo"
}

src_compile() {
	default

	if use emacs; then
		elisp-compile src/*.el || die
	fi
}

src_install() {
        emake DESTDIR="${D}" install

	if use emacs; then
		# *.el are installed by the build system
		elisp-install ${PN} src/*.elc
		elisp-site-file-install "${FILESDIR}/50${PN}-gentoo.el"
	else
		rm -r "${ED}/usr/share/emacs" || die
	fi

	if use doc ; then
		dohtml -r doc/reference/html/*
	fi

	if use java ; then
		java-pkg_newjar java/${P}.jar ${PN}.jar || die
		rm -r "${ED}"/usr/share/java || die

		if use doc ; then
			java-pkg_dojavadoc doc/java
		fi
	fi

        rm -f "${ED}/usr/bin/*.def"
	prune_libtool_files
}

pkg_postinst() {
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}

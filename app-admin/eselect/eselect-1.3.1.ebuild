# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect/eselect-1.3.1.ebuild,v 1.9 2012/06/27 03:18:16 jer Exp $

EAPI=3

inherit eutils bash-completion-r1

DESCRIPTION="Gentoo's multi-purpose configuration and management tool"
HOMEPAGE="http://www.gentoo.org/proj/en/eselect/"
SRC_URI="mirror://gentoo/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 arm hppa ~ia64 ~m68k ~mips ppc ppc64 ~s390 ~sh ~sparc x86 ~ppc-aix ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="doc"

RDEPEND="sys-apps/sed
	|| (
		sys-apps/coreutils
		sys-freebsd/freebsd-bin
		app-misc/realpath
	)"
DEPEND="${RDEPEND}
	app-arch/xz-utils
	doc? ( dev-python/docutils )"
RDEPEND="!app-admin/eselect-news
	${RDEPEND}
	sys-apps/file
	dev-libs/pdcurses"

# Commented out: only few users of eselect will edit its source
#PDEPEND="emacs? ( app-emacs/gentoo-syntax )
#	vim-syntax? ( app-vim/eselect-syntax )"

src_prepare() {
  if [[ ${CHOST} == *-mingw* ]]; then
    epatch "${FILESDIR}"/${P}-mingw.patch
	fi
}

src_compile() {
	emake || die

	if use doc; then
		emake html || die
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die
	newbashcomp misc/${PN}.bashcomp ${PN} || die
	dodoc AUTHORS ChangeLog NEWS README TODO doc/*.txt || die

	if use doc; then
		dohtml *.html doc/* || die
	fi
	
	if [[ ${CHOST} == *-mingw* ]]; then
	  #remove unused module in mingw64
	  rm -f "${ED}"/usr/share/eselect/modules/kernel.eselect
	  rm -f "${ED}"/usr/share/man/man1/kernel-config.1
	  rm -f "${ED}"/usr/share/man/man5/kernel.eselect.5
	  rm -f "${ED}"/usr/bin/kernel-config
	  rm -f "${ED}"/usr/share/eselect/modules/binutils.eselect
	  rm -f "${ED}"/usr/share/man/man5/binutils.eselect.5
	  rm -f "${ED}"/usr/share/eselect/modules/news.eselect
	  rm -f "${ED}"/usr/share/man/man5/news.eselect.5
	fi
}


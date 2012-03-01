# Copyright 2011 Rinrin
# Distributed under the terms of the GNU General Public License v2

EAPI=3
inherit eutils subversion toolchain-funcs

DESCRIPTION="Posix Threads library for Microsoft Windows"
HOMEPAGE="http://mingw-w64.sourceforge.net/"
ESVN_REPO_URI="https://mingw-w64.svn.sourceforge.net/svnroot/mingw-w64/experimental/winpthreads"

LICENSE="MIT BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=!sys-libs/pthreads-win32
RDEPEND="${DEPEND}"

src_unpack() {
  subversion_src_unpack
}

src_prepare() {
  subversion_src_prepare
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
  emake DESTDIR="${D}" install
  rm -f "${ED}"/usr/lib*/libwinpthread.la
}


inherit eutils multilib libtool toolchain-funcs

EAPI="3"
DESCRIPTION="iconv implementation using Win32 API to convert."
HOMEPAGE="http://code.google.com/p/win-iconv/"
SRC_URI="http://win-iconv.googlecode.com/files/${P}.tar.bz2"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="!sys-libs/glibc
	!sys-apps/man-pages
	!dev-libs/libiconv"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"
}

src_compile() {
	emake CC=${CHOST}-gcc STRIP=${CHOST}-strip \
	      AR=${CHOST}-ar RANLIB=${CHOST}-ranlib \
	      DLLTOOL=${CHOST}-dlltool DLLWRAP=${CHOST}-dllwrap \
	      SPECS_FLAGS="--implib libiconv.dll.a" || die "emake failed"
}

src_test() {
	emake CC=${CHOST}-gcc test || die "emake test failed"
}

src_install() {
  insinto "/usr/include" && doins "${WORKDIR}/${P}/iconv.h"
  insopts -m0755 && insinto "/usr/bin" && doins "${WORKDIR}/${P}/iconv.dll"
  insopts -m0755 && insinto "/usr/bin" && doins "${WORKDIR}/${P}/win_iconv.exe"
  insinto "/usr/lib64" && doins "${WORKDIR}/${P}/libiconv.a"
  insinto "/usr/lib64" && doins "${WORKDIR}/${P}/libiconv.dll.a"
}

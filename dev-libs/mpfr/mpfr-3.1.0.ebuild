# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/mpfr/mpfr-3.1.0.ebuild,v 1.3 2011/12/09 20:49:07 aballier Exp $

EAPI="3"

# NOTE: we cannot depend on autotools here starting with gcc-4.3.x
inherit eutils multilib

MY_PV=${PV/_p*}
MY_P=${PN}-${MY_PV}
PLEVEL=${PV/*p}
DESCRIPTION="library for multiple-precision floating-point computations with exact rounding"
HOMEPAGE="http://www.mpfr.org/"
SRC_URI="http://www.mpfr.org/mpfr-${MY_PV}/${MY_P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 -sparc-fbsd -x86-fbsd"
IUSE="static-libs"

RDEPEND=">=dev-libs/gmp-4.1.4-r2[static-libs?]"
DEPEND="${RDEPEND}"

RESTRICT="test"

S=${WORKDIR}/${MY_P}

src_prepare() {
	[[ -d ${FILESDIR}/${PV} ]] && epatch "${FILESDIR}"/${PV}/*.patch
	[[ ${PLEVEL} == ${PV} ]] && return 0
	for ((i=1; i<=PLEVEL; ++i)) ; do
		patch=patch$(printf '%02d' ${i})
		if [[ -f ${FILESDIR}/${MY_PV}/${patch} ]] ; then
			epatch "${FILESDIR}"/${MY_PV}/${patch}
		elif [[ -f ${DISTDIR}/${PN}-${MY_PV}_p${i} ]] ; then
			epatch "${DISTDIR}"/${PN}-${MY_PV}_p${i}
		else
			ewarn "${DISTDIR}/${PN}-${MY_PV}_p${i}"
			die "patch ${i} missing - please report to bugs.gentoo.org"
		fi
	done
	sed -i '/if test/s:==:=:' configure #261016
	find . -type f -print0 | xargs -0 touch -r configure
}

src_configure() {
    #avoid test failure for mingw64
    case ${CHOST} in
        *64*mingw* )
            CBUILD=${CHOST}
            ;;
        *)
            ;;
    esac
	econf \
		--docdir=${EPREFIX}/usr/share/doc/${PF} \
		$(use_enable static-libs static) \
		$(use_enable !static-libs shared) \
		|| die
}

src_install() {
	emake install DESTDIR="${D}" || die
	use static-libs || rm -f "${D}${EPREFIX}"/usr/$(get_libdir)/libmpfr.la

	# clean up html/license install
	pushd "${D}${EPREFIX}"/usr/share/doc/${PF} >/dev/null
	dohtml *.html && rm COPYING* *.html || die
	popd >/dev/null
	# some, but not all, are already installed
	dodoc AUTHORS BUGS ChangeLog NEWS README TODO
	prepalldocs
}

pkg_preinst() {
	preserve_old_lib /usr/$(get_libdir)/libmpfr.so.1
}

pkg_postinst() {
	preserve_old_lib_notify /usr/$(get_libdir)/libmpfr.so.1
}

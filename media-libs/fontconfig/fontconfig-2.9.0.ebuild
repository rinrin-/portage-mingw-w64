# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/fontconfig/fontconfig-2.9.0.ebuild,v 1.2 2012/05/05 08:02:34 jdhore Exp $

EAPI="4"

inherit autotools eutils libtool toolchain-funcs flag-o-matic

DESCRIPTION="A library for configuring and customizing font access"
HOMEPAGE="http://fontconfig.org/"
SRC_URI="http://fontconfig.org/release/${P}.tar.gz"

LICENSE="MIT"
SLOT="1.0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd"
IUSE="doc static-libs"

# Purposefully dropped the xml USE flag and libxml2 support.  Expat is the
# default and used by every distro.  See bug #283191.

RDEPEND=">=media-libs/freetype-2.2.1
	>=dev-libs/expat-1.95.3"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? (
		app-text/docbook-sgml-utils[jadetex]
		=app-text/docbook-sgml-dtd-3.1*
	)"
PDEPEND="app-admin/eselect-fontconfig
	virtual/ttf-fonts"

#you sholuld add `cygpath` into run-test.sh to enable test in mingw64
RESTRICT="test"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-2.7.1-latin-reorder.patch	# 130466
	epatch "${FILESDIR}"/${PN}-2.3.2-docbook.patch			# 310157

  if [[ ${CHOST} == *-mingw* ]]; then
    epatch "${FILESDIR}"/${PN}-2.9.0-mingw64.patch
    #mingw64 need pkg.m4
	  export AT_M4DIR="${EPREFIX}/usr/share/aclocal"
	fi
	  
	eautoreconf

	# Needed to get a sane .so versioning on fbsd, please dont drop.
	# If you have to run eautoreconf, you can also leave the elibtoolize
	# call as it will be a no-op.
	elibtoolize
}

src_configure() {
	local myconf
	if tc-is-cross-compiler; then
		myconf="--with-arch=${ARCH}"
		replace-flags -mtune=* -DMTUNE_CENSORED
		replace-flags -march=* -DMARCH_CENSORED
	fi
	
	if [[ ${CHOST} == *-mingw* ]]; then
	  myconf="${myconf} --with-confdir=${EPREFIX}/etc/fonts"
	  myconf="${myconf} --with-default-fonts=APPSHAREFONTDIR"
	  myconf="${myconf} --with-cache-dir=WINDOWSTEMPDIR_FONTCONFIG_CACHE"
	else
	  myconf="${myconf} --with-default-fonts=${EPREFIX}/usr/share/fonts"
	  myconf="${myconf} --with-add-fonts=${EPREFIX}/usr/local/share/fonts"
	fi
	econf \
		$(use_enable static-libs static) \
		$(use_enable doc docs) \
		$(use_enable doc docbook) \
		--localstatedir=${EPREFIX}/var \
		${myconf} || die
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install"
	emake DESTDIR="${D}" -C doc install-man || die "emake install-man"

	find "${ED}" -name '*.la' -exec rm -f {} +

	#fc-lang directory contains language coverage datafiles
	#which are needed to test the coverage of fonts.
	insinto /usr/share/fc-lang
	doins fc-lang/*.orth

	insinto /etc/fonts
	doins "${S}"/fonts.conf

	dodoc doc/fontconfig-user.{txt,pdf}
	dodoc AUTHORS ChangeLog README

	if [[ -e ${D}usr/share/doc/fontconfig/ ]];  then
		mv "${D}"usr/share/doc/fontconfig/* "${D}"/usr/share/doc/${P}
		rm -rf "${D}"usr/share/doc/fontconfig
	fi

	# Changes should be made to /etc/fonts/local.conf, and as we had
	# too much problems with broken fonts.conf we force update it ...
	echo 'CONFIG_PROTECT_MASK="/etc/fonts/fonts.conf"' > "${T}"/37fontconfig
	#doenvd "${T}"/37fontconfig
	mv "${T}"/37fontconfig /etc/env.d/37fontconfig

	# As of fontconfig 2.7, everything sticks their noses in here.
	#dodir /etc/sandbox.d
	#echo 'SANDBOX_PREDICT="/var/cache/fontconfig"' > "${D}"/etc/sandbox.d/37fontconfig
}

pkg_preinst() {
	# Bug #193476
	# /etc/fonts/conf.d/ contains symlinks to ../conf.avail/ to include various
	# config files.  If we install as-is, we'll blow away user settings.
	ebegin "Syncing fontconfig configuration to system"
	if [[ -e "${EPREFIX}"/etc/fonts/conf.d ]]; then
		for file in "${EPREFIX}"/etc/fonts/conf.avail/*; do
			f=${file##*/}
			if [[ -L "${EPREFIX}"/etc/fonts/conf.d/${f} ]]; then
				[[ -f ${ED}etc/fonts/conf.avail/${f} ]] \
					&& ln -sf ../conf.avail/"${f}" "${ED}"etc/fonts/conf.d/ &>/dev/null
			else
				[[ -f ${ED}etc/fonts/conf.avail/${f} ]] \
					&& rm "${ED}"etc/fonts/conf.d/"${f}" &>/dev/null
			fi
		done
	fi
	eend $?
}

pkg_postinst() {
	einfo "Cleaning broken symlinks in "${EPREFIX}"/etc/fonts/conf.d/"
	find -L "${EPREFIX}"/etc/fonts/conf.d/ -type l -delete

	echo
	ewarn "Please make fontconfig configuration changes using \`eselect fontconfig\`"
	ewarn "Any changes made to "${EPREFIX}"/etc/fonts/fonts.conf will be overwritten."
	ewarn
	ewarn "If you need to reset your configuration to upstream defaults, delete"
	ewarn "the directory "${EPREFIX}"/etc/fonts/conf.d/ and re-emerge fontconfig."
	echo

	if [[ ${ROOT} = / ]]; then
		ebegin "Creating global font cache"
		"${EPREFIX}"/usr/bin/fc-cache -srf
		eend $?
	fi
}

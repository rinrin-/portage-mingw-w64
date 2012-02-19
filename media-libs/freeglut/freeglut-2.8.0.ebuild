# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/freeglut/freeglut-2.8.0.ebuild,v 1.1 2012/01/16 22:42:41 ssuominen Exp $

EAPI=4
inherit eutils libtool

DESCRIPTION="A completely OpenSourced alternative to the OpenGL Utility Toolkit (GLUT) library"
HOMEPAGE="http://freeglut.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="debug static-libs"

RDEPEND=""
DEPEND="${RDEPEND}"

DOCS="AUTHORS ChangeLog NEWS README TODO"

src_prepare() {
	# Please read the comments in the patch before thinking about dropping it
	# yet again...
	epatch "${FILESDIR}"/${PN}-2.4.0-bsd-usb-joystick.patch

	# Needed for sane .so versionning on bsd, please don't drop
	elibtoolize
}

src_configure() {
	econf \
		$(use_enable static-libs static) \
		--enable-replace-glut \
		$(use_enable debug)
}

src_install() {
	default
	dohtml -r doc
	find "${ED}" -name '*.la' -exec rm -f {} +
}

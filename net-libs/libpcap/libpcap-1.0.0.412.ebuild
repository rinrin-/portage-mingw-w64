# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libpcap/libpcap-1.2.1.ebuild,v 1.1 2012/01/04 02:40:15 radhermit Exp $

EAPI=3
inherit autotools eutils

DESCRIPTION=" the industry-standard tool for link-layer network access in Windows environments"
HOMEPAGE="http://www.winpcap.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

S="${WORKDIR}/${PN}"

RDEPEND=""
DEPEND="${RDEPEND}
	sys-devel/flex
	virtual/yacc"


src_prepare() {
	# our version of winpcap
	cp "${FILESDIR}"/libpcap.tar.bz2 ${WORKDIR}
	cd "${WORKDIR}"
	tar axf "${WORKDIR}"/libpcap.tar.bz2
	epatch "${FILESDIR}"/${PN}-mingw64-remove-dup-errno-def.patch
	
	# disable default src_configure step
	cd ${S}
	rm -f configure
}

src_compile() {
	cd Win32/Dll
	emake CC=${CHOST}-gcc WINDRES=${CHOST}-windres -f makefile.mingw64
	cd ../..
	emake CC=${CHOST}-gcc WINDRES=${CHOST}-windres -f makefile.mingw64
}

src_install() {

    insopts -m0755 && insinto /usr/bin && doins wpcap.dll
    insinto /usr/$(get_libdir) && doins libwpcap.dll.a
    insinto /usr/include
    doins Win32/Include/bittypes.h
    doins Win32/Include/ip6_misc.h
    doins Win32/common/Packet32.h
    doins Win32/Extensions/Win32-Extensions.h
    doins pcap.h
    doins pcap-bpf.h
    doins pcap-namedb.h
    doins pcap-stdinc.h
    doins remote-ext.h
    cp -R pcap ${ED}/usr/include
    insinto /usr/share/man/man3
    doins *.3pcap
    
    cd Win32/Dll
    insopts -m0755 && insinto /usr/bin && doins Packet.dll
    insinto /usr/$(get_libdir) && doins libpacket.dll.a
}

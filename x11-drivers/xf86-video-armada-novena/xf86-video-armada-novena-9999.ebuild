# Copyright (c) 2016 sakaki <sakaki@deciban.com>
# Copyright (c) 2018,2021 Wade Cline <wadecline@hotmail.com>
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="7"

inherit autotools eutils git-r3 xorg-3

DESCRIPTION="Accelerated video driver for the Novena's i.MX6"
EGIT_BRANCH="unstable-devel"
# Yes this is non-TLS HTTP but the self-signed certificate issued by the site
# has a stupidly short expiration time.
EGIT_REPO_URI="http://git.arm.linux.org.uk/cgit/xf86-video-armada.git"
HOMEPAGE="http://git.arm.linux.org.uk/cgit/xf86-video-armada.git"

IUSE=""
LICENSE="GPL-2"
RESTRICT="mirror"
SLOT="0"

RDEPEND="
	>=x11-libs/libdrm-armada-0.2.0
	>=dev-embedded/etna_viv-20160915
	>=x11-libs/pixman-0.34.0
	>=x11-libs/libdrm-2.4.68
	>=x11-proto/xf86driproto-2.1.1-r1
"

DEPEND="${RDEPEND}
"

src_unpack() {
	# Unknown why 'default' doesn't do the correct thing here, so use
	# 'xorg-2_src_unpack' as per the stack trace that appears when using
	# the default PKI (now xorg-3_src_unpack).
	xorg-3_src_unpack
}

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	xorg-3_src_configure
	econf --with-etnaviv-include=/usr/include \
		--with-etnaviv-lib=/usr/lib \
		--disable-vivante
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}


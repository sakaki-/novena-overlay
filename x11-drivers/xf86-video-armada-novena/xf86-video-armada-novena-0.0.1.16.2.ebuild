# Copyright (c) 2016 sakaki <sakaki@deciban.com>
# Copyright (c) 2018,2021 Wade Cline <wadecline@hotmail.com>
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="7"

# 'xorg-2' seems to expect git repos to be for '9999' versions only, so some
# environment variables need to be set here and later.
XORG_BASE_INDIVIDUAL_URI=""
inherit autotools eutils git-r3 xorg-3

DESCRIPTION="Accelerated video driver for the Novena's i.MX6"
EGIT_BRANCH="unstable-devel"
# The maintainer does not appear interested in creating an annotated tag in
# order to demarcate versions which do not support Xorg 1.20, but this appears
# to be the commit from which support exists and which this ebuild is based
# upon, even though the (fake) version number used is extremely ugly.
EGIT_COMMIT="5d7b814e9743fa942754dd843db7b3c9e90fdc2a"
# FIXME: 'https://git.arm.linux.org.uk/cgit/xf86-video-armada.git' appears to be the new location
EGIT_REPO_URI="http://git.arm.linux.org.uk/cgit/xf86-video-armada.git"
HOMEPAGE="http://git.arm.linux.org.uk/cgit/xf86-video-armada.git"

GIT_ECLASS="git-r3"
IUSE=""
KEYWORDS="~arm"
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


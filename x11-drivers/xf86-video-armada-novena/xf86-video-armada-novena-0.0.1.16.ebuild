# Copyright (c) 2016 sakaki <sakaki@deciban.com>
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="5"

inherit eutils versionator autotools
inherit xorg-2

DESCRIPTION="Accelerated video driver for the Novena's i.MX6"
HOMEPAGE="https://github.com/xobs/xserver-xorg-video-armada"

# we rename to the more usual xf86-video-<foo> format

# base name versions of form X.Y.Z   fetch vX.Y.Z.tar.gz    from GitHub
# base name versions of form X.Y.Z.R fetch vX.Y.Z-rR.tar.gz from GitHub
# (trailing -rN in base name is reserved for ebuild revisions)
MY_PV="$(replace_version_separator 3 '-r')"

SRC_URI="${HOMEPAGE}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"

RESTRICT="mirror"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~arm"
IUSE=""

RDEPEND="
	>=x11-libs/libdrm-armada-0.2.0
	>=dev-embedded/etna_viv-20160915
	>=x11-libs/pixman-0.34.0
	>=x11-libs/libdrm-2.4.68
	>=x11-proto/xf86driproto-2.1.1-r1
	<x11-base/xorg-server-1.20
"

DEPEND="${RDEPEND}
"

src_unpack() {
	default
	# fix name for unpacked directory
	mv "${WORKDIR}/xserver-xorg-video-armada-${MY_PV}" "${S}"
}

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	xorg-2_src_configure
	econf --with-etnaviv-include=/usr/include \
		--with-etnaviv-lib=/usr/lib \
		--disable-vivante
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}


# Copyright (c) 2016 sakaki <sakaki@deciban.com>
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="6"

inherit eutils autotools git-r3

DESCRIPTION="Userspace interface to kernel DRM services (armada specific)"
HOMEPAGE="http://git.armlinux.org.uk/~rmk/libdrm-armada.git"

SRC_URI=""
EGIT_REPO_URI="git://ftp.arm.linux.org.uk/~rmk/libdrm-armada.git"
EGIT_BRANCH="master"
EGIT_COMMIT="6b461c163b0bd02c76b65d94cc2fb3767167bda8"

RESTRICT="mirror"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~arm"
IUSE=""

RDEPEND="
	>=x11-libs/libdrm-2.4.68
"

DEPEND="${RDEPEND}"

src_prepare() {
	default
	eautoreconf
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}
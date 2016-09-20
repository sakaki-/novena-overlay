# Copyright (c) 2016 sakaki <sakaki@deciban.com>
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="6"

inherit eutils

DESCRIPTION="Support files for the Heirloom version of the Novena SBC"
HOMEPAGE="https://github.com/xobs/${PN}"

SRC_URI="${HOMEPAGE}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

RESTRICT="mirror"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~arm"

RDEPEND="
	>=sys-fs/udev-225-r1
"

DEPEND="${RDEPEND}"

src_install() {
	insinto /lib/udev/rules.d
	doins *.rules
}


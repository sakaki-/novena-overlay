# Copyright (c) 2016 sakaki <sakaki@deciban.com>
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="6"

inherit eutils versionator

DESCRIPTION="Tool to view/edit the contents of the Novena SBC's personality EEPROM"
HOMEPAGE="https://github.com/xobs/${PN}"

# base name versions of form X.Y   fetch vX.Y.tar.gz    from GitHub
# base name versions of form X.Y.Z fetch vX.Y-rZ.tar.gz from GitHub
# (trailing -rN in base name is reserved for ebuild revisions)
MY_PV="$(replace_version_separator 2 '-r')"

SRC_URI="${HOMEPAGE}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"

RESTRICT="mirror"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~arm"

RDEPEND="
"

DEPEND="${RDEPEND}"

src_unpack() {
	default
	if [[ ${MY_PV} != ${PV} ]]; then
		# fix name for unpacked directory
		mv "${WORKDIR}/${PN}-${MY_PV}" "${S}"
	fi
}

src_prepare() {
	default
	epatch "${FILESDIR}/${P}-add-missing-i2c.h-include.patch"
}

src_install() {
	dosbin ${PN}
	doman ${PN}.8
}

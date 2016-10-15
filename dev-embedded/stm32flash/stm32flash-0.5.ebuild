# Copyright (c) 2016 sakaki <sakaki@deciban.com>
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="6"

inherit eutils versionator

DESCRIPTION="STM32 chip flashing utility using a serial bootloader"
HOMEPAGE="http://${PN}.sourceforge.net/index.html"

SRC_URI="https://sourceforge.net/projects/${PN}/files/${P}.tar.gz/download -> ${P}.tar.gz"

RESTRICT="mirror"
LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~arm"
IUSE=""

RDEPEND="
"

DEPEND="${RDEPEND}
"

DOCS=( AUTHORS HOWTO I2C.txt protocol.txt )

src_unpack() {
	default
	# fix name for unpacked directory
	mv "${WORKDIR}/${PN}" "${S}"
}

src_install() {
	emake DESTDIR="${D}" PREFIX=/usr install
	einstalldocs
}
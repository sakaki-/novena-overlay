# Copyright (c) 2016 sakaki <sakaki@deciban.com>
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="6"

inherit eutils qmake-utils versionator

DESCRIPTION="GUI to view/edit the contents of the Novena SBC's personality EEPROM"
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
IUSE="+gksu"

RDEPEND="
	dev-qt/qtgui:5
	dev-qt/qtcore:5
	dev-qt/qtwidgets:5
	gksu? ( >=x11-libs/gksu-2.0.2 )
"

DEPEND="${RDEPEND}"

# Generates a QA warning about value for 'Categories' key otherwise 
QA_DESKTOP_FILE="usr/share/applications/novena-eeprom-gui.desktop"

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
	epatch "${FILESDIR}/${P}-add-unsigned-char-casts.patch"
	if use gksu; then
		sed -i -e 's/^Exec=novena-eeprom-gui$/Exec=gksu novena-eeprom-gui/' \
			novena-eeprom-gui.desktop || die
		sed -i -e 's/^Name=Novena EEPROM GUI$/Name=Novena EEPROM GUI (Run as root)/' \
			novena-eeprom-gui.desktop || die
	fi
}

src_configure() {
	eqmake5
}

src_install() {
	# currently a manual install
	dobin ${PN}
	doman ${PN}.1
	insinto /usr/share/applications
	doins ${PN}.desktop
	insinto /usr/share/${PN}
	doins ${PN}.png
}

pkg_postinst() {
	if ! use gksu && [[ -z ${REPLACING_VERSIONS} ]]; then
		ewarn "As things stand, this GUI must be launched by the root user, if it"
		ewarn "is to work correctly (otherwise, the I2C bus cannot be accessed)."
		ewarn "Consider re-emerging with the gksu USE flag set."
	fi
}

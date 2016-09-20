# Copyright (c) 2016 sakaki <sakaki@deciban.com>
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="6"

inherit eutils versionator

DESCRIPTION="Firmware loader for the Senoko battery/passthrough board"
HOMEPAGE="https://github.com/xobs/firmware-senoko"

# we take the firmware installer script from the firmware-senoko package, but,
# as we don't install the firmware blobs as well (preferring to build ourselves
# from scratch, via the sys-firmware/senoko-chibios package), we use
# update-senoko, rather than firmware-senoko, as our package name

# we assume this is major version 3
# versions of form 3.X.Y   fetch vX.Y.tar.gz    from GitHub
# versions of form 3.X.Y.Z fetch vX.Y-rZ.tar.gz from GitHub
# (trailing -rN in base name is reserved for ebuild revisions)
MY_PV="$(get_after_major_version)"
MY_PV="$(replace_version_separator 2 '-r' "${MY_PV}")"

SRC_URI="${HOMEPAGE}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"

RESTRICT="mirror"
LICENSE="BSD"
SLOT="3"
KEYWORDS="~arm"
IUSE=""

RDEPEND="
	>=sys-firmware/senoko-chibios-3.2.5
"

DEPEND="${RDEPEND}
"

src_unpack() {
	default
	# fix name for unpacked directory
	mv "${WORKDIR}/firmware-senoko-${MY_PV}" "${S}"
}

src_install() {
	default
	# just the script and its manpage (above "default" handles README.md)
	exeinto /usr/bin
	doexe ${PN}
	into /usr
	doman ${PN}.1
}

pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog "You can use the supplied ${PN} script to upload firmware to the"
		elog "Senoko battery/passthrough board on your Novena (assuming one is fitted)."
		elog "Appropriate uploadable firmware (as built from source by the"
		elog "sys-firmware/senoko-chibios package) may be found at"
		elog "/lib/firmware/senoko.hex; its underlying ELF-format binary at"
		elog "/usr/share/firmware-senoko/senoko.elf."
	fi
}

# Copyright (c) 2016 sakaki <sakaki@deciban.com>
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="6"

inherit eutils versionator

DESCRIPTION="Xorg configuration files for the Novena SBC"
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
	>=x11-drivers/xf86-video-armada-novena-0.0.1.16
	>=x11-base/xorg-server-1.18.3
	>=sys-fs/udev-225-r1
"

DEPEND="${RDEPEND}"

src_unpack() {
	default
	if [[ ${MY_PV} != ${PV} ]]; then
		# fix name for unpacked directory
		mv "${WORKDIR}/${PN}-${MY_PV}" "${S}"
	fi
}

src_install() {
	insinto /usr/share/X11/xorg.conf.d
	doins 60-novena.conf
	# we'll also insert the galcore udev rule for completeness, but it won't
	# be used (no kernel driver; kernel has to be patched explicitly to add)
	insinto /lib/udev/rules.d
	doins 98-galcore.rules
}


pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog "Your X display has been set up to use the 'armada' driver by default."
		elog "This is fully open-source (as configured) and should work well for most"
		elog "systems, but if you have trouble, simply delete the file"
		elog "/usr/share/X11/xorg.conf.d/60-novena.conf and restart; your system will"
		elog "then use the fallback 'modesetting' driver instead."
	fi
}

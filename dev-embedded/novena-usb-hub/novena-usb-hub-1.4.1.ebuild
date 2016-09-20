# Copyright (c) 2016 sakaki <sakaki@deciban.com>
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="6"

inherit eutils versionator

DESCRIPTION="Hub management (power control, etc.) for Novena"
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
	>=virtual/libusb-1
	>=sys-apps/openrc-0.21.3
	>=sys-power/pm-utils-1.4.1
"

DEPEND="${RDEPEND}
	virtual/pkgconfig
"

src_unpack() {
	default
	if [[ ${MY_PV} != ${PV} ]]; then
		# fix name for unpacked directory
		mv "${WORKDIR}/${PN}-${MY_PV}" "${S}"
	fi
}

src_prepare() {
	default
	# get rid of Debian-specific function in Makefile
	sed -i 's/$(shell[^)]*dpkg-buildflags[^)]*)//g' Makefile || die
}

src_install() {
	default
	# also deal with ancillary files not handled by make install
	newinitd "${FILESDIR}/init.d_${PN}" "${PN}"
	exeinto /etc/pm/sleep.d
	newexe "${FILESDIR}/pm_sleep.d_reset-bluetooth-port.sh" "reset-bluetooth-port.sh"
}

pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog "A OpenRC service has been created to ensure correct power-on behaviour."
		elog "To enable it, issue:"
		elog "-- # rc-update add ${PN} default"
		elog ""
		elog "Also, a sleep power-management hook function has been added to"
		elog "/etc/pm/sleep.d/"
		elog "However, this hook needs no further user action to activate."
	fi
}

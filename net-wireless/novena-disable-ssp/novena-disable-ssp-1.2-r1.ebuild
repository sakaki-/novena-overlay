# Copyright (c) 2016 sakaki <sakaki@deciban.com>
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="6"

inherit eutils versionator systemd

DESCRIPTION="Small daemon which disables SSP on all Bluetooth adaptors"
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
IUSE=""

RDEPEND="
	>=net-wireless/bluez-5.39
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
	epatch "${FILESDIR}"/${P}-remove-bswap_128-redefinition.patch
	# get rid of Debian-specific function in Makefile
	sed -i 's/$(shell[^)]*dpkg-buildflags[^)]*)//g' Makefile || die
}

src_install() {
	default
	# also deal with ancillary files not handled by make install
	newinitd "${FILESDIR}/init.d_${PN}" "${PN}"
	systemd_dounit "debian/${PN}.service"
}

pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog "To enable this service, add it to boot sequence and activate it:"
		if has_version sys-apps/openrc; then
			elog "-- # rc-update add ${PN} default"
			elog "-- # /etc/init.d/${PN} start"
		else
			# assume systemd
			elog "-- # systemctl enable ${PN}"
			elog "-- # systemctl start ${PN}"
		fi
	fi
}

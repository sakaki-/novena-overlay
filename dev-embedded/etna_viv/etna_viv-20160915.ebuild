# Copyright (c) 2016 sakaki <sakaki@deciban.com>
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="6"

inherit eutils autotools git-r3 linux-info

DESCRIPTION="FOSS user-space driver for the Vivante GCxxx series embedded GPUs"
HOMEPAGE="https://github.com/etnaviv/etna_viv"

SRC_URI=""
EGIT_REPO_URI="https://github.com/etnaviv/etna_viv.git"
EGIT_BRANCH="master"
# parse date into YYYY-MM-DD format that git rev-list understands
# will check out last commit < (NB not <=) date given
EGIT_COMMIT_DATE="${PV:0:4}-${PV:4:2}-${PV:6:2}"

RESTRICT="mirror"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~arm"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}"

pkg_setup() {
	elog "Checking kernel configuration..."
	linux-info_pkg_setup
	get_version
	if linux_config_exists; then
		if kernel_is -lt 4 5 0; then
			ewarn "You should use a kernel >= 4.5 with this library (which you"
			ewarn "do not appear to be), unless it is specially patched."
			ewarn "Assuming you know what you are doing, and proceeding."
		elif ! linux_chkconfig_present DRM_ETNAVIV; then
			ewarn "Your current kernel does not have DRM_ETNAVIV set."
			ewarn "Make sure it is before trying to use this library."
			ewarn "Assuming you know what you are doing, and proceeding."
		else
			elog "Kernel configuration OK"
		fi
	else
		ewarn "Cannot read current kernel config!"
		ewarn "Assuming you know what you are doing, and proceeding."
	fi
}

src_compile() {
	cd src || die
	emake GCABI="imx6_v4_1_0"
}

src_install() {
	# no provided (usable) install target for make
	# so handle manually
	dolib.a src/etnaviv/libetnaviv.a
	doheader -r src/etnaviv
	# we don't want any internal headers though
	rm -fv "${D}/usr/include/etnaviv/viv_internal.h"
	dodoc src/README.md
}

# Copyright (c) 2016 sakaki <sakaki@deciban.com>
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="5"

ETYPE="sources"
K_WANT_GENPATCHES="base"
K_GENPATCHES_VER="1"
K_DEBLOB_AVAILABLE="1"

inherit kernel-2
detect_version

BASE_SERVER_URI="https://github.com/sakaki-"
GITHUB_PROJECT="novena-overlay"
GITHUB_PATCHES="novena-kernel-patches"
NOVENA_HOMEPAGE_URI="${BASE_SERVER_URI}/${GITHUB_PROJECT}"
# manually set the r1 suffix on patchset; we generally won't want to do this
NOVENA_PATCHES_TARBALL="${GITHUB_PATCHES}-${PV}-r1.tar.gz"
NOVENA_PATCHES_URI="${BASE_SERVER_URI}/${GITHUB_PATCHES}/archive/v${PV}-r1.tar.gz -> ${NOVENA_PATCHES_TARBALL}"

HGPV="${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}-2"
HGPV_URI="http://dev.gentoo.org/~blueness/hardened-sources/hardened-patches/hardened-patches-${HGPV}.extras.tar.bz2"
SRC_URI="${KERNEL_URI} ${HGPV_URI} ${GENPATCHES_URI} ${ARCH_URI} ${NOVENA_PATCHES_URI}"

UNIPATCH_LIST="${DISTDIR}/hardened-patches-${HGPV}.extras.tar.bz2 ${DISTDIR}/${NOVENA_PATCHES_TARBALL}"
UNIPATCH_EXCLUDE="
	1500_XATTR_USER_PREFIX.patch
	2900_dev-root-proc-mount-fix.patch
"

UNIPATCH_STRICTORDER="yes"

DESCRIPTION="Hardened kernel sources (kernel series ${KV_MAJOR}.${KV_MINOR}) + Novena patchset"
HOMEPAGE="http://www.gentoo.org/proj/en/hardened/"
IUSE="+deblob"

KEYWORDS="~arm"

RDEPEND=">=sys-devel/gcc-4.5"
DEPEND="${RDEPEND}"

pkg_postinst() {
	kernel-2_pkg_postinst

	local GRADM_COMPAT="sys-apps/gradm-3.1*"

	ewarn
	ewarn "Users of grsecurity's RBAC system must ensure they are using"
	ewarn "${GRADM_COMPAT}, which is compatible with ${PF}."
	ewarn "It is strongly recommended that the following command is issued"
	ewarn "prior to booting a ${PF} kernel for the first time:"
	ewarn
	ewarn "emerge -na =${GRADM_COMPAT}"
	ewarn

	if has_version sys-devel/distcc; then
		einfo "It is not recommended to use distcc / pump when building this kernel."
		einfo "Perform a (normal) local make instead."
	fi

	if use deblob; then
		ewarn "This kernel will be deblobbed during build. As almost all devices on the"
		ewarn "Novena can operate under a 'libre' kernel, this is fine, but be aware that"
		ewarn "you will *not* have access to Bluetooth via the Atheros AR9462"
		ewarn "WiFi adaptor, as this requires uploaded firmware (WiFi access will work"
		ewarn "fine with a deblobbed kernel, however)."
		ewarn "If this bothers you, either re-emerge this package with the deblob USE"
		ewarn "flag unset, or use sys-kernel/novena-sources instead, or use a"
		ewarn "libre-compatible Bluetooth dongle."
	fi
}

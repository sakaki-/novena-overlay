# Copyright (c) 2016 sakaki <sakaki@deciban.com>
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="5"
ETYPE="sources"
K_WANT_GENPATCHES="base extras experimental"
K_GENPATCHES_VER="3"
K_SECURITY_UNSUPPORTED="1"

inherit kernel-2
detect_version
detect_arch

KEYWORDS="~arm"

BASE_SERVER_URI="https://github.com/sakaki-"
GITHUB_PROJECT="gentoo-novena-overlay"
GITHUB_PATCHES="novena-kernel-patches"
NOVENA_HOMEPAGE_URI="${BASE_SERVER_URI}/${GITHUB_PROJECT}"
NOVENA_PATCHES_TARBALL="${GITHUB_PATCHES}-${PV}.tar.gz"
NOVENA_PATCHES_URI="${BASE_SERVER_URI}/${GITHUB_PATCHES}/archive/v${PV}.tar.gz -> ${NOVENA_PATCHES_TARBALL}"

UNIPATCH_LIST="${DISTDIR}/${NOVENA_PATCHES_TARBALL}"
UNIPATCH_STRICTORDER="yes"
# add filenames of any patches you wish to exclude to the below list
UNIPATCH_EXCLUDE="
	1101-novena_defconfig-enable-minimal-GRKERNSEC.patch
"

HOMEPAGE="https://dev.gentoo.org/~mpagano/genpatches"
IUSE="experimental"

DESCRIPTION="Full sources with the Novena and Gentoo patchset for the ${KV_MAJOR}.${KV_MINOR} kernel tree"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI} ${NOVENA_PATCHES_URI}"

K_EXTRAELOG="Please direct issues with this kernel (on the Novena SBC)
to sakaki <sakaki@deciban.com>"


pkg_postinst() {
	kernel-2_pkg_postinst
	einfo "For more info on this patchset, and how to report problems, see:"
	einfo "${HOMEPAGE}"
}

pkg_postrm() {
	kernel-2_pkg_postrm
}

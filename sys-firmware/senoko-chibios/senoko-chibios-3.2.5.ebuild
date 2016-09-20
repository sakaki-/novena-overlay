# Copyright (c) 2016 sakaki <sakaki@deciban.com>
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="6"

inherit eutils versionator flag-o-matic

DESCRIPTION="Open-source ChibiOS firmware for the Senoko battery/passthrough board"
HOMEPAGE="https://github.com/xobs/${PN}-3"

# we assume this is major version 3
# versions of form 3.X.Y   fetch vX.Y.tar.gz    from GitHub
# versions of form 3.X.Y.Z fetch vX.Y-rZ.tar.gz from GitHub
# (trailing -rN in base name is reserved for ebuild revisions)
MY_PV="$(get_after_major_version)"
MY_PV="$(replace_version_separator 2 '-r' "${MY_PV}")"

SRC_URI="${HOMEPAGE}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"

RESTRICT="mirror distcc distcc-pump strip"
LICENSE="BSD"
SLOT="3"
KEYWORDS="~arm"
IUSE=""

RDEPEND="
"

DEPEND="${RDEPEND}
	>=sys-devel/gcc-4.9.3
"

# not actually 'PREBUILT', as we are going to build senoko.elf (and its
# derivative senoko.hex) from source... however, as we are cross-compiling
# we'll get scary-sounding QA warnings if we don't flag this (output) file
QA_PREBUILT="usr/share/firmware-senoko/senoko.elf"

src_unpack() {
	default
	# fix name for unpacked directory
	mv "${WORKDIR}/${PN}-3-${MY_PV}" "${S}"
}

src_prepare() {
	default
	# we avoid doing a git checkout just to set a value that records
	# the SHA-1 of HEAD (which is known a priori for GitHub tarballs,
	# given the tag)
	edos2unix senoko/Makefile
	epatch "${FILESDIR}"/${P}-set-gitversion.patch
}

src_compile() {
	cd "${S}/senoko" || die
	strip-flags
	emake USE_VERBOSE_COMPILE="yes"
}

src_install() {
	# install built firmware to the location expected by update-senoko
	insinto /lib/firmware
	doins senoko/build/senoko.hex
	# the elf version is just for reference
	insinto /usr/share/firmware-senoko
	doins senoko/build/senoko.elf
	dodoc senoko/README.md
}

pkg_postinst() {
	elog "Created /lib/firmware/senoko.hex; you may use the utility update-senoko"
	elog "(from package dev-embedded/update-senoko) to write this to the board."
	elog "For reference, the underlying ELF-format binary has also been saved, at"
	elog "/usr/share/firmware-senoko/senoko.elf."
}

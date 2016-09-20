# Copyright (c) 2016 sakaki <sakaki@deciban.com>
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="6"

inherit eutils autotools versionator

DESCRIPTION="Novena-packaged version of U-Boot"
HOMEPAGE="https://github.com/xobs/${PN}"

# base name versions of form X.Y   fetch vX.Y.tar.gz    from GitHub
# base name versions of form X.Y.Z fetch vX.Y.rZ.tar.gz from GitHub
# (trailing -rN in base name is reserved for ebuild revisions)
MY_PV="$(replace_version_separator 2 '.r')-novena"

SRC_URI="${HOMEPAGE}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"

RESTRICT="mirror"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~arm"
IUSE="caps"

RDEPEND="
"
DEPEND="${RDEPEND}
"

pkg_pretend() {
	# check that /boot is mounted
	if ! grep -q ' /boot ' 2>/dev/null <(mount); then
		die "You should have /boot mounted to install this package."
	fi
	# let's hope it stays that way until we're done!
}

src_unpack() {
	default
	if [[ ${MY_PV} != ${PV} ]]; then
		# fix name for unpacked directory
		mv "${WORKDIR}/${PN}-${MY_PV}" "${S}"
	fi
}

src_configure() {
	emake novena_config
}

src_install() {
	dosbin debian/novena-install-spl
	doman debian/novena-install-spl.8

	insinto "/usr/share/${PN}"
	doins u-boot.img
	newins SPL u-boot.spl
	
	exeinto /etc/kernel/postinst.d/
	newexe debian/novena-kernel-install-postinst zz-novena-kernel-install
}

pkg_postinst() {
	# call the Debian post-install script; this will copy u-boot.img and
	# u-boot.spl into /boot (let's hope it is still mounted!) and also
	# invoke novena-install-spl to write the u-boot.spl into the MBR
	# (MBR insert only happens if running kernel was invoked with either:
	#     root=PARTUUID=4e6f7653-03 or root=PARTUUID=4e6f764d-03
	# in its commandline).
	"${S}/debian/postinst" configure || die "Failed running postinst script"
	
	elog "The first-stage bootloader (aka secondary program loader, u-boot.spl)"
	elog "and the main, second-stage bootloader (u-boot.img) have been copied into both"
	elog "the /usr/share/${PN} and /boot directories."
	elog "Furthermore, u-boot.spl has also been written into the MBR of the Novena's"
	elog "on-board micro-SD card."
	elog ""
	elog "Should you need to write to the MBR of a different disk, you can use the"
	elog "provided utility /usr/sbin/novena-install-spl (a manpage for this has"
	elog "also been installed)."
}

pkg_prerm() {
	# mimic Debian's "prerm remove"
	if grep -q ' /boot ' 2>/dev/null <(mount); then
		rm -f /boot/u-boot.img
		rm -f /boot/u-boot.spl
	else
		# don't make this fatal, in case there's some nasty reason /boot
		# can't be mounted...
		ewarn "/boot is not mounted; you must manually mount it and then delete"
		ewarn "the files /boot/u-boot.{img,spl}, to complete the unmerge."
	fi
}

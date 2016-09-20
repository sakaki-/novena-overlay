# Copyright (c) 2016 sakaki <sakaki@deciban.com>
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="6"

inherit eutils autotools versionator

DESCRIPTION="Distribute hardware interrupts across processors on Novena"
HOMEPAGE="https://github.com/xobs/irqbalanced"

# base name versions of form X.Y   fetch vX.Y.tar.gz    from GitHub
# base name versions of form X.Y.Z fetch vX.Y-rZ.tar.gz from GitHub
# (trailing -rN in base name is reserved for ebuild revisions)
MY_PV="$(replace_version_separator 2 '-r')"

SRC_URI="${HOMEPAGE}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"

RESTRICT="mirror"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~arm"
IUSE="caps"

RDEPEND="dev-libs/glib:2
	caps? ( sys-libs/libcap-ng )
	>=sys-apps/openrc-0.21.3
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	!sys-apps/irqbalance
"

src_unpack() {
	default
	# NB untarred name is still 'irqbalanced' in GitHub tarball
	mv "${WORKDIR}/irqbalanced-${MY_PV}" "${S}"
}

src_prepare() {
	default
	epatch "${FILESDIR}"/${P}-build.patch
	mv cap-ng.m4 acinclude.m4 || die
	eautoreconf
}

src_configure() {
	# follow Debian package and place binary in /usr/sbin, not /sbin
	econf \
		--sbindir=/usr/sbin \
		$(use_with caps libcap-ng)
}

src_install() {
	default
	newinitd "${FILESDIR}"/irqbalance.init-0.55-r2 irqbalance
	newconfd "${FILESDIR}"/irqbalance.confd irqbalance
}

pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog "To enable this service, add it to boot sequence and activate it:"
		elog "-- # rc-update add irqbalance default"
		elog "-- # /etc/init.d/irqbalance start"
	fi
}

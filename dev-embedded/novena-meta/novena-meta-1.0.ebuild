# Copyright (c) 2016 sakaki <sakaki@deciban.com>
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="6"

DESCRIPTION="Merge this to pull in all baseline Novena packages"
HOMEPAGE=""
SRC_URI=""

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~arm"
IUSE="libre kernel u-boot +gui heirloom"

RDEPEND="
	kernel? (
		libre? (
			>=sys-kernel/novena_hardened-sources-4.7.2[deblob]
		)
		!libre? (
			>=sys-kernel/linux-firmware-20160331
			|| (
				>=sys-kernel/novena-sources-4.7.2
				>=sys-kernel/novena_hardened-sources-4.7.2
			)
		)
	)

	u-boot? (
		>=dev-embedded/u-boot-novena-2014.10.8
	)
	>=dev-embedded/novena-eeprom-2.3
	>=dev-embedded/novena-usb-hub-1.4.1
	>=sys-apps/irqbalance-novena-0.56
	>=media-sound/pulseaudio-novena-1.2
	>=sys-firmware/senoko-chibios-3.2.5
	>=dev-embedded/update-senoko-3.2.5
	>=net-wireless/novena-disable-ssp-1.2

	gui? (
		>=x11-drivers/xf86-video-armada-novena-0.0.1.16
		>=x11-misc/xorg-novena-1.7.1
		>=dev-embedded/novena-eeprom-gui-1.3.1
		>=sys-devel/portage-distccmon-gui-1.0
	)

	heirloom? (
		>=dev-embedded/novena-heirloom-1.1
	)
"

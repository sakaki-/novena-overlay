# Copyright (c) 2016 sakaki <sakaki@deciban.com>
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="6"

inherit eutils

DESCRIPTION="Support files for pulseaudio on the Novena SBC"
HOMEPAGE="https://github.com/xobs/${PN}"

SRC_URI="${HOMEPAGE}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

RESTRICT="mirror"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~arm"

RDEPEND="
	>=media-sound/pulseaudio-8.0
	>=sys-fs/udev-225-r1
"

DEPEND="${RDEPEND}"

src_install() {
	insinto /etc/pulse
	doins etc/pulse/novena.pa
	insinto /lib/udev/rules.d
	doins lib/udev/rules.d/*.rules
	insinto /usr/share/pulseaudio/alsa-mixer/profile-sets
	doins usr/share/pulseaudio/alsa-mixer/profile-sets/*.conf
	insinto /usr/share/pulseaudio/alsa-mixer/paths
	doins usr/share/pulseaudio/alsa-mixer/paths/*.conf
}

pkg_postinst() {
	elog "To get headphone output working, you _may_ need to unmute the left"
	elog "and right mixer channels (run alsamixer, press F6, select the"
	elog "imx-audio-es8328 sound card, press F3 to show playback controls,"
	elog "then scroll across and ensure both are unmuted; you can use the"
	elog "'m' button to mute/unmute)."
	elog ""
	elog "Also, to prevent crackling in the audio output, it is recommended"
	elog "to use the contents of /etc/pulse/novena.pa in /etc/pulse/default.pa"
	elog "To do this, run:"
	elog "-- # emerge --config media-sound/pulseaudio-novena"
}


# Debian allows one package to 'divert' the configuration files of another, but
# Gentoo frowns on this practice; so, rather than hijack media-sound/pulseaudio
# completely in this overlay, we will add a pkg_config step (which the user must
# run)

pkg_config() {
	if [ -s "${ROOT}"/etc/pulse/novena.pa ]; then
		if cmp --silent "${ROOT}"/etc/pulse/{default,novena}.pa; then
			einfo "The necessary changes have already been made; nothing to do."
		else
			einfo "Press ENTER to use the custom Novena setup for pulseaudio"
			einfo "(and restart the pulseaudio server), or Control-C to abort now..."
			read
			einfo "OK, modifying /etc/pulse/default.pa..."
			cp "${ROOT}/etc/pulse/default.pa" "${ROOT}/etc/pulse/default.pa.orig"
			cat "${ROOT}/etc/pulse/novena.pa" > "${ROOT}/etc/pulse/default.pa"
			export LNUSER="$(logname)"
			if [[ $LNUSER == "root" ]]; then
				# user shouldn't really be running a graphical login as root
				einfo "You are logged-in natively as root; NOT restarting pulseaudio"
				einfo "Please do so yourself now, if necessary"
			else
				einfo "Restarting pulseaudio..."
				# must do this as original user
				su - "${LNUSER}" -c 'pulseaudio --kill; pulseaudio --start'
			fi
			einfo ""
			einfo "All done. Your old configuration has been saved at"
			einfo "/etc/pulse/default.pa.orig, in case you should need to restore it."
		fi
	else
		eerror "Could not find configuration file ${ROOT}/etc/pulse/novena.pa!"
		die
	fi
}
#!/bin/sh

# ensure bluetooth power managed correctly across suspend / resume

case "$1" in
	hibernate|suspend)
		/usr/bin/novena-usb-hub -d u3
		;;
	thaw|resume)
		/usr/bin/novena-usb-hub -d u3
		/usr/bin/novena-usb-hub -e u3
		;;
esac

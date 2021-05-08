#!/bin/sh

. /etc/X11/xinit/xinitrc.d/*

if [ -d /etc/X11/xinit/xinitrc.d ]; then
	for f in /etc/X11/xinit/xinitrc.d/*; do
		[ -x $f ] && . $f
	done
	unset f
fi

xset +fp $HOME/.local/share/fonts
xset fp rehash

export PATH=$PATH:/home/marionette/bin
exec xmonad

#sxhkd -c ~/.config/berry/sxhkdrc &
#exec berry -c ~/.config/berry/autostart

#!/bin/sh

# /etc/X11/xinit/xinitrc
#
# global xinitrc file, used by all X sessions started by xinit (startx)

# invoke global X session script
. /etc/X11/Xsession

echo "Custom .Xresources loading"
xrdb -merge $HOME/.Xresources

echo "Custom .Xmodmap"
xmodmap $HOME/.Xmodmap

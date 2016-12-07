#!/bin/bash
#
# Emacs is started as daemon in /etc/systemd/user
#
# See https://bugs.launchpad.net/elementaryos/+bug/1355274
XLIB_SKIP_ARGB_VISUALS=1

emacsclient -t --alternate-editor="" --eval "(dired \"$1\")"

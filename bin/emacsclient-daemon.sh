#!/bin/bash
#
# Emacs is started as daemon in /etc/systemd/user
#
# See https://bugs.launchpad.net/elementaryos/+bug/1355274
#
# It accepts the -c/-t (defaulting to -c) parameter.

do_usage() {
    echo -n
    echo "Usage:"
    echo "$0 [-c|-t]"
    exit 1
}

XLIB_SKIP_ARGB_VISUALS=1

EMACS_BIN=$(which emacs)
EMACS_ICON=/usr/share/icons/hicolor/scalable/apps/emacs24.svg

if [ 0 -eq $(pgrep --exact --count emacs) ]
then
    echo "Starting server."
    notify-send -i "$EMACS_ICON" -u normal -h int:transient:1 "Starting server" "Please wait."

    $EMACS_BIN --daemon
fi

EMACS_PARAMS=""
EMACS_FILE=""
if [[ "$1" = "-c" || "$1" = "-t" ]] ; then
    EMACS_PARAMS="$1"
    EMACS_FILE="$2"
elif [ -e "$1" ] ; then
    EMACS_PARAMS="-c"
    EMACS_FILE="$1"
else
    do_usage
fi

emacsclient $EMACS_PARAMS -a emacs $EMACS_FILE

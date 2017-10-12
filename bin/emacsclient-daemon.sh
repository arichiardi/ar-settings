#!/bin/bash
#
# Emacs is started as daemon in /etc/systemd/user
#
# See https://bugs.launchpad.net/elementaryos/+bug/1355274
#
# It accepts the same parameters as emacs, adding -c if no -c or -nw is
# supplied (effectively defaulting to the graphical version of emacs).

set -ex

XLIB_SKIP_ARGB_VISUALS=1

EMACS_BIN=$(which emacs)
EMACSCLIENT_BIN=$(which emacsclient)
EMACS_ICON=/usr/share/icons/hicolor/scalable/apps/emacs25.svg

if [ 0 -eq $(pgrep --exact --count emacs) ]
then
    echo "Starting server."
    notify-send -i "$EMACS_ICON" -u normal -h int:transient:1 "Starting server" "Please wait."
    $EMACS_BIN --daemon
fi

EMACS_PARAMS="-a emacs $@"

if [[ ! ( ! "$EMACS_PARAMS" =~ "-c" && ! "$EMACS_PARAMS" =~ "-nw" ) ]]; then
    EMACS_PARAM="-c $EMACS_PARAMS"
fi

if [[ "$EMACS_PARAMS" =~ "-nw" ]]; then
    echo "Using plain emacs because of https://debbugs.gnu.org/cgi/bugreport.cgi?bug=28800"
    EMACSCLIENT_BIN=$EMACS_BIN
fi

$EMACSCLIENT_BIN $EMACS_PARAMS

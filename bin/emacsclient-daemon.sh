#!/bin/bash
#
# Emacs is started as daemon in /etc/systemd/user
#
# See https://bugs.launchpad.net/elementaryos/+bug/1355274
#
# It accepts the same parameters as emacs, adding -c if no -c or -nw is
# supplied (effectively defaulting to the graphical version of emacs).

set -e

export XLIB_SKIP_ARGB_VISUALS=1

emacs_bin=$(which emacs)
emacsclient_bin=$(which emacsclient)
emacs_icon=$HOME/.icons/emacs.svg

if [ 0 -eq $(pgrep --exact --count emacs) ]; then
    echo "Starting server."
    notify-send -i "$emacs_icon" -u normal -h "int:transient:1" "Starting server" "Please wait."
    $emacs_bin --no-splash --daemon
fi

emacs_params="-a emacs"

if [[ ! ( ! "$emacs_params" =~ "-c" && ! "$emacs_params" =~ "-nw" ) ]]; then
    emacs_param="-c $EMACS_PARAMS"
fi

$emacsclient_bin $emacs_params $@

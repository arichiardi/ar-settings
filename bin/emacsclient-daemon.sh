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

EMACS_ICON=/usr/share/icons/hicolor/scalable/apps/emacs24.svg
if [ ! "active" = $(systemctl --user is-active emacs.service) ]
then
    echo "Starting server."
    notify-send -i "$EMACS_ICON" -u normal -h int:transient:1 "Starting server" "Please wait."
    systemctl --user start emacs.service
    # kap - it is a systemd service now
    # emacsclient -t --alternate-editor="" "$@"

    while [ ! "active" = $(systemctl --user is-active emacs.service) ] ; do sleep 1 ; done
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

# Import vars in systemd user services$
# https://wiki.archlinux.org/index.php/Systemd/User$
systemctl --user import-environment PATH SSH_ENV LANG EDITOR VISUAL ALTERNATE_EDITOR GPGKEY MANPATH NODE_PATH BOOT_JVM_OPTIONS BOOT_COLOR

emacsclient $EMACS_PARAMS -a emacs $EMACS_FILE

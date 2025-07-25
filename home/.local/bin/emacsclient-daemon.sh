#!/bin/bash
#
# Emacs is started as daemon in /etc/systemd/user
#
# See https://bugs.launchpad.net/elementaryos/+bug/1355274
#
# It accepts the same parameters as emacs, adding -c if no -c or -nw is
# supplied (effectively defaulting to the graphical version of emacs).
set -uo pipefail

source $HOME/.local/share/ar/helpers.sh

emacs_bin=$(which emacs)
emacsclient_bin=$(which emacsclient)

if `is_os linux`; then
    emacs_icon=$HOME/.icons/emacs.svg
else
    emacs_icon=/System/Volumes/Data/opt/homebrew/Cellar/emacs-plus@30/30.1/Emacs.app/Contents/Resources/Emacs.icns
fi

notification_title="Emacs Server"
notification_msg="Starting, please wait."

is_running=false
if `is_os linux`; then
    running_count=$(pgrep --exact --count emacs)
    is_running=`test "$running_count" -gt 0 && echo true`
elif `is_os darwin`; then
    running_count=$(pgrep -x Emacs | uniq | wc -l)
    is_running=`test "$running_count" -gt 0 && echo true`
fi

if [ ! $is_running ]; then
    if `is_os linux`; then
        notify-send -i "$emacs_icon" -u normal -h "int:transient:1" "$notification_title" "$notification_msg"
    elif `is_os darwin`; then
        if `which -s terminal-notifier`; then
            terminal-notifier -message "$notification_msg" -title "$notification_title" -sender "org.gnu.Emacs"
        else
            osascript -e display notification "$notification_msg" with title "$notification_title"
        fi
    fi
fi

emacs_params="-a emacs"

if [[ ! ( ! "$emacs_params" =~ "-c" && ! "$emacs_params" =~ "-nw" ) ]]; then
    emacs_param="-c $emacs_param"
fi

if `is_os darwin`; then
    # Forcing profile sourcing because it does not seem to happen on macos
    source $HOME/.profile
fi

$emacsclient_bin $emacs_params "$@"

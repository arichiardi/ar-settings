#!/bin/sh
MAIN_NAME=$(xrandr | grep -E "eDP[0-9]+ connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
OTHER_NAME=$(xrandr | grep -E "DP1-?[0-9]+ connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")

XRANDR_COMMAND="xrandr --output $OTHER_NAME --mode 1680x1050 --pos 0x0 --rotate normal \
--output $MAIN_NAME --primary --mode 1920x1080 --pos 1680x0 --rotate normal \
--output VIRTUAL1 --off --output VGAi-1 --off"

eval $XRANDR_COMMAND

if [ "$?" -ne 0 ]; then
    echo "Failed: $XRANDR_COMMAND"
fi

exit 0

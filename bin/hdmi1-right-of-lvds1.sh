#!/bin/sh
HDMI_NAME=$(xrandr | grep -E "HDMI-?[0-9]+ connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
LVDS_NAME=$(xrandr | grep -E "LVDS-?[0-9]+ connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")

XRANDR_COMMAND="xrandr --output $HDMI_NAME --mode 1920x1080 --pos 1366x0 --rotate normal --output $LVDS_NAME --primary --mode 1366x768 --pos 0x0 --rotate normal --output VIRTUAL-1 --off --output DP-1 --off --output VGAi-1 --off"

eval $XRANDR_COMMAND

if [ "$?" -ne 0 ]; then
    echo "Failed: $XRANDR_COMMAND"
fi

exit 0

#!/bin/sh
MAIN_NAME=$(xrandr | grep -E "eDP[0-9]+ connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
OTHER_NAME=$(xrandr | grep -E "DP1-?[0-9]+ connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")

XRANDR_COMMAND="xrandr --output $MAIN_NAME --primary --mode 1920x1080 --pos 0x0 --rotate normal \
--output ${OTHER_ARRAY[0]} --off \
--output ${OTHER_ARRAY[1]} --off \
--output VIRTUAL-1 --off --output DPi-1 --off --output VGAi-1 --off"

eval $XRANDR_COMMAND

if [ "$?" -ne 0 ]; then
    echo "Failed: $XRANDR_COMMAND"
fi

exit 0

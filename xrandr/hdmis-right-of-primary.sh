#!/bin/bash
MAIN_NAME=$(xrandr | grep -E "eDP[0-9]+ connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
OTHER_NAME=$(xrandr | grep -E "DP1-?[0-9]+ connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")

# The blank space, which is part of the IFS shell variable, is used by default
# in arrays assignment.
declare -a OTHER_ARRAY
OTHER_ARRAY=($OTHER_NAME)

XRANDR_COMMAND="xrandr --output ${OTHER_ARRAY[1]} --mode 1680x1050 --pos 0x0 --rotate normal \
--output ${OTHER_ARRAY[0]} --primary --mode 1680x1050 --pos 1680x0 --rotate normal \
--output $MAIN_NAME --mode 1920x1080 --pos 3600x0 --rotate normal \
--output VIRTUAL1 --off"

eval $XRANDR_COMMAND

if [ "$?" -ne 0 ]; then
    echo "Failed: $XRANDR_COMMAND"
fi

exit 0

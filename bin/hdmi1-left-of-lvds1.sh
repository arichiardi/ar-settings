#!/bin/bash

set -uo pipefail

main_xrandr=$(xrandr --query | grep -E 'eDP[0-9]+ connected')
main_name=$(echo "$main_xrandr" | awk -F '[ x+]' '/\<connected\>/{print $1}')
main_width=$(echo "$main_xrandr" | awk -F '[ x+]' '/\<connected\>/{print $4}')
main_height=$(echo "$main_xrandr" | awk -F '[ x+]' '/\<connected\>/{print $5}')
main_resolution=$main_width"x"$main_height

# detecting external monitors
external_name=$(xrandr --query | grep -E "DP1-?[0-9]+ connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
if [ -z "$external_name" ]; then
    external_name=$(xrandr --query | grep -E "HDMI-?[0-9]+ connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
fi
if [ -z "$external_name" ]; then
    echo "Failed: cannot find external monitors."
    exit 1
fi

external_xrandr=$(xrandr --query | grep "$external_name")
external_width=$(echo "$external_xrandr" | awk -F '[ x+]' '/\<connected\>/{print $3}')
external_height=$(echo "$external_xrandr" | awk -F '[ x+]' '/\<connected\>/{print $4}')

# can be specified as parameter
external_resolution=${1:-$external_width"x"$external_height}

if [[ ! "$external_resolution" =~ ^[0-9]+[xX]{1}[0-9]+$ ]]; then
   echo "Failed: resolution has to be \"width\"x\"height\" (was $external_resolution)".
   exit 1
fi

external_position="0x0"
main_position=$external_width"x0"

# The blank space, which is part of the IFS shell variable, is used by default
# in arrays assignment. external_name will contain a space separated list that we
# convert to array.
declare -a external_array
external_array=($external_name)

cmd="xrandr --output ${external_array[0]} --mode $external_resolution --pos $external_position --rotate normal \
 --output $main_name --primary --mode $main_resolution --pos $main_position --rotate normal \
 --output VIRTUAL1 --off --output VGA1 --off"

eval $cmd

if [ "$?" -ne 0 ]; then
    echo "Failed: $cmd"
fi

exit 0

#!/bin/bash

set -uo pipefail

# The name assigned to the main monitor (usually the laptop's)
main_id=${1:-}
if [ -z $main_id ]; then
    echo "Failed: you need to specify a monitor id as first parameter."
    exit 1
fi

# This can be either an index in the xrandr size table or width x height
external_size=${2:-"0"}

main_xrandr=$(xrandr --query | grep -E "$main_id"'-?[0-9]* connected' | sed -e "s/[[:blank:]]primary//")
main_name=$(echo "$main_xrandr" | awk -F '[ x+]' '/\<connected\>/{print $1}')
main_width=$(echo "$main_xrandr" | awk -F '[ x+]' '/\<connected\>/{print $3}')
main_height=$(echo "$main_xrandr" | awk -F '[ x+]' '/\<connected\>/{print $4}')
main_resolution=$main_width"x"$main_height

# detecting external monitors
external_name=$(xrandr --query | grep -E "^DP1-?[0-9]* connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
if [ -z "$external_name" ]; then
    external_name=$(xrandr --query | grep -E "^HDMI-?[0-9]* connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
fi

if [ -z "$external_name" ]; then
    echo "Failed: cannot find external monitors."
    exit 1
fi

external_position=$main_width"x0"
main_position=0x0

# The blank space, which is part of the IFS shell variable, is used by default
# in arrays assignment. external_name will contain a space separated list that we
# convert to array.
declare -a external_array
external_array=($external_name)

cmd="xrandr --output ${external_array[0]} --size $external_size --pos $external_position --rotate normal \
--output $main_name --primary --mode $main_resolution --pos $main_position --rotate normal \
--output VIRTUAL1 --off --output VGAi-1 --off"

eval $cmd

if [ "$?" -ne 0 ]; then
    echo "Failed: $cmd"
fi

exit 0

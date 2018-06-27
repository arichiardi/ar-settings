#!/bin/bash

set -ueo pipefail

# The name assigned to the main monitor (usually the laptop's)
main_id=${1:-}
if [ -z $main_id ]; then
    echo "Failed: you need to specify a monitor id as first parameter."
    exit 1
fi

main_xrandr=$(xrandr --query | grep -E "$main_id"'-?[0-9]* connected' | sed -e "s/[[:blank:]]primary//")
main_name=$(echo "$main_xrandr" | awk -F '[ x+]' '/\<connected\>/{print $1}')
main_width=$(echo "$main_xrandr" | awk -F '[ x+]' '/\<connected\>/{print $3}')
main_height=$(echo "$main_xrandr" | awk -F '[ x+]' '/\<connected\>/{print $4}')
main_resolution=$main_width"x"$main_height

# detecting external monitors
set +e
external_name=$(xrandr --query | grep -E "^DP1-?[0-9]* connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
set -e

if [ -z "$external_name" ]; then
    set -e
    external_name=$(xrandr --query | grep -E "^HDMI-?[0-9]* connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
    set +e
fi

if [ -z "$external_name" ]; then
    echo "Failed: cannot find external monitors."
    exit 1
fi

external_position=$main_width"x0"

external_resolution=${2:-}

# grepping the resolution in the "connected" line
if [[ ! "$external_resolution" =~ ^[0-9]+[xX]{1}[0-9]+ ]]; then
    external_xrandr=$(xrandr --query | grep "$external_name" | sed -e "s/[[:blank:]]primary//")
    computed_width=$(echo "$external_xrandr" | awk -F '[ x+]' '/\<connected\>/{print $3}')
    computed_height=$(echo "$external_xrandr" | awk -F '[ x+]' '/\<connected\>/{print $4}')
    external_resolution=$computed_width"x"$computed_height
    unset computed_width
    unset external_height
fi

# grepping the list of resolutions for the first mode
if [[ ! "$external_resolution" =~ [0-9]+[xX]{1}[0-9]+ ]]; then
    external_first_mode=$(xrandr --query | grep -A 2 "$external_name" | tail -n +2 | head -n 1)
    external_resolution=$(echo "$external_first_mode" | awk -F ' ' '{print $1}')
fi

# has to be width x height if specified
if [[ -n "$external_resolution" && ! "$external_resolution" =~ ^[0-9]+[xX]{1}[0-9]+$ ]]; then
   echo "Failed: resolution has to be \"width\"x\"height\" (was $external_resolution)".
   exit 1
fi

# The blank space, which is part of the IFS shell variable, is used by default
# in arrays assignment. external_name will contain a space separated list that we
# convert to array.
declare -a external_array
external_array=($external_name)
main_position=0x0

cmd="xrandr --output ${external_array[0]} --mode $external_resolution --pos $external_position --rotate normal \
--output $main_name --primary --mode $main_resolution --pos $main_position --rotate normal \
--output VIRTUAL1 --off"

set +e
eval $cmd
set -e

if [ "$?" -ne 0 ]; then
    echo "Failed!"
else
    echo "Success!"
fi

exit 0

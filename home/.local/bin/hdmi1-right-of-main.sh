#!/bin/bash

set -euo pipefail

# The name assigned to the main monitor (usually the laptop's)
main_id=${1:-}
if [ -z $main_id ]; then
    echo "Failed: you need to specify a monitor id as first parameter."
    exit 1
fi

# 23-01-2021 - New variables and overrides cause I want to try HiDPI settings with my 4K.
framebuffer_dpi=192
main_resolution=1920x1080
main_scale=2x2
external_id=DP1
external_resolution=3840x2160
external_position=3840x0
external_scale=1x1

main_xrandr=$(xrandr --query | grep -E "$main_id"'-?[0-9]* connected' | sed -e "s/[[:blank:]]primary//")
main_name=$(echo "$main_xrandr" | awk -F '[ x+]' '/\<connected\>/{print $1}')

if [[ ! "$main_resolution" =~ [0-9]+[xX]{1}[0-9]+ ]]; then
    main_width=$(echo "$main_xrandr" | awk -F '[ x+]' '/\<connected\>/{print $3}')
    main_height=$(echo "$main_xrandr" | awk -F '[ x+]' '/\<connected\>/{print $4}')
    main_resolution=$main_width"x"$main_height
fi

# detecting external monitors
set +e
external_name=$(xrandr --query | grep -E "^$external_id-?[0-9]* connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
set -e

if [ -z "$external_name" ]; then
    set +e
    external_name=$(xrandr --query | grep -E "^HDMI-?[0-9]* connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
    set -e
fi

if [ -z "$external_name" ]; then
    echo "Failed: cannot find external monitors."
    exit 1
fi

# grepping the list of resolutions for the highest resolution
if [[ ! "$external_resolution" =~ [0-9]+[xX]{1}[0-9]+ ]]; then
    set +e
    external_first_mode=$(xrandr --query | grep -A 2 "$external_name" | tail -n +2 | head -n 1)
    set -e
    external_resolution=$(echo "$external_first_mode" | awk -F ' ' '{print $1}')
fi

# grepping the resolution in the "connected" line
if [[ ! "$external_resolution" =~ ^[0-9]+[xX]{1}[0-9]+ ]]; then
    set +e
    external_xrandr=$(xrandr --query | grep "$external_name" | sed -e "s/[[:blank:]]primary//")
    set -e
    computed_width=$(echo "$external_xrandr" | awk -F '[ x+]' '/\<connected\>/{print $3}')
    computed_height=$(echo "$external_xrandr" | awk -F '[ x+]' '/\<connected\>/{print $4}')
    external_resolution=$computed_width"x"$computed_height
    external_position=$main_width"x0"
    unset computed_width
    unset external_height
fi

# has to be width x height if specified
if [[ -n "$external_resolution" && ! "$external_resolution" =~ ^[0-9]+[xX]{1}[0-9]+$ ]]; then
   echo "Failed: resolution has to be \"width\"x\"height\" (was $external_resolution)".
   exit 1
fi

# The blank space, which is part of the IFS shell variable, is used by default in arrays
# assignment. external_name will contain a space separated list that we convert to array.
declare -a external_array
external_array=($external_name)
main_position=0x0

cmd="xrandr --dpi $framebuffer_dpi \
--output $main_name --primary --mode $main_resolution --scale $main_scale --pos $main_position --rotate normal \
--output ${external_array[0]} --mode $external_resolution --scale $external_scale  --pos $external_position --rotate normal \
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

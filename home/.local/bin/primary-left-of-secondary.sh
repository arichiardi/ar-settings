#!/bin/bash

set -euo pipefail

# The name assigned to the primary monitor (in xrandr parlance)
primary_id=${1:-}
if [ -z $primary_id ]; then
    echo "Failed: you need to specify a primary monitor id as first parameter."
    exit 1
fi

secondary_id=${2:-}
if [ -z $secondary_id ]; then
    non_primary_ids=()
    for id in $(xrandr --query | awk -F '[ x+]' '!/primary|Screen/{print $1}' | xargs); do
        non_primary_ids+=( $id )
    done
    secondary_id=${non_primary_ids[0]}
    if [ -z $secondary_id ]; then
        echo "Failed: cannot automatically detect the secondary monitor id."
        exit 1
    fi
fi

# 23-01-2021 - New variables and overrides cause I want to try HiDPI settings with my 4K.
framebuffer_dpi=96
primary_resolution=1920x1080
primary_scale=1x1
secondary_resolution=1920x1080
secondary_position=1920x0
secondary_scale=1x1

primary_xrandr=$(xrandr --query | grep -E "$primary_id"'-?[0-9]* connected' | sed -e "s/[[:blank:]]primary//")
primary_name=$(echo "$primary_xrandr" | awk -F '[ x+]' '/\<connected\>/{print $1}')

if [[ ! "$primary_resolution" =~ [0-9]+[xX]{1}[0-9]+ ]]; then
    primary_width=$(echo "$primary_xrandr" | awk -F '[ x+]' '/\<connected\>/{print $3}')
    primary_height=$(echo "$primary_xrandr" | awk -F '[ x+]' '/\<connected\>/{print $4}')
    primary_resolution=$primary_width"x"$primary_height
fi

# detecting external monitors
set +e
secondary_name=$(xrandr --query | grep -E "^$secondary_id-?[0-9]* connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
set -e

if [ -z "$secondary_name" ]; then
    set +e
    secondary_name=$(xrandr --query | grep -E "^HDMI-?[0-9]* connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
    set -e
fi

if [ -z "$secondary_name" ]; then
    echo "Failed: cannot find external monitors."
    exit 1
fi

# grepping the list of resolutions for the highest resolution
if [[ ! "$secondary_resolution" =~ [0-9]+[xX]{1}[0-9]+ ]]; then
    set +e
    secondary_first_mode=$(xrandr --query | grep -A 2 "$secondary_name" | tail -n +2 | head -n 1)
    set -e
    secondary_resolution=$(echo "$secondary_first_mode" | awk -F ' ' '{print $1}')
fi

# grepping the resolution in the "connected" line
if [[ ! "$secondary_resolution" =~ ^[0-9]+[xX]{1}[0-9]+ ]]; then
    set +e
    secondary_xrandr=$(xrandr --query | grep "$secondary_name" | sed -e "s/[[:blank:]]primary//")
    set -e
    computed_width=$(echo "$secondary_xrandr" | awk -F '[ x+]' '/\<connected\>/{print $3}')
    computed_height=$(echo "$secondary_xrandr" | awk -F '[ x+]' '/\<connected\>/{print $4}')
    secondary_resolution=$computed_width"x"$computed_height
    secondary_position=$primary_width"x0"
    unset computed_width
    unset secondary_height
fi

# has to be width x height if specified
if [[ -n "$secondary_resolution" && ! "$secondary_resolution" =~ ^[0-9]+[xX]{1}[0-9]+$ ]]; then
   echo "Failed: resolution has to be \"width\"x\"height\" (was $secondary_resolution)".
   exit 1
fi

# The blank space, which is part of the IFS shell variable, is used by default in arrays
# assignment. secondary_name will contain a space separated list that we convert to array.
declare -a secondary_array
secondary_array=($secondary_name)
primary_position=0x0

cmd="xrandr --dpi $framebuffer_dpi \
--output $primary_name --primary --mode $primary_resolution --scale $primary_scale --pos $primary_position --rotate normal \
--output ${secondary_array[0]} --mode $secondary_resolution --scale $secondary_scale  --pos $secondary_position --rotate normal \
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

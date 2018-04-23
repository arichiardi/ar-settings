#!/bin/bash

set -uo pipefail

# The name assigned to the main monitor (usually the laptop's)
main_id=${1:-}
if [ -z $main_id ]; then
    echo "Failed: you need to specify a monitor id as first parameter."
    exit 1
fi

main_name=$(xrandr --query | grep -E "$main_id"'-?[0-9]* connected' | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")

# detecting external monitors
external_name=$(xrandr --query | grep -E "^DP1-?[0-9]* connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
if [ -z $external_name ]; then
    external_name=$(xrandr --query | grep -E "^HDMI-?[0-9]* connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
fi
if [ -z $external_name ]; then
    echo "Failed: cannot find external monitors."
    exit 1
fi

# The blank space, which is part of the IFS shell variable, is used by default
# in arrays assignment. The external_name var will contain a space separated
# list that we convert to array.
declare -a external_array
external_array=($external_name)

# everything hardcoded for now

cmd="xrandr --output ${external_array[1]} --mode 1680x1050 --pos 0x0 --rotate normal \
--output ${external_array[0]} --primary --mode 1680x1050 --pos 1680x0 --rotate normal \
--output $main_name --mode 1920x1080 --pos 3360x0 --rotate normal \
--output VIRTUAL1 --off"

eval $cmd

if [ "$?" -ne 0 ]; then
    echo "Failed: $cmd"
fi

exit 0

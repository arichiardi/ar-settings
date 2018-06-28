#!/bin/bash

set -xeuo pipefail

# The name assigned to the main monitor (usually the laptop's)
main_id=${1:-}
if [ -z $main_id ]; then
    echo "Failed: you need to specify a monitor id as first parameter."
    exit 1
fi

set +e
main_name=$(xrandr --query | grep -E "$main_id"'-?[0-9]* connected' | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
set -e


# The blank space, which is part of the IFS shell variable, is used by default
# in arrays assignment. The external_name var will contain a space separated
# list that we convert to array.
declare -a external_array

set +e
external_array=($(xrandr --query | grep -E "^DP1-?[0-9]* connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/"))
set -e

if [ ${#external_array[@]} -eq 0 ]; then
    set +e
    external_array=($(xrandr --query | grep -E "^HDMI-?[0-9]* connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/"))
    set -e
fi

if [ ${#external_array[@]} -eq 0 ]; then
    echo "Failed: cannot find external monitors."
    exit 1
fi

cmd="xrandr --output ${external_array[1]} --mode 1680x1050 --pos 0x0 --rotate normal \
--output ${external_array[0]} --primary --mode 1680x1050 --pos 1680x0 --rotate normal \
--output $main_name --mode 1920x1080 --pos 3360x0 --rotate normal \
--output VIRTUAL1 --off"

eval $cmd

if [ "$?" -ne 0 ]; then
    echo "Failed!"
else
    echo "Success!"
fi

exit 0

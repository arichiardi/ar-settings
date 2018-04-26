#!/bin/bash

set -uo pipefail

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
external_name=$(xrandr --query | grep -E "^DP1-?[0-9]* connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
if [ -z "$external_name" ]; then
    external_name=$(xrandr --query | grep -E "^HDMI-?[0-9]* connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
fi

# The blank space, which is part of the IFS shell variable, is used by default
# in arrays assignment. external_name will contain a space separated list that we
# convert to array.
declare -a external_array
external_array=($external_name)

external_lenght=${#external_array[@]}

if [[ $external_lenght > 0 ]]; then
    output_args=

    for (( i=0; i<${external_lenght}; i++ ));
    do
        output_args="$output_args""--output ${external_array[i]} --off "
    done

    cmd="xrandr --output $main_name --primary --mode $main_resolution --pos 0x0 --rotate normal $output_args"

    eval $cmd

    if [ "$?" -ne 0 ]; then
        echo "Failed: $cmd"
    fi
fi

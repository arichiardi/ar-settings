#!/bin/bash

set -xeuo pipefail
scriptdir="$(cd "$(dirname "$0")"; pwd -P)"

# Start
do_usage() {
    echo
    echo "TODO."
    echo
    echo "Usage:"
    echo " -p|--primary <xrandr id> -l|left <xrandr id> -r|--right <xrandr id>"
    exit 1
}

do_error() {
  echo $1
  echo
  do_usage
  exit 1
}

set +e
TEMP=`getopt -o hp:r:l: --long help,primary:,left:,right: -n 'primary-between-displays.sh' -- "$@"`
set -e
eval set -- "$TEMP"

primary_id=
left_id=
right_id=

while true ; do
    case "$1" in
        -p|--primary) primary_id="$2" ; shift 2 ;;
        -r|--right) right_id="$2" ; shift 2 ;;
        -l|--left) left_id="$2" ; shift 2 ;;
        -h|--help) shift ; do_usage ; break ;;
        --) shift ; break ;;
        *) do_usage ; exit 1 ;;
    esac
done

# The name assigned to the primary monitor (in xrandr parlance)
if [ -z $primary_id ]; then
    do_error "Failed: you need to specify a primary monitor id."
fi

if [ -z $left_id ]; then
    do_error "Failed: you need to specify a left monitor id."
fi

if [ -z $right_id ]; then
    do_error "Failed: you need to specify a right monitor id."
fi

connected_ids=()

for id in $(xrandr --query | awk -F '[ x+]' '/\<connected\>/{print $1}' | xargs); do
    connected_ids+=( $id )
done

echo "${connected_ids[@]}"
right_connected=no
left_connected=no
for id in "${connected_ids[@]}"
do
    if [ "$id" == "$right_id" ]; then
       right_connected=yes
    elif [ "$id" == "$left_id" ]; then
       left_connected=yes
    fi
done

if [ "$left_connected" == "no" ]; then
    do_error "Failed: the specified left monitor does not exist or is disconnected"
fi
if [ "$right_connected" == "no" ]; then
    do_error "Failed: the specified right monitor does not exist or is disconnected"
fi

function current_resolution() {
    # First and only parameter will be the monitor id
    local monitor_id=$1
    set +e
    local xrandr_query=$(xrandr --query | grep -w "$monitor_id" | sed -e "s/[[:blank:]]primary//")
    set -e
    local computed_width=$(echo "$xrandr_query" | awk -F '[ x+]' '/\<connected\>/{print $3}')
    local computed_height=$(echo "$xrandr_query" | awk -F '[ x+]' '/\<connected\>/{print $4}')

    echo $computed_width"x"$computed_height
}

# 23-01-2021 - New variables and overrides cause I want to try HiDPI settings with my 4K.
framebuffer_dpi=96

###################
# Primary Monitor #
###################
primary_resolution=
primary_scale=1x1

if [[ ! "$primary_resolution" =~ [0-9]+[xX]{1}[0-9]+ ]]; then
    primary_resolution=$(current_resolution $primary_id)
fi

primary_width=$(echo "$primary_resolution" | awk -F 'x' '{print $1}')
primary_height=$(echo "$primary_resolution" | awk -F 'x' '{print $2}')

################
# Left monitor #
################

left_resolution=
left_scale=1x1
left_width=
left_height=

if [[ ! "$left_resolution" =~ [0-9]+[xX]{1}[0-9]+ ]]; then
    left_resolution=$(current_resolution $left_id)
fi

# has to be width x height if specified
if [[ -n "$left_resolution" && ! "$left_resolution" =~ ^[0-9]+[xX]{1}[0-9]+$ ]]; then
   echo "Failed: resolution has to be \"width\"x\"height\" (was $left_resolution)".
   exit 64
fi

left_width=$(echo "$left_resolution" | awk -F 'x' '{print $1}')
left_height=$(echo "$left_resolution" | awk -F 'x' '{print $2}')

#################
# Right monitor #
#################

right_resolution=
right_position=1920x0
right_scale=1x1

if [[ ! "$right_resolution" =~ [0-9]+[xX]{1}[0-9]+ ]]; then
    right_resolution=$(current_resolution $right_id)
fi

if [[ -n "$right_resolution" && ! "$right_resolution" =~ ^[0-9]+[xX]{1}[0-9]+$ ]]; then
   echo "Failed: resolution has to be \"width\"x\"height\" (was $right_resolution)".
   exit 64
fi

left_position="0x0"
primary_position="$left_width"x0
right_position="$(($left_width + $primary_width))x0"

cmd="xrandr --dpi $framebuffer_dpi \
--output $primary_id --primary --mode $primary_resolution --scale $primary_scale --pos $primary_position \
--output $right_id --mode $right_resolution --scale $right_scale  --pos $right_position \
--output $left_id --mode $left_resolution --scale $left_scale  --pos $left_position"

set +e
eval $cmd
set -e

if [ "$?" -ne 0 ]; then
    echo "Failed!"
else
    echo "Success!"
fi

exit 0

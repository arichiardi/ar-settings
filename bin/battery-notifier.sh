#! /bin/bash -x
#
# Notify when the battery is under a certain percentage
#
SLEEP_TIME_IF_SAFE=30    # Time between checks in minutes when safe.
SLEEP_TIME_IF_WARNING=10 # Time between checks in minutes when warning.
SLEEP_TIME_IF_CRITICAL=5 # Time between checks in minutes when critical.
SAFE_PERCENT=30          # Still safe at this level.
WARNING_PERCENT=20       # Warn when battery at this level.
CRITICAL_PERCENT=7       # Notify more often when battery is at this level.
NOTIFICATION_TIME=10     # Notification expiration time.
BATTERY_DEVICE=BAT0      # The battery device ID.

while [ true ]; do

    status=$(cat /sys/class/power_supply/$BATTERY_DEVICE/status)

    if [[ -n $(echo $status | grep -i discharging) ]]; then
        percentage=$(cat /sys/class/power_supply/$BATTERY_DEVICE/capacity)

        if [[ $percentage -gt $SAFE_PERCENT ]]; then
            SLEEP_TIME=$((SLEEP_TIME_IF_SAFE))
        else
            SLEEP_TIME=$((SLEEP_TIME_IF_WARNING))

            if [[ $percentage -ge $CRITICAL_PERCENT && $percentage -le $WARNING_PERCENT ]]; then
                notify-send -t $((NOTIFICATION_TIME)) -u normal -i battery-low "Battery level is getting low ($percentage%)"
            elif [[ $percentage -le $CRITICAL_PERCENT ]]; then
                SLEEP_TIME=$((SLEEP_TIME_IF_CRITICAL))
                notify-send -t $((NOTIFICATION_TIME)) -u normal -i battery-caution "Battery level is critical ($percentage%)"
            fi
            # if [[ $rem_bat -le $CRITICAL_PERCENT ]]; then
            #     SLEEP_TIME=1
            #     pm-hibernate
            # fi
        fi
    else
        SLEEP_TIME=$((SLEEP_TIME_IF_SAFE))
    fi

    sleep ${SLEEP_TIME}m

done

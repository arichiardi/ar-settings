#!/usr/bin/env bash
# Print the CPU status tail for conky: usage, temperature, and power draw, on
# one line. Conky prefixes the `CPU` label and appends this output:
#
#   12% • 41°C • 88.4 W
#
# A field name prints a single number, for a small spot in the conky config.
# The usage form reads one /proc/stat row, so it works for one core at a time,
# like conky's $cpu and $cpucore:
#
#   conky_cpu_status.sh             12% • 41°C • 88.4 W
#   conky_cpu_status.sh cpu         12
#   conky_cpu_status.sh cpu 3       7
#
# Each part is optional. The script prints only the parts it can measure, and it
# adds " • " between them, never at the end. A machine with no sensor support
# prints the usage alone, or nothing, and exits 0.
#
# This file replaces inline pipelines in the conky config. Conky cannot read a
# multi-line ${execi} object: the object spans lines, so conky drops it and
# renders nothing. It also parses one line at a time, so an ${if_match} block
# must open and close on the same line. A script keeps the branches readable and
# leaves no nesting in the config.
#
# Source of each part:
#   usage  /proc/stat, first "cpu" row, against the last snapshot. See cpu_usage.
#   temp   sensors Tctl, for the zenpower driver on AMD Zen, else coretemp
#          Package id for Intel.
#   power  sysfs accelerated_amd_energy_measure/techdev_tpower_ave, AMD's package
#          power per CCD, in milliwatts. When that is absent, fall back to
#          sensors: RAPL_P_Package for AMD, then the sum of the SVI2_P_ rails,
#          then Intel coretemp Power (1sec). Print nothing when both fail.
#
# Portability: check every input with an `if`. When sensors is missing, lm-sensors
# has no chips configured, or a driver exposes no such label, that part prints
# nothing and the script still exits 0. The conky config calls this from a plain
# ${execi}, so a machine without support shows the CPU usage alone.
#
# Two rules for the sensors parsers:
#
# 1. End every read in awk. Under `set -e` and pipefail, a grep with no match
#    fails its branch. Guard each grep with an `if`, or let awk print nothing.
# 2. Strip non-digit text from a field, then test it: gsub(/[^0-9.]/, "", v).
#    The unit is the last field, so $NF returns "W". A label can hold spaces,
#    e.g. "Package id 0:" and "Power (1sec):", so the value is not always field
#    2. Test each candidate in awk's own script: shell arithmetic on a string
#    such as "48.0°C" dies with a arithmetic error, and gsub in a shell
#    parameter expansion takes an unquoted pattern.
#
# Latency: the script is state-free. It stores no files, and it reads /proc/stat
# and the sensors sources on each call. CPU usage takes two samples one second
# apart, so every status call costs one second. Conky runs an ${execi} command on
# its own update_interval of 1.0 seconds, so this window matches conky's $cpu.
# Measure with "time ~/.config/conky/conky_cpu_status.sh". Keep the sensors read to
# one run per call, through the cache in read_sensors: a `sensors` scan is slow,
# and an ${execi} blocks conky's refresh while it runs.

set -euo pipefail

uid=$(id -u)
sensors_cache=/tmp/conky-sensors.$uid.$$

# Read the cpu row of /proc/stat once, and print "idle total". Args: core number,
# or "" for the whole CPU. The row holds cumulative jiffies: user, nice, system,
# idle, iowait, irq, softirq, steal. A bare `read` cannot take this row, because
# the label lands in field 1 and shifts every value by one; that off-by-one made
# idle read a busy count, so usage printed a fixed value. Match $1 in awk: "cpu"
# matches only the whole-CPU row, "cpu3" matches that core alone. Print nothing
# when the row is missing, e.g. a core taken offline by CPU hotplug.
stat_row() {
    local label
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        label="cpu$1"
    else
        label=cpu
    fi
    awk -v label="$label" '$1 == label {
        idle = $5 + $6
        total = $2 + $3 + $4 + $5 + $6 + $7 + $8 + $9
        printf "%d %d\n", idle, total
        exit
    }' /proc/stat 2>/dev/null
}

# Print CPU usage as a whole percentage, with no stored state. Take two samples of
# the cpu row, one second apart: jiffies are cumulative, so one read yields no
# rate. Keep the window at one second, to match conky's $cpu and conky's
# update_interval = 1.0. The call costs one second, and an ${execi} in conky
# blocks that refresh. Print nothing when the row is missing. Args: core number,
# or "" for the whole CPU.
cpu_usage() {
    local a b
    a=$(stat_row "$1") || true
    if [[ -z "$a" ]]; then
        return 0
    fi
    sleep 1
    b=$(stat_row "$1") || true
    if [[ -z "$b" ]]; then
        return 0
    fi
    awk -v a="$a" -v b="$b" 'BEGIN {
        split(a, x, " "); split(b, y, " ")
        di = y[1] - x[1]; dt = y[2] - x[2]
        if (dt > 0) { printf "%d", (dt - di) * 100 / dt }
    }'
}

# Print the sensors snapshot for this call, and cache it inside the call. Cache a
# failed run too, so a missing binary costs one attempt, not one per field.
read_sensors() {
    if [[ ! -e "$sensors_cache" ]]; then
        sensors >"$sensors_cache" 2>/dev/null || : >"$sensors_cache"
    fi
    cat "$sensors_cache"
}

# Print the numeric value of a sensor label, e.g. "41.5". Args: output, pattern.
# A label is one line that starts with the pattern; walk its fields from right to
# left and print the first field that is a plain number after stripping units.
# Print nothing when no line matches.
sensor_value() {
    awk -v pat="$2" '$0 ~ pat {
        for (i = NF; i > 1; i--) {
            v = $i
            gsub(/[^0-9.]/, "", v)
            if (v ~ /^[0-9]+([.][0-9]+)?$/) { print v; exit }
        }
    }' <<<"$1"
}

# Print the sum of every sensor label that matches a pattern, e.g. the AMD SVI2
# power rails. Args: output, pattern. Print nothing when no line matches.
sensor_sum() {
    awk -v pat="$2" '$0 ~ pat {
        for (i = NF; i > 1; i--) {
            v = $i
            gsub(/[^0-9.]/, "", v)
            if (v ~ /^[0-9]+([.][0-9]+)?$/) { sum += v; n += 1; break }
        }
    } END { if (n > 0) printf "%.1f", sum }' <<<"$1"
}

# Return the sensor block for one chip. Args: output, pattern. A chip header
# starts a line, e.g. "zenpower-pci-00c3", and its block runs to the next blank
# line. Match at line start so a device path in an Adapter row cannot select it.
sensor_block() {
    sed -n "/^$2/,/^\$/p" <<<"$1"
}

# Print the CPU temperature as a plain number, e.g. "41.5", with no unit. Read
# Tctl from the zenpower block on AMD Zen; fall back to coretemp's package
# sensor on Intel. Print nothing when no label matches.
cpu_temp() {
    local out block
    if command -v sensors >/dev/null 2>&1; then
        out=$(read_sensors)
        block=$(sensor_block "$out" 'zenpower-')
        if [[ -n "$block" ]]; then
            sensor_value "$block" '^Tctl'
            return 0
        fi
        block=$(sensor_block "$out" 'coretemp-')
        if [[ -n "$block" ]]; then
            sensor_value "$block" '^Package'
        fi
    fi
}

# Print the package power draw from sysfs, as a plain number of watts. AMD
# exposes techdev_tpower_ave under accelerated_amd_energy_measure, in
# milliwatts. Only core 0 of each CCD exports it, so sum every node. Print
# nothing when the tree is absent, e.g. on Intel, in a VM, or on a kernel
# without this interface.
#
# Test each glob with -e before -r: an unmatched glob leaves the pattern text, and
# a non-matching test must not run. Read the node inside an `if`, because `set -e`
# and pipefail abort the whole function on a read that fails, e.g. a path that is
# a directory.
cpu_power_sysfs() {
    local node value mw=0 found=0
    if [[ ! -d /sys/devices/system/cpu ]]; then
        return 0
    fi
    for node in /sys/devices/system/cpu/cpu*/accelerated_amd_energy_measure/techdev_tpower_ave; do
        [[ -e "$node" && -r "$node" ]] || continue
        if value=$(<"$node"); then
            if [[ "$value" =~ ^[0-9]+$ ]]; then
                mw=$(( mw + value ))
                found=1
            fi
        fi
    done
    if (( found )); then
        awk -v m="$mw" 'BEGIN { printf "%.1f", m / 1000 }'
    fi
}

# Print the package power draw from sensors, as a plain number of watts, e.g.
# "88.4", with no unit. Read AMD's RAPL rail, then the sum of the SVI2_P_ rails,
# then Intel coretemp's power sensor. Print nothing when no label matches.
cpu_power_sensors() {
    local out block
    if command -v sensors >/dev/null 2>&1; then
        out=$(read_sensors)
        block=$(sensor_block "$out" 'zenpower-')
        if [[ -n "$block" ]]; then
            # RAPL names the package rail. Keep AMD's choice: prefer it, and sum
            # the SVI2 rails when no RAPL label exists on this kernel.
            if grep -q 'RAPL_P_Package' <<<"$block"; then
                sensor_value "$block" '^RAPL_P_Package'
            else
                sensor_sum "$block" '^SVI2_P_'
            fi
            return 0
        fi
        block=$(sensor_block "$out" 'coretemp-')
        if [[ -n "$block" ]]; then
            sensor_value "$block" '^Power'
        fi
    fi
}

# Print the status row, e.g. "12% • 41°C • 88.4 W". Print one number for a
# per-core call: "conky_cpu_status.sh cpu 3" prints CPU 3's usage, with no unit
# and no separator, like conky's $cpucore. The whole-CPU form "cpu" is the same
# number that starts the row.
main() {
    local arg="${1:-status}"
    local usage temp power sysfs out
    case "$arg" in
        status) ;;
        cpu | core)
            if [[ ! "${2:-}" =~ ^[0-9]+$ ]]; then
                echo "usage: ${0##*/} [status|cpu N]" >&2
                exit 2
            fi
            usage=$(cpu_usage "$2" || true)
            printf '%s\n' "${usage:-0}"
            return 0
            ;;
        *)
            echo "usage: ${0##*/} [status|cpu N]" >&2
            exit 2
            ;;
    esac

    usage=$(cpu_usage "" || true)
    temp=$(cpu_temp || true)

    out=()
    # A temperature of 0°C is a sensor that cannot measure, so drop it.
    temp_is_positive=0
    if [[ -n "$temp" ]] && (( $(awk -v t="$temp" 'BEGIN { print (t > 0) ? 1 : 0 }') )); then
        temp_is_positive=1
    fi

    # Resolve power last, and ask sensors only when sysfs has nothing. Each
    # source applies its own positive test, so a source that reads 0 reports
    # nothing and the next source is tried. This keeps sensors out of the common
    # AMD path.
    sysfs=$(cpu_power_sysfs || true)
    power=""
    if [[ "$sysfs" =~ ^[0-9]+([.][0-9]+)?$ ]] && (( $(awk -v p="$sysfs" 'BEGIN { print (p > 0) ? 1 : 0 }') )); then
        power="$sysfs"
    else
        power=$(cpu_power_sensors || true)
    fi
    power_is_positive=0
    if [[ "$power" =~ ^[0-9]+([.][0-9]+)?$ ]] && (( $(awk -v p="$power" 'BEGIN { print (p > 0) ? 1 : 0 }') )); then
        power_is_positive=1
    fi

    # Build the row from the parts that exist. Join with " • ", and add a unit
    # only to a part that is present, so a missing source leaves no gap and no
    # empty field.
    if [[ "$usage" =~ ^[0-9]+$ ]]; then
        out+=("${usage}%")
    fi
    if (( temp_is_positive )); then
        out+=("${temp}°C")
    fi
    if (( power_is_positive )); then
        # Print one decimal, as the config did. Sensors reports 88.40 W, and the
        # panel shows 88.4 W.
        out+=("$(awk -v p="$power" 'BEGIN { printf "%.1f", p }') W")
    fi

    for (( i = 0; i < ${#out[@]}; i++ )); do
        if (( i > 0 )); then
            printf ' • '
        fi
        printf '%s' "${out[i]}"
    done
    printf '\n'
}

main "$@"

# Remove the sensors snapshot on exit. The file lives in a shared directory, so a
# plain rm -f at entry would drop other users' cache and expose theirs. The name
# is unique per call, through uid and pid, so calls cannot collide.
rm -f "$sensors_cache"
exit 0

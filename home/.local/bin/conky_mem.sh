#!/usr/bin/env bash
# Print the whole RAM value for conky, on one line. Conky renders the output as
# a single string, so this file owns all memory logic that conky cannot
# express:
#
#   34/124GiB • 37.5/37.8°C
#
# Used memory first, then the total in GiB, one unit for both. The row shows
# used and total only: no percentage and no available figure. With no SPD5118
# sensor, the temperature group drops out and the row shows only the memory
# amount.
#
# A field name as the first argument prints one part, with no separator:
#
#   conky_mem.sh            34/124GiB • 37.5/37.8°C   (full string)
#   conky_mem.sh total      124
#   conky_mem.sh temps      37.5/37.8°C   (empty with no SPD5118 sensor)
#
# The `total` and `temps` fields read the cache, so a slow field does not run
# on every update. Conky calls them from its own ${execi} objects.
#
# Conky runs the full string once per update (execi 10). That leaves two rules:
#
# 1. It must finish fast. It renders conky's text once per update, so the
#    script has about ten seconds of work, not one shell call. `sensors` runs
#    on every call, and the memory total reads a cached copy.
# 2. A cache needs an mtime. Conky caches the output of ${execi}, so the file
#    content cannot tell the script that time passed. Use the mtime as the
#    clock, with `stat -c %Y`.
#
# Keep memory logic here, not in the conky config. Conky cannot read a
# multi-line ${execi} object: the object spans lines, so conky drops it and
# renders nothing.
#
# gawk note: `n++` as a statement inside {...} applies that block to the last
# input record only. Earlier values drop out of the join, so one stick
# disappears from the output. `n += 1` is not affected. Keep the `n += 1` form.

set -euo pipefail

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/conky"
cache_file="$cache_dir/mem-total"
total_max_age=86400   # seconds; the total changes on reboot only

# Print the RAM total in GiB, from a cache. Refresh when the cache is missing
# or older than `total_max_age`. MemTotal is in KiB, 1 GiB = 1048576 KiB.
# /proc/meminfo needs no extra binary.
mem_total() {
    local now age
    now=$(date +%s)
    if [[ -f "$cache_file" ]]; then
        age=$(( now - $(stat -c %Y "$cache_file") ))
        if (( age < total_max_age )); then
            cat "$cache_file"
            return 0
        fi
    fi

    local total
    total=$(awk '$1 == "MemTotal:" { printf "%d", $2 / 1048576 }' /proc/meminfo)
    mkdir -p "$cache_dir"
    printf '%s' "$total" > "$cache_file"
    printf '%s' "$total"
}

# Print the stick temperatures, e.g. "37.5/37.8°C", from one `sensors` run.
# Each SPD5118 DIMM sensor sits at i2c address 0x50 to 0x53. Keep the numeric
# part of its temp1 field, e.g. "+37.5°C" -> "37.5", and skip a stick with no
# number, e.g. "temp1: N/A". The values share one unit at the end, joined with
# "/" and no space, to match the tight "used/total" style of the row. Print
# nothing when no sensor is present.
mem_temps() {
    sensors \
        | grep -A2 -E '^spd5118-i2c-[0-9]+-5[0-3]$' \
        | grep 'temp1' \
        | awk '
            {
                t = $2
                gsub(/[^0-9.]/, "", t)
                if (t == "") { next }
                vals = vals (vals == "" ? "" : "/") t
                n += 1
            }
            END {
                if (n > 0) { printf "%s°C", vals }
            }
        '
}

# Print used memory as a plain GiB number, e.g. "34". The unit sits after the
# total in the row. MemAvailable is not read: this row wants used and total.
# The source is /proc/meminfo, so no extra binary runs.
#
# Used = MemTotal - MemFree - Buffers - SReclaimable. Do not subtract all of
# `Cached`: procps `free` does that, and its result matches "what the page care
# can hand back" (59 GiB on this box), not what processes hold. Conky's ${mem}
# uses the formula here, so the row keeps the number it showed before.
#
# A box with under 1 GiB used prints "0", which is what conky's ${mem} shows at
# that size.
mem_used() {
    awk '
        $1 == "MemTotal:"       { total = $2 }
        $1 == "MemFree:"        { free = $2 }
        $1 == "Buffers:"        { buffers = $2 }
        /^SReclaimable:/        { sreclaimable = $2 }
        END {
            used = total - free - buffers - sreclaimable
            printf "%d", used / 1048576
        }
    ' /proc/meminfo
}

used=$(mem_used)
total=$(mem_total)
temps=$(mem_temps || true)

case "${1:-}" in
    # One field only. No separator and no leading unit, so a caller can place
    # the value in its own spot.
    total)
        printf '%s\n' "$total"
        ;;
    temps)
        printf '%s\n' "$temps"
        ;;
    "")
        # The full RAM string: amount with one unit, then temperatures when
        # present.
        printf '%s/%sGiB' "$used" "$total"
        if [[ -n "$temps" ]]; then
            printf ' • %s' "$temps"
        fi
        printf '\n'
        ;;
    *)
        echo "usage: ${0##*/} [total|temps]" >&2
        exit 2
        ;;
esac

exit 0

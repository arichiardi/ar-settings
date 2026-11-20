#!/usr/bin/env bash
# Print the CPU product name for a conky row, on one line:
#
#   Ryzen 9 7950X
#
# The trim drops vendor text and a core-count phrase, so the row stays narrow. A
# sibling script, conky_cpu_freq.sh, prints peak and average MHz for the row
# below this one.
#
# Source of the name:
#   Linux    /proc/cpuinfo, the "model name" key. Every CPU in the file shares one
#            value on a normal box, so read the first row. See fs/proc/cpuinfo.c.
#   Windows  reg.exe, HKLM\Hardware\Description\System\CentralProcessor\0, value
#            ProcessorNameString. reg.exe runs from Linux under Wine and inside
#            WinPE, where it edits a mounted offline hive:
#            reg load "HKLM\offline" /path/Windows/System32/config/SOFTWARE. See
#            the Microsoft registry reference for that value name.
#   macOS    sysctl -n machdep.cpu.brand_string
#
# Trim rules, in order: drop a leading vendor word, then drop a core-count phrase
# such as "16-Core" or "32 CPU Cores", then drop trailing "Processor". The vendor
# rule lists AMD and Intel; an unknown vendor keeps its text. A box with no known
# source prints nothing and exits 0.
#
# Keep this file readable in one pass. Conky cannot read a multi-line ${execi}
# object: the object spans lines, so conky drops it and renders nothing.

set -euo pipefail

# Print the raw brand string for this platform, with vendor text and core count.
raw_name() {
    if [[ -r /proc/cpuinfo ]]; then
        awk -F': *' '/^model name/ { print $2; exit }' /proc/cpuinfo
        return 0
    fi
    # Windows: reg.exe, plain text, no quoting on the key path.
    if command -v reg >/dev/null 2>&1; then
        reg query "HKLM\Hardware\Description\System\CentralProcessor\0" \
            //v ProcessorNameString 2>/dev/null \
            | awk -F'Registry_SZ:' '/ProcessorNameString/ { sub(/^[ \\t]+/, "", $2); print $2; exit }'
        return 0
    fi
    if command -v sysctl >/dev/null 2>&1; then
        sysctl -n machdep.cpu.brand_string 2>/dev/null || true
    fi
}

# Print the trimmed name. Args: raw brand string.
trim_name() {
    sed -E 's/^(AMD|Intel) +//; s/[0-9]+([ -](Core|CPU))[ ]*[A-Za-z]*s?( Processor)?//g; s/ +Processor$//; s/ +$//' <<<"$1"
}

name=$(raw_name || true)
# Print no trailing newline: conky reads each ${execi} as literal text, and a
# newline ends an ${alignr} segment on the same row. tr -d drops the newline that
# sed adds.
if [[ -n "$name" ]]; then
    trim_name "$name" | tr -d "\n"
fi
exit 0

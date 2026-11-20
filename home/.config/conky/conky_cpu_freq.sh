#!/usr/bin/env bash
# Print peak and average CPU frequency for a conky row, on one line, with MHz
# last:
#
#   4951/3254 MHz
#
# The box has many cores, so it prints aggregates, not one value per core. Peak is
# the highest frequency in the sample. Average covers every core in the sample.
# The model name lives in cpu_brand.sh, on the row above this one: a wide name
# plus 32 frequencies cannot share one aligned row.
#
# A field name as the first argument prints one number, with no unit and no text,
# for a small spot in the conky config:
#
#   conky_cpu_freq.sh            4951/3254 MHz
#   conky_cpu_freq.sh peak       4951
#   conky_cpu_freq.sh avg        3254
#
# Power draw lives in conky_cpu_status.sh, on the CPU row with the temperature.
# Keep it there: one place for watts, and this row stays short.

# Frequency source: /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq, the
# same file conky's $freq reads. The file holds kHz, so divide by 1000 for MHz.
# Under AMD P-State (active, guided, or passive mode) the kernel fills that file
# from the APERF/MPERF ratio, which is the measured clock. Under the amd_cpufreq
# driver it holds the last requested frequency instead. Read
# /sys/devices/system/cpu/amd_pstate/status to learn which mode runs. See:
#   drivers/cpufreq/cpufreq.c            scaling_cur_freq show path
#   arch/x86/kernel/cpu/aperfmperf.c     arch_freq_get_on_cpu
#
# SMT counts each core twice: a 16-core CPU reports 32 cpufreq nodes. This script
# samples every node, so a thread that runs a busy sibling sets the peak.
#
# Portability: this script runs on any machine. The reader checks the sysfs tree
# with an `if` first, and each node with -e and -r. When the tree is missing, e.g.
# in a VM, on a non-Linux kernel, or without a cpufreq driver, the script prints
# the model name alone, peak and avg print nothing, and every path exits 0.
#
# The name loses vendor text and a core-count phrase, so the row stays narrow. A
# core with no readable node is skipped: CPU hotplug leaves no gap in the row.
# Keep this file readable in one pass. Conky cannot read a multi-line ${execi}
# object: the object spans lines, so conky drops it and renders nothing.

set -euo pipefail

field="${1:-}"

# Print one MHz value per online CPU, in numeric cpu order. The shell glob sorts
# by byte, so cpu10 lands before cpu2: pass the pairs through `sort -n` on the
# core number first. Test each glob with -e before -r, so an unmatched pattern is
# never read. Read inside an `if`: under `set -e` and pipefail a failed read
# aborts the function. Print nothing when the tree is absent.
cpu_freq_khz() {
    local node core khz
    if [[ ! -d /sys/devices/system/cpu ]]; then
        return 0
    fi
    for node in /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq; do
        [[ -e "$node" && -r "$node" ]] || continue
        if khz=$(<"$node"); then
            if [[ "$khz" =~ ^[0-9]+$ ]]; then
                core=${node#/sys/devices/system/cpu/cpu}
                core=${core%%/*}
                printf '%d %s\n' "$core" "$khz"
            fi
        fi
    done | sort -n -k1,1
}

# Reduce the MHz list to aggregates. Args: "peak" or "avg" print one number; ""
# prints the row text, with MHz last.
summarize() {
    local mode="$1"
    cpu_freq_khz | awk -v mode="$mode" '
        {
            mhz = int($2 / 1000)
            if (mhz <= 0) { next }
            n += 1
            sum += mhz
            if (n == 1 || mhz > peak) { peak = mhz }
        }
        END {
            if (n == 0) { exit }
            if (mode == "peak") { printf "%d", peak; exit }
            if (mode == "avg") { printf "%d", int(sum / n); exit }
            printf "%d/%d MHz", peak, int(sum / n)
        }
    '
}

case "$field" in
    peak | avg)
        summarize "$field"
        printf '\n'
        ;;
    "")
        # Print no trailing newline: conky reads each ${execi} as literal text, and a
        # newline ends an ${alignr} segment. Keep the newline only for field calls.
        summarize "" || true
        ;;
    *)
        echo "usage: ${0##*/} [peak|avg]" >&2
        exit 2
        ;;
esac

exit 0

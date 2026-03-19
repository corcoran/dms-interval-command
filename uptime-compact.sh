#!/bin/sh
# Compact uptime display with smart precision.
#
# By default, shows the two most relevant units:
#   months/weeks/days → down to hours
#   hours only        → hours + minutes
#   minutes only      → minutes + seconds
#
# Options:
#   --minutes   Always include minutes
#   --seconds   Always include minutes and seconds

show_minutes=0
show_seconds=0

for arg in "$@"; do
    case "$arg" in
        --minutes) show_minutes=1 ;;
        --seconds) show_seconds=1; show_minutes=1 ;;
        --help|-h)
            echo "Usage: uptime-compact.sh [OPTIONS]"
            echo ""
            echo "Display system uptime in a compact, readable format."
            echo "Shows the two most relevant time units by default."
            echo ""
            echo "Options:"
            echo "  --minutes   Always include minutes"
            echo "  --seconds   Always include minutes and seconds"
            echo "  --help, -h  Show this help message"
            exit 0
            ;;
    esac
done

total=$(awk '{printf "%d", $1}' /proc/uptime)

mo=$((total / 2592000))
d=$(((total % 2592000) / 86400))
h=$(((total % 86400) / 3600))
m=$(((total % 3600) / 60))
s=$((total % 60))
w=$((d / 7))
d=$((d % 7))

sep=" "
if [ "$mo" -gt 0 ]; then
    out="${mo}mo"
    [ "$w" -gt 0 ] && out="${out}${sep}${w}w"
    [ "$d" -gt 0 ] && out="${out}${sep}${d}d"
    [ "$h" -gt 0 ] && out="${out}${sep}${h}h"
    [ "$show_minutes" -eq 1 ] && out="${out}${sep}${m}m"
    [ "$show_seconds" -eq 1 ] && out="${out}${sep}${s}s"
elif [ "$w" -gt 0 ]; then
    out="${w}w"
    [ "$d" -gt 0 ] && out="${out}${sep}${d}d"
    [ "$h" -gt 0 ] && out="${out}${sep}${h}h"
    [ "$show_minutes" -eq 1 ] && out="${out}${sep}${m}m"
    [ "$show_seconds" -eq 1 ] && out="${out}${sep}${s}s"
elif [ "$d" -gt 0 ]; then
    out="${d}d${sep}${h}h"
    [ "$show_minutes" -eq 1 ] && out="${out}${sep}${m}m"
    [ "$show_seconds" -eq 1 ] && out="${out}${sep}${s}s"
elif [ "$h" -gt 0 ]; then
    out="${h}h${sep}${m}m"
    [ "$show_seconds" -eq 1 ] && out="${out}${sep}${s}s"
else
    out="${m}m${sep}${s}s"
fi

printf '%s\n' "$out"

#!/usr/bin/env bash
# Kill any running instance, then start one bar per connected monitor.
killall -q polybar
while pgrep -x polybar >/dev/null; do sleep 0.2; done

for m in $(polybar --list-monitors | cut -d: -f1); do
    MONITOR=$m polybar --reload main &
done

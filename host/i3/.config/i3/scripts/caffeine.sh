#!/usr/bin/env bash
# Toggle DPMS/screensaver. Polybar reads stdout; `toggle` flips state.
ACCENT="#7aa2f7"
DIM="#565f89"

STATE=$(xset q | grep "DPMS is" | awk '{print $3}')

if [ "$1" = "toggle" ]; then
  if [ "$STATE" = "Enabled" ]; then
    xset s off -dpms
    notify-send -u low "󰅶 Caffeine" "Screen will stay awake"
  else
    xset s on +dpms
    notify-send -u low "󰅽 Caffeine" "Auto-sleep restored"
  fi
else
  if [ "$STATE" = "Enabled" ]; then
    echo "%{F${DIM}}󰅽%{F-}"
  else
    echo "%{F${ACCENT}}󰅶%{F-}"
  fi
fi

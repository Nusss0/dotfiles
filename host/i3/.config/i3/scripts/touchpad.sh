#!/usr/bin/env bash
# Touchpad preferences. Looks the device up by name so the ID can change.
command -v xinput >/dev/null 2>&1 || exit 0

DEV=$(xinput list --name-only | grep -i touchpad | head -1)
[ -z "$DEV" ] && exit 0

set_prop() {
  xinput list-props "$DEV" | grep -q "$1" && \
    xinput set-prop "$DEV" "$1" "$2" 2>/dev/null
}

set_prop "libinput Tapping Enabled" 1
set_prop "libinput Natural Scrolling Enabled" 1
set_prop "libinput Disable While Typing Enabled" 1
set_prop "libinput Accel Speed" 0.4

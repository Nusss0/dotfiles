#!/usr/bin/env bash
OPTIONS="  Lock\n  Suspend\n  Logout\n  Reboot\n  Shutdown"

CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Power" \
  -theme-str 'window {width: 320px;} listview {lines: 5;} element-text {horizontal-align: 0.0; font: "JetBrainsMono Nerd Font 12";}')

case "$CHOICE" in
  *Lock*)     ~/.config/i3/scripts/lock.sh ;;
  *Suspend*)  systemctl suspend ;;
  *Logout*)   i3-msg exit ;;
  *Reboot*)   systemctl reboot ;;
  *Shutdown*) systemctl poweroff ;;
esac

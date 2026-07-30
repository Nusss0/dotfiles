#!/usr/bin/env bash
# Power menu. No input bar, so j/k navigate directly.
OPTIONS="  Lock\n  Suspend\n  Logout\n  Reboot\n  Shutdown"

THEME='
window   { width: 300px; border: 2px; border-color: #7aa2f7; border-radius: 10px;
           background-color: #1a1b26; padding: 12px; location: center; anchor: center; }
mainbox  { children: [ listview ]; background-color: transparent; }
listview { lines: 5; spacing: 4px; scrollbar: false; cycle: true;
           background-color: transparent; }
element  { padding: 10px 14px; border-radius: 6px; background-color: transparent;
           text-color: #c0caf5; cursor: pointer; }
element selected { background-color: #7aa2f7; text-color: #1a1b26; }
element-text { horizontal-align: 0.0; vertical-align: 0.5;
               background-color: transparent; text-color: inherit;
               font: "JetBrainsMono Nerd Font 12"; }
'

CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -p "" \
  -kb-row-down "j,Down" \
  -kb-row-up "k,Up" \
  -kb-cancel "Escape,q" \
  -theme-str "$THEME")

case "$CHOICE" in
  *Lock*)     ~/.config/i3/scripts/lock.sh ;;
  *Suspend*)  systemctl suspend ;;
  *Logout*)   i3-msg exit ;;
  *Reboot*)   systemctl reboot ;;
  *Shutdown*) systemctl poweroff ;;
esac

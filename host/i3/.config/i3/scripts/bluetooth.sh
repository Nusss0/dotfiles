#!/usr/bin/env bash
# Bluetooth manager in rofi. Pure bluetoothctl.
pgrep -x rofi >/dev/null && { pkill -x rofi; exit 0; }

ACCENT="#7aa2f7"
RED="#f7768e"

command -v bluetoothctl >/dev/null || { notify-send "Error" "bluetoothctl not found"; exit 1; }

SPLASH_PID=""
splash() {
  rofi -e "$1" -theme-str '
    window { width: 320px; border: 2px; border-color: #7aa2f7; border-radius: 10px;
             background-color: #1a1b26; padding: 24px; location: center; anchor: center; }
    textbox { text-color: #7aa2f7; horizontal-align: 0.5;
              font: "JetBrainsMono Nerd Font 13"; background-color: transparent; }
  ' >/dev/null 2>&1 &
  SPLASH_PID=$!
  sleep 0.15
}
unsplash() {
  [ -n "$SPLASH_PID" ] && kill "$SPLASH_PID" 2>/dev/null
  wait "$SPLASH_PID" 2>/dev/null
  SPLASH_PID=""
}

note() { notify-send -u low -t 2500 "$1" "$2"; }

menu() {
  echo "$1" | rofi -dmenu -i -p "$2" \
    -kb-row-down "Down,Control+j" -kb-row-up "Up,Control+k" \
    -theme-str "window {width: ${3:-480px};} listview {lines: ${4:-6};} element-text {horizontal-align: 0.0;}" \
    -mesg "$5"
}

status_line() {
  local powered connected
  powered=$(bluetoothctl show | awk '/Powered:/ {print $2}')
  if [ "$powered" != "yes" ]; then
    echo "<span color='$RED'><b>Adapter off</b></span>"
    return
  fi
  connected=$(bluetoothctl devices Connected | sed 's/^Device [0-9A-F:]* //' | paste -sd', ')
  if [ -n "$connected" ]; then
    echo "<span color='$ACCENT'><b>Connected:</b></span> $connected"
  else
    echo "<span color='#565f89'>No device connected</span>"
  fi
}

device_list() {
  bluetoothctl devices Paired | while read -r _ mac name; do
    if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
      echo "* $name|$mac"
    else
      echo "  $name|$mac"
    fi
  done
}

pick_device() {
  local list sel
  list=$(device_list)
  [ -z "$list" ] && { note "Bluetooth" "No paired devices"; return 1; }
  sel=$(menu "$(echo "$list" | cut -d'|' -f1)" "$1" "480px" "8" "<span color='#565f89'>* = connected</span>")
  [ -z "$sel" ] && return 1
  echo "$list" | grep -F "$sel|" | cut -d'|' -f2 | head -1
}

scan_pair() {
  splash "Scanning for devices…"
  bluetoothctl --timeout 12 scan on >/dev/null 2>&1
  unsplash
  local list sel mac
  list=$(bluetoothctl devices | sed 's/^Device //' | awk '{mac=$1; $1=""; sub(/^ /,""); print $0"|"mac}')
  [ -z "$list" ] && { note "Bluetooth" "No devices found"; return; }
  sel=$(menu "$(echo "$list" | cut -d'|' -f1)" "Pair" "560px" "10" "<span color='#565f89'>Select a device to pair</span>")
  [ -z "$sel" ] && return
  mac=$(echo "$list" | grep -F "$sel|" | cut -d'|' -f2 | head -1)
  splash "Pairing with $sel…"
  bluetoothctl pair "$mac" >/dev/null 2>&1
  bluetoothctl trust "$mac" >/dev/null 2>&1
  bluetoothctl connect "$mac" >/dev/null 2>&1
  local rc=$?
  unsplash
  [ $rc -eq 0 ] && note "Bluetooth" "Paired and connected: $sel" \
                || note "Bluetooth" "Pairing failed — try blueman for PIN devices"
}

main() {
  local powered opt_power choice mac
  powered=$(bluetoothctl show | awk '/Powered:/ {print $2}')
  [ "$powered" = "yes" ] && opt_power="Turn adapter off" || opt_power="Turn adapter on"

  choice=$(menu "Connect device
Disconnect device
Scan and pair
Open Blueman
$opt_power" "Bluetooth" "480px" "5" "$(status_line)")

  case "$choice" in
    "Connect device")
      mac=$(pick_device "Connect") || return
      splash "Connecting…"
      bluetoothctl connect "$mac" >/dev/null 2>&1
      local rc=$?
      unsplash
      [ $rc -eq 0 ] && note "Bluetooth" "Connected" || note "Bluetooth" "Connection failed"
      ;;
    "Disconnect device")
      mac=$(pick_device "Disconnect") || return
      bluetoothctl disconnect "$mac" >/dev/null 2>&1 && note "Bluetooth" "Disconnected"
      ;;
    "Scan and pair")     scan_pair ;;
    "Open Blueman")      blueman-manager & ;;
    "Turn adapter on")   bluetoothctl power on  >/dev/null 2>&1; note "Bluetooth" "Adapter on" ;;
    "Turn adapter off")  bluetoothctl power off >/dev/null 2>&1; note "Bluetooth" "Adapter off" ;;
  esac
}

main

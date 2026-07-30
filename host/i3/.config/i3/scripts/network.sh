#!/usr/bin/env bash
# Wifi manager in rofi. Pure nmcli.
ACCENT="#7aa2f7"
RED="#f7768e"

command -v nmcli >/dev/null || { notify-send "Error" "nmcli not found"; exit 1; }

note() { notify-send -u low -t 2500 "$1" "$2"; }

active_info() {
  local a name type ip
  a=$(nmcli -t -f NAME,TYPE,DEVICE connection show --active | head -n1)
  if [ -n "$a" ]; then
    name=$(echo "$a" | cut -d: -f1)
    type=$(echo "$a" | cut -d: -f2)
    ip=$(nmcli -g ip4.address connection show "$name" | head -n1 | cut -d/ -f1)
    echo "<span color='$ACCENT'><b>Connected:</b></span> $name ($type)
<span color='#565f89'><b>IP:</b> ${ip:-N/A}</span>"
  else
    echo "<span color='$RED'><b>Disconnected</b></span>"
  fi
}

connect_new() {
  local ssid="$1" pass
  pass=$(rofi -dmenu -password -p "Password" \
    -theme-str 'window {width: 450px;} listview {lines: 0;}' \
    -mesg "<span color='$ACCENT'>$ssid</span>")
  [ -z "$pass" ] && return
  note "Wi-Fi" "Connecting to $ssid..."
  if nmcli device wifi connect "$ssid" password "$pass" >/dev/null 2>&1; then
    note "Wi-Fi" "Connected to $ssid"
  else
    note "Wi-Fi" "Failed — wrong password?"
  fi
}

do_connect() {
  local ssid="$1"
  if nmcli connection show "$ssid" >/dev/null 2>&1; then
    note "Wi-Fi" "Connecting to saved: $ssid"
    nmcli connection up id "$ssid" >/dev/null 2>&1 && note "Wi-Fi" "Connected" || connect_new "$ssid"
  else
    connect_new "$ssid"
  fi
}

scan() {
  note "Wi-Fi" "Scanning..."
  local list sel ssid
  list=$(nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list --rescan yes |
    awk -F: 'length($2)>0 { mark = ($1=="*") ? "* " : "  "; printf "%s%-32s %3s%%  %s\n", mark, substr($2,1,32), $3, ($4=="" ? "open" : $4) }')
  [ -z "$list" ] && { note "Wi-Fi" "No networks found"; return; }
  sel=$(echo "$list" | rofi -dmenu -i -p "Wi-Fi" \
    -theme-str 'window {width: 700px;} listview {lines: 10;} element-text {font: "JetBrainsMono Nerd Font 10";}')
  [ -z "$sel" ] && return
  ssid=$(echo "${sel:2}" | sed 's/  *[0-9]*%.*$//' | sed 's/ *$//')
  do_connect "$ssid"
}

details() {
  nmcli -p device show | rofi -dmenu -p "Details" \
    -theme-str 'window {width: 950px;} listview {lines: 16;} element-text {font: "JetBrainsMono Nerd Font 9";}' >/dev/null
}

main() {
  local wifi net menu choice o_wifi o_net
  wifi=$(nmcli radio wifi)
  net=$(nmcli networking)
  [ "$wifi" = "enabled" ] && o_wifi="Disable Wi-Fi" || o_wifi="Enable Wi-Fi"
  [ "$net" = "enabled" ]  && o_net="Disable Networking" || o_net="Enable Networking"

  menu="Scan Networks
$o_wifi
Connection Details
Connection Editor
$o_net"

  choice=$(echo "$menu" | rofi -dmenu -i -p "Network" \
    -theme-str 'window {width: 450px;} listview {lines: 5;} element-text {horizontal-align: 0.0;}' \
    -mesg "$(active_info)")

  case "$choice" in
    "Scan Networks")       scan ;;
    "Enable Wi-Fi")        nmcli radio wifi on;  note "Wi-Fi" "On" ;;
    "Disable Wi-Fi")       nmcli radio wifi off; note "Wi-Fi" "Off" ;;
    "Connection Details")  details ;;
    "Connection Editor")   nm-connection-editor & ;;
    "Enable Networking")   nmcli networking on;  note "Network" "Enabled" ;;
    "Disable Networking")  nmcli networking off; note "Network" "Disabled" ;;
  esac
}

main

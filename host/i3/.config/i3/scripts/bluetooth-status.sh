#!/usr/bin/env bash
# Connected device name for polybar. Icon lives in the module prefix.
command -v bluetoothctl >/dev/null 2>&1 || exit 0

if [ "$(bluetoothctl show 2>/dev/null | awk '/Powered:/ {print $2}')" != "yes" ]; then
  echo "off"
  exit 0
fi

NAME=$(bluetoothctl devices Connected 2>/dev/null | head -1 | sed 's/^Device [0-9A-F:]* //')
[ -n "$NAME" ] && echo "$NAME" || echo "—"

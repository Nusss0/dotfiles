#!/usr/bin/env bash
# Reads cava's raw FIFO and prints block characters for polybar.
FIFO=/tmp/cava.fifo
BLOCKS=(" " "▁" "▂" "▃" "▄" "▅" "▆" "▇")

if ! command -v playerctl >/dev/null 2>&1 || \
   [ "$(playerctl status 2>/dev/null)" != "Playing" ]; then
  echo ""
  exit 0
fi

[ -p "$FIFO" ] || { echo ""; exit 0; }

if IFS= read -r -t 1 line < "$FIFO"; then
  out=""
  IFS=';' read -ra vals <<< "$line"
  for v in "${vals[@]}"; do
    [[ "$v" =~ ^[0-7]$ ]] && out+="${BLOCKS[$v]}"
  done
  echo "$out"
else
  echo ""
fi

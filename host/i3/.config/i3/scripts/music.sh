#!/usr/bin/env bash
# Track title + cava bars for polybar. Spotify first, browser as fallback.
FIFO=/tmp/cava.fifo
PLAYERS="spotify,chromium,firefox,%any"
BLOCKS=(" " "▁" "▂" "▃" "▄" "▅" "▆" "▇")

command -v playerctl >/dev/null 2>&1 || exit 0

STATUS=$(playerctl --player="$PLAYERS" status 2>/dev/null)
[ -z "$STATUS" ] && exit 0

TITLE=$(playerctl --player="$PLAYERS" metadata --format '{{title}}' 2>/dev/null)
[ -z "$TITLE" ] && exit 0
ARTIST=$(playerctl --player="$PLAYERS" metadata --format '{{artist}}' 2>/dev/null)
if [ -n "$ARTIST" ]; then
  TITLE="$(printf '%.20s' "$TITLE") - $(printf '%.16s' "$ARTIST")"
else
  TITLE=$(printf '%.30s' "$TITLE")
fi

if [ "$STATUS" != "Playing" ]; then
  echo "$TITLE"
  exit 0
fi

BARS=""
if [ -p "$FIFO" ] && IFS= read -r -t 1 line < "$FIFO"; then
  IFS=';' read -ra vals <<< "$line"
  for v in "${vals[@]}"; do
    [[ "$v" =~ ^[0-7]$ ]] && BARS+="${BLOCKS[$v]}"
  done
fi

echo "$BARS  $TITLE"

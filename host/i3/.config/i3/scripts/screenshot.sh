#!/usr/bin/env bash
# Region screenshot to clipboard. Delay lets held modifiers release.
sleep 0.4
maim -s -u -k 2>/tmp/maim.err | xclip -selection clipboard -t image/png
if [ -s /tmp/maim.err ]; then
  notify-send -u critical "Screenshot failed" "$(head -c 200 /tmp/maim.err)"
else
  notify-send -u low "Screenshot" "Copied to clipboard"
fi

#!/usr/bin/env bash
# Blurred lock with clock. i3lock-color installs as `i3lock`, so detect by feature.
BG="1a1b26"
RING="#7aa2f7cc"
TEXT="#c0caf5ee"
WRONG="#f7768ebb"
VERIFY="#7dcfffbb"
INSIDE="#1a1b2688"
BLANK="#00000000"

pgrep -x i3lock >/dev/null && exit 0

# Let any rofi window close and the compositor repaint before capturing.
if pgrep -x rofi >/dev/null; then
  pkill -x rofi
  for _ in $(seq 20); do pgrep -x rofi >/dev/null || break; sleep 0.05; done
fi
sleep 0.2

if ! i3lock --version 2>&1 | grep -q "\.c\."; then
  exec i3lock -n -c "$BG"
fi

exec i3lock -n \
  --blur 6 --clock --indicator \
  --radius=130 --ring-width=6 \
  --inside-color=$INSIDE --ring-color=$RING --line-color=$BLANK \
  --keyhl-color=$TEXT --bshl-color=$WRONG \
  --ringver-color=$VERIFY --insidever-color=$INSIDE --separator-color=$RING \
  --ringwrong-color=$WRONG --insidewrong-color=$INSIDE \
  --verif-color=$TEXT --wrong-color=$WRONG \
  --time-color=$TEXT --date-color=$TEXT \
  --time-str="%H:%M" --time-size=60 --time-pos="ix:iy+5" \
  --time-font="JetBrainsMono Nerd Font:style=ExtraBold" \
  --date-str="%A, %d %B" --date-size=14 --date-pos="ix:iy+35" \
  --date-font="JetBrainsMono Nerd Font:style=Bold" \
  --verif-text="Verifying" --verif-size=20 --verif-pos="ix:iy" \
  --wrong-text="Denied" --wrong-size=20 --wrong-pos="ix:iy" \
  --no-modkey-text --ignore-empty-password --pass-media-keys

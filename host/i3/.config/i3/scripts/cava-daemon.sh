#!/usr/bin/env bash
# Runs cava against the current default sink's monitor, restarting
# when the sink changes (e.g. bluetooth connect/disconnect).
FIFO=/tmp/cava.fifo
CFG=/tmp/cava.conf

cleanup() { pkill -x cava 2>/dev/null; rm -f "$FIFO" "$CFG"; }
trap cleanup EXIT INT TERM

write_config() {
  cat > "$CFG" << CFGEOF
[general]
framerate = 20
bars = 8
autosens = 1

[input]
method = pulse
source = $1

[output]
method = raw
raw_target = $FIFO
data_format = ascii
ascii_max_range = 7

[smoothing]
noise_reduction = 45
CFGEOF
}

rm -f "$FIFO"; mkfifo "$FIFO"
LAST=""

while true; do
  SINK=$(pactl info 2>/dev/null | awk -F': ' '/Default Sink/ {print $2}')
  MON="${SINK}.monitor"
  if [ -n "$SINK" ]; then
    # restart if the sink changed OR cava is no longer running
    if [ "$MON" != "$LAST" ] || ! pgrep -x cava >/dev/null; then
      pkill -x cava 2>/dev/null
      sleep 0.3
      write_config "$MON"
      cava -p "$CFG" >/dev/null 2>&1 &
      LAST="$MON"
    fi
  fi
  sleep 3
done

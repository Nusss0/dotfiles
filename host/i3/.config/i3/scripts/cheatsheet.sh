#!/usr/bin/env bash
# Single instance: pressing the key again closes it.
pgrep -x rofi >/dev/null && { pkill -x rofi; exit 0; }
# Searchable list of every i3 keybinding, parsed from the live config.
I3_CONF="$HOME/.config/i3/config"
ACCENT="#7aa2f7"

OUTPUT=$(awk '
  /^##[^#]/ { desc = substr($0, 3); gsub(/^[ \t]+|[ \t]+$/, "", desc); next }
  /^[ \t]*bindsym/ {
      line = $0
      sub(/^[ \t]*bindsym[ \t]+/, "", line)
      sub(/^--[a-z-]+[ \t]+/, "", line)
      idx = index(line, " ")
      if (idx == 0) next
      key = substr(line, 1, idx-1)
      cmd = substr(line, idx+1)
      sub(/^exec[ \t]+/, "", cmd)
      sub(/^--no-startup-id[ \t]+/, "", cmd)
      gsub(/^[ \t]+|[ \t]+$/, "", cmd)
      d = (desc == "") ? cmd : desc
      printf "%s|%s\n", key, d
      desc = ""
  }
' "$I3_CONF" | sed 's/\$mod/Super/g' | column -t -s '|' --output-separator '  │  ')

[ -z "$OUTPUT" ] && { rofi -e "No bindsym entries found in $I3_CONF"; exit 1; }

HEADER="<span color='$ACCENT'><b>  i3 KEYBINDINGS  </b></span>
<span color='#565f89' font='JetBrainsMono Nerd Font 9'>Type to filter  ·  Ctrl+J/K or arrows to scroll</span>"

OVERRIDE='
window   { width: 1100px; }
listview { lines: 18; spacing: 3px; cycle: false; }
element  { padding: 5px 10px; }
element-text { font: "JetBrainsMono Nerd Font 10"; }
'

echo "$OUTPUT" | rofi -dmenu -i -scroll-method 1 -p "Search" -theme-str "$OVERRIDE" -mesg "$HEADER" >/dev/null

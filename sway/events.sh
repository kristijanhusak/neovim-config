#!/bin/sh

handle_submap() {
  qs -c noctalia-shell ipc call plugin:submap refresh
}

swaymsg -t subscribe -m '[ "mode" ]' | while read -r _; do
  handle_submap
done &

swaymsg -t subscribe -m '[ "window" ]' | while read -r line; do
  if [ "$(printf '%s\n' "$line" | jq -r '.change')" = "new" ]; then
    if [ "$(swaymsg -t get_tree | jq -r '.. | select(.type?) | select(.focused == true).fullscreen_mode')" -eq 1 ]; then
      sleep 0.15
      swaymsg fullscreen disable
      swaymsg "[con_id=$(printf '%s\n' "$line" | jq -r '.container.id')]" focus
    fi
  fi
done &

wait

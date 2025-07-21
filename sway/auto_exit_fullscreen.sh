#!/bin/sh

swaymsg -t subscribe -m '[ "window" ]' | while read line
do
    if [ "$(echo "$line" | jq -r '.change')" = "new" ]; then
        if [ "$(swaymsg -t get_tree | jq -r '.. | select(.type?) | select(.focused==true).fullscreen_mode')" -eq 1 ]; then
            sleep 0.15
            swaymsg fullscreen disable
            swaymsg [con_id=$(echo "$line" | jq -r '.container.id')] focus
        fi
    fi
done

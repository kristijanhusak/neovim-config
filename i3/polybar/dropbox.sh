#!/bin/sh
status=$(dropbox-cli status)

if [[ "$status" == "Up to date" ]]; then
    echo "%{F#1f88ff}%{F-}"
elif [[ "$status" == "Syncing"* ]]; then
    echo "%{F#1f88ff}󰜷%{F-}"
elif [[ "$status" == "Connecting..." ]]; then
    echo "%{F#FFA500}󰇚%{F-}"
else
    echo "%{F#FF0000}%{F-}"
fi


#!/bin/bash

# --- Get Default Playback Output (Sink) ---
DEFAULT_SINK_NAME=$(pactl info | grep 'Default Sink' | awk '{print $3}')
DEFAULT_SINK_DESC=""

# Try to get the friendly description of the sink
if [[ -n "$DEFAULT_SINK_NAME" ]]; then
    DEFAULT_SINK_DESC=$(pactl list sinks | grep -A 5 "Name: $DEFAULT_SINK_NAME" | grep 'Description:' | sed 's/^[[:space:]]*Description:[[:space:]]*//')
    if [[ -z "$DEFAULT_SINK_DESC" ]]; then
        # Fallback to the name if description is not found (or empty)
        DEFAULT_SINK_DESC="$DEFAULT_SINK_NAME"
    fi
else
    DEFAULT_SINK_DESC="N/A (No default sink found)"
fi

# --- Get Default Microphone Input (Source) ---
DEFAULT_SOURCE_NAME=$(pactl info | grep 'Default Source' | awk '{print $3}')
DEFAULT_SOURCE_DESC=""

# Try to get the friendly description of the source
if [[ -n "$DEFAULT_SOURCE_NAME" ]]; then
    DEFAULT_SOURCE_DESC=$(pactl list sources | grep -A 5 "Name: $DEFAULT_SOURCE_NAME" | grep 'Description:' | sed 's/^[[:space:]]*Description:[[:space:]]*//')
    if [[ -z "$DEFAULT_SOURCE_DESC" ]]; then
        # Fallback to the name if description is not found (or empty)
        DEFAULT_SOURCE_DESC="$DEFAULT_SOURCE_NAME"
    fi
else
    DEFAULT_SOURCE_DESC="N/A (No default source found)"
fi

# --- Create and Send Notification ---
NOTIFICATION_TITLE="Current Audio Devices"
NOTIFICATION_BODY="Output: $DEFAULT_SINK_DESC\nInput: $DEFAULT_SOURCE_DESC"

notify-send "$NOTIFICATION_TITLE" "$NOTIFICATION_BODY" -i audio-speakers -t 3000

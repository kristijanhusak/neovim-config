#!/bin/bash

# Get a list of all sinks by name and their corresponding descriptions
mapfile -t SINK_DATA < <(pactl list sinks | awk '/^Sink #/ {sink_id=$2} /^\s*Name:/ {sink_name=$2} /^\s*Description:/ {gsub("^[ \t]*Description:[ \t]*", ""); sink_desc=$0; print sink_name "|" sink_desc}')

# Parse the data into two separate arrays: names and descriptions
SINK_NAMES=()
SINK_DESCRIPTIONS=()
for line in "${SINK_DATA[@]}"; do
    SINK_NAMES+=( "$(echo "$line" | cut -d'|' -f1)" )
    SINK_DESCRIPTIONS+=( "$(echo "$line" | cut -d'|' -f2)" )
done

# Get the current default sink name
DEFAULT_SINK_NAME=$(pactl info | grep 'Default Sink' | awk '{print $3}')

# Find the index of the current default sink
CURRENT_INDEX=-1
for i in "${!SINK_NAMES[@]}"; do
    if [[ "${SINK_NAMES[$i]}" == "$DEFAULT_SINK_NAME" ]]; then
        CURRENT_INDEX=$i
        break
    fi
done

# Calculate the next sink's index
NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#SINK_NAMES[@]} ))

# Get the name and description of the next sink
NEXT_SINK_NAME="${SINK_NAMES[$NEXT_INDEX]}"
NEXT_SINK_DESC="${SINK_DESCRIPTIONS[$NEXT_INDEX]}"

# Set the next sink as the default
pactl set-default-sink "$NEXT_SINK_NAME"

# Send a notification to confirm the switch with the human-readable description
NOTIF_BODY="Switched default output to: $NEXT_SINK_DESC"
notify-send "Audio Output Changed" "$NOTIF_BODY" -i audio-speakers -t 3000

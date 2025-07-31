#!/bin/sh

set -e
SHORT=$(curl -Ss --fail 'https://wttr.in?format=3')
TOOLTIP=$(curl -s --fail 'https://wttr.in?dT')
jq -c -n --arg text "$SHORT" --arg tooltip "$TOOLTIP" '{"text":$text,"tooltip":$tooltip}'

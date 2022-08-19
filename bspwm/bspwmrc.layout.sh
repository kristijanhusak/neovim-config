#!/usr/bin/env sh

PRIMARY=$(xrandr --query | grep " connected" | grep "primary" | cut -d" " -f1)
OTHERS=$(xrandr --query | grep " connected" | grep -v "primary" | cut -d" " -f1)

echo $PRIMARY
echo $OTHERS

if [[ "$OTHERS" = "" || "$PRIMARY" = "" ]]; then
  bspc monitor -d 1 2 3 4 5 6 7 8
else
  bspc monitor "$PRIMARY" -d 1 3 5 7
  for m in $OTHERS; do
    bspc monitor "$OTHERS" -d 2 4 6 8
  done
fi

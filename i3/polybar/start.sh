#!/usr/bin/env sh

PRIMARY=$(xrandr --query | grep " connected" | grep "primary" | cut -d" " -f1)
OTHERS=$(xrandr --query | grep " connected" | grep -v "primary" | cut -d" " -f1)

# Terminate already running bar instances
killall -q polybar > /dev/null

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done
MONITOR=$PRIMARY polybar bar &> /dev/null &

sleep 3;

for m in $OTHERS; do
    MONITOR=$m polybar bar &> /dev/null &
done

#!/usr/bin/env sh

# Terminate already running bar instances
killall -q polybar > /dev/null

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar bar &> /dev/null &
done

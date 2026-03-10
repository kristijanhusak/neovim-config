#!/bin/sh

activeworkspace=$(hyprctl activeworkspace -j)
activewindow=$(hyprctl activewindow -j)
clients=$(hyprctl clients -j)

echo "{
  \"activeworkspace\": $activeworkspace,
  \"activewindow\": $activewindow,
  \"clients\": $clients
}"

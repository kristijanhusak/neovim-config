#!/bin/sh

sleep 0.2 && grim -g "$(slurp)" ~/Pictures/screenshots/screenshot_$(date +%Y_%m_%d_%H_%M_%S).png

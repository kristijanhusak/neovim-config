#!/bin/sh

handle() {
  case $1 in
    submap*) handle_submap $1 ;;
  esac
}

handle_submap() {
  noctalia msg scripted-widget submap all refresh
}

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done


#!/bin/sh

handle() {
  case $1 in
    submap*) handle_submap $1 ;;
    activewindowv2*) handle_window $1 ;;
    openwindow*) handle_window $1 ;;
    closewindow*) handle_window $1 ;;
    movewindow*) handle_window $1 ;;
    workspacev2*) handle_window $1 ;;
  esac
}

handle_submap() {
  qs -c noctalia-shell ipc call plugin:submap refresh
}

handle_window() {
  qs -c noctalia-shell ipc call plugin:scrolling-windows refresh
}

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done


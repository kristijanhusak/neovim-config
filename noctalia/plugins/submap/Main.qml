import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services.UI
import qs.Commons
import qs.Widgets

Item {
  id: root

  property var pluginApi: null
  property string submapName: "default"

  function refreshSubmap() {
    submapProcess.running = true
  }

  IpcHandler {
    target: "plugin:submap"
    function refresh() {
      refreshSubmap()
    }
  }

  Component.onCompleted: {
    refreshSubmap()
  }

  Process {
    id: submapProcess

    command: [
      '/bin/sh',
      '-c',
      `
        if [ -n "$SWAYSOCK" ]; then
          swaymsg -r -t get_binding_state | jq -r '.name // "default"'
        elif [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
          hyprctl submap
        else
          printf 'default\n'
        fi
      `
    ]
    running: false

    stdout: StdioCollector {
    }

    onExited: exitCode => {
      if (exitCode !== 0) {
        Logger.e("Submap", "Failed to get submap, exit code:", exitCode);
        return;
      }

      try {
        submapName = stdout.text.trim() || "default";
      } catch (e) {
        Logger.e("Submap", "Failed to get submap:", e);
      }
    }
  }
}

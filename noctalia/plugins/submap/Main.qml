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

  IpcHandler {
    target: "plugin:submap"
    function refresh() {
      submapProcess.running = true
    }
  }

  Process {
    id: submapProcess

    command: ['/usr/bin/hyprctl', 'submap']
    running: false

    stdout: StdioCollector {
    }

    onExited: exitCode => {
      if (exitCode !== 0) {
        Logger.e("Submap", "Failed to get submap, exit code:", exitCode);
        return;
      }

      try {
        submapName = stdout.text.trim();
      } catch (e) {
        Logger.e("Submap", "Failed to get submap:", e);
      }
    }
  }
}

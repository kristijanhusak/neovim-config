import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Widgets
import qs.Services.UI
import qs.Services.Keyboard
import qs.Modules.Bar.Extras

Item {
  id: root

  // Required properties for bar widgets
  property var pluginApi: null
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""

  property string submapName: "default"

  visible: submapName != "default"
  implicitWidth: pill.width
  implicitHeight: pill.height

  BarPill {
    id: pill
    screen: root.screen
    autoHide: false
    forceOpen: true
    forceClose: submapName == "default"
    text: submapName.toUpperCase()
    customTextColor: Color.mError
  }

  Process {
    id: submapProcess

    command: ['/usr/bin/hyprctl', 'submap']
    running: false

    stdout: StdioCollector {
    }

    onExited: exitCode => {
      if (exitCode === 0) {
        try {
          submapName = stdout.text.trim();
        } catch (e) {
          Logger.e("Submap", "Failed to get submap:", e);
        }
      } else {
        Logger.e("Submap", "Failed to get submap, exit code:", exitCode);
      }
    }
  }

  IpcHandler {
    target: "plugin:submap"
    function refresh() {
      Logger.i("Submap", "refreshing submap")
      submapProcess.running = true;
    }
  }
}

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services.UI
import qs.Commons
import qs.Widgets

Item {
  id: root

  property var pluginApi: null
  property var monitorInfo: null
  property int leftCount: 0
  property int rightCount: 0

  Process {
    id: monitorInfoProcess

    command: ['/usr/bin/hyprctl', 'monitors', '-j']

    stdout: StdioCollector {}

    onExited: exitCode => {
      if (exitCode !== 0) {
        Logger.e("Scrolling windows", "Failed to get monitor info, exit code:", exitCode);
        return;
      }

      try {
        var response = JSON.parse(stdout.text);
        monitorInfo = response[0];
        activeWorkspaceProcess.running = true;
      } catch (e) {
        Logger.e("Scrolling windows", "Failed to get monitor info:", e);
      }
    }
  }

  Process {
    id: activeWorkspaceProcess

    command: ['/home/kristijan/.config/noctalia/plugins/scrolling-windows/info.sh']
    running: false

    stdout: StdioCollector {}

    onExited: exitCode => {
      if (exitCode !== 0) {
        Logger.e("Scrolling windows", "Failed to get windows info, exit code:", exitCode);
        return;
      }

      try {
        var response = JSON.parse(stdout.text);
        setOutput(response);
      } catch (e) {
        Logger.e("Scrolling windows", "Failed to get windows info:", e);
      }
    }
  }

  Component.onCompleted: {
    monitorInfoProcess.running = true;
  }


  IpcHandler {
    target: "plugin:scrolling-windows"
    function refresh() {
      activeWorkspaceProcess.running = true;
    }
  }

  function setOutput(info) {
    const { activeworkspace, activewindow, clients } = info;

    const workspaceWindows = clients.filter(window => Number(window.workspace.id) === Number(activeworkspace.id));

    if (workspaceWindows.length <= 1) {
      leftCount = 0;
      rightCount = 0;
      return;
    }

    const windowsOutside = workspaceWindows.filter(window => window.at[0] < 0 || window.at[0] >= monitorInfo.width)

    if (!windowsOutside.length) {
      leftCount = 0;
      rightCount = 0;
      return;
    }

    leftCount = windowsOutside.filter(window => window.at[0] < 0).length;
    rightCount = windowsOutside.filter(window => window.at[0] >= monitorInfo.width).length;
  }
}

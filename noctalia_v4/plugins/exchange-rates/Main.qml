import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services.UI
import qs.Commons
import qs.Widgets

Item {
  id: root

  property var pluginApi: null

  property string displayText: ""
  property string tooltip: ""
  property bool force: false

  function fetchRates(shouldForce = false) {
    Logger.i("ExchangeRates", "Fetching exchange rates...");
    force = shouldForce
    apiProcess.running = true
  }

  Component.onCompleted: {
    fetchRates();
  }

  Process {
    id: apiProcess

    command: ['/home/kristijan/.config/noctalia/plugins/exchange-rates/exchangerates.sh', force ? '--force' : '']
    running: false

    stdout: StdioCollector {
    }

    onExited: exitCode => {
      force = false
      if (exitCode === 0) {
        try {
          var response = JSON.parse(stdout.text);
          displayText = response.text;
          Logger.i("ExchangeRates", displayText);
          tooltip = response.tooltip;
        } catch (e) {
          Logger.e("ExchangeRates", "Failed to parse rates:", e);
        }
      } else {
        Logger.e("ExchangeRates", "Failed to fetch rates, exit code:", exitCode);
      }
    }
  }

  Timer {
    id: refreshTimer

    // Every 5 min
    interval: 5 * 60 * 1000
    repeat: true
    running: true

    onTriggered: {
      fetchRates()
    }
  }
}

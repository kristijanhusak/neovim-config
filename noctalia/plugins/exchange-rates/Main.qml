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

  function fetchRates() {
    Logger.i("ExchangeRates", "Fetching exchange rates...");
    apiProcess.running = true
  }

  Component.onCompleted: {
    fetchRates();
  }

  Process {
    id: apiProcess

    command: ['/home/kristijan/.config/noctalia/plugins/exchange-rates/exchangerates.sh']
    running: false

    stdout: StdioCollector {
    }

    onExited: exitCode => {
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

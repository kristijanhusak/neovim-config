import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Widgets
import qs.Services.UI
import qs.Modules.Bar.Extras


Item {
  id: root

  property ShellScreen screen

  // Widget properties passed from Bar.qml for per-instance settings
  property string widgetId: ""
  property string section: ""

  property string displayText: ""
  property string tooltip: ""
  property bool loading: false
  signal ratesUpdated

  implicitWidth: pill.width
  implicitHeight: pill.height

  function fetchRates() {
    Logger.i("ExchangeRates", "Fetching exchange rates...");
    if (loading) {
      return;
    }

    loading = true
    apiProcess.running = true
  }

  Component.onCompleted: {
    fetchRates();
  }

  Process {
    id: apiProcess

    command: ['/home/kristijan/.config/hyprpanel/exchangerates.sh']
    running: false

    stdout: StdioCollector {
    }

    onExited: exitCode => {
      loading = false;
      if (exitCode === 0) {
        try {
          var response = JSON.parse(stdout.text);
          displayText = response.text;
          Logger.i("ExchangeRates", displayText);
          tooltip = response.tooltip;
          ratesUpdated();
          pill.show();
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

  BarPill {
    id: pill
    oppositeDirection: true
    screen: root.screen
    autoHide: false
    forceOpen: true
    icon: "currency-dollar"
    text: displayText
    tooltipText: tooltip
  }
}


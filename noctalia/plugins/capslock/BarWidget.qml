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
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""
  property bool capslockEnabled: false

  implicitWidth: pill.width
  implicitHeight: pill.height

  visible: capslockEnabled

  Component.onCompleted: {
    var p = pill
    LockKeysService.registerComponent("submap");
    LockKeysService.capsLockChanged.connect(function(capslockActive) {
      capslockEnabled = capslockActive
    })
  }

  BarPill {
    id: pill
    screen: root.screen
    autoHide: false
    forceOpen: true
    forceClose: !capslockEnabled
    customTextColor: Color.mError
    text: "CAPSLOCK"
  }
}

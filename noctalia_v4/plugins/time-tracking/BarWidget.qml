import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
  id: root

  // Required properties for bar widgets
  property var pluginApi: null
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""

  property string displayValue: pluginApi?.mainInstance?.displayValue || "00:00"

  // Per-screen bar properties (for multi-monitor and vertical bar support)
  readonly property string screenName: screen?.name ?? ""
  readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)

  // Content dimensions (visual capsule size)
  readonly property real contentWidth: content.implicitWidth + Style.marginM * 2
  readonly property real contentHeight: capsuleHeight

  // Widget dimensions (extends to full bar height for better click area)
  implicitWidth: contentWidth
  implicitHeight: contentHeight

  // Visual capsule - centered within the full click area
  Rectangle {
    id: visualCapsule
    x: Style.pixelAlignCenter(parent.width, width)
    y: Style.pixelAlignCenter(parent.height, height)
    width: root.contentWidth
    height: root.contentHeight
    color: Style.capsuleColor
    radius: Style.radiusL
    border.color: Style.capsuleBorderColor
    border.width: Style.capsuleBorderWidth

    RowLayout {
      id: content
      anchors.centerIn: parent
      spacing: Style.marginS

      NIcon {
        icon: pluginApi?.mainInstance?.running ? "player-pause-filled" : "player-play-filled"
        color: Color.mPrimary
      }

      NText {
        visible: pluginApi?.mainInstance?.elapsedSeconds > 0
        text: displayValue
        color: Color.mPrimary
      }
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton

    onEntered: {
      const value = pluginApi?.mainInstance?.getTooltip()
      TooltipService.show(root, value, BarService.getTooltipDirection())
    }

    onExited: {
      TooltipService.hide()
    }

    onClicked: function (mouse) {
      if (!pluginApi?.mainInstance) {
        return
      }

      if (mouse.button === Qt.LeftButton) {
        return pluginApi.mainInstance.toggle()
      }

      if (mouse.button === Qt.MiddleButton) {
        return pluginApi.mainInstance.reset()
      }
    }
  }

}

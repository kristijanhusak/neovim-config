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

  property int leftCount: pluginApi?.mainInstance.leftCount || 0
  property int rightCount: pluginApi?.mainInstance.rightCount || 0
  visible: leftCount > 0 || rightCount > 0

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
        visible: leftCount > 0
        icon: "caret-left"
        color: Color.mPrimary
      }

      NText {
        visible: leftCount > 0
        text: leftCount
        color: Color.mPrimary
      }

      NIcon {
        icon: "app-window"
        pointSize: 13
      }

      NText {
        visible: rightCount > 0
        text: rightCount
        color: Color.mPrimary
      }

      NIcon {
        visible: rightCount > 0
        icon: "caret-right"
        color: Color.mPrimary
      }
    }
  }
}

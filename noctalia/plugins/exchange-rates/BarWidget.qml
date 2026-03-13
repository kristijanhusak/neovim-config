import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Widgets
import qs.Services.UI
import qs.Services.System

Item {
  id: root

  property var pluginApi: null
  property ShellScreen screen

  // Widget properties passed from Bar.qml for per-instance settings
  property string widgetId: ""
  property string section: ""

  property string displayText: pluginApi?.mainInstance.displayText || ""
  property string tooltip: pluginApi?.mainInstance.tooltip || ""
  property bool hovered: false

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
    color: hovered ? Color.mHover : Style.capsuleColor
    radius: Style.radiusL
    border.color: Style.capsuleBorderColor
    border.width: Style.capsuleBorderWidth

    RowLayout {
      id: content
      anchors.centerIn: parent
      spacing: Style.marginS

      NIcon {
        color: hovered ? Color.mOnHover : Color.mOnSurface
        icon: "currency-dollar"
      }

      NText {
        text: displayText
        color: hovered ? Color.mOnHover : Color.mOnSurface
        pointSize: Style.fontSizeS
      }
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.RightButton

    onEntered: {
      hovered = true;
      TooltipService.show(root, tooltip, BarService.getTooltipDirection())
    }

    onExited: {
      hovered = false;
      TooltipService.hide()
    }

    onClicked: (mouse) => {
      if (mouse.button === Qt.RightButton) {
        pluginApi?.mainInstance.fetchRates(true);
      }
    }
  }
}


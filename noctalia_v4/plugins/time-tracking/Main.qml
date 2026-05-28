import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services.UI
import qs.Commons
import qs.Widgets

Item {
  id: root

  property var pluginApi: null
  property int elapsedSeconds: 0
  property string displayValue: formatDuration(elapsedSeconds)
  property bool running: false
  property var startedAt: 0
  property var history: []
  readonly property int thresholdSeconds: 60 * 60 * 8 // 8 hours
  property bool thresholdNotified: false

  Timer {
    id: timeTrackingTimer

    // Every second
    interval: 1000
    repeat: true
    running: false

    onTriggered: {
      elapsedSeconds += 1
      displayValue = formatDuration(elapsedSeconds)
      if (elapsedSeconds >= thresholdSeconds && !thresholdNotified) {
        thresholdNotified = true
        ToastService.showWarning('Time tracking', '8 hours have passed', 60000)
      }
    }
  }

  function toggle() {
    if (running) {
      running = false
      history.push({
        startedAt,
        endedAt: new Date()
      })
    } else {
      startedAt = new Date()
      running = true
    }

    timeTrackingTimer.running = running
  }

  function reset() {
    ToastService.showWarning('Time tracking', 'Confirm time tracking reset?', 5000, 'Yes', () => {
      running = false
      timeTrackingTimer.running = false
      thresholdNotified = false
      history = []
      startedAt = 0
      elapsedSeconds = 0
    })
  }

  function padNumber(val) {
    if (val < 10) {
      return `0${val}`
    }

    return val
  }


  function formatDuration(seconds, includeSeconds = false) {
    var h = Math.floor(seconds / 3600)
    var m = Math.floor((seconds % 3600) / 60)
    var value = `${padNumber(h)}:${padNumber(m)}`
    if (includeSeconds) {
      const s = Math.floor(seconds % 60)
      value += `:${padNumber(s)}`
    }

    return value
  }

  function formatTime(date) {
    var h = date.getHours()
    var m = date.getMinutes()
    var s = date.getSeconds()
    return `${padNumber(h)}:${padNumber(m)}:${padNumber(s)}`
  }

  function getTooltip() {
    return history.map(({ endedAt, startedAt }) => {
      const seconds = Math.floor(endedAt - startedAt) / 1000
      return `${formatTime(startedAt)} - ${formatTime(endedAt)} -> ${formatDuration(seconds, true)}`
    }).join('\n') || displayValue
  }
}

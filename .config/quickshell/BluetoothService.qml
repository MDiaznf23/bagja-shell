pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth

Singleton {
  id: root

  readonly property bool available: Bluetooth.defaultAdapter !== null
  readonly property bool enabled: available && Bluetooth.defaultAdapter.enabled

  property var connectedDevices: []
  property var allDevices: []

  readonly property bool hasConnected: connectedDevices.length > 0

  readonly property string icon: {
    if (!available) return "󰂲"
    if (!enabled)   return "󰂲"
    if (hasConnected) return "󰂱"
    return "󰂯"
  }

  function toggle() {
    if (available)
      Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled
  }

  function refresh() {
    scanProcess.running = true
  }

  Process {
    id: scanProcess
    command: ["bash", Quickshell.shellDir + "/scripts/scan_bluetooth.sh"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          var all = JSON.parse(text)
          root.allDevices = all
          root.connectedDevices = all.filter(d => d.connected)
        } catch(e) {
          console.log("BT scan error:", e)
        }
      }
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: scanProcess.running = true
  }
}

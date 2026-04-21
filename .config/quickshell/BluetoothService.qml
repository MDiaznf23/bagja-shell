pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
  id: root

  readonly property bool available: Bluetooth.defaultAdapter !== null
  readonly property bool enabled: available && Bluetooth.defaultAdapter.enabled
  readonly property var connectedDevices: Bluetooth.connectedDevices
  readonly property var allDevices: available ? Bluetooth.defaultAdapter.devices : []
  readonly property bool hasConnected: connectedDevices.length > 0

  readonly property string icon: {
    if (!available || !enabled) return "󰂲"
    if (hasConnected) return "󰂱"
    return "󰂯"
  }

  function toggle() {
    if (available)
      Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled
  }
}

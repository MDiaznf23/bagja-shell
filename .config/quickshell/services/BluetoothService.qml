pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    readonly property bool available: Bluetooth.defaultAdapter !== null
    readonly property bool enabled: available && Bluetooth.defaultAdapter.enabled
    readonly property var allDevices: available ? Bluetooth.defaultAdapter.devices.values : []
    readonly property var connectedDevices: allDevices.filter(d => d.connected)
    readonly property bool hasConnected: connectedDevices.length > 0
    readonly property url iconSource: Icons.bluetooth(enabled, hasConnected)

    property string connectingAddress: ""

    function toggle() {
        if (available)
            Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled
    }

    function connectDevice(address) {
        if (connectingAddress !== "") return   
        var device = _findByAddress(address)
        if (!device) return
        connectingAddress = address
        if (device.connected)
            device.disconnect()
        else
            device.connect()
    }

    function clearConnecting(address) {
        if (connectingAddress === address)
            connectingAddress = ""
    }

    function _findByAddress(address) {
        for (var i = 0; i < allDevices.length; i++) {
            if (allDevices[i].address === address)
                return allDevices[i]
        }
        return null
    }
}

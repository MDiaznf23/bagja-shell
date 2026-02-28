import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Bluetooth

PanelWindow {
  id: root

  implicitWidth: 280
  implicitHeight: 320

  property bool isShowing: false

  Timer {
    id: showTimer
    interval: 16
    onTriggered: root.isShowing = true
  }

  onVisibleChanged: {
    if (visible) {
      isShowing = false
      showTimer.start()
    } else {
      isShowing = false
    }
  }

  anchors {
    top: true
    right: true
  }

  margins {
    top: 28
    right: 13
  }

  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

  signal requestClose()

  Rectangle {
    id: mainRect
    anchors.fill: parent
    color: "transparent"

    Rectangle {
      id: topPatch
      height: 12
      gradient: Gradient {
        orientation: Gradient.Horizontal 
        GradientStop { position: 0.1; color: Colors.isDark ? Colors.surface : Colors.surface }
        GradientStop { position: 0.99; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim }
      }
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.leftMargin: 12
      z: 5
    }

    opacity: root.isShowing ? 1 : 0
    Behavior on opacity {
      NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
    }

    transform: Translate {
      y: root.isShowing ? 0 : -(root.implicitHeight + 50)
      Behavior on y {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
      }
    }

    Rectangle {
      anchors.fill: parent
      anchors.leftMargin: 12
      anchors.bottomMargin: 12
      gradient: Gradient {
        orientation: Gradient.Horizontal 
        GradientStop { position: 0.1; color: Colors.isDark ? Colors.surface : Colors.surface }
        GradientStop { position: 0.99; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim }
      }
      radius: 10
      border.color: Colors.outlineVariant
      border.width: 2

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        RowLayout {
          Layout.fillWidth: true

          Text {
            text: "Bluetooth"
            color: Colors.isDark ? Colors.primary : Colors.secondary 
            font.pixelSize: 14
            font.bold: true
            Layout.fillWidth: true
          }

          Rectangle {
            width: 32; height: 16
            radius: 8
            color: BluetoothService.enabled
            ? Colors.isDark ? Colors.primaryContainer : Colors.primaryFixed 
            : Colors.isDark ? Colors.surfaceContainerHigh : Colors.surfaceContainer

            Behavior on color {
              ColorAnimation { duration: 150 }
            }

            Rectangle {
              width: 12; height: 12
              radius: 8
              color: Colors.isDark ? Colors.surfaceContainer : Colors.surface
              anchors.verticalCenter: parent.verticalCenter
              x: BluetoothService.enabled ? 18 : 3

              Behavior on x {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
              }
            }

            MouseArea {
              anchors.fill: parent
              onClicked: BluetoothService.toggle()
            }
          }

          Rectangle {
            width: 20; height: 20
            color: closeArea.containsMouse 
            ? Colors.isDark ? Colors.errorContainer : Colors.surface 
            : "transparent"
            radius: 4
            Text {
              anchors.centerIn: parent
              text: "✕"
              color: Colors.overSurface
              font.pixelSize: 12
            }
            MouseArea {
              id: closeArea
              anchors.fill: parent
              hoverEnabled: true
              onClicked: root.requestClose()
            }
          }
        }

        Rectangle {
          Layout.fillWidth: true
          height: 1
          color: Colors.outlineVariant
        }

        Text {
          visible: !BluetoothService.available
          text: "No adapter Bluetooth"
          color: Colors.overSurfaceVariant
          font.pixelSize: 12
          Layout.alignment: Qt.AlignHCenter
        }

        Text {
          visible: BluetoothService.available && !BluetoothService.enabled
          text: "Bluetooth is off"
          color: Colors.overSurfaceVariant
          font.pixelSize: 12
          Layout.alignment: Qt.AlignHCenter
        }

        ListView {
          id: deviceList
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true
          spacing: 6
          visible: BluetoothService.enabled
          model: BluetoothService.allDevices

          Text {
            anchors.centerIn: parent
            text: "No devices"
            color: Colors.overSurfaceVariant
            font.pixelSize: 12
            visible: deviceList.count === 0
          }

          delegate: Rectangle {
            id: deviceItem
            required property var modelData

            property bool isConnected: modelData.connected

            width: deviceList.width
            height: 55
            color: deviceArea.containsMouse
              ? Colors.isDark ? Colors.surfaceContainerHigh : Colors.primaryFixedDim
              : Colors.isDark ? Colors.surfaceContainer : Colors.surfaceContainerHigh
            radius: 6

            Behavior on color { ColorAnimation { duration: 100 } }

            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: 12
              anchors.rightMargin: 12
              spacing: 8

              Text {
                Layout.alignment: Qt.AlignTop
                topPadding: -2
                text: {
                  var ic = deviceItem.modelData.type
                  if (ic === "headphone") return "󰋋"
                  if (ic === "phone")     return "󰄜"
                  if (ic === "keyboard")  return "󰌌"
                  if (ic === "mouse")     return "󰍽"
                  if (ic === "computer")  return "󰇄"
                  return "󰂯"
                }
                color: deviceItem.isConnected
                  ? Colors.isDark ? Colors.primary : Colors.tertiary
                  : Colors.overSurfaceVariant
                font.pixelSize: 40
              }

              ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                  text: deviceItem.modelData.name
                  color: Colors.overSurface
                  font.pixelSize: 12
                  elide: Text.ElideRight
                  Layout.fillWidth: true
                }

                Text {
                  visible: deviceItem.isConnected
                  text: "Connected"
                  color: Colors.isDark ? Colors.primary : Colors.tertiary
                  font.pixelSize: 10
                }

                Text {
                  visible: !deviceItem.isConnected && deviceItem.modelData.paired
                  text: "Paired"
                  color: Colors.overSurface
                  font.pixelSize: 10
                }
              }

              Rectangle {
                width: 40; height: 22
                radius: 11
                color: deviceItem.isConnected
                  ? Colors.isDark ? Colors.secondaryContainer : Colors.primaryContainer
                  : Colors.isDark ? Colors.overSecondary : Colors.outline

                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                  anchors.centerIn: parent
                  text: deviceItem.isConnected ? "On" : "Off"
                  color: deviceItem.isConnected
                    ? Colors.isDark ? Colors.primary : Colors.overSecondary
                    : Colors.isDark ? Colors.overSurface : Colors.overPrimary
                  font.pixelSize: 10
                  font.bold: true
                }

                MouseArea {
                  anchors.fill: parent
                  onClicked: {
                    connectProcess.command = [
                      "bash",
                      Quickshell.shellDir + "/scripts/connect_bluetooth.sh",
                      deviceItem.modelData.mac,
                      "toggle"
                    ]
                    connectProcess.running = true
                  }
                }
              }
            }

            MouseArea {
              id: deviceArea
              anchors.fill: parent
              hoverEnabled: true
              onClicked: {}
            }
          }
        }

        Process {
          id: connectProcess
          onRunningChanged: {
            if (!running) BluetoothService.refresh()
          }
        }
      }
      Rectangle {
        id: rightPatch
        width: 12
        height: parent.height
        gradient: Gradient {
          orientation: Gradient.Horizontal 
          GradientStop { position: 0.1; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim }
          GradientStop { position: 0.8; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim }
        }
        anchors.right: parent.right
        anchors.rightMargin: -2
        z: 5
      }

      Canvas {
        id: rightWing
        width: 14; height: 14
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: -12
        anchors.rightMargin: 0
        z: 10
        onPaint: {
          var ctx = getContext("2d")
          ctx.reset()
          ctx.fillStyle = Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim 
          ctx.beginPath()
          ctx.moveTo(0, 0)
          ctx.lineTo(0, 2)
          ctx.arc(0, 14, 12, Math.PI / 2, 0, false)
          ctx.lineTo(12, 14)
          ctx.lineTo(14, 14)
          ctx.lineTo(14, 0)
          ctx.closePath()
          ctx.fill()
        }
      }

      Canvas {
        id: rightWing1
        width: 14; height: 14
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: -12
        anchors.rightMargin: 0
        z: 10
        onPaint: {
          var ctx = getContext("2d")
          ctx.reset()
          ctx.fillStyle = Colors.outlineVariant
          ctx.beginPath()
          ctx.moveTo(0, 0)
          ctx.lineTo(0, 2)
          ctx.arc(0, 14, 12, Math.PI / 2, 0, false)
          ctx.lineTo(12, 14)
          ctx.lineTo(14, 14)
          ctx.arc(0, 14, 14, 0, Math.PI / 2, true)
          ctx.closePath()
          ctx.fill()
        }
      }
    }

    Canvas {
      id: leftWing
      width: 14; height: 14
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.leftMargin: 0
      z: 10
      onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        ctx.fillStyle = Colors.isDark ? Colors.surface : Colors.surface 
        ctx.beginPath()
        ctx.moveTo(0, 0)
        ctx.lineTo(0, 2)
        ctx.arc(0, 14, 12, Math.PI / 2, 0, false)
        ctx.lineTo(12, 14)
        ctx.lineTo(14, 14)
        ctx.lineTo(14, 0)
        ctx.closePath()
        ctx.fill()
      }
    }

    Canvas {
      id: leftWing1
      width: 14; height: 14
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.leftMargin: 0
      z: 10
      onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        ctx.fillStyle = Colors.outlineVariant
        ctx.beginPath()
        ctx.moveTo(0, 0)
        ctx.lineTo(0, 2)
        ctx.arc(0, 14, 12, Math.PI / 2, 0, false)
        ctx.lineTo(12, 14)
        ctx.lineTo(14, 14)
        ctx.arc(0, 14, 14, 0, Math.PI / 2, true)
        ctx.closePath()
        ctx.fill()
      }
    }
  }
}

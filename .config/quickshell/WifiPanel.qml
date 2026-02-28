import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
  id: root

  implicitWidth: 280
  implicitHeight: 320

  property bool isShowing: false
  property var networks: []

  Timer {
    id: showTimer
    interval: 16
    onTriggered: root.isShowing = true
  }

  // Auto scan 
  onVisibleChanged: {
    if (visible) {
      isShowing = false
      showTimer.start()
      scanProcess.running = true
    } else {
      isShowing = false
    }
  }

  // Scan every 5 sec
  Timer {
    id: autoScanTimer
    interval: 5000
    repeat: true
    running: root.visible
    onTriggered: scanProcess.running = true
  }

  Process {
    id: scanProcess
    command: [Quickshell.shellDir + "/scripts/scan_wifi.sh"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          root.networks = JSON.parse(text)
        } catch(e) {
          root.networks = []
        }
      }
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
      antialiasing: true
      layer.enabled: true
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
      radius: 12
      border.color: Colors.outlineVariant
      border.width: 2

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // Header
        RowLayout {
          Layout.fillWidth: true

          Text {
            text: "Wifi"
            color: Colors.overSurfaceVariant
            font.pixelSize: 14
            font.bold: true
            Layout.fillWidth: true
          }

          // Scan button
          Rectangle {
            width: 20; height: 20
            color: scanArea.containsMouse 
              ? Colors.isDark ? Colors.primaryContainer : Colors.secondaryFixed 
              : "transparent"
            radius: 4

            Text {
              id: scanIcon
              anchors.centerIn: parent
              text: "󰑐"
              color: scanProcess.running 
                ? Colors.isDark ? Colors.primary : Colors.secondary 
                : Colors.overSurface
              font.pixelSize: 14

              RotationAnimation on rotation {
                running: scanProcess.running
                from: 0; to: 360
                duration: 1000
                loops: Animation.Infinite
              }
            }

            MouseArea {
              id: scanArea
              anchors.fill: parent
              hoverEnabled: true
              onClicked: scanProcess.running = true
            }
          }

          // Close button
          Rectangle {
            width: 20; height: 20
            color: closeArea.containsMouse 
              ? Colors.isDark ? Colors.overSecondary : Colors.secondary 
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

        // Divider
        Rectangle {
          Layout.fillWidth: true
          height: 1
          color: Colors.outline
        }

        // Network list
        ListView {
          id: networkList
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true
          spacing: 6

          model: root.networks

          Text {
            anchors.centerIn: parent
            text: scanProcess.running ? "Scanning..." : "No Networks"
            color: Colors.overSurface
            font.pixelSize: 12
            visible: networkList.count === 0
          }

          delegate: Rectangle {
            id: netItem
            required property var modelData

            width: networkList.width
            height: 55
            color: netArea.containsMouse 
              ? Colors.isDark ? Colors.surfaceContainerHigh : Colors.primaryFixedDim 
              : Colors.isDark ? Colors.surfaceContainer : Colors.surfaceContainerHigh
            radius: 6

            Behavior on color {
              ColorAnimation { duration: 100 }
            }

            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: 12
              anchors.rightMargin: 12
              spacing: 8

              // Signal strength icon
              Text {
                Layout.alignment: Qt.AlignTop
                topPadding: -2
                text: {
                  var s = netItem.modelData.signal
                  if (s >= 75) return "󰤨"
                  if (s >= 50) return "󰤥"
                  if (s >= 25) return "󰤢"
                  return "󰤯"
                }
                color: netItem.modelData.connected === true || netItem.modelData.connected === "true"
                  ? (Colors.isDark ? Colors.tertiary : Colors.primary)
                  : (Colors.isDark ? Colors.overSurfaceVariant : Colors.outline)
                font.pixelSize: 40
              }

              // SSID + status
              ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                  text: netItem.modelData.ssid
                  color: Colors.overSurface
                  font.pixelSize: 12
                  elide: Text.ElideRight
                  Layout.fillWidth: true
                }

                Text {
                  visible: netItem.modelData.connected === true || netItem.modelData.connected === "true"
                  text: "Connected"
                  color: Colors.isDark ? Colors.primary : Colors.secondary
                  font.pixelSize: 10
                }
              }

              // Lock icon
              Text {
                visible: netItem.modelData.secured === true || netItem.modelData.secured === "true"
                text: "󰌾"
                color: Colors.tertiary
                font.pixelSize: 12
              }

              // Connect button
              Rectangle {
                width: 40; height: 22
                radius: 11
                color: netItem.modelData.connected === true || netItem.modelData.connected === "true"
                  ? (Colors.isDark ? Colors.overPrimary : Colors.primaryContainer)
                  : (Colors.isDark ? Colors.secondaryContainer : Colors.outline)

                Behavior on color {
                  ColorAnimation { duration: 150 }
                }

                Text {
                  anchors.centerIn: parent
                  text: (netItem.modelData.connected === true || netItem.modelData.connected === "true") ? "On" : "Off"
                  color: netItem.modelData.connected === true || netItem.modelData.connected === "true"
                    ? (Colors.isDark ? Colors.tertiaryFixed : Colors.overPrimary)
                    : (Colors.isDark ? Colors.overSurfaceVariant : Colors.overSecondary)
                  font.pixelSize: 10
                  font.bold: true
                }

                MouseArea {
                  anchors.fill: parent
                  onClicked: {
                    connectProcess.ssid = netItem.modelData.ssid
                    connectProcess.running = true
                  }
                }
              }
            }

            MouseArea {
              id: netArea
              anchors.fill: parent
              hoverEnabled: true
              onClicked: {}
            }
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
          GradientStop { position: 0.78; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim }
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

  // Connect process 
  Process {
    id: connectProcess
    property string ssid: ""
    command: [Quickshell.shellDir + "/scripts/connect_wifi.sh", ssid]
    onRunningChanged: {
      if (!running) scanProcess.running = true
    }
  }
}

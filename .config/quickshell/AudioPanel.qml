import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
  id: root

  implicitWidth: 280
  implicitHeight: 360

  property bool isShowing: false
  property var sinks: []
  property var sources: []

  property var deviceModel: {
    var items = []
    items.push({ type: "header", label: "Output" })
    if (sinks.length === 0)
      items.push({ type: "empty", label: "No output device" })
    for (var i = 0; i < sinks.length; i++)
      items.push({ type: "sink", data: sinks[i] })
    items.push({ type: "divider" })
    items.push({ type: "header", label: "Input" })
    if (sources.length === 0)
      items.push({ type: "empty", label: "No input device" })
    for (var j = 0; j < sources.length; j++)
      items.push({ type: "source", data: sources[j] })
    return items
  }

  Process {
    id: sinkListener
    command: ["python3", Quickshell.shellDir + "/scripts/get_audio_devices.py", "sink"] 
    running: true
    Component.onDestruction: running = false
    stdout: SplitParser {
      onRead: data => {
        try { root.sinks = JSON.parse(data) } catch(e) {}
      }
    }
  }

  Process {
    id: sourceListener
    command: ["python3", Quickshell.shellDir + "/scripts/get_audio_devices.py", "source"]
    running: false
    stdout: SplitParser {
      onRead: data => {
        try { root.sources = JSON.parse(data) } catch(e) {}
      }
    }
  }

  Process {
    id: setDefaultProc
    command: []
  }

  Timer {
    id: showTimer
    interval: 16
    onTriggered: root.isShowing = true
  }

  onVisibleChanged: {
    if (visible) {
      isShowing = false
      showTimer.start()
      sinkListener.running = false
      sourceListener.running = false
      sinkListener.running = true
      sourceListener.running = true
    } else {
      isShowing = false
      sinkListener.running = false
      sourceListener.running = false
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

    Rectangle {
      anchors.fill: parent
      anchors.leftMargin: 12
      anchors.bottomMargin: 12
      gradient: Gradient {
        orientation: Gradient.Horizontal 
        GradientStop { position: 0.1; color: Colors.isDark ? Colors.surface : Colors.surface }
        GradientStop { position: 0.9; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim }
      }
      radius: 10
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
            text: "Audio Devices"
            color: Colors.isDark ? Colors.primary : Colors.secondary
            font.pixelSize: 14
            font.bold: true
            Layout.fillWidth: true
          }
          Rectangle {
            width: 20; height: 20
            color: closeArea.containsMouse 
            ? Colors.isDark ? Colors.errorContainer : Colors.errorContainer 
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

        // ListView
        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true

          ListView {
            id: deviceList
            anchors.fill: parent
            model: root.deviceModel
            spacing: 6

            ScrollBar.vertical: ScrollBar {
              policy: ScrollBar.AsNeeded
              width: 3
              contentItem: Rectangle {
                implicitWidth: 2
                implicitHeight: 2
                radius: 2
                color: Colors.isDark ? Colors.primaryContainer : Colors.inversePrimary
                opacity: parent.pressed ? 1.0 : parent.hovered ? 0.8 : 0.5
              }
              background: Rectangle {
                implicitWidth: 2
                radius: 2
                color: Colors.isDark ? Colors.surfaceContainer : Colors.surface
                opacity: 0.5
              }
            }

            delegate: Item {
              id: delegateItem
              required property var modelData
              width: deviceList.width

              height: modelData.type === "header"  ? 28
                    : modelData.type === "divider" ? 17
                    : modelData.type === "empty"   ? 24
                    : 44

              // Header
              Text {
                visible: delegateItem.modelData.type === "header"
                text: delegateItem.modelData.label || ""
                color: Colors.isDark ? Colors.primary : Colors.secondary
                font.pixelSize: 12
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
              }

              // Divider
              Rectangle {
                visible: delegateItem.modelData.type === "divider"
                width: parent.width
                height: 1
                color: Colors.outlineVariant
                anchors.verticalCenter: parent.verticalCenter
              }

              // Empty message
              Text {
                visible: delegateItem.modelData.type === "empty"
                text: delegateItem.modelData.label || ""
                color: Colors.overSurfaceVariant
                font.pixelSize: 11
                anchors.verticalCenter: parent.verticalCenter
              }

              // Device item
              Rectangle {
                visible: delegateItem.modelData.type === "sink" || delegateItem.modelData.type === "source"
                anchors.fill: parent
                anchors.rightMargin: 5
                color: (delegateItem.modelData.data && delegateItem.modelData.data.is_active) 
                ? Colors.isDark ? Colors.overSecondary : Colors.inversePrimary 
                : Colors.isDark ? Colors.surfaceContainerHigh : Colors.surfaceContainerHigh
                radius: 6
                border.color: "transparent"
                border.width: 1

                RowLayout {
                  anchors.fill: parent
                  anchors.leftMargin: 10
                  anchors.rightMargin: 10
                  spacing: 8

                  Text {
                    text: delegateItem.modelData.type === "sink" ? "󰕾" : "󰍬"
                    color: (delegateItem.modelData.data && delegateItem.modelData.data.is_active) 
                    ? Colors.isDark ? Colors.primary : Colors.secondary
                    : Colors.overSurface
                    font.pixelSize: 16
                  }

                  ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                      text: delegateItem.modelData.data
                            ? (delegateItem.modelData.data.name_short || delegateItem.modelData.data.name)
                            : ""
                      color: Colors.overSurface
                      font.pixelSize: 11
                      elide: Text.ElideRight
                      Layout.fillWidth: true
                    }
                    Text {
                      text: delegateItem.modelData.data ? (delegateItem.modelData.data.volume + "%") : ""
                      color: (delegateItem.modelData.data && delegateItem.modelData.data.is_active) 
                      ? Colors.isDark ? Colors.primary : Colors.secondary
                      : Colors.overSurface
                      font.pixelSize: 10
                    }
                  }

                  Rectangle {
                    width: 40; height: 22
                    radius: 11
                    color: (delegateItem.modelData.data && delegateItem.modelData.data.is_active) 
                    ? Colors.isDark ? Colors.secondaryContainer : Colors.secondaryContainer 
                    : Colors.isDark ? Colors.surfaceContainerHighest : Colors.tertiaryContainer
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Text {
                      anchors.centerIn: parent
                      text: (delegateItem.modelData.data && delegateItem.modelData.data.is_active) ? "✓" : "Set"
                      color: (delegateItem.modelData.data && delegateItem.modelData.data.is_active) 
                      ? Colors.isDark ? Colors.primary : Colors.overSecondaryContainer
                      : Colors.isDark ? Colors.overSurface : Colors.overPrimary
                      font.pixelSize: 10
                      font.bold: true
                    }
                    MouseArea {
                      anchors.fill: parent
                      onClicked: {
                        if (delegateItem.modelData.data && !delegateItem.modelData.data.is_active) {
                          var isSource = delegateItem.modelData.type === "source"
                          setDefaultProc.command = [
                            "pactl",
                            isSource ? "set-default-source" : "set-default-sink",
                            delegateItem.modelData.data.name
                          ]
                          setDefaultProc.running = true
                        }
                      }
                    }
                  }
                }
              }
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
}

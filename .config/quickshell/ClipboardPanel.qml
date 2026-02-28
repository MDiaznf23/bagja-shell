import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
  id: root

  implicitWidth: 280
  implicitHeight: 360

  property bool isShowing: false
  property var clipItems: []

  // Load list 
  onVisibleChanged: {
    if (visible) {
      isShowing = false
      showTimer.start()
      listProcess.running = true
    } else {
      isShowing = false
    }
  }

  Timer {
    id: showTimer
    interval: 16
    onTriggered: root.isShowing = true
  }

  // Reload 
  Timer {
    id: autoReloadTimer
    interval: 2000
    repeat: true
    running: root.visible
    onTriggered: listProcess.running = true
  }

  Process {
    id: listProcess
    command: [Quickshell.shellDir + "/scripts/clipboard.sh", "list"]
    stdout: StdioCollector {
      onStreamFinished: {
        var lines = text.trim().split("\n")
        var result = []
        for (var i = 0; i < lines.length; i++) {
          if (lines[i].trim() === "") continue
          var tab = lines[i].indexOf("\t")
          if (tab === -1) continue
          var id = lines[i].substring(0, tab)
          var preview = lines[i].substring(tab + 1)
          result.push({ id: id, preview: preview })
        }
        root.clipItems = result
      }
    }
  }

  Process {
    id: copyProcess
    property string itemId: ""
    property string itemText: ""
    property bool shouldClose: false  
    command: [Quickshell.shellDir + "/scripts/clipboard.sh", "decode", itemId, itemText]
    onRunningChanged: {
      if (!running && shouldClose) {  
        shouldClose = false
        root.requestClose()
      }
    }
  }

  Process {
    id: deleteProcess
    property string itemId: ""
    property string itemText: ""
    command: [Quickshell.shellDir + "/scripts/clipboard.sh", "delete", itemId, itemText]
    onRunningChanged: {
      if (!running) listProcess.running = true
    }
  }

  Process {
    id: wipeProcess
    command: [Quickshell.shellDir + "/scripts/clipboard.sh", "wipe"]
    onRunningChanged: {
      if (!running) {
        root.clipItems = []
        reloadAfterWipeTimer.start()
      }
    }
  }

  Timer {
    id: reloadAfterWipeTimer
    interval: 500
    onTriggered: listProcess.running = true
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

          Row {
            spacing: 6
            Layout.fillWidth: true

            Text {
              text: "󰅍"
              color: Colors.isDark ? Colors.primary : Colors.secondary
              font.pixelSize: 14
              font.family: "JetBrainsMono Nerd Font"
              anchors.verticalCenter: parent.verticalCenter
            }

            Text {
              text: "Clipboard"
              color: Colors.overSurfaceVariant
              font.pixelSize: 14
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          // Clear all
          Rectangle {
            width: 20; height: 20
            color: clearArea.containsMouse
              ? Colors.isDark ? Colors.primaryContainer : Colors.secondaryFixed
              : "transparent"
            radius: 4

            Text {
              anchors.centerIn: parent
              text: "󰃢"
              color: Colors.overSurface
              font.pixelSize: 13
              font.family: "JetBrainsMono Nerd Font"
            }

            MouseArea {
              id: clearArea
              anchors.fill: parent
              hoverEnabled: true
              onClicked: wipeProcess.running = true
            }
          }

          // Close
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

        // List
        ListView {
          id: clipList
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true
          spacing: 6

          model: root.clipItems

          Text {
            anchors.centerIn: parent
            text: listProcess.running ? "Loading..." : "Clipboard kosong"
            color: Colors.overSurface
            font.pixelSize: 12
            visible: clipList.count === 0
          }

          delegate: Rectangle {
            id: clipItem
            required property var modelData
            required property int index

            width: clipList.width
            height: 44
            color: itemArea.containsMouse
              ? Colors.isDark ? Colors.surfaceContainerHigh : Colors.primaryFixedDim
              : Colors.isDark ? Colors.surfaceContainer : Colors.surfaceContainerHigh
            radius: 6

            Behavior on color { ColorAnimation { duration: 100 } }

            MouseArea {
              id: itemArea
              anchors.fill: parent
              hoverEnabled: true
              onClicked: (mouse) => {
                if (mouse.x > (width - 36)) {
                  deleteProcess.itemId = clipItem.modelData.id
                  deleteProcess.itemText = clipItem.modelData.preview
                  deleteProcess.running = true
                } else {
                  copyProcess.shouldClose = true
                  copyProcess.itemId = clipItem.modelData.id
                  copyProcess.itemText = clipItem.modelData.preview
                  copyProcess.running = true
                }
              }
            }

            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: 10
              anchors.rightMargin: 10
              spacing: 8

              Text {
                text: clipItem.modelData.preview
                color: Colors.overSurface
                font.pixelSize: 11
                elide: Text.ElideRight
                Layout.fillWidth: true
              }

              // Copy icon
              Rectangle {
                width: 26; height: 20
                radius: 10
                property bool isHovered: itemArea.containsMouse && 
                  itemArea.mouseX <= (clipItem.width - 36)
                color: isHovered
                  ? Colors.isDark ? Colors.primaryContainer : Colors.primary
                  : "transparent"
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                  anchors.centerIn: parent
                  text: "󰆏"
                  color: parent.isHovered
                    ? Colors.isDark ? Colors.overPrimaryContainer : Colors.overPrimary
                    : Colors.overSurface
                  font.pixelSize: 12
                  font.family: "JetBrainsMono Nerd Font"
                }
              }

              // Delete button 
              Rectangle {
                id: deleteRect
                width: 20; height: 20
                radius: 10
                property bool isHovered: itemArea.containsMouse && 
                  itemArea.mouseX > (clipItem.width - 36)
                color: isHovered
                  ? Colors.isDark ? Colors.errorContainer : Colors.error
                  : "transparent"
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                  anchors.centerIn: parent
                  text: "󰅖"
                  color: deleteRect.isHovered ? Colors.overError : Colors.overSurface
                  font.pixelSize: 11
                  font.family: "JetBrainsMono Nerd Font"
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
        width: 14; height: 14
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: -12
        z: 10
        onPaint: {
          var ctx = getContext("2d")
          ctx.reset()
          ctx.fillStyle = Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim
          ctx.beginPath()
          ctx.moveTo(0, 0); ctx.lineTo(0, 2)
          ctx.arc(0, 14, 12, Math.PI / 2, 0, false)
          ctx.lineTo(12, 14); ctx.lineTo(14, 14); ctx.lineTo(14, 0)
          ctx.closePath(); ctx.fill()
        }
      }

      Canvas {
        width: 14; height: 14
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: -12
        z: 10
        onPaint: {
          var ctx = getContext("2d")
          ctx.reset()
          ctx.fillStyle = Colors.outlineVariant
          ctx.beginPath()
          ctx.moveTo(0, 0); ctx.lineTo(0, 2)
          ctx.arc(0, 14, 12, Math.PI / 2, 0, false)
          ctx.lineTo(12, 14); ctx.lineTo(14, 14)
          ctx.arc(0, 14, 14, 0, Math.PI / 2, true)
          ctx.closePath(); ctx.fill()
        }
      }
    }

    Canvas {
      width: 14; height: 14
      anchors.top: parent.top
      anchors.left: parent.left
      z: 10
      onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        ctx.fillStyle = Colors.isDark ? Colors.surface : Colors.surface
        ctx.beginPath()
        ctx.moveTo(0, 0); ctx.lineTo(0, 2)
        ctx.arc(0, 14, 12, Math.PI / 2, 0, false)
        ctx.lineTo(12, 14); ctx.lineTo(14, 14); ctx.lineTo(14, 0)
        ctx.closePath(); ctx.fill()
      }
    }

    Canvas {
      width: 14; height: 14
      anchors.top: parent.top
      anchors.left: parent.left
      z: 10
      onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        ctx.fillStyle = Colors.outlineVariant
        ctx.beginPath()
        ctx.moveTo(0, 0); ctx.lineTo(0, 2)
        ctx.arc(0, 14, 12, Math.PI / 2, 0, false)
        ctx.lineTo(12, 14); ctx.lineTo(14, 14)
        ctx.arc(0, 14, 14, 0, Math.PI / 2, true)
        ctx.closePath(); ctx.fill()
      }
    }
  }
}

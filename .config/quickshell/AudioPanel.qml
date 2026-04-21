import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire

PanelWindow {
  id: root

  implicitWidth: 280
  implicitHeight: 360

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

  anchors { top: true; right: true }
  margins { top: 28; right: 13 }

  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

  PwObjectTracker {
    objects: Pipewire.nodes.values
  }

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
        GradientStop { position: 0.1; color: Colors.topbar_gradient5 }
        GradientStop { position: 0.99; color: Colors.topbar_gradient6 }
      }
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.leftMargin: 12
      z: 5
    }

    Rectangle {
      id: innerRect
      anchors.fill: parent
      anchors.leftMargin: 12
      anchors.bottomMargin: 12
      gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0.1; color: Colors.topbar_gradient5 }
        GradientStop { position: 0.9; color: Colors.topbar_gradient6 }
      }
      radius: 10
      border.color: Colors.outline_variant
      border.width: 2

      ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        // Header
        RowLayout {
          Layout.fillWidth: true
          Text {
            text: "Audio Devices"
            color: Colors.header_title
            font.pixelSize: 14
            font.bold: true
            Layout.fillWidth: true
          }
          Rectangle {
            width: 20; height: 20
            color: closeArea.containsMouse ? Colors.close_btn_hovered : "transparent"
            radius: 4
            Text { anchors.centerIn: parent; text: "✕"; color: Colors.close_btn_icon; font.pixelSize: 12 }
            MouseArea {
              id: closeArea
              anchors.fill: parent
              hoverEnabled: true
              onClicked: root.requestClose()
            }
          }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Colors.divider }

        // Output Label
        Text {
          text: "Output"
          color: Colors.header_title
          font.pixelSize: 12
          font.bold: true
        }

        // Output List
        ListView {
          id: outputList
          Layout.fillWidth: true
          Layout.preferredHeight: outputList.count * 44 + Math.max(0, outputList.count - 1) * 4
          Layout.maximumHeight: outputList.count * 44 + Math.max(0, outputList.count - 1) * 4
          clip: true
          spacing: 4
          model: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream)

          ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            width: 3
            contentItem: Rectangle {
              implicitWidth: 2; implicitHeight: 2; radius: 2
              color: Colors.scrollbar_thumb
              opacity: parent.pressed ? 1.0 : parent.hovered ? 0.8 : 0.5
            }
            background: Rectangle {
              implicitWidth: 2; radius: 2
              color: Colors.scrollbar_track
              opacity: 0.5
            }
          }

          delegate: Rectangle {
            required property var modelData
            width: outputList.width
            height: 44
            radius: 6
            color: (Pipewire.defaultAudioSink && modelData.id === Pipewire.defaultAudioSink.id)
            ? Colors.isDark ? Colors.audio_item_active_bg : Qt.alpha(Colors.audio_item_active_bg, 0.3) 
            : Colors.audio_item_inactive_bg

            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: 10
              anchors.rightMargin: 10
              spacing: 8

              Text {
                text: "󰕾"
                color: (Pipewire.defaultAudioSink && modelData.id === Pipewire.defaultAudioSink.id)
                  ? Colors.audio_item_active_icon : Colors.audio_item_inactive_icon
                font.pixelSize: 16
              }

              Text {
                text: modelData.description || modelData.name || ""
                color: Colors.audio_item_text
                font.pixelSize: 11
                elide: Text.ElideRight
                Layout.fillWidth: true
              }

              Rectangle {
                width: 40; height: 22
                radius: 11
                color: (Pipewire.defaultAudioSink && modelData.id === Pipewire.defaultAudioSink.id)
                  ? Colors.audio_toggle_active_bg : Colors.audio_toggle_inactive_bg
                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                  anchors.centerIn: parent
                  text: (Pipewire.defaultAudioSink && modelData.id === Pipewire.defaultAudioSink.id) ? "✓" : "Set"
                  color: (Pipewire.defaultAudioSink && modelData.id === Pipewire.defaultAudioSink.id)
                    ? Colors.audio_toggle_active_text : Colors.audio_toggle_inactive_text
                  font.pixelSize: 10
                  font.bold: true
                }

                MouseArea {
                  anchors.fill: parent
                  onClicked: Pipewire.preferredDefaultAudioSink = modelData
                }
              }
            }
          }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Colors.divider }

        // Input Label
        Text {
          text: "Input"
          color: Colors.header_title
          font.pixelSize: 12
          font.bold: true
        }

        // Input List
        ListView {
          id: inputList
          Layout.fillWidth: true
          Layout.preferredHeight: inputList.count * 44 + Math.max(0, inputList.count - 1) * 4
          Layout.maximumHeight: inputList.count * 44 + Math.max(0, inputList.count - 1) * 4
          clip: true
          spacing: 4
          model: Pipewire.nodes.values.filter(n => !n.isSink && !n.isStream && n.audio !== null)

          ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            width: 3
            contentItem: Rectangle {
              implicitWidth: 2; implicitHeight: 2; radius: 2
              color: Colors.scrollbar_thumb
              opacity: parent.pressed ? 1.0 : parent.hovered ? 0.8 : 0.5
            }
            background: Rectangle {
              implicitWidth: 2; radius: 2
              color: Colors.scrollbar_track
              opacity: 0.5
            }
          }

          delegate: Rectangle {
            required property var modelData
            width: inputList.width
            height: 44
            radius: 6
            color: (Pipewire.defaultAudioSource && modelData.id === Pipewire.defaultAudioSource.id)
            ? Colors.isDark ? Colors.audio_item_active_bg : Qt.alpha(Colors.audio_item_active_bg, 0.3)  
            : Colors.audio_item_inactive_bg

            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: 10
              anchors.rightMargin: 10
              spacing: 8

              Text {
                text: "󰍬"
                color: (Pipewire.defaultAudioSource && modelData.id === Pipewire.defaultAudioSource.id)
                  ? Colors.audio_item_active_icon : Colors.audio_item_inactive_icon
                font.pixelSize: 16
              }

              Text {
                text: modelData.description || modelData.name || ""
                color: Colors.audio_item_text
                font.pixelSize: 11
                elide: Text.ElideRight
                Layout.fillWidth: true
              }

              Rectangle {
                width: 40; height: 22
                radius: 11
                color: (Pipewire.defaultAudioSource && modelData.id === Pipewire.defaultAudioSource.id)
                  ? Colors.audio_toggle_active_bg : Colors.audio_toggle_inactive_bg
                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                  anchors.centerIn: parent
                  text: (Pipewire.defaultAudioSource && modelData.id === Pipewire.defaultAudioSource.id) ? "✓" : "Set"
                  color: (Pipewire.defaultAudioSource && modelData.id === Pipewire.defaultAudioSource.id)
                    ? Colors.audio_toggle_active_text : Colors.audio_toggle_inactive_text
                  font.pixelSize: 10
                  font.bold: true
                }

                MouseArea {
                  anchors.fill: parent
                  onClicked: Pipewire.preferredDefaultAudioSource = modelData
                }
              }
            }
          }
        }

        // Spacer - serap sisa ruang
        Item { Layout.fillWidth: true; Layout.fillHeight: true }

        // Bottom padding
        Item { Layout.fillWidth: true; height: 4 }
      }

      Rectangle {
        id: rightPatch
        width: 12; height: parent.height
        color: Colors.rightbar_gradient1 
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
        z: 10
        onPaint: {
          var ctx = getContext("2d")
          ctx.reset()
          ctx.fillStyle = Colors.rightbar_gradient1
          ctx.beginPath()
          ctx.moveTo(0, 0); ctx.lineTo(0, 2)
          ctx.arc(0, 14, 12, Math.PI / 2, 0, false)
          ctx.lineTo(12, 14); ctx.lineTo(14, 14); ctx.lineTo(14, 0)
          ctx.closePath(); ctx.fill()
        }
      }

      Canvas {
        id: rightWing1
        width: 14; height: 14
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: -12
        z: 10
        onPaint: {
          var ctx = getContext("2d")
          ctx.reset()
          ctx.fillStyle = Colors.outline_variant
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
      id: leftWing
      width: 14; height: 14
      anchors.top: parent.top
      anchors.left: parent.left
      z: 10
      onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        ctx.fillStyle = Colors.topbar_gradient5
        ctx.beginPath()
        ctx.moveTo(0, 0); ctx.lineTo(0, 2)
        ctx.arc(0, 14, 12, Math.PI / 2, 0, false)
        ctx.lineTo(12, 14); ctx.lineTo(14, 14); ctx.lineTo(14, 0)
        ctx.closePath(); ctx.fill()
      }
    }

    Canvas {
      id: leftWing1
      width: 14; height: 14
      anchors.top: parent.top
      anchors.left: parent.left
      z: 10
      onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        ctx.fillStyle = Colors.outline_variant
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

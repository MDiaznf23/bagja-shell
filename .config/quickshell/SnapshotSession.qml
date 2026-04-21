import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
  id: snapshotWindow
  property bool isShowing: false
  signal requestClose()

  anchors { top: true; left: true; right: true; bottom: true }
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
  WlrLayershell.namespace: "snapshotsession"

  property string currentLayout: "dwindle"

  Process {
      id: getLayout
      command: ["bash", "-c", "hyprctl getoption general:layout | grep 'str:' | awk '{print $2}'"]
      running: false
      stdout: StdioCollector {
          waitForEnd: true
          onStreamFinished: currentLayout = text.trim()
      }
  }

  onVisibleChanged: {
    if (visible) {
      getLayout.running = false
      getLayout.running = true
      isShowing = true
      sessionNameInput.text = ""
      sessionIconInput.text = ""
      sessionNameInput.forceActiveFocus()
    }
  }

  MouseArea {
    anchors.fill: parent
    onClicked: snapshotWindow.requestClose()
  }

  Rectangle {
    id: panel
    anchors.centerIn: parent
    width: 360
    height: contentCol.implicitHeight + 40
    radius: 16
    gradient: Gradient {
      orientation: Gradient.Horizontal
      GradientStop { position: 0.0; color: Colors.background }
      GradientStop { position: 0.9; color: Colors.background_variant1 }
    }
    border.color: Colors.outline_variant
    border.width: 2

    opacity: isShowing ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    MouseArea { anchors.fill: parent }

    ColumnLayout {
      id: contentCol
      anchors.centerIn: parent
      width: parent.width - 40
      spacing: 14

      Text {
        Layout.alignment: Qt.AlignHCenter
        text: "󰉏  Snapshot Session"
        font.pixelSize: 15
        font.weight: Font.Medium
        color: Colors.text
      }

      Text {
          Layout.alignment: Qt.AlignHCenter
          text: "Stay on current workspace while saving"
          font.pixelSize: 10
          color: Colors.text_variant1
      }

      // Session Name input
      Rectangle {
        Layout.fillWidth: true
        height: 40
        radius: 10
        color: Qt.alpha(Colors.snapshot_input_bg, 0.8)
        border.color: sessionNameInput.activeFocus ? Colors.snapshot_input_border : Colors.outline_variant
        border.width: 2
        Behavior on border.color { ColorAnimation { duration: 150 } }

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: 12
          anchors.rightMargin: 12

          Text {
            text: "󰑕"
            font.pixelSize: 16
            color: Colors.text_variant1
          }

          TextInput {
            id: sessionNameInput
            Layout.fillWidth: true
            font.pixelSize: 13
            color: Colors.snapshot_input_text
            selectionColor: Colors.snapshot_input_selection
            selectedTextColor: Colors.snapshot_input_selected_text

            Keys.onPressed: (event) => {
              if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                sessionIconInput.forceActiveFocus()
                event.accepted = true
              } else if (event.key === Qt.Key_Escape) {
                snapshotWindow.requestClose()
                event.accepted = true
              }
            }

            Text {
              visible: parent.text === ""
              text: "Session name..."
              color: Colors.snapshot_input_placeholder
              font.pixelSize: parent.font.pixelSize
            }
          }
        }
      }

      // Session Icon input
      Rectangle {
        Layout.fillWidth: true
        height: 40
        radius: 10
        color: Qt.alpha(Colors.snapshot_input_bg, 0.8)
        border.color: sessionIconInput.activeFocus ? Colors.snapshot_input_border : Colors.outline_variant
        border.width: 2
        Behavior on border.color { ColorAnimation { duration: 150 } }

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: 12
          anchors.rightMargin: 12

          Text {
            text: "󰀻"
            font.pixelSize: 16
            color: Colors.snapshot_input_icon
          }

          TextInput {
            id: sessionIconInput
            Layout.fillWidth: true
            font.pixelSize: 13
            color: Colors.snapshot_input_text
            selectionColor: Colors.snapshot_input_selection
            selectedTextColor: Colors.snapshot_input_selected_text

            Keys.onPressed: (event) => {
              if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                doSnapshot()
                event.accepted = true
              } else if (event.key === Qt.Key_Escape) {
                snapshotWindow.requestClose()
                event.accepted = true
              }
            }

            Text {
              visible: parent.text === ""
              text: "Icon (default: 󰘚 )"
              color: Colors.text_variant1
              font.pixelSize: parent.font.pixelSize
            }
          }
        }
      }

      Rectangle {
        Layout.fillWidth: true
        implicitHeight: warningRow.implicitHeight + 16
        radius: 8
        color: currentLayout === "dwindle"
          ? Qt.alpha(Colors.snapshot_warning_bg, 0.1)
          : Qt.alpha(Colors.snapshot_info_bg, 0.1)
        border.color: currentLayout === "dwindle"
            ? Qt.alpha(Colors.snapshot_warning_border, 0.3)
            : Qt.alpha(Colors.snapshot_info_border, 0.3)
        border.width: 1

        RowLayout {
          id: warningRow
          anchors.fill: parent
          anchors.leftMargin: 10
          anchors.rightMargin: 10
          anchors.topMargin: 8
          anchors.bottomMargin: 8

          Text {
            id: warningText
            Layout.fillWidth: true
            text: currentLayout === "dwindle"
                ? "Current layout is Dwindle — all windows will be snapshotted with equal size. Switch to Master (Super+Shift+M) for custom sizing."
                : "Current layout is Master — window sizes will be snapshotted as arranged."
            font.pixelSize: 10
            color: currentLayout === "dwindle" ? Colors.snapshot_warning_text : Colors.snapshot_info_text
            wrapMode: Text.WordWrap
          }
        }
      }
      // Save button
      Rectangle {
        Layout.fillWidth: true
        height: 40
        radius: 10
        color: saveHover.containsMouse
          ? Colors.snapshot_save_hovered : Colors.snapshot_save_bg
        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
          anchors.centerIn: parent
          text: "󰉏  Save Session"
          font.pixelSize: 13
          font.weight: Font.Medium
          color: Colors.text
        }

        MouseArea {
          id: saveHover
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: doSnapshot()
        }
      }
    }
  }

  Process {
      id: snapshotProc
      running: false
      command: []
      onExited: {
          Quickshell.execDetached([
              "notify-send",
              "Session Saved",
              "Session '" + sessionNameInput.text + "' has been saved",
              "--icon=folder-saved-search",
              "--urgency=normal"
          ])
      }
  }

  function doSnapshot() {
    var name = sessionNameInput.text.trim()
    if (name === "") return

    var icon = sessionIconInput.text.trim() || "󰘚"

    snapshotProc.command = [
      "bash", "-c",
      "echo '" + name + "\n" + icon + "' | bash " +
      Quickshell.shellDir + "/scripts/snapshot_session.sh '" + name + "' '" + icon + "'"
    ]
    snapshotProc.command = [
      "bash", Quickshell.shellDir + "/scripts/snapshot_session_gui.sh",
      name, icon
    ]
    snapshotProc.running = true
    snapshotWindow.requestClose()
  }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
  id: powerMenu
  property bool isShowing: false
  property int selectedIndex: 0
  signal requestClose()

  anchors { top: true; left: true; right: true; bottom: true }
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
  WlrLayershell.namespace: "powermenu"

  onVisibleChanged: {
    if (visible) {
      isShowing = true
      selectedIndex = 0
      keyboardFocusItem.forceActiveFocus()
    }
  }

  property var actions: [
    { label: "Lock",     icon: "󰌾", command: "qs ipc call lockscreen lock" },
    { label: "Logout",   icon: "󰍃", command: "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit" },
    { label: "Sleep",    icon: "󰤄", command: "systemctl suspend" },
    { label: "Reboot",   icon: "󰑙", command: "systemctl reboot" },
    { label: "Shutdown", icon: "󰐥", command: "systemctl poweroff" },
  ]

  Process { id: actionProc; running: false; command: [] }

  function executeSelected() {
    actionProc.command = ["bash", "-c", actions[selectedIndex].command]
    actionProc.running = true
    powerMenu.requestClose()
  }

  Item {
    id: keyboardFocusItem
    focus: true
    
    property bool keyboardActive: false

    Keys.onPressed: (event) => {
      keyboardActive = true  
      if (event.key === Qt.Key_Left || event.key === Qt.Key_H) {
          selectedIndex = (selectedIndex - 1 + actions.length) % actions.length
      } else if (event.key === Qt.Key_Right || event.key === Qt.Key_L) {
          selectedIndex = (selectedIndex + 1) % actions.length
      } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Space) {
          executeSelected()
      } else if (event.key === Qt.Key_Escape) {
          powerMenu.requestClose()
      }
      event.accepted = true
    }
  }

  MouseArea {
    anchors.fill: parent
    onClicked: powerMenu.requestClose()
  }

  Rectangle {
    anchors.fill: parent
    color: "#000000"
    opacity: isShowing ? 0.5 : 0
    Behavior on opacity {
      NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
  }

  Rectangle {
    id: panel
    anchors.centerIn: parent
    width: actionRow.width + 40
    height: actionRow.height + 40
    gradient: Gradient {
      orientation: Gradient.Horizontal
      GradientStop { position: 0.0; color: Colors.isDark ? Colors.surfaceDim : Colors.surface }
      GradientStop { position: 0.9; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.primaryFixedDim }
    }
    radius: 16
    border.color: Colors.outlineVariant
    border.width: 2

    opacity: isShowing ? 1 : 0
    Behavior on opacity {
      NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    MouseArea { anchors.fill: parent }

    Row {
      id: actionRow
      anchors.centerIn: parent
      spacing: 16

      Repeater {
        model: powerMenu.actions

        Column {
          spacing: 8
          property bool isSelected: index === powerMenu.selectedIndex

          Rectangle {
            width: 64
            height: 64
            radius: 12
            color: (!keyboardFocusItem.keyboardActive && iconHover.containsMouse || parent.isSelected) 
            ? Colors.isDark ? Colors.overPrimaryFixed : Colors.primaryContainer 
            : Colors.isDark ? Colors.surfaceContainerHigh : Colors.surfaceContainerHigh
            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
              anchors.centerIn: parent
              text: modelData.icon
              font.pixelSize: 28
              font.family: "JetBrainsMono Nerd Font"
              color: (!keyboardFocusItem.keyboardActive && iconHover.containsMouse || parent.parent.isSelected) 
              ? Colors.overSurfaceVariant 
              : Colors.overSurface
              Behavior on color { ColorAnimation { duration: 150 } }
            }

            MouseArea {
              id: iconHover
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onEntered: {
                keyboardFocusItem.keyboardActive = false  
                powerMenu.selectedIndex = index
              }
              onClicked: powerMenu.executeSelected()
            }
          }

          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: modelData.label
            color: parent.isSelected 
            ? Colors.isDark ? Colors.tertiaryFixedDim : Colors.primary 
            : Colors.overSurface
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
            Behavior on color { ColorAnimation { duration: 150 } }
          }
        }
      }
    }
  }
}

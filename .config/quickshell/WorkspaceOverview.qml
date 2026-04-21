import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
  id: workspaceOverview
  property bool isShowing: false
  property bool isClosing: false
  signal requestClose()

  anchors { top: true; left: true; right: true; bottom: true }
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
  WlrLayershell.namespace: "workspaceoverview"

  property int dropTargetWorkspace: -1
  property var workspaceList: []
  property bool draggingWindow: false
  property string draggingAddress: ""
  property string draggingClass: ""
  property string draggingTitle: ""
  property int draggingFromWs: -1
  property real ghostX: 0
  property real ghostY: 0

  Process {
    id: workspaceProc
    command: ["bash", Quickshell.shellDir + "/scripts/get-workspaces.sh"]
    running: workspaceOverview.visible
    stdout: SplitParser {
      onRead: (data) => {
        if (workspaceOverview.isClosing) return 
        try {
          var parsed = JSON.parse(data.trim())
          if (Array.isArray(parsed) && parsed.length > 0)
            workspaceOverview.workspaceList = parsed
        } catch (e) {}
      }
    }
  }

  Process { id: moveProc; running: false; command: [] }
  Process { id: killProc; running: false; command: [] }
  Process { id: switchProc; running: false; command: [] }

  onVisibleChanged: {
    if (visible) {
      isShowing = true
      isClosing = false  // ← reset
      draggingWindow = false
      dropTargetWorkspace = -1
      keyboardFocusItem.selectedWorkspace = 0
      keyboardFocusItem.forceActiveFocus()
    } else {
      isShowing = false
      isClosing = true   // ← set saat tutup
    }
  }

  Item {
    id: keyboardFocusItem
    focus: true
    property int selectedWorkspace: 0

    Keys.onPressed: (event) => {
      if (event.key === Qt.Key_Escape) {
        workspaceOverview.requestClose()
      } else if (event.key === Qt.Key_Left || event.key === Qt.Key_H) {
        selectedWorkspace = Math.max(0, selectedWorkspace - 1)
      } else if (event.key === Qt.Key_Right || event.key === Qt.Key_L) {
        selectedWorkspace = Math.min(workspaceOverview.workspaceList.length - 1, selectedWorkspace + 1)
      } else if (event.key === Qt.Key_Up || event.key === Qt.Key_K) {
        selectedWorkspace = Math.max(0, selectedWorkspace - 5)
      } else if (event.key === Qt.Key_Down || event.key === Qt.Key_J) {
        selectedWorkspace = Math.min(workspaceOverview.workspaceList.length - 1, selectedWorkspace + 5)
      } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Space) {
        if (workspaceOverview.workspaceList.length > 0) {
          var wsId = workspaceOverview.workspaceList[selectedWorkspace].id
          switchProc.command = ["hyprctl", "dispatch", "workspace", wsId.toString()]
          switchProc.running = true
          workspaceOverview.requestClose()
        }
      }
      event.accepted = true
    }
  }

  Rectangle {
    id: panel
    anchors.centerIn: parent
    width: parent.width - 42
    height: contentColumn.implicitHeight + 40

    gradient: Gradient {
      orientation: Gradient.Horizontal
      GradientStop { position: 0.0; color: Colors.background }
      GradientStop { position: 0.9; color: Colors.background_variant1 }
    }
    radius: 16
    border.color: Colors.outline_variant
    border.width: 2

    opacity: isShowing ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    transform: Translate {
      y: isShowing ? 0 : 30
      Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
    }

    MouseArea { anchors.fill: parent }

    ColumnLayout {
      id: contentColumn
      anchors {
        top: parent.top
        left: parent.left
        right: parent.right
        margins: 20
      }
      spacing: 16

      RowLayout {
        Layout.fillWidth: true
        Text {
          text: "Workspace Overview"
          color: Colors.text
          font.pixelSize: 16
          font.bold: true
          font.family: "JetBrainsMono Nerd Font"
        }
        Item { Layout.fillWidth: true }
        Text {
          text: workspaceOverview.draggingWindow
            ? "Drop to workspace to move"
            : "← → ↑ ↓ navigate  •  Enter switch  •  Drag to move  •  ✕ close  •  Esc exit"
          color: Colors.text_variant1
          font.pixelSize: 10
          font.family: "JetBrainsMono Nerd Font"
        }
      }

      Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Colors.outline_variant
      }

      Flow {
        id: workspaceRow
        Layout.fillWidth: true
        spacing: 12

        Repeater {
          model: workspaceOverview.workspaceList

          Rectangle {
            id: wsCard
            property var wsData: modelData
            property bool isActive: wsData.focused === true
            property bool isKeySelected: index === keyboardFocusItem.selectedWorkspace
            property bool isDropTarget: workspaceOverview.dropTargetWorkspace === wsData.id
                                        && workspaceOverview.draggingWindow

            width: {
              var cols = Math.min(workspaceOverview.workspaceList.length, 5)
              return (workspaceRow.width - (cols - 1) * 12) / cols
            }
            height: 160

            color: isDropTarget
              ? Qt.alpha(Colors.ws_card_drop_bg, 0.25)
              : isActive
                ? Qt.alpha(Colors.ws_card_active_bg, Colors.isDark ? 1.0 : 0.7)
                : Colors.ws_card_inactive_bg

            radius: 10
            border.color: isDropTarget ? Colors.ws_card_drop_border
              : isKeySelected ? Colors.ws_card_key_border
              : isActive ? Colors.ws_card_active_border
              : Colors.ws_card_inactive_border
            border.width: isDropTarget || isKeySelected ? 2 : 1

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            MouseArea {
              anchors.fill: parent
              enabled: !workspaceOverview.draggingWindow
              propagateComposedEvents: true
              onClicked: {
                switchProc.command = ["hyprctl", "dispatch", "workspace", wsData.id.toString()]
                switchProc.running = true
                workspaceOverview.requestClose()
              }
            }

            DropArea {
              anchors.fill: parent
              onEntered: {
                if (workspaceOverview.draggingWindow)
                  workspaceOverview.dropTargetWorkspace = wsData.id
              }
              onExited: {
                if (workspaceOverview.dropTargetWorkspace === wsData.id)
                  workspaceOverview.dropTargetWorkspace = -1
              }
              onDropped: {
                if (workspaceOverview.draggingWindow &&
                    workspaceOverview.draggingFromWs !== wsData.id &&
                    workspaceOverview.draggingClass !== "") {
                  moveProc.command = ["bash", "-c",
                    "hyprctl dispatch movetoworkspacesilent " + wsData.id +
                    ",address:" + workspaceOverview.draggingAddress]
                  moveProc.running = true
                }
                workspaceOverview.draggingWindow = false
                workspaceOverview.dropTargetWorkspace = -1
              }
            }

            ColumnLayout {
              anchors.fill: parent
              anchors.margins: 8
              spacing: 6

              RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Rectangle {
                  width: 20; height: 20
                  radius: 10
                  color: wsCard.isActive ? Colors.ws_badge_active_bg
                    : wsCard.isKeySelected ? Qt.alpha(Colors.ws_badge_key_bg, 0.3)
                    : Colors.ws_badge_inactive_bg

                  Text {
                    anchors.centerIn: parent
                    text: wsData.id
                    color: wsCard.isActive ? Colors.ws_badge_active_text : Colors.ws_badge_inactive_text
                    font.pixelSize: 10
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                  }
                }

                Text {
                  text: wsData.focused
                    ? "active"
                    : (wsData.apps && wsData.apps.length > 0
                        ? wsData.apps.length + " app" + (wsData.apps.length > 1 ? "s" : "")
                        : "empty")
                  color: wsCard.isActive ? Colors.ws_status_active : Colors.ws_status_inactive
                  font.pixelSize: 9
                  font.family: "JetBrainsMono Nerd Font"
                  Layout.fillWidth: true
                }
              }

              Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Colors.outline_variant
                opacity: 0.5
              }

              Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Column {
                  width: parent.width
                  spacing: 3

                  Repeater {
                    model: wsData.apps ? wsData.apps.slice(0, 5) : []

                    Item {
                      id: appItem
                      property var appData: modelData
                      width: parent.width
                      height: 24

                      property bool isBeingDragged: workspaceOverview.draggingWindow
                        && workspaceOverview.draggingClass === appData.class
                        && workspaceOverview.draggingTitle === appData.title

                      Rectangle {
                        anchors.fill: parent
                        radius: 5
                        color: appHoverHandler.hovered && !workspaceOverview.draggingWindow
                          ? Colors.ws_app_hovered_bg
                          : "transparent"
                        opacity: appItem.isBeingDragged ? 0.3 : 1.0
                        Behavior on color { ColorAnimation { duration: 100 } }

                        RowLayout {
                          anchors.fill: parent
                          anchors.leftMargin: 5
                          anchors.rightMargin: 5
                          spacing: 6

                          Image {
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16
                            source: {
                              var cls = appData.class ? appData.class.toLowerCase() : ""
                              if (!cls) return "image://icon/application-x-executable"
                              var path = Quickshell.iconPath(cls, true)
                              if (path) return path
                              path = Quickshell.iconPath(appData.class, true)
                              return path || "image://icon/application-x-executable"
                            }
                            sourceSize: Qt.size(16, 16)
                            fillMode: Image.PreserveAspectFit
                            onStatusChanged: if (status === Image.Error) source = "image://icon/application-x-executable"
                          }

                          Text {
                            text: appData.title || appData.class || "Unknown"
                            color: Colors.ws_app_title
                            font.pixelSize: 9
                            font.family: "JetBrainsMono Nerd Font"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                          }

                          Text {
                            text: "✕"
                            color: Colors.ws_app_close_icon 
                            font.pixelSize: 8
                            visible: appHoverHandler.hovered && !workspaceOverview.draggingWindow
                            MouseArea {
                              anchors.fill: parent
                              cursorShape: Qt.PointingHandCursor
                              onClicked: {
                                killProc.command = ["bash", "-c",
                                  "hyprctl dispatch closewindow address:" + appData.address]
                                killProc.running = true
                              }
                            }
                          }
                        }
                      }

                      HoverHandler { id: appHoverHandler }

                      DragHandler {
                        id: appDragHandler
                        target: null
                        dragThreshold: 8

                        onActiveChanged: {
                          if (active) {
                            workspaceOverview.draggingWindow = true
                            workspaceOverview.draggingClass = appData.class
                            workspaceOverview.draggingTitle = appData.title
                            workspaceOverview.draggingAddress = appData.address
                            workspaceOverview.draggingFromWs = wsData.id
                          } else {
                            dragVisual.Drag.drop()
                            workspaceOverview.draggingWindow = false
                            workspaceOverview.dropTargetWorkspace = -1
                          }
                        }

                        onCentroidChanged: {
                          if (active) {
                            var pos = appItem.mapToItem(overlayContainer, centroid.position.x, centroid.position.y)
                            workspaceOverview.ghostX = pos.x - 70
                            workspaceOverview.ghostY = pos.y - 12
                          }
                        }
                      }
                    }
                  }

                  Text {
                    visible: wsData.apps && wsData.apps.length > 5
                    text: "+" + ((wsData.apps ? wsData.apps.length : 0) - 5) + " more"
                    color: Colors.ws_more_text
                    font.pixelSize: 9
                    font.family: "JetBrainsMono Nerd Font"
                    leftPadding: 5
                  }

                  Item {
                    visible: !wsData.apps || wsData.apps.length === 0
                    width: parent.width
                    height: 40
                    Text {
                      anchors.centerIn: parent
                      text: "empty"
                      color: Colors.outline_variant
                      font.pixelSize: 9
                      font.family: "JetBrainsMono Nerd Font"
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

  Item {
    id: overlayContainer
    anchors.fill: parent
    z: 999
    enabled: false

    Rectangle {
      id: dragVisual
      width: 140
      height: 24
      radius: 6
      color: Colors.drag_visual_bg
      border.color: Colors.drag_visual_border
      border.width: 1
      visible: workspaceOverview.draggingWindow
      x: workspaceOverview.ghostX
      y: workspaceOverview.ghostY

      Drag.active: workspaceOverview.draggingWindow
      Drag.hotSpot.x: 70
      Drag.hotSpot.y: 12
      Drag.supportedActions: Qt.MoveAction

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 6

        Image {
          Layout.preferredWidth: 14
          Layout.preferredHeight: 14
          source: {
            var cls = workspaceOverview.draggingClass.toLowerCase()
            if (!cls) return "image://icon/application-x-executable"
            var path = Quickshell.iconPath(cls, true)
            return path || "image://icon/application-x-executable"
          }
          sourceSize: Qt.size(14, 14)
          fillMode: Image.PreserveAspectFit
          onStatusChanged: if (status === Image.Error) source = "image://icon/application-x-executable"
        }

        Text {
          text: workspaceOverview.draggingTitle || workspaceOverview.draggingClass
          color: Colors.text
          font.pixelSize: 9
          font.family: "JetBrainsMono Nerd Font"
          elide: Text.ElideRight
          Layout.fillWidth: true
        }
      }
    }
  }
}

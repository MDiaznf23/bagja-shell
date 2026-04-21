import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Item {
  id: root
  signal appLaunched()
  property var appList: []

  implicitWidth: appRow.width
  implicitHeight: appRow.height

  Rectangle {
    id: removeMenu
    visible: false
    width: 30
    height: 30
    z: 999
    y: 9
    color: Colors.remove_menu_bg
    radius: 6
    property string targetApp: ""

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onExited: removeMenu.visible = false
      Rectangle {
        anchors.fill: parent
        color: parent.containsMouse ? Colors.remove_menu_hovered : "transparent"
        radius: 6
      }
      Text { anchors.centerIn: parent; text: "X"; color: Colors.remove_menu_icon ; font.pixelSize: 12 }
      onClicked: {
        removeProcess.command = ["python3", Quickshell.shellDir + "/scripts/app_manager.py", "remove", removeMenu.targetApp]
        removeProcess.running = true
        removeMenu.visible = false
      }
    }
  }

  Row {
    id: appRow
    spacing: 15

    Repeater {
      model: root.appList.slice(0, 17)

      delegate: Item {
        width: 48
        height: 48

        Image {
          id: appIcon
          source: {
            var entry = DesktopEntries.byId(modelData)
            var iconName = entry ? entry.icon : modelData
            if (!iconName) return Qt.resolvedUrl(Quickshell.shellDir + "/assets/error.png")
            if (iconName.startsWith("/")) return Qt.resolvedUrl(iconName)
            var path = Quickshell.iconPath(iconName, true)
            if (!path) return Qt.resolvedUrl(Quickshell.shellDir + "/assets/error.png")
            return path
          }
          width: 48
          height: 48
          sourceSize: Qt.size(48, 48)
          fillMode: Image.PreserveAspectFit
          smooth: true
          opacity: appMouseArea.containsMouse ? 0.7 : 1.0
          Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        MouseArea {
          id: appMouseArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          propagateComposedEvents: true
          acceptedButtons: Qt.LeftButton | Qt.RightButton

          onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
              var pos = mapToItem(root, 0, 0)
              removeMenu.targetApp = modelData
              removeMenu.x = pos.x + 16
              removeMenu.visible = true
            } else {
              removeMenu.visible = false
              root.launchApp(modelData)
            }
          }
        }

        scale: appMouseArea.containsMouse ? 1.3 : appMouseArea.pressed ? 0.9 : 1.0
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

        Rectangle {
          anchors.fill: parent
          color: "transparent"
          border.color: "transparent"
          border.width: appMouseArea.containsMouse ? 2 : 0
          radius: 4
          opacity: appMouseArea.containsMouse ? 0.5 : 0
          Behavior on opacity { NumberAnimation { duration: 150 } }
        }
      }
    }
  }

  FileView {
    id: appsFileWatcher
    path: Quickshell.shellDir + "/apps.json"
    watchChanges: true
    onFileChanged: root.reloadApps()
  }

  Process {
    id: loadProcess
    command: ["python3", Quickshell.shellDir + "/scripts/app_manager.py", "export"]
    running: false
    stdout: SplitParser {
      onRead: data => {
        try {
          var apps = JSON.parse(data.trim())
          root.appList = apps
        } catch (e) {
          console.error("Error parsing apps:", e)
        }
      }
    }
    onExited: (code, status) => {
      if (code !== 0) {
        console.error("Error loading apps, using defaults")
        root.appList = ["firefox", "kitty", "discord"]
      }
    }
  }

  Process {
    id: removeProcess
    command: ["echo", ""]
  }

  Timer {
    interval: 30000
    running: true
    repeat: true
    onTriggered: root.reloadApps()
  }

  Component.onCompleted: { reloadApps() }

  function reloadApps() { loadProcess.running = true }

  function launchApp(appName) {
    appLaunched()
    var entry = DesktopEntries.byId(appName)
    if (!entry) {
      var all = DesktopEntries.applications.values
      for (var i = 0; i < all.length; i++) {
        if (all[i].id.toLowerCase().includes(appName.toLowerCase())) {
          entry = all[i]
          break
        }
      }
    }
    if (entry) entry.execute()
    else console.warn("Desktop entry not found:", appName)
  }
}

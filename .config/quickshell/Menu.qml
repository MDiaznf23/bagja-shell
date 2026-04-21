import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Controls
import Quickshell.Wayland
import Quickshell.Io
import Qt5Compat.GraphicalEffects

PanelWindow {
  id: root

  implicitWidth: 544
  implicitHeight: 438

  anchors {
    left: true
    top: true
  }

  margins {
    top: 28
    left: 13
  }

  color: "transparent"

  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

  signal requestClose()

  property var categoryApps: ({})
  property var categories: []
  property int currentCategoryIndex: 0
  property bool isShowing: false
  property bool isLoading: false
  signal requestPowerMenu()

  Timer {
    id: showTimer
    interval: 16
    onTriggered: root.isShowing = true
  }

  onVisibleChanged: {
    if (visible) {
      isShowing = false
      showTimer.start()
    }
  }

  onIsShowingChanged: {
    if (!isShowing) contextMenu.visible = false
  }

  Connections {
    target: DesktopEntries.applications
    function onValuesChanged() {
      reloadTimer.restart()
    }
  }

  Component.onCompleted: {
    if (DesktopEntries.applications.values.length > 0) {
      loadApplications()
    } else {
      console.log("Waiting for desktop entries to load...")
      delayTimer.start()
    }
  }

  Timer {
    id: reloadTimer
    interval: 200
    repeat: false
    onTriggered: loadApplications()
  }

  Timer {
    id: delayTimer
    interval: 100
    repeat: true
    triggeredOnStart: false

    onTriggered: {
      console.log("Checking desktop entries... Count:", DesktopEntries.applications.values.length)
      if (DesktopEntries.applications.values.length > 0) {
        loadApplications()
        delayTimer.stop()
      }
    }
  }

  function loadApplications() {
    if (root.isLoading) return
    root.isLoading = true

    var appsByCategory = {}
    var seenIds = {}  // ← filter duplikat by id

    for (var i = 0; i < DesktopEntries.applications.values.length; i++) {
        var app = DesktopEntries.applications.values[i]

        if (!app || !app.name) continue

        // Skip kalau id sudah pernah diproses
        var appId = app.id || app.name
        if (seenIds[appId]) continue
        seenIds[appId] = true

        var mainCategories = ["AudioVideo", "Audio", "Video", "Development", "Education",
            "Game", "Graphics", "Network", "Office", "Science", "Settings", "System", "Utility"]

        var category = "Other"
        if (app.categories && app.categories.length > 0) {
            if (app.categories.indexOf("X-WayDroid-App") !== -1) {
                category = "WayDroid"
            } else {
                for (var c = 0; c < app.categories.length; c++) {
                    if (mainCategories.indexOf(app.categories[c]) !== -1) {
                        category = app.categories[c]
                        break
                    }
                }
            }
        }

        var categoryMapping = {
            "AudioVideo": "Multimedia",
            "Audio": "Multimedia",
            "Video": "Multimedia",
            "Development": "Development",
            "Game": "Games",
            "Graphics": "Graphics",
            "Network": "Internet",
            "Office": "Office",
            "Settings": "Settings",
            "System": "System",
            "Utility": "Accessories"
        }

        if (categoryMapping[category]) {
            category = categoryMapping[category]
        }

        if (!appsByCategory[category]) {
            appsByCategory[category] = []
        }

        appsByCategory[category].push(app)
    }

    root.categoryApps = appsByCategory
    root.categories = Object.keys(appsByCategory).sort()

    if (root.currentCategoryIndex >= root.categories.length) {
        root.currentCategoryIndex = 0
    }

    categoryModel.clear()
    for (var j = 0; j < root.categories.length; j++) {
        categoryModel.append({ categoryName: root.categories[j] })
    }

    if (root.categories.length > 0) {
        updateAppList()
    }

    root.isLoading = false
  }

  ListModel {
    id: categoryModel
  }

  ListModel {
    id: appListModel
  }

  function updateAppList() {
    appListModel.clear()
    var catName = root.categories[currentCategoryIndex]
    var apps = root.categoryApps[catName] || []

    for (var i = 0; i < apps.length; i++) {
      appListModel.append({
        name: apps[i].name,
        icon: apps[i].icon,
        comment: apps[i].comment,
        desktopEntry: apps[i]
      })
    }
  }

  MouseArea {
    anchors.fill: parent
    propagateComposedEvents: true
    onClicked: (mouse) => {
      if (contextMenu.visible) {
        contextMenu.visible = false
        mouse.accepted = true
      } else {
        mouse.accepted = false
      }
    }
  }

  Rectangle {
    id: mainRect
    width: 530
    height: 350
    anchors.top: parent.top
    anchors.left: parent.left
    gradient: Gradient {
      orientation: Gradient.Horizontal
      GradientStop { position: 0.1; color: Colors.topbar_gradient1  }
      GradientStop { position: 0.5; color: Colors.topbar_gradient2 }
      GradientStop { position: 0.99; color: Colors.topbar_gradient3 }
    }

    radius: 12
    border.color: Colors.outline_variant
    border.width: 2

    opacity: root.isShowing ? 1 : 0
    Behavior on opacity {
      NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
    }

    transform: Translate {
      y: root.isShowing ? 0 : -420
      Behavior on y {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
      }
    }

    ColumnLayout {
      anchors.fill: parent
      spacing: 0

      RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 0

        Item {
          Layout.fillHeight: true
          Layout.preferredWidth: 192

          Rectangle {
            anchors.fill: parent
            color: "transparent"

            ColumnLayout {
              anchors.fill: parent
              anchors.rightMargin: 10
              anchors.topMargin: 10 
              anchors.bottomMargin: 10 
              anchors.leftMargin: 12
              spacing: 8

              Text {
                text: "Categories"
                color: Colors.text
                font.bold: true
                font.pixelSize: 14
              }

              Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Colors.outline
              }

              Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ListView {
                  anchors.fill: parent
                  model: categoryModel
                  spacing: 4
                  currentIndex: root.currentCategoryIndex

                  ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    width: 3
                    contentItem: Rectangle {
                      implicitWidth: 2
                      implicitHeight: 2
                      radius: 2
                      color: Colors.scrollbar_thumb
                      opacity: parent.pressed ? 1.0 : parent.hovered ? 0.8 : 0.5
                    }
                    background: Rectangle {
                      implicitWidth: 2
                      radius: 2
                      color: Colors.scrollbar_track
                      opacity: 0.5
                    }
                  }

                  delegate: MouseArea {
                    width: ListView.view.width
                    height: 35
                    hoverEnabled: true

                    Rectangle {
                      anchors.fill: parent
                      anchors.rightMargin: 5
                      color: {
                        if (root.currentCategoryIndex === index)
                          return Colors.category_selected
                        if (parent.containsMouse)
                          return Qt.alpha(Colors.category_hovered, 0.7)
                        return "transparent"
                      }
                      radius: 6

                      RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        spacing: 8

                        Text {
                          text: model.categoryName
                          color: root.currentCategoryIndex === index ? Colors.text : Colors.text_variant1 
                          font.pixelSize: 12
                          Layout.fillWidth: true
                        }
                      }
                    }

                    onClicked: {
                      root.currentCategoryIndex = index
                      root.updateAppList()
                    }
                  }
                }
              }
            }
          }
        }

        Rectangle { Layout.preferredWidth: 2; Layout.fillHeight: true; color: Colors.outline_variant }

        Item {
          Layout.fillHeight: true
          Layout.fillWidth: true

          Rectangle {
            anchors.fill: parent
            anchors.rightMargin: 12
            color: "transparent"

            ColumnLayout {
              anchors.fill: parent
              anchors.rightMargin: 0
              anchors.topMargin: 10 
              anchors.bottomMargin: 10 
              anchors.leftMargin: 12
              spacing: 8

              RowLayout {
                Layout.fillWidth: true

                Text {
                  text: root.categories[root.currentCategoryIndex] || "Applications"
                  color: Colors.text
                  font.bold: true
                  font.pixelSize: 14
                  Layout.fillWidth: true
                }

                Text {
                  text: appListModel.count + " apps"
                  color: Colors.text
                  font.pixelSize: 11
                }
              }

              Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Colors.outline
              }

              Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ListView {
                  anchors.fill: parent
                  model: appListModel
                  spacing: 4

                  ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    width: 3
                    contentItem: Rectangle {
                      implicitWidth: 4
                      implicitHeight: 4
                      radius: 2
                      color: Colors.scrollbar_thumb
                      opacity: parent.pressed ? 1.0 : parent.hovered ? 0.8 : 0.5
                    }
                    background: Rectangle {
                      implicitWidth: 4
                      radius: 2
                      color: Colors.scrollbar_track
                      opacity: 0.5
                    }
                  }

                  delegate: MouseArea {
                    width: ListView.view.width
                    height: 45
                    hoverEnabled: true

                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: (mouse) => {
                      if (mouse.button === Qt.RightButton) {
                        contextMenu.appName = model.icon
                        var pos = mapToItem(null, 0, 0)
                        contextMenu.x = pos.x + width - contextMenu.width
                        contextMenu.y = pos.y + 4
                        contextMenu.visible = true
                      } else {
                        model.desktopEntry.execute()
                        root.requestClose()
                      }
                    }

                    Rectangle {
                      anchors.fill: parent
                      anchors.rightMargin: 5
                      color: parent.containsMouse 
                        ? Colors.container_level_1_variant1 
                        : "transparent"
                      radius: 6
                      border.color: "transparent"
                      border.width: 2

                      RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 12
                        spacing: 12

                        Rectangle {
                          Layout.preferredWidth: 32
                          Layout.preferredHeight: 32
                          color: Colors.container_level_1
                          radius: 6
                          border.color: Colors.outline_variant
                          border.width: 2

                          Image {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            source: {
                              if (!model.icon) return "image://icon/application-x-executable"
                              if (model.icon.startsWith("/")) return Qt.resolvedUrl(model.icon)
                              var path = Quickshell.iconPath(model.icon, true)
                              if (!path) return Qt.resolvedUrl(Quickshell.shellDir + "/assets/error.png")
                              return path
                            }
                            sourceSize: Qt.size(24, 24)
                            fillMode: Image.PreserveAspectFit

                            onStatusChanged: {
                              if (status === Image.Error)
                                source = "image://icon/application-x-executable"
                            }
                          }
                        }

                        ColumnLayout {
                          Layout.fillWidth: true
                          spacing: 2

                          Text {
                            text: model.name
                            color: Colors.text
                            font.pixelSize: 13
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                          }

                          Text {
                            text: model.comment || "No description"
                            color: Colors.text
                            font.pixelSize: 10
                            elide: Text.ElideRight
                            Layout.fillWidth: true
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
      }

      Rectangle { 
        Layout.fillWidth: true; 
        Layout.preferredHeight: 2; 
        color: Colors.outline_variant 
      }

      Rectangle {
        Layout.fillWidth: true
        height: 48
        color: "transparent"

        RowLayout {
          anchors.fill: parent
          anchors.topMargin: 0
          anchors.leftMargin: 16
          anchors.rightMargin: 10
          spacing: 10

          Item {
            width: 28; height: 28
            Layout.alignment: Qt.AlignVCenter

            Text {
              anchors.centerIn: parent
              text: ""
              font.pixelSize: 18
              font.family: "JetBrainsMono Nerd Font"
              color: Colors.text
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.requestClose()
                Qt.callLater(() => { isShellSettingsVisible = true })
              }
            }
          }

          Item {
            width: 28
            height: 28
            Layout.alignment: Qt.AlignVCenter

            Image {
              id: profileImg
              anchors.fill: parent
              source: Qt.resolvedUrl(Quickshell.shellDir + "/assets/profile.jpg")
              fillMode: Image.PreserveAspectCrop
              layer.enabled: true
              layer.effect: OpacityMask {
                maskSource: Rectangle {
                  width: profileImg.width
                  height: profileImg.height
                  radius: 14
                  visible: false
                }
              }
            }
          }

          Text {
            id: usernameText
            color: Colors.text
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            Layout.fillWidth: true

            Process {
              command: ["whoami"]
              running: true
              stdout: SplitParser {
                onRead: data => usernameText.text = data.trim()
              }
            }
          }

          Item {
            width: 32
            height: 32
            z: 10

            Text {
              anchors.centerIn: parent
              text: "\uf011"
              font.family: "JetBrainsMono Nerd Font"
              font.pixelSize: 16
              color: Colors.text
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: (mouse) => {
                mouse.accepted = true
                root.requestClose()
                root.requestPowerMenu()
              }
            }
          }
        }
      }
    }

    Canvas {
      id: rightWing
      width: 14; height: 14
      anchors.top: mainRect.top
      anchors.right: mainRect.right
      anchors.rightMargin: -12
      z: 10
      onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        ctx.fillStyle = Colors.topbar_gradient3 
        ctx.lineWidth = 2
        ctx.beginPath()
        ctx.moveTo(14, 0)
        ctx.lineTo(14, 2)
        ctx.arc(14, 14, 12, Math.PI / 2, Math.PI, true)
        ctx.lineTo(2, 14)
        ctx.lineTo(0, 14)
        ctx.lineTo(0, 0)
        ctx.closePath()
        ctx.fill()
      }
    }

    Canvas {
      id: rightWing1
      width: 14; height: 14
      anchors.top: mainRect.top
      anchors.right: mainRect.right
      anchors.rightMargin: -12
      z: 10
      onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        ctx.fillStyle = Colors.outline_variant
        ctx.lineWidth = 2
        ctx.beginPath()
        ctx.moveTo(14, 0)
        ctx.lineTo(14, 2)
        ctx.arc(14, 14, 12, Math.PI / 2, Math.PI, true)
        ctx.lineTo(2, 14)
        ctx.lineTo(0, 14)
        ctx.arc(14, 14, 14, Math.PI, Math.PI / 2, false)
        ctx.closePath()
        ctx.fill()
      }
    }

    Canvas {
      id: leftWing
      width: 14; height: 14
      anchors.bottom: mainRect.bottom
      anchors.left: mainRect.left
      anchors.bottomMargin: -12
      z: 10
      onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        ctx.fillStyle = Colors.topbar_gradient1 
        ctx.lineWidth = 2
        ctx.beginPath()
        ctx.moveTo(14, 0)
        ctx.lineTo(14, 2)
        ctx.arc(14, 14, 12, Math.PI / 2, Math.PI, true)
        ctx.lineTo(2, 14)
        ctx.lineTo(0, 14)
        ctx.lineTo(0, 0)
        ctx.closePath()
        ctx.fill()
      }
    }

    Canvas {
      id: leftWing1
      width: 14; height: 14
      anchors.bottom: mainRect.bottom
      anchors.left: mainRect.left
      anchors.bottomMargin: -12
      z: 10
      onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        ctx.fillStyle = Colors.outline_variant
        ctx.lineWidth = 2
        ctx.beginPath()
        ctx.moveTo(14, 0)
        ctx.lineTo(14, 2)
        ctx.arc(14, 14, 12, Math.PI / 2, Math.PI, true)
        ctx.lineTo(2, 14)
        ctx.lineTo(0, 14)
        ctx.arc(14, 14, 14, Math.PI, Math.PI / 2, false)
        ctx.closePath()
        ctx.fill()
      }
    }

    Rectangle {
      id: topPatch
      height: 12
      gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0.1; color: Colors.topbar_gradient1  }
        GradientStop { position: 0.5; color: Colors.topbar_gradient2 }
        GradientStop { position: 0.99; color: Colors.topbar_gradient3 }
      }
      anchors.top: mainRect.top
      anchors.left: mainRect.left
      anchors.right: mainRect.right
    }

    Rectangle {
      id: leftPatch
      height: parent.height
      width: 12
      color: Colors.topbar_gradient1 
      anchors.top: mainRect.top
      anchors.left: mainRect.left
    }
  }

  Rectangle {
    id: contextMenu
    property string appName
    visible: false
    width: 140
    height: 36
    z: 999
    color: Colors.context_menu_bg
    radius: 6
    border.color: Colors.outline
    border.width: 1

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      Rectangle {
        anchors.fill: parent
        color: parent.containsMouse 
          ? Colors.context_menu_hovered 
          : "transparent"
        radius: 6
      }
      Text { anchors.centerIn: parent; text: "Add to Panel"; color: Colors.text_variant1; font.pixelSize: 12 }
      onClicked: {
        addProcess.command = ["python3", Quickshell.shellDir + "/scripts/app_manager.py", "add", contextMenu.appName]
        addProcess.running = true
        contextMenu.visible = false
      }
    }
  }

  Process {
    id: addProcess
    command: ["echo", ""]
  }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
  id: launcherWindow
    
  visible: true
  implicitWidth: 480
  implicitHeight: 540
    
  anchors {
    left: true
    bottom: true
  }

  margins {
    left: -2
    bottom: -2
  }
    
  color: "transparent"
    
  exclusionMode: ExclusionMode.Ignore
  
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

  // ── State ──────────────────────────────────────────────
  property var filteredApps: []
  property bool isShowing: false

  // "select" | "apps" | "sessions"
  property string currentMode: "select"
  // 0 = Apps highlighted, 1 = Sessions highlighted
  property int modeSelectIndex: 0

  property var sessionsList: []
  property int sessionIndex: 0

  signal requestClose()

  property int currentWorkspace: 1

  Process {
    id: getWorkspace
    command: ["hyprctl", "activeworkspace", "-j"]
    running: false
    stdout: StdioCollector {
        waitForEnd: true
        onStreamFinished: {
            try {
                var ws = JSON.parse(text)
                launcherWindow.currentWorkspace = ws.id
            } catch(e) {
                console.log("workspace parse error:", e)
            }
        }
    }
}

  // ── Sessions JSON loader ───────────────────────────────
  FileView {
    id: sessionsFile
    path: Quickshell.shellDir + "/sessions.json"
    watchChanges: true
    onFileChanged: reload()
    onTextChanged: {
        var raw = sessionsFile.text()
        if (!raw) return
        var trimmed = raw.trim()
        if (!trimmed.startsWith("[") || !trimmed.endsWith("]")) return
        try {
            launcherWindow.sessionsList = JSON.parse(trimmed)
        } catch(e) {
            console.log("parse error:", e)
        }
    }
  }


  // ── Visibility / reset ─────────────────────────────────
  onVisibleChanged: {
    if (visible) {
        isShowing = true
        currentMode = "select"
        modeSelectIndex = 0
        sessionIndex = 0
        searchInput.text = ""
        updateFilteredApps()

        getWorkspace.running = false  // reset dulu
        getWorkspace.running = true   // baru jalankan lagi
    }
}

  // ── App helpers ────────────────────────────────────────
  function updateFilteredApps() {
    var query = searchInput.text.toLowerCase()
    var source = DesktopEntries.applications.values

    // deduplicate by name+exec
    var seen = {}
    var unique = source.filter(function(app) {
      var key = (app.name || "") + "|" + (app.execString || "")
      if (seen[key]) return false
      seen[key] = true
      return true
    })

    if (query === "") {
        filteredApps = unique
    } else {
      filteredApps = unique.filter(function(app) {
        return app.name.toLowerCase().includes(query) ||
          (app.description && app.description.toLowerCase().includes(query)) ||
          (app.genericName && app.genericName.toLowerCase().includes(query))
      })
    }
    appListView.currentIndex = 0
  }

  function launchApp(entry) {
    entry.execute()
    requestClose()
  }

  // ── Session launcher ───────────────────────────────────
  function launchSession(session) {
    var ws = launcherWindow.currentWorkspace
    Quickshell.execDetached(["hyprctl", "dispatch", "workspace", ws.toString()])

    var layout = session.layout || "master"
    Quickshell.execDetached(["hyprctl", "keyword", "general:layout", layout])

    if (layout === "master") {
        Quickshell.execDetached(["hyprctl", "keyword", "master:new_status", "slave"])
    }

    var launchedAddresses = []
    launchNext(session.apps, 0, ws, session, launchedAddresses)
    requestClose()
  }

  function launchNext(apps, index, ws, session, launchedAddresses) {
    if (index >= apps.length) {
        if (session.mfact && (session.layout || "master") === "master") {
            var finishTimer = Qt.createQmlObject('import QtQuick; Timer {}', launcherWindow)
            finishTimer.interval = 100
            finishTimer.repeat = false
            finishTimer.triggered.connect(function() {
                finishTimer.destroy()
                Quickshell.execDetached([
                  "bash", "-c",
                  "hyprctl dispatch focuswindow address:0x" + launchedAddresses[0] +
                  " && sleep 0.02" +
                  " && hyprctl dispatch layoutmsg 'mfact -0.05'" +
                  " && sleep 0.02" +
                  " && hyprctl dispatch layoutmsg 'mfact " + session.mfact + "'"
              ])
            })
            finishTimer.start()
        }
        return
    }

    var app = apps[index]
    var launchTimer = Qt.createQmlObject('import QtQuick; Timer {}', launcherWindow)
    launchTimer.interval = app.delay || 0
    launchTimer.repeat = false
    launchTimer.triggered.connect(function() {
    launchTimer.destroy()

      var snapClass = app["class"] || app.exec.split(" ")[0]

      var watcher = Qt.createQmlObject('
          import Quickshell.Io
          Process { running: false }', launcherWindow)
      watcher.command = ["bash", "-c",
          "socat -t 15 - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | " +
          "while IFS= read -r line; do " +
          "if [[ \"$line\" == openwindow* ]]; then " +
          "DATA=\"${line#openwindow>>}\"; " +
          "ADDR=$(echo $DATA | cut -d',' -f1); " +
          "CLASS=$(echo $DATA | cut -d',' -f3); " +
          "if [[ \"$CLASS\" == \"" + snapClass + "\" ]]; then echo $ADDR; pkill -P $$ socat; break; fi; " +
          "fi; done"
      ]
      var watchOut = Qt.createQmlObject('import Quickshell.Io; StdioCollector { waitForEnd: true }', watcher)
      watcher.stdout = watchOut
      watcher.exited.connect(function() {
          var newAddr = watchOut.text.trim()
          if (newAddr) launchedAddresses.push(newAddr)
          watcher.destroy()
          launchNext(apps, index + 1, ws, session, launchedAddresses)
      })
      watcher.running = true

      Quickshell.execDetached([
          "hyprctl", "dispatch", "exec",
          "[workspace " + ws + "] " + app.exec
      ])
    })
    launchTimer.start()
  }

  Connections {
    target: DesktopEntries.applications
    function onValuesChanged() { updateFilteredApps() }
  }

  // ── Background gradient helper (unchanged from original) ─

  // ══════════════════════════════════════════════════════
  //  MAIN BACKGROUND
  // ══════════════════════════════════════════════════════
  Rectangle {
    id: launcherBackground
    anchors {
      bottom: parent.bottom
      left:   parent.left
      leftMargin:   15
      bottomMargin: 15
    }
    width:  430
    height: {
      if (currentMode === "select")   return 130
      if (currentMode === "sessions") return Math.max(100, Math.min(400, 50 + (Math.min(sessionsList.length, 4) * 56)))
      return Math.max(100, Math.min(400, 97 + (Math.min(filteredApps.length, 4) * 50)))
    }
    radius: 14

    property real screenHeight: Quickshell.screens[0].height
    property real topBarHeight: 30
    property real bottomMargin: 15
    property real effectiveBottom: screenHeight - bottomMargin
    property real wEnd:   (effectiveBottom - topBarHeight) / (screenHeight - topBarHeight)
    property real wStart: wEnd - (height / (screenHeight - topBarHeight))

    function leftbarColorAt(p) {
      var stops = [
        {pos: 0.0,  color: Colors.leftbar_gradient1},
        {pos: 0.2,  color: Colors.leftbar_gradient2},
        {pos: 0.3,  color: Colors.leftbar_gradient3},
        {pos: 0.4,  color: Colors.leftbar_gradient4},
        {pos: 0.46, color: Colors.leftbar_gradient5},
        {pos: 0.6,  color: Colors.leftbar_gradient6},
        {pos: 0.7,  color: Colors.leftbar_gradient7},
        {pos: 0.8,  color: Colors.leftbar_gradient8},
        {pos: 0.9,  color: Colors.leftbar_gradient9},
        {pos: 1.0,  color: Colors.leftbar_gradient10},
      ]
      if (p <= 0) return stops[0].color
      if (p >= 1) return stops[stops.length-1].color
      for (var i = 0; i < stops.length - 1; i++) {
        if (p >= stops[i].pos && p <= stops[i+1].pos) {
          var t = (p - stops[i].pos) / (stops[i+1].pos - stops[i].pos)
          return Qt.rgba(
            stops[i].color.r + t*(stops[i+1].color.r - stops[i].color.r),
            stops[i].color.g + t*(stops[i+1].color.g - stops[i].color.g),
            stops[i].color.b + t*(stops[i+1].color.b - stops[i].color.b),
            1.0
          )
        }
      }
    }

    gradient: Gradient {
      orientation: Gradient.Vertical
      GradientStop { position: 0.0;  color: launcherBackground.leftbarColorAt(launcherBackground.wStart) }
      GradientStop { position: (0.2  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.2)  }
      GradientStop { position: (0.3  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.3)  }
      GradientStop { position: (0.4  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.4)  }
      GradientStop { position: (0.46 - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.46) }
      GradientStop { position: (0.6  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.6)  }
      GradientStop { position: (0.7  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.72) }
      GradientStop { position: (0.8  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.8)  }
      GradientStop { position: (0.9  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.9)  }
      GradientStop { position: 1.0;  color: launcherBackground.leftbarColorAt(launcherBackground.wEnd)  }
    }
    border.color: Colors.outline_variant
    border.width: 2

    opacity: launcherWindow.visible ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    transform: Translate {
      y: isShowing ? 0 : 550
      Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
    }
    Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    // ════════════════════════════════════════════════════
    //  CONTENT STACK
    // ════════════════════════════════════════════════════
    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 12
      spacing: currentMode === "apps" ? 8 : 0

      // ── MODE SELECTOR ──────────────────────────────────
      Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: currentMode === "select"

        // Keyboard handler for mode selection
        Keys.onPressed: (event) => {
          if (event.key === Qt.Key_Escape) {
            requestClose(); event.accepted = true
          } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Right || event.key === Qt.Key_Tab) {
            modeSelectIndex = modeSelectIndex === 0 ? 1 : 0
            event.accepted = true
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            currentMode = modeSelectIndex === 0 ? "apps" : "sessions"
            if (currentMode === "apps") {
              searchInput.forceActiveFocus()
            } else {
              sessionFocus.forceActiveFocus()
            }
            event.accepted = true
          }
        }
        focus: currentMode === "select"

        ColumnLayout {
          anchors.centerIn: parent
          spacing: 16

          // Header label
          Text {
            Layout.alignment: Qt.AlignHCenter
            text: "What are we doing today?"
            font.pixelSize: 13
            font.weight: Font.Medium
            color: Colors.text
          }

          // Two mode buttons
          RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 6

            Repeater {
              model: [
                { label: "Apps",     icon: "󰘚", desc: "Launch any app" },
                { label: "Sessions", icon: "󱡀", desc: "Start a workflow" }
              ]
              delegate: Rectangle {
                required property var modelData
                required property int index

                width:  170
                height: 70
                radius: 12 
                color: modeSelectIndex === index
                  ? Colors.mode_select_active_bg
                  : Qt.alpha(Colors.mode_select_inactive_bg, 0.8)
                border.color: modeSelectIndex === index ? Colors.mode_select_active_border : Colors.outline_variant
                border.width: 2

                Behavior on color  { ColorAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 120 } }

                ColumnLayout {
                  anchors.fill: parent
                  spacing: 0

                  Item { Layout.fillHeight: true }

                  Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: modelData.label
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    color: modeSelectIndex === index
                    ? Colors.mode_select_active_text
                    : Colors.mode_select_inactive_text
                  }

                  Item { Layout.fillHeight: true }
                }

                MouseArea {
                  anchors.fill: parent
                  onClicked: {
                    modeSelectIndex = index
                    currentMode = index === 0 ? "apps" : "sessions"
                    if (currentMode === "apps")     
                      searchInput.forceActiveFocus()
                    else                            
                      sessionFocus.forceActiveFocus()
                  }
                }
              }
            }
          }
        }
      }

      // ── APPS MODE (your original list, unchanged) ──────
      Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: 8
        visible: currentMode === "apps"
        color: Qt.alpha(Colors.launcher_list_bg, 0.8)

        ColumnLayout {
          anchors.fill: parent
          spacing: 0

          // Topbar
          Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            color: "transparent"

            RowLayout {
              anchors.fill: parent
              anchors.topMargin: -12
              anchors.leftMargin: 12
              anchors.rightMargin: 12
              anchors.bottomMargin: -12

              // Back button
              Text {
                text: "󰁍"
                font.pixelSize: 14
                color: Colors.launcher_back_icon

                MouseArea {
                  anchors.fill: parent
                  onClicked: { currentMode = "select" }
                }
              }

              Text { text: "  "; font.pixelSize: 1 }

              Text {
                text: filteredApps.length + " apps"
                font.pixelSize: 12
                color: Colors.launcher_count_text 
              }

              Item { Layout.fillWidth: true }

              Text {
                text: "↑↓ Navigate  •  Enter Launch  •  Esc Back"
                font.pixelSize: 11
                color: Colors.launcher_hint_text
              }
            }
          }

          ListView {
            id: appListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 2

            model: ScriptModel { values: filteredApps }

            highlight: Rectangle { color: "transparent"; radius: 6 }
            highlightMoveDuration: 100

            delegate: Rectangle {
              required property var modelData
              required property int index

              width:  appListView.width
              height: 48
              x: 8
              color: "transparent"
              radius: 6

              Rectangle {
                anchors.fill: parent
                color: appListView.currentIndex === index
                  ? Colors.launcher_item_active_bg
                  : "transparent"
                radius: 6
              }

              RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                spacing: 12

                Rectangle {
                  Layout.preferredWidth: 35
                  Layout.preferredHeight: 35
                  radius: 8
                  border.color: Colors.outline_variant
                  border.width: 1
                  color: Colors.launcher_icon_bg

                  Image {
                    anchors.centerIn: parent
                    width: 24; height: 24
                    source: {
                      if (!modelData.icon) return "image://icon/application-x-executable"
                      if (modelData.icon.startsWith("/")) return Qt.resolvedUrl(modelData.icon)
                      var path = Quickshell.iconPath(modelData.icon, true)
                      if (!path) return Qt.resolvedUrl(Quickshell.shellDir + "/assets/error.png")
                      return path
                    }
                    sourceSize: Qt.size(24, 24)
                    fillMode: Image.PreserveAspectFit
                    onStatusChanged: {
                      if (status === Image.Error) source = "image://icon/application-x-executable"
                    }
                  }
                }

                ColumnLayout {
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignVCenter
                  spacing: 2

                  Text {
                    text: modelData.name || ""
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: Colors.launcher_app_name
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                  }
                  Text {
                    text: modelData.description || modelData.genericName || ""
                    font.pixelSize: 10
                    color: Colors.launcher_app_desc 
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                  }
                }
              }
            }
          }
        }
      }

      // ── SESSIONS MODE ──────────────────────────────────
      Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: 8
        visible: currentMode === "sessions"
        color: Qt.alpha(Colors.session_list_bg, 0.8)

        // Invisible item to capture keyboard in sessions mode
        Item {
          id: sessionFocus
          anchors.fill: parent
          focus: currentMode === "sessions"

          Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) {
              currentMode = "select"; event.accepted = true
            } else if (event.key === Qt.Key_Down) {
              if (sessionIndex < sessionsList.length - 1) sessionIndex++
              sessionListView.positionViewAtIndex(sessionIndex, ListView.Contain)
              event.accepted = true
            } else if (event.key === Qt.Key_Up) {
              if (sessionIndex > 0) sessionIndex--
              sessionListView.positionViewAtIndex(sessionIndex, ListView.Contain)
              event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              if (sessionsList.length > 0)
                launcherWindow.launchSession(sessionsList[sessionIndex])
              event.accepted = true
            }
          }
        }

        ColumnLayout {
          anchors.fill: parent
          spacing: 0

          // Topbar
          Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            color: "transparent"

            RowLayout {
              anchors.fill: parent
              anchors.topMargin: -12
              anchors.leftMargin: 12
              anchors.rightMargin: 12
              anchors.bottomMargin: -12

              Text {
                text: "󰁍"
                font.pixelSize: 14
                color: Colors.session_back_icon
                MouseArea {
                  anchors.fill: parent
                  onClicked: { currentMode = "select" }
                }
              }
              Text { text: "  "; font.pixelSize: 1 }

              Text {
                text: sessionsList.length + " sessions"
                font.pixelSize: 12
                color: Colors.session_count_text
              }

              Item { Layout.fillWidth: true }

              Text {
                text: "↑↓ Navigate  •  Enter Launch  •  Esc Back"
                font.pixelSize: 11
                color: Colors.session_hint_text 
              }
            }
          }

          // Session list
          ListView {
            id: sessionListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            currentIndex: sessionIndex

            model: ScriptModel { values: sessionsList }

            highlight: Rectangle { color: "transparent"; radius: 8 }
            highlightMoveDuration: 100

            delegate: Rectangle {
              required property var modelData
              required property int index

              width:  sessionListView.width
              height: 52
              radius: 8
              color: "transparent"

              Rectangle {
                anchors.fill: parent
                radius: 8
                color: sessionIndex === index
                  ? Colors.session_item_active_bg : "transparent"
              }

              RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 10

                // Session icon badge
                Rectangle {
                  Layout.preferredWidth: 32
                  Layout.preferredHeight: 32
                  Layout.alignment: Qt.AlignVCenter
                  radius: 10
                  color: sessionIndex === index
                    ? Qt.alpha(Colors.session_icon_active_bg, 0.3)
                    : Colors.session_icon_inactive_bg
                  border.color: sessionIndex === index ? Colors.outline : Colors.outline_variant
                  border.width: 1
                  Behavior on color { ColorAnimation { duration: 100 } }

                  Text {
                    anchors.centerIn: parent
                    text: modelData.icon || "󰘚"
                    font.pixelSize: 20
                    color: sessionIndex === index ? Colors.session_icon_active : Colors.session_icon_inactive
                  }
                }

                // Text info
                ColumnLayout {
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignVCenter
                  spacing: 4

                  Text {
                    text: modelData.name || ""
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: Colors.session_app_name
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                  }
                  // App chips row
                  Row {
                    spacing: 4
                    Repeater {
                      model: modelData.apps ? modelData.apps.slice(0, 4) : []
                      delegate: Rectangle {
                        required property var modelData
                        height: 14
                        width: appChipLabel.implicitWidth + 8
                        radius: 4
                        color: Qt.alpha(Colors.session_chip_bg, 0.9)
                        Text {
                          id: appChipLabel
                          anchors.centerIn: parent
                          text: modelData.exec ? modelData.exec.split(" ")[0] : ""
                          font.pixelSize: 9
                          color: Colors.session_chip_text
                        }
                      }
                    }
                  }
                }

                // Workspace badge
                Rectangle {
                  Layout.preferredWidth: 63
                  Layout.preferredHeight: 28
                  Layout.alignment: Qt.AlignVCenter
                  radius: 6
                  color: sessionIndex === index
                    ? Qt.alpha(Colors.session_workspace_active, 0.3) : "transparent"

                  Text {
                    anchors.centerIn: parent
                    text: "Workspace " + launcherWindow.currentWorkspace
                    font.pixelSize: 9
                    font.weight: Font.Medium
                    color: sessionIndex === index
                    ? Colors.session_workspace_text_active
                    : Colors.session_workspace_text_inactive
                  }
                }
              }

              MouseArea {
                anchors.fill: parent
                onClicked: {
                  sessionIndex = index
                  sessionFocus.forceActiveFocus()
                }
                onDoubleClicked: {
                  launcherWindow.launchSession(sessionsList[index])
                }
              }
            }
          }
        }
      }

      // ── SEARCH BAR (apps mode only) ────────────────────
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 36
        radius: 16
        visible: currentMode === "apps"
        color: Qt.alpha(Colors.search_bg, 0.8)
        border.color: searchInput.activeFocus ? Colors.search_border : Colors.search_border_inactive
        border.width: 2

        Behavior on border.color { ColorAnimation { duration: 150 } }

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: 12
          spacing: 12

          Text {
            text: "󰍉"
            font.pixelSize: 20
            color: Colors.search_icon
          }

          TextInput {
            id: searchInput
            Layout.fillWidth: true
            font.pixelSize: 15
            color: Colors.search_text
            selectionColor: Colors.search_selection
            selectedTextColor: Colors.search_selected_text

            onTextChanged: updateFilteredApps()

            Keys.onPressed: (event) => {
              if (event.key === Qt.Key_Escape) {
                if (text !== "") {
                  text = ""           // first Esc clears search
                } else {
                  currentMode = "select"  // second Esc goes back to mode select
                }
                event.accepted = true
              } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (filteredApps.length > 0)
                  launcherWindow.launchApp(filteredApps[appListView.currentIndex])
                event.accepted = true
              } else if (event.key === Qt.Key_Down) {
                if (appListView.currentIndex < filteredApps.length - 1) {
                  appListView.currentIndex++
                  appListView.positionViewAtIndex(appListView.currentIndex, ListView.Contain)
                }
                event.accepted = true
              } else if (event.key === Qt.Key_Up) {
                if (appListView.currentIndex > 0) {
                  appListView.currentIndex--
                  appListView.positionViewAtIndex(appListView.currentIndex, ListView.Contain)
                }
                event.accepted = true
              }
            }

            Text {
              visible: parent.text === ""
              text: "Type to search applications..."
              color: Colors.search_placeholder
              font.pixelSize: parent.font.pixelSize
            }
          }
        }
      }
    }

    // ── Decorative strips & corners ──
    Rectangle {
      Layout.leftMargin: -12
      z: 1
      width: 12
      height: parent.height
      gradient: Gradient {
        orientation: Gradient.Vertical
        GradientStop { position: 0.0;  color: launcherBackground.leftbarColorAt(launcherBackground.wStart) }
        GradientStop { position: (0.2  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.2)  }
        GradientStop { position: (0.3  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.3)  }
        GradientStop { position: (0.4  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.4)  }
        GradientStop { position: (0.46 - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.46) }
        GradientStop { position: (0.6  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.6)  }
        GradientStop { position: (0.7  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.72) }
        GradientStop { position: (0.8  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.8)  }
        GradientStop { position: (0.9  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.9)  }
        GradientStop { position: 1.0;  color: launcherBackground.leftbarColorAt(launcherBackground.wEnd)  }
      }
    }

    Rectangle {
      anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
      z: 1
      width: parent.width
      height: 12
      gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0.01; color: Colors.bottombar_gradient1 }
        GradientStop { position: 0.1;  color: Colors.bottombar_gradient1 }
        GradientStop { position: 0.60; color: Colors.bottombar_gradient2 }
        GradientStop { position: 1.0;  color: Colors.bottombar_gradient3 }
      }
    }

    Connections {
      target: launcherBackground
      function onWStartChanged() { lefttopLauncher.requestPaint() }
    }

    Canvas {
      id: lefttopLauncher
      width: 14; height: 14
      anchors { bottom: parent.top; left: parent.left }
      anchors.bottomMargin: -2
      transform: Scale { origin.x: 7; origin.y: 7; yScale: -1 }
      z: 1
      onPaint: {
        var ctx = getContext("2d"); ctx.reset()
        ctx.fillStyle = launcherBackground.leftbarColorAt(launcherBackground.wStart).toString()
        ctx.lineWidth = 2
        ctx.beginPath()
        ctx.moveTo(14, 0); ctx.lineTo(14, 2)
        ctx.arc(14, 14, 12, Math.PI / 2, Math.PI, true)
        ctx.lineTo(2, 14); ctx.lineTo(0, 14); ctx.lineTo(0, 0)
        ctx.closePath(); ctx.fill()
      }
    }

    Canvas {
      id: lefttopLauncher1
      width: 14; height: 14
      anchors { bottom: parent.top; left: parent.left }
      anchors.bottomMargin: -2
      transform: Scale { origin.x: 7; origin.y: 7; yScale: -1 }
      z: 1
      onPaint: {
        var ctx = getContext("2d"); ctx.reset()
        ctx.fillStyle = Colors.outline_variant
        ctx.beginPath()
        ctx.moveTo(14, 0); ctx.lineTo(14, 2)
        ctx.arc(14, 14, 12, Math.PI / 2, Math.PI, true)
        ctx.lineTo(2, 14); ctx.lineTo(0, 14)
        ctx.arc(14, 14, 14, Math.PI, Math.PI / 2, false)
        ctx.closePath(); ctx.fill()
      }
    }

    Canvas {
      id: rightbottomLauncher
      width: 14; height: 14
      anchors { bottom: parent.bottom; right: parent.right }
      anchors.rightMargin: -12
      transform: Scale { origin.x: 7; origin.y: 7; yScale: -1 }
      z: 1
      onPaint: {
        var ctx = getContext("2d"); ctx.reset()
        ctx.fillStyle = Colors.bottombar_gradient3
        ctx.lineWidth = 2
        ctx.beginPath()
        ctx.moveTo(14, 0); ctx.lineTo(14, 2)
        ctx.arc(14, 14, 12, Math.PI / 2, Math.PI, true)
        ctx.lineTo(2, 14); ctx.lineTo(0, 14); ctx.lineTo(0, 0)
        ctx.closePath(); ctx.fill()
      }
    }

    Canvas {
      id: rightbottomLauncher1
      width: 14; height: 14
      anchors { bottom: parent.bottom; right: parent.right }
      anchors.rightMargin: -12
      transform: Scale { origin.x: 7; origin.y: 7; yScale: -1 }
      z: 1
      onPaint: {
        var ctx = getContext("2d"); ctx.reset()
        ctx.fillStyle = Colors.outline_variant
        ctx.beginPath()
        ctx.moveTo(14, 0); ctx.lineTo(14, 2)
        ctx.arc(14, 14, 12, Math.PI / 2, Math.PI, true)
        ctx.lineTo(2, 14); ctx.lineTo(0, 14)
        ctx.arc(14, 14, 14, Math.PI, Math.PI / 2, false)
        ctx.closePath(); ctx.fill()
      }
    }
  }
}

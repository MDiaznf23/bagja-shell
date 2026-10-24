import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import QtQuick.Controls
import ".."
import "../services"
import "../components"

FloatingWindow {
  id: root

  implicitWidth: 600
  implicitHeight: 500
  minimumSize: Qt.size(420, 360)

  property bool isShowing: false
  property string activeTab: "Appearance"

  color: "transparent"

  signal requestClose()

  onVisibleChanged: {
    if (visible) {
      isShowing = false
      showTimer.start()
    } else {
      isShowing = false
    }
  }

  Timer {
    id: showTimer
    interval: 16
    onTriggered: root.isShowing = true
  }

  Rectangle {
    id: panel
    Keys.onEscapePressed: root.requestClose()
    anchors.fill: parent
    gradient: Gradient {
      orientation: Gradient.Horizontal
      GradientStop { position: 0.1; color: Colors.background }
      GradientStop { position: 0.99; color: Colors.background_variant1 }
    }
    radius: 16
    border.color: Colors.outline_variant
    border.width: 2
    opacity: root.isShowing ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

    RowLayout {
      anchors.fill: parent
      spacing: 0

      // SIDEBAR
      Rectangle {
        Layout.preferredWidth: 160
        Layout.fillHeight: true
        color: Colors.settings_sidebar_bg
        radius: 16
        border.width: 2 
        border.color: Colors.outline_variant

        Rectangle {
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          anchors.right: parent.right
          width: 16
          color: parent.color 
        }

        Rectangle {
          anchors.top: parent.top
          anchors.right: parent.right
          height: 2
          width: 16
          color: Colors.outline_variant
        }

        Rectangle {
          anchors.bottom: parent.bottom
          anchors.right: parent.right
          height: 2
          width: 16
          color: Colors.outline_variant
        }

        ColumnLayout {
          anchors.fill: parent
          spacing: 0

          // Header sidebar
          Rectangle {
            Layout.fillWidth: true
            height: 48
            color: "transparent"
            Text {
              anchors.left: parent.left
              anchors.leftMargin: 16
              anchors.verticalCenter: parent.verticalCenter
              text: "Settings"
              color: Colors.text_variant1
              font.pixelSize: 13
              font.bold: true
            }
          }

          // Divider sidebar
          Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            height: 1
            color: Colors.outline_variant
          }

          // Tab buttons
          ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 10
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            spacing: 4

            Repeater {
              model: [
                { label: "Appearance", icon: "palette" },
                { label: "Behavior",   icon: "settings" },
                { label: "Themes",     icon: "paintbrush" },
                { label: "About",      icon: "info" }
              ]

              delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                height: 36
                radius: 8
                color: root.activeTab === modelData.label
                  ? Colors.settings_tab_active_bg
                  : tabHover.containsMouse
                    ? Qt.alpha(Colors.settings_tab_hovered_bg, 0.5)
                    : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }

                RowLayout {
                  anchors.fill: parent
                  anchors.leftMargin: 10
                  anchors.rightMargin: 10
                  spacing: 8

                  SvgIcon {
                    source: Icons.url(modelData.icon)
                    size: 16
                    color: root.activeTab === modelData.label
                      ? Colors.settings_tab_active_text : Colors.settings_tab_inactive_text
                    Layout.alignment: Qt.AlignVCenter
                  }

                  Text {
                    text: modelData.label
                    font.pixelSize: 12
                    font.bold: root.activeTab === modelData.label
                    color: root.activeTab === modelData.label
                      ? Colors.settings_tab_active_text : Colors.settings_tab_inactive_text
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                  }
                }

                MouseArea {
                  id: tabHover
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.activeTab = modelData.label
                }
              }
            }
          }

          Item { Layout.fillHeight: true }
        }
      }

      // Content
      ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 0

        // Header Content
        Rectangle {
          Layout.fillWidth: true
          height: 48
          color: "transparent"

          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 16

            Text {
              text: root.activeTab
              color: Colors.text_variant1
              font.pixelSize: 13
              font.bold: true
              Layout.fillWidth: true
              Layout.alignment: Qt.AlignVCenter
            }

            Rectangle {
              width: 20; height: 20
              color: closeHover.containsMouse
                ? Colors.close_btn_hovered
                : "transparent"
              radius: 4
              Layout.alignment: Qt.AlignVCenter

              SvgIcon {
                anchors.centerIn: parent
                source: Icons.url("x")
                size: 14
                color: Colors.close_btn_icon
              }

              MouseArea {
                id: closeHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.requestClose()
              }
            }
          }
        }

        // Divider 
        Rectangle {
          Layout.fillWidth: true
          Layout.leftMargin: 20
          Layout.rightMargin: 16
          height: 1
          color: Colors.divider
        }

        // Appearance
        ColumnLayout {
          visible: root.activeTab === "Appearance"
          Layout.fillWidth: true
          Layout.fillHeight: true
          Layout.topMargin: 10
          Layout.rightMargin: 16
          Layout.leftMargin: 20
          spacing: 10

          RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
              spacing: 2
              Layout.fillWidth: true
              Text { text: "Color Engine"; color: Colors.text; font.pixelSize: 12; font.bold: true }
              Text { text: "Wallpaper color extraction engine"; color: Colors.text_variant1; font.pixelSize: 10 }
            }

            Item { Layout.fillWidth: true }

            Rectangle {
              id: engineDropdown
              width: 100; height: 24
              radius: 6
              color: dropdownHover.containsMouse ? Colors.variant_inactive_bg : Colors.variant_inactive_bg
              border.color: Colors.outline_variant
              border.width: 1

              RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 6
                spacing: 4

                Text {
                  text: StateGlobals.colorEngine
                  color: Colors.text
                  font.pixelSize: 10
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignVCenter
                }

                SvgIcon {
                  source: Icons.url("chevron-down")
                  size: 12
                  color: Colors.text_variant1
                  rotation: enginePopup.visible ? 180 : 0
                  Behavior on rotation { NumberAnimation { duration: 150 } }
                  Layout.alignment: Qt.AlignVCenter
                }
              }

              MouseArea {
                id: dropdownHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: enginePopup.visible ? enginePopup.close() : enginePopup.open()
              }

              Popup {
                id: enginePopup
                y: parent.height + 4
                width: parent.width
                padding: 4
                background: Rectangle {
                  radius: 6
                  color: Colors.settings_sidebar_bg
                  border.color: Colors.outline_variant
                  border.width: 1
                }

                ColumnLayout {
                  width: parent.width
                  spacing: 2

                  Repeater {
                    model: ["warnaza", "m3wal"]
                    delegate: Rectangle {
                      required property string modelData
                      Layout.fillWidth: true
                      height: 24
                      radius: 4
                      color: itemHover.containsMouse
                        ? Colors.variant_inactive_bg
                        : StateGlobals.colorEngine === modelData
                          ? Colors.variant_active_bg : "transparent"
                      Behavior on color { ColorAnimation { duration: 100 } }

                      Text {
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: 10
                        font.bold: StateGlobals.colorEngine === modelData
                        color: StateGlobals.colorEngine === modelData
                          ? Colors.variant_active_text : Colors.text
                      }

                      MouseArea {
                        id: itemHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                          StateGlobals.colorEngine = modelData
                          applyEngineProcess.running = false
                          applyEngineProcess.command = ["bash", Quickshell.shellDir + "/scripts/set_engine.sh", modelData]
                          applyEngineProcess.running = true
                          enginePopup.close()
                        }
                      }
                    }
                  }
                }
              }
            }
          }

          Rectangle { Layout.fillWidth: true; height: 1; color: Colors.outline_variant }

          RowLayout {
            Layout.fillWidth: true
            visible: StateGlobals.colorEngine === "m3wal"
            Layout.preferredHeight: StateGlobals.colorEngine === "m3wal" ? implicitHeight : 0

            ColumnLayout {
              spacing: 2 
              Layout.fillWidth: true

              // read variants
              Component.onCompleted: {
                readVariantProcess.running = true
              }

              Process {
                id: readVariantProcess
                command: ["bash", "-c", "grep '^variant = ' " + Quickshell.env("HOME") + "/.config/m3-colors/m3-colors.conf | awk '{print toupper($3)}'"]
                running: false
                stdout: SplitParser {
                  onRead: (data) => { variantGrid.currentVariant = data.trim() }
                }
              }

              Text {
                text: "Color Variant"
                color: Colors.text
                font.pixelSize: 12
                font.bold: true
              }
              Text {
                text: "Material You color scheme variant"
                color: Colors.text_variant1
                font.pixelSize: 10
              }
            }
          }

          // Grid variant
          GridLayout {
            id: variantGrid
            visible: StateGlobals.colorEngine === "m3wal"
            Layout.preferredHeight: StateGlobals.colorEngine === "m3wal" ? implicitHeight : 0
            Layout.fillWidth: true
            columns: 4
            columnSpacing: 6
            rowSpacing: 6

            property string currentVariant: "CONTENT"

            Repeater {
              model: ["AUTO", "CONTENT", "VIBRANT", "EXPRESSIVE", "NEUTRAL", "TONALSPOT", "FIDELITY", "MONOCHROME"]

              delegate: Rectangle {
                required property string modelData
                Layout.fillWidth: true
                height: 28
                radius: 6
                color: variantGrid.currentVariant === modelData
                  ? Colors.variant_active_bg : Colors.variant_inactive_bg
                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                  anchors.centerIn: parent
                  text: modelData
                  font.pixelSize: 9
                  font.bold: variantGrid.currentVariant === modelData
                  color: variantGrid.currentVariant === modelData
                    ? Colors.variant_active_text : Colors.variant_inactive_text
                }

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    variantGrid.currentVariant = modelData
                    variantProcess.command = ["bash", Quickshell.shellDir + "/scripts/set_variant.sh", modelData]
                    variantProcess.running = true
                  }
                }
              }
            }
          }

          Process { id: variantProcess; running: false }

          Process { id: applyEngineProcess; running: false } 

          Item { Layout.fillHeight: true }
        }

        // Behavior
        ColumnLayout {
          visible: root.activeTab === "Behavior"
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: 0

          Process { id: modeProcess; running: false }
          Process { id: brightnessProcess; running: false }
          Process { id: binSizeProcess; running: false }
          Process { id: deltaMinProcess; running: false }

          Process {
            id: readBehaviorProcess
            running: false
            stdout: SplitParser {
              onRead: data => {
                var parts = data.trim().split("=")
                if (parts.length < 2) return
                var key = parts[0].trim()
                var val = parts[1].trim()
                if (key === "mode") modeRow.currentMode = val
                if (key === "brightness_threshold") brightnessSlider.value = parseInt(val)
                if (key === "bin_size") binSizeSlider.value = parseInt(val)
                if (key === "delta_min") deltaMinSlider.value = parseFloat(val)
              }
            }
          }

          Component.onCompleted: {
            readBehaviorProcess.command = ["bash", "-c",
              "grep -E '^(mode|brightness_threshold|bin_size|delta_min) = ' " + StateGlobals.configPath]
            readBehaviorProcess.running = true
          }

          Connections {
            target: StateGlobals
            function onConfigPathChanged() {
              readBehaviorProcess.running = false
              readBehaviorProcess.command = ["bash", "-c",
                "grep -E '^(mode|brightness_threshold|bin_size|delta_min) = ' " + StateGlobals.configPath]
              readBehaviorProcess.running = true
            }
          }

          ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true

            ScrollBar.vertical: ScrollBar {
              visible: size < 1.0
              anchors.right: parent.right  // paksa ke kanan
              anchors.rightMargin: 16
              anchors.top: parent.top
              anchors.bottom: parent.bottom
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

            ColumnLayout {
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.leftMargin: 20
              anchors.rightMargin: 16
              spacing: 16

              Item { height: 4 }

              // Mode
              RowLayout {
                id: modeRow
                Layout.fillWidth: true
                property string currentMode: "auto"

                ColumnLayout {
                  spacing: 2
                  Layout.fillWidth: true
                  Text { text: "Mode"; color: Colors.text; font.pixelSize: 12; font.bold: true }
                  Text { text: "Color scheme mode"; color: Colors.text_variant1; font.pixelSize: 10 }
                }

                Item { Layout.fillWidth: true }

                RowLayout {
                  spacing: 4
                  Repeater {
                    model: ["light", "dark", "auto"]
                    delegate: Rectangle {
                      required property string modelData
                      width: 40; height: 24
                      radius: 6
                      color: modeRow.currentMode === modelData
                        ? Colors.mode_selector_active_bg : Colors.mode_selector_inactive_bg
                      Behavior on color { ColorAnimation { duration: 120 } }

                      Text {
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: 9
                        font.bold: modeRow.currentMode === modelData
                        color: modeRow.currentMode === modelData
                          ? Colors.mode_selector_active_text : Colors.mode_selector_inactive_text
                      }

                      MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                          modeRow.currentMode = modelData
                          modeProcess.command = ["bash", "-c",
                            "sed -i 's/^mode = .*/mode = " + modelData + "/' " + StateGlobals.configPath]
                          modeProcess.running = true
                        }
                      }
                    }
                  }
                }
              }

              Rectangle { Layout.fillWidth: true; height: 1; color: Colors.outline_variant }

              // Brightness Threshold
              RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                  spacing: 2
                  Layout.fillWidth: true
                  Text { text: "Brightness Threshold"; color: Colors.text; font.pixelSize: 12; font.bold: true }
                  Text { text: "Threshold for light/dark detection"; color: Colors.text_variant1; font.pixelSize: 10 }
                }

                Item { Layout.fillWidth: true }

                Text {
                  text: brightnessSlider.value.toString()
                  color: Colors.text
                  font.pixelSize: 11
                  Layout.alignment: Qt.AlignVCenter
                }
              }

              Slider {
                id: brightnessSlider
                Layout.fillWidth: true
                from: 0; to: 255; stepSize: 1
                value: 120
                onPressedChanged: {
                  if (!pressed) {
                    brightnessProcess.command = ["bash", "-c",
                      "sed -i 's/^brightness_threshold = .*/brightness_threshold = " + Math.round(value) + "/' " + StateGlobals.configPath]
                    brightnessProcess.running = true
                  }
                }
              }

              Rectangle { Layout.fillWidth: true; height: 1; color: Colors.outline_variant }

              // Warnaza only — Bin Size
              RowLayout {
                Layout.fillWidth: true
                visible: StateGlobals.colorEngine === "warnaza"
                Layout.preferredHeight: StateGlobals.colorEngine === "warnaza" ? implicitHeight : 0

                ColumnLayout {
                  spacing: 2
                  Layout.fillWidth: true
                  Text { text: "Bin Size"; color: Colors.text; font.pixelSize: 12; font.bold: true }
                  Text { text: "Color quantization bin size"; color: Colors.text_variant1; font.pixelSize: 10 }
                }

                Item { Layout.fillWidth: true }

                Text {
                  text: binSizeSlider.value.toString()
                  color: Colors.text
                  font.pixelSize: 11
                  Layout.alignment: Qt.AlignVCenter
                }
              }

              Slider {
                id: binSizeSlider
                Layout.fillWidth: true
                visible: StateGlobals.colorEngine === "warnaza"
                Layout.preferredHeight: StateGlobals.colorEngine === "warnaza" ? implicitHeight : 0
                from: 1; to: 16; stepSize: 1
                value: 4
                onPressedChanged: {
                  if (!pressed) {
                    binSizeProcess.command = ["bash", "-c",
                      "sed -i 's/^bin_size = .*/bin_size = " + Math.round(value) + "/' " + StateGlobals.configPath]
                    binSizeProcess.running = true
                  }
                }
              }

              Rectangle { Layout.fillWidth: true; height: 1; color: Colors.outline_variant; visible: StateGlobals.colorEngine === "warnaza" }

              // Warnaza only — Delta Min
              RowLayout {
                Layout.fillWidth: true
                visible: StateGlobals.colorEngine === "warnaza"
                Layout.preferredHeight: StateGlobals.colorEngine === "warnaza" ? implicitHeight : 0

                ColumnLayout {
                  spacing: 2
                  Layout.fillWidth: true
                  Text { text: "Delta Min"; color: Colors.text; font.pixelSize: 12; font.bold: true }
                  Text { text: "Minimum color distance"; color: Colors.text_variant1; font.pixelSize: 10 }
                }

                Item { Layout.fillWidth: true }

                Text {
                  text: deltaMinSlider.value.toFixed(1)
                  color: Colors.text
                  font.pixelSize: 11
                  Layout.alignment: Qt.AlignVCenter
                }
              }

              Slider {
                id: deltaMinSlider
                Layout.fillWidth: true
                visible: StateGlobals.colorEngine === "warnaza"
                Layout.preferredHeight: StateGlobals.colorEngine === "warnaza" ? implicitHeight : 0
                from: 0; to: 20; stepSize: 0.5
                value: 5.0
                onPressedChanged: {
                  if (!pressed) {
                    deltaMinProcess.command = ["bash", "-c",
                      "sed -i 's/^delta_min = .*/delta_min = " + value.toFixed(1) + "/' " + StateGlobals.configPath]
                    deltaMinProcess.running = true
                  }
                }
              }

              Rectangle {
                Layout.fillWidth: true; height: 1; color: Colors.outline_variant
                visible: StateGlobals.colorEngine === "warnaza"
              }

              Item { height: 4 }
            }
          }
        }

        // Themes
        ColumnLayout {
          id: themesTab
          visible: root.activeTab === "Themes"
          Layout.fillWidth: true
          Layout.fillHeight: true
          Layout.topMargin: 10
          Layout.rightMargin: 16
          Layout.leftMargin: 20
          spacing: 10

          property string fetchStatusText: "Memuat catalog…"
          property string currentThemeName: ""
          property var pendingChecks: []
          readonly property string scriptsDir: Quickshell.shellDir + "/scripts"
          readonly property string catalogCacheFile: Quickshell.env("HOME") + "/.cache/quickshell/themes-catalog.json"
          readonly property string currentThemeFile: Quickshell.env("HOME") + "/.cache/quickshell/current-theme"

          function refreshCatalog() {
            fetchStatusText = "Mengambil catalog…"
            fetchCatalogProcess.running = false
            fetchCatalogProcess.running = true
          }

          function checkAllStatuses() {
            var arr = []
            for (var i = 0; i < themesModel.count; i++) arr.push(i)
            pendingChecks = arr
            runNextStatusCheck()
          }

          function runNextStatusCheck() {
            if (pendingChecks.length === 0 || statusCheckProcess.running) return
            var idx = pendingChecks.shift()
            var item = themesModel.get(idx)
            statusCheckProcess.targetIndex = idx
            statusCheckProcess.command = ["bash", scriptsDir + "/theme_status.sh", item.name, item.repo, item.branch]
            statusCheckProcess.running = true
          }

          function installTheme(index) {
            var item = themesModel.get(index)
            themesModel.setProperty(index, "status", "installing")
            installProcess.targetIndex = index
            installProcess.command = ["bash", scriptsDir + "/theme_install.sh", item.name, item.repo, item.branch]
            installProcess.running = true
          }

          function switchTheme(name) {
            switchProcess.command = ["bash", scriptsDir + "/theme_switch.sh", name]
            switchProcess.running = true
          }

          onVisibleChanged: {
            if (visible) {
              currentThemeReadProcess.running = true
              refreshCatalog()
            }
          }

          ListModel { id: themesModel }

          Process {
            id: currentThemeReadProcess
            running: false
            command: ["bash", "-c", "cat '" + themesTab.currentThemeFile + "' 2>/dev/null"]
            stdout: StdioCollector {
              onStreamFinished: themesTab.currentThemeName = this.text.trim()
            }
          }

          Process {
            id: fetchCatalogProcess
            running: false
            command: ["bash", themesTab.scriptsDir + "/theme_fetch_catalog.sh"]
            stdout: StdioCollector {
              onStreamFinished: {
                var result = this.text.trim()
                if (result === "OK") {
                  themesTab.fetchStatusText = "Catalog terbaru"
                  catalogFile.reload()
                } else if (result === "STALE") {
                  themesTab.fetchStatusText = "Gagal update, pakai cache lama"
                  catalogFile.reload()
                } else {
                  themesTab.fetchStatusText = "Gagal ambil catalog & belum ada cache"
                }
              }
            }
          }

          Process {
            id: statusCheckProcess
            property int targetIndex: -1
            running: false
            stdout: StdioCollector {
              onStreamFinished: {
                if (statusCheckProcess.targetIndex >= 0) {
                  themesModel.setProperty(statusCheckProcess.targetIndex, "status", this.text.trim())
                }
              }
            }
            onExited: themesTab.runNextStatusCheck()
          }

          Process {
            id: installProcess
            property int targetIndex: -1
            running: false
            stdout: StdioCollector {
              onStreamFinished: {
                var result = this.text.trim()
                themesModel.setProperty(installProcess.targetIndex, "status",
                  result === "DONE" ? "installed" : "error")
              }
            }
          }

          Process {
            id: switchProcess
            running: false
            stdout: StdioCollector {
              onStreamFinished: {
                if (this.text.trim() === "SWITCHED") currentThemeReadProcess.running = true
              }
            }
          }

          FileView {
            id: catalogFile
            path: themesTab.catalogCacheFile
            printErrors: false
            onLoaded: {
              try {
                var data = JSON.parse(text())
                themesModel.clear()
                for (var i = 0; i < data.length; i++) {
                  var t = data[i]
                  themesModel.append({
                    name: t.name || "",
                    display_name: t.display_name || t.name || "",
                    description: t.description || "",
                    repo: t.repo || "",
                    branch: t.branch || "main",
                    preview: t.preview || "",
                    status: "checking"
                  })
                }
                themesTab.checkAllStatuses()
              } catch (e) {
                themesTab.fetchStatusText = "Format catalog.json tidak valid"
              }
            }
          }

          // Header
          RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
              spacing: 2
              Layout.fillWidth: true
              Text { text: "Ricing Catalog"; color: Colors.text; font.pixelSize: 12; font.bold: true }
              Text { text: themesTab.fetchStatusText; color: Colors.text_variant1; font.pixelSize: 10 }
            }
            Item { Layout.fillWidth: true }
            Rectangle {
              width: 70; height: 24; radius: 6
              color: refreshHover.containsMouse ? Colors.variant_inactive_bg : "transparent"
              border.color: Colors.outline_variant
              border.width: 1
              Text { anchors.centerIn: parent; text: "Refresh"; font.pixelSize: 10; color: Colors.text }
              MouseArea {
                id: refreshHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: themesTab.refreshCatalog()
              }
            }
          }

          Rectangle { Layout.fillWidth: true; height: 1; color: Colors.outline_variant }

          ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true

            ColumnLayout {
              width: parent.width
              spacing: 8

              Repeater {
                model: themesModel
                delegate: Rectangle {
                  id: themeCard
                  required property string name
                  required property string display_name
                  required property string description
                  required property string preview
                  required property string status
                  required property int index

                  Layout.fillWidth: true
                  Layout.preferredHeight: 84
                  radius: 10
                  color: themesTab.currentThemeName === name ? Colors.settings_tab_active_bg : Colors.settings_sidebar_bg
                  border.color: Colors.outline_variant
                  border.width: 1

                  RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    Rectangle {
                      width: 64; height: 64
                      radius: 8
                      color: Colors.variant_inactive_bg
                      clip: true
                      Image {
                        anchors.fill: parent
                        source: themeCard.preview
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                      }
                    }

                    ColumnLayout {
                      Layout.fillWidth: true
                      spacing: 2

                      RowLayout {
                        spacing: 6
                        Text { text: themeCard.display_name; color: Colors.text; font.pixelSize: 12; font.bold: true }
                        Text {
                          visible: themesTab.currentThemeName === themeCard.name
                          text: "• Active"
                          color: Colors.settings_tab_active_text
                          font.pixelSize: 9
                        }
                      }
                      Text {
                        text: themeCard.description
                        color: Colors.text_variant1
                        font.pixelSize: 10
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        maximumLineCount: 2
                        elide: Text.ElideRight
                      }
                      Text {
                        text: themeCard.status === "not_installed" ? "Belum diinstall"
                          : themeCard.status === "installed" ? "Terinstall"
                          : themeCard.status === "update_available" ? "Ada update"
                          : themeCard.status === "installing" ? "Menginstall…"
                          : themeCard.status === "checking" ? "Mengecek…"
                          : "Gagal, coba refresh"
                        color: themeCard.status === "update_available" ? Colors.mode_selector_active_text : Colors.text_variant1
                        font.pixelSize: 9
                      }
                    }

                    ColumnLayout {
                      spacing: 4
                      Layout.alignment: Qt.AlignVCenter

                      Rectangle {
                        width: 90; height: 24
                        radius: 6
                        visible: themeCard.status === "not_installed" || themeCard.status === "update_available" || themeCard.status === "error"
                        color: installHover.containsMouse ? Colors.variant_active_bg : Colors.variant_inactive_bg
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Text {
                          anchors.centerIn: parent
                          text: themeCard.status === "update_available" ? "Update" : "Install"
                          font.pixelSize: 10
                          color: Colors.text
                        }
                        MouseArea {
                          id: installHover
                          anchors.fill: parent
                          hoverEnabled: true
                          cursorShape: Qt.PointingHandCursor
                          onClicked: themesTab.installTheme(themeCard.index)
                        }
                      }

                      Rectangle {
                        width: 90; height: 24
                        radius: 6
                        visible: themeCard.status === "installed" || themeCard.status === "update_available"
                        color: themesTab.currentThemeName === themeCard.name
                          ? Colors.variant_active_bg
                          : (switchHover.containsMouse ? Colors.variant_active_bg : Colors.variant_inactive_bg)
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Text {
                          anchors.centerIn: parent
                          text: themesTab.currentThemeName === themeCard.name ? "Aktif" : "Switch"
                          font.pixelSize: 10
                          color: Colors.text
                        }
                        MouseArea {
                          id: switchHover
                          anchors.fill: parent
                          hoverEnabled: themesTab.currentThemeName !== themeCard.name
                          cursorShape: Qt.PointingHandCursor
                          onClicked: if (themesTab.currentThemeName !== themeCard.name) themesTab.switchTheme(themeCard.name)
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }

        // About 
        ColumnLayout {
          visible: root.activeTab === "About"
          Layout.fillWidth: true
          Layout.fillHeight: true
          Layout.topMargin: 10
          Layout.rightMargin: 16
          Layout.leftMargin: 20
          spacing: 10

          ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 4

            Text {
              text: "Bagja Shell"
              color: Colors.text
              font.pixelSize: 16
              font.bold: true
              Layout.alignment: Qt.AlignHCenter
            }

            Text {
              text: "One shell, every workflow"
              color: Colors.text_variant1
              font.pixelSize: 11
              Layout.alignment: Qt.AlignHCenter
            }
          }

          Rectangle { Layout.fillWidth: true; height: 1; color: Colors.outline_variant }

          ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
              text: "Description"
              color: Colors.text_variant1
              font.pixelSize: 11
              font.bold: true
              Layout.fillWidth: true
            }

            Text {
              text: `The philosophy behind this is simple. "Bagja" means happy in my language so the user can be happy about their desktop.`
              color: Colors.text_variant1
              font.pixelSize: 11
              Layout.fillWidth: true
              wrapMode: Text.WordWrap  
            }

            Text {
              text: `I built Bagja because my ADHD makes sticking to a strict, single workflow frustrating. I needed a shell that adapts to my fluctuating energy and memory, so I merged the best parts of different desktop paradigms into one:`
              color: Colors.text_variant1
              font.pixelSize: 11
              Layout.fillWidth: true
              wrapMode: Text.WordWrap  
            }

            Repeater {
              model: [
                "The Keybind Problem: Keyboard navigation is fast, but forgetting shortcuts is a daily struggle. Bagja includes a bottom dock for quick visual reference.",
                "The Memory Problem: Docks have limits, and I often forget what packages I have installed over time. To fix this, I integrated a full visual start menu linked to the dock.",
                "Adaptive Energy: Some days I want the hyper-efficiency of a keyboard-only workflow. Other days, I am tired and just want a fully clickable GUI panel. Bagja seamlessly switches between both."
              ]

              RowLayout {
                required property string modelData
                Layout.fillWidth: true
                spacing: 6
                Layout.alignment: Qt.AlignTop

                Text {
                  text: "•"
                  color: Colors.text_variant1
                  font.pixelSize: 11
                  Layout.alignment: Qt.AlignTop
                }

                Text {
                  text: modelData
                  color: Colors.text_variant1
                  font.pixelSize: 11
                  Layout.fillWidth: true
                  wrapMode: Text.WordWrap
                }
              }
            }
          }

          Rectangle { Layout.fillWidth: true; height: 1; color: Colors.outline_variant }

          RowLayout {
            Layout.fillWidth: true
            Text { text: "Version"; color: Colors.text_variant1; font.pixelSize: 11; Layout.fillWidth: true }
            Text { text: "1.0.0"; color: Colors.text; font.pixelSize: 11 }
          }

          RowLayout {
            Layout.fillWidth: true
            Text { text: "Built with"; color: Colors.text_variant1; font.pixelSize: 11; Layout.fillWidth: true }
            Text { text: "Quickshell + QML"; color: Colors.text; font.pixelSize: 11 }
          }

          Item { Layout.fillHeight: true }
        }
      }
    }
  }
}

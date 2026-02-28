import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick.Controls 

PanelWindow {
  id: root

  implicitWidth: 600
  implicitHeight: 450

  property bool isShowing: false
  property string activeTab: "Appearance"

  anchors {
    top: true
    left: true
    right: true
    bottom: true
  }

  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

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
    width: root.implicitWidth
    height: root.implicitHeight
    anchors.centerIn: parent
    gradient: Gradient {
      orientation: Gradient.Horizontal
      GradientStop { position: 0.1; color: Colors.isDark ? Colors.surface : Colors.surface }
      GradientStop { position: 0.99; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim }
    }
    radius: 16
    border.color: Colors.outlineVariant
    border.width: 2
    opacity: root.isShowing ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
    transform: Translate {
      y: root.isShowing ? 0 : -20
      Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
    }

    RowLayout {
      anchors.fill: parent
      spacing: 0

      // SIDEBAR
      Rectangle {
        Layout.preferredWidth: 160
        Layout.fillHeight: true
        color: Colors.isDark ? Colors.surfaceContainer : Colors.surfaceContainerHigh
        radius: 16
        border.width: 2 
        border.color: Colors.outlineVariant

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
          color: Colors.outlineVariant
        }

        Rectangle {
          anchors.bottom: parent.bottom
          anchors.right: parent.right
          height: 2
          width: 16
          color: Colors.outlineVariant
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
              color: Colors.overSurfaceVariant
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
            color: Colors.outlineVariant
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
                { label: "Appearance", icon: "󰔎" },
                { label: "Behavior",   icon: "󰒓" },
                { label: "About",      icon: "󰋽" }
              ]

              delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                height: 36
                radius: 8
                color: root.activeTab === modelData.label
                  ? Colors.isDark ? Colors.overPrimary : Colors.primaryFixedDim
                  : tabHover.containsMouse
                    ? Colors.isDark ? Qt.alpha(Colors.surfaceContainerHigh, 0.8) : Qt.alpha(Colors.primaryFixedDim, 0.5)
                    : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }

                RowLayout {
                  anchors.fill: parent
                  anchors.leftMargin: 10
                  anchors.rightMargin: 10
                  spacing: 8

                  Text {
                    text: modelData.icon
                    font.pixelSize: 14
                    font.family: "JetBrainsMono Nerd Font"
                    color: root.activeTab === modelData.label
                      ? Colors.isDark ? Colors.primary : Colors.primary
                      : Colors.overSurfaceVariant
                    Layout.alignment: Qt.AlignVCenter
                  }

                  Text {
                    text: modelData.label
                    font.pixelSize: 12
                    font.bold: root.activeTab === modelData.label
                    color: root.activeTab === modelData.label
                      ? Colors.isDark ? Colors.primary : Colors.primary
                      : Colors.overSurfaceVariant
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
              color: Colors.overSurfaceVariant
              font.pixelSize: 13
              font.bold: true
              Layout.fillWidth: true
              Layout.alignment: Qt.AlignVCenter
            }

            Rectangle {
              width: 20; height: 20
              color: closeHover.containsMouse
                ? Colors.isDark ? Colors.overSecondary : Colors.secondary
                : "transparent"
              radius: 4
              Layout.alignment: Qt.AlignVCenter

              Text {
                anchors.centerIn: parent
                text: "✕"
                color: Colors.overSurface
                font.pixelSize: 12
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
          color: Colors.outlineVariant
        }

        // Appearance
        ColumnLayout {
          visible: root.activeTab === "Appearance"
          Layout.fillWidth: true
          Layout.fillHeight: true
          Layout.topMargin: 10
          Layout.rightMargin: 20
          Layout.leftMargin: 20
          spacing: 10

          RowLayout {
            Layout.fillWidth: true

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
                color: Colors.overSurface
                font.pixelSize: 12
                font.bold: true
              }
              Text {
                text: "Material You color scheme variant"
                color: Colors.overSurfaceVariant
                font.pixelSize: 10
              }
            }
          }

          // Grid variant
          GridLayout {
            id: variantGrid
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
                color: parent.currentVariant === modelData
                  ? Colors.isDark ? Colors.primaryContainer : Colors.primaryFixedDim
                  : Colors.isDark ? Colors.surfaceContainer : Colors.surfaceContainerHigh
                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                  anchors.centerIn: parent
                  text: modelData
                  font.pixelSize: 9
                  font.bold: parent.currentVariant === modelData
                  color: parent.currentVariant === modelData
                    ? Colors.isDark ? Colors.primary : Colors.primary
                    : Colors.overSurfaceVariant
                }

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    parent.parent.currentVariant = modelData
                    variantProcess.command = ["bash", Quickshell.shellDir + "/scripts/set_variant.sh", modelData]
                    variantProcess.running = true
                  }
                }
              }
            }
          }

          Process { id: variantProcess; running: false }

          Rectangle { Layout.fillWidth: true; height: 1; color: Colors.outlineVariant }

          Item { Layout.fillHeight: true }
        }

        // Behavior
        ColumnLayout {
          visible: root.activeTab === "Behavior"
          Layout.fillWidth: true
          Layout.fillHeight: true
          Layout.margins: 20
          spacing: 16

          // Mode
          RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
              spacing: 2
              Layout.fillWidth: true
              Text {
                text: "Mode"
                color: Colors.overSurface
                font.pixelSize: 12
                font.bold: true
              }
              Text {
                text: "Color scheme mode"
                color: Colors.overSurfaceVariant
                font.pixelSize: 10
              }
            }

            Item { Layout.fillWidth: true }

            RowLayout {
              spacing: 4
              property string currentMode: "auto"

              Repeater {
                model: ["light", "dark", "auto"]
                delegate: Rectangle {
                  required property string modelData
                  width: 40; height: 24
                  radius: 6
                  color: parent.currentMode === modelData
                    ? Colors.isDark ? Colors.primaryContainer : Colors.primaryFixedDim
                    : Colors.isDark ? Colors.surfaceContainer : Colors.surfaceContainerHigh
                  Behavior on color { ColorAnimation { duration: 120 } }

                  Text {
                    anchors.centerIn: parent
                    text: modelData
                    font.pixelSize: 9
                    font.bold: parent.currentMode === modelData
                    color: parent.currentMode === modelData
                      ? Colors.isDark ? Colors.primary : Colors.primary
                      : Colors.overSurfaceVariant
                  }

                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                      parent.parent.currentMode = modelData
                      modeProcess.command = ["bash", "-c",
                        "sed -i 's/^mode = .*/mode = " + modelData + "/' " +
                        Quickshell.env("HOME") + "/.config/m3-colors/m3-colors.conf"]
                      modeProcess.running = true
                    }
                  }
                }
              }
            }
          }

          Rectangle { Layout.fillWidth: true; height: 1; color: Colors.outlineVariant }

          Item { Layout.fillHeight: true }
        }

        // About 
        ColumnLayout {
          visible: root.activeTab === "About"
          Layout.fillWidth: true
          Layout.fillHeight: true
          Layout.topMargin: 10
          Layout.rightMargin: 20
          Layout.leftMargin: 20
          spacing: 10

          ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 4

            Text {
              text: "Bagja Shell"
              color: Colors.overSurface
              font.pixelSize: 16
              font.bold: true
              Layout.alignment: Qt.AlignHCenter
            }

            Text {
              text: "One shell, every workflow"
              color: Colors.overSurfaceVariant
              font.pixelSize: 11
              Layout.alignment: Qt.AlignHCenter
            }
          }

          Rectangle { Layout.fillWidth: true; height: 1; color: Colors.outlineVariant }

          ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
              text: "Description"
              color: Colors.overSurfaceVariant
              font.pixelSize: 11
              font.bold: true
              Layout.fillWidth: true
            }

            Text {
              text: `The philosophy behind this is simple. "Bagja" means happy in my language so the user can be happy about their desktop.`
              color: Colors.overSurfaceVariant
              font.pixelSize: 11
              Layout.fillWidth: true
              wrapMode: Text.WordWrap  
            }

            Text {
              text: `I built Bagja because my ADHD makes sticking to a strict, single workflow frustrating. I needed a shell that adapts to my fluctuating energy and memory, so I merged the best parts of different desktop paradigms into one:`
              color: Colors.overSurfaceVariant
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
                  color: Colors.overSurfaceVariant
                  font.pixelSize: 11
                  Layout.alignment: Qt.AlignTop
                }

                Text {
                  text: modelData
                  color: Colors.overSurfaceVariant
                  font.pixelSize: 11
                  Layout.fillWidth: true
                  wrapMode: Text.WordWrap
                }
              }
            }
          }

          Rectangle { Layout.fillWidth: true; height: 1; color: Colors.outlineVariant }

          RowLayout {
            Layout.fillWidth: true
            Text { text: "Version"; color: Colors.overSurfaceVariant; font.pixelSize: 11; Layout.fillWidth: true }
            Text { text: "1.0.0"; color: Colors.overSurface; font.pixelSize: 11 }
          }

          RowLayout {
            Layout.fillWidth: true
            Text { text: "Built with"; color: Colors.overSurfaceVariant; font.pixelSize: 11; Layout.fillWidth: true }
            Text { text: "Quickshell + QML"; color: Colors.overSurface; font.pixelSize: 11 }
          }

          Item { Layout.fillHeight: true }
        }
      }
    }
  }
}

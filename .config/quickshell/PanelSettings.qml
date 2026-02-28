import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Controls
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Bluetooth

PanelWindow {
  id: root

  implicitWidth: 274
  implicitHeight: Math.min(380, Math.max(baseHeight, baseHeight + (notifHistory.length - 1) * (notifItemHeight + 6)))

  property int baseHeight: 360
  property int notifItemHeight: 50
  property int buttonHeight: 55
  property int fontsizeButton: 9
  property int iconsizeButton: 20

  property bool wifiEnabled: false
  property bool dndActive: false 
  signal dndToggled()
  
  Process {
    id: wifiStatusCheck
    command: ["bash", "-c", "nmcli radio wifi"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        root.wifiEnabled = text.trim() === "enabled"
      }
    }
  }

  Process {
    id: audioEventWatcher
    command: ["bash", "-c", "pactl subscribe | grep --line-buffered \"Event 'change' on sink\""]
    running: true
    stdout: SplitParser {
      onRead: data => {
        panelGetVolume.running = true
      }
    }
  }

  Timer {
    interval: 3000
    repeat: true
    running: true
    onTriggered: wifiStatusCheck.running = true
  }

  signal openBluetooth()
  signal openWifi()
  signal openAudio()
  signal openNotifications()

  anchors {
    top: true
    right: true
  }

  margins {
    top: 28
    right: -8
  }

  color: "transparent"

  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
  property var notifHistory: []
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

  Item {
    anchors.fill: parent
    anchors.bottomMargin: 12 
    anchors.leftMargin: 12


    Rectangle {
      id: mainRect
      anchors.fill: parent
      color: "transparent"

      radius: 12

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
          GradientStop { position: 0.01; color: Colors.isDark ? Colors.surface : Colors.surface }
          GradientStop { position: 0.90; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim }
        }
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        z: 5
      }

      RowLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0

        Item {
          Layout.fillHeight: true
          Layout.preferredWidth: 240

          Rectangle {
            anchors.fill: parent
            gradient: Gradient {
              orientation: Gradient.Horizontal 
              GradientStop { position: 0.01; color: Colors.isDark ? Colors.surface : Colors.surface }
              GradientStop { position: 0.78; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim }
            }
            radius: 12
            border.color: Colors.outlineVariant
            border.width: 2

            ColumnLayout {
              anchors.fill: parent
              anchors.leftMargin: 14
              anchors.rightMargin: 12
              anchors.topMargin: 14
              anchors.bottomMargin: 14
              spacing: 6

              ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                  Layout.fillWidth: true
                  spacing: 6

                  ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: 0
                    spacing: 4

                    Rectangle {
                      Layout.fillWidth: true
                      height: buttonHeight
                      color: root.wifiEnabled 
                        ? (Colors.isDark ? Colors.overPrimaryFixed : Colors.primaryFixedDim)
                        : (Colors.isDark ? Colors.surfaceContainerHigh : Colors.surfaceDim)
                      radius: 6

                      Text {
                        anchors.centerIn: parent
                        text: ""
                        color: Colors.isDark ? Colors.primary : Colors.secondary
                        font.pixelSize: iconsizeButton
                      }

                      MouseArea {
                        anchors.fill: parent
                        onClicked: root.openWifi()
                      }

                    }
                    Text {
                      Layout.alignment: Qt.AlignHCenter
                      text: "Wifi"
                      color: Colors.overSurface
                      font.pixelSize: fontsizeButton
                    }
                  }

                  ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: 0
                    spacing: 4
                    
                    Rectangle {
                      Layout.fillWidth: true
                      height: buttonHeight
                      color: (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled) 
                        ? (Colors.isDark ? Colors.overTertiary : Colors.secondaryFixedDim)
                        : (Colors.isDark ? Colors.surfaceContainerHigh : Colors.surfaceDim)
                      radius: 6

                      Text {
                        anchors.centerIn: parent
                        text: "󰂯"
                        color: Colors.isDark ? Colors.tertiary : Colors.primary
                        font.pixelSize: iconsizeButton
                      }

                      MouseArea {
                        anchors.fill: parent
                        onClicked: {
                          root.openBluetooth()
                        }
                      }

                    }
                    Text {
                      Layout.alignment: Qt.AlignHCenter
                      text: "Bluetooth"
                      color: Colors.overSurface
                      font.pixelSize: fontsizeButton
                    }
                  }

                  ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: 0
                    spacing: 4
                    
                    Rectangle {
                      Layout.fillWidth: true
                      height: buttonHeight 
                      color: nightModeOn 
                        ? (Colors.isDark ? Colors.tertiaryContainer : Colors.tertiaryFixedDim)
                        : (Colors.isDark ? Colors.surfaceContainerHigh : Colors.surfaceDim)
                      radius: 6

                      property bool nightModeOn: false

                      Text {
                        anchors.centerIn: parent
                        text: ""
                        color: Colors.overSecondaryContainer
                        font.pixelSize: iconsizeButton
                      }

                      MouseArea {
                        anchors.fill: parent
                        onClicked: {
                          parent.nightModeOn = !parent.nightModeOn
                          Quickshell.execDetached(["/bin/bash", Quickshell.shellDir + "/scripts/toggle_night_mode.sh"])
                        }
                      }
                    }
                    Text {
                      Layout.alignment: Qt.AlignHCenter
                      text: "Night Mode"
                      color: Colors.overSurface
                      font.pixelSize: fontsizeButton
                    }
                  }
                }

                RowLayout {
                  Layout.fillWidth: true
                  spacing: 6
                  ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: 0
                    spacing: 4
                    
                    Rectangle {
                      Layout.fillWidth: true
                      height: buttonHeight
                      color: dndActive 
                        ? (Colors.isDark ? Colors.tertiaryContainer : Colors.primaryFixed)
                        : (Colors.isDark ? Colors.surfaceContainerHigh : Colors.surfaceDim)
                      radius: 6

                      Text {
                        anchors.centerIn: parent
                        text: "󰂛"
                        color: Colors.overSecondaryContainer
                        font.pixelSize: iconsizeButton
                      }

                      MouseArea {
                        anchors.fill: parent
                        onClicked: root.dndToggled()
                      }

                    }
                    Text {
                      Layout.alignment: Qt.AlignHCenter
                      text: "DND"
                      color: Colors.overSurface
                      font.pixelSize: fontsizeButton
                    }
                  }
                  ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: 0
                    spacing: 4
                    
                    Rectangle {
                      Layout.fillWidth: true
                      height: buttonHeight
                      color: Colors.isDark ? Colors.overSecondaryFixedVariant : Colors.inversePrimary
                      radius: 6

                      Text {
                        anchors.centerIn: parent
                        text: ""
                        color: Colors.isDark ? Colors.primary : Colors.secondary
                        font.pixelSize: iconsizeButton
                      }

                      MouseArea {
                        anchors.fill: parent
                        onClicked: {
                          Quickshell.execDetached(["hyprpicker", "-a"]) 
                        }
                      }

                    }
                    Text {
                      Layout.alignment: Qt.AlignHCenter
                      text: "Color Picker"
                      color: Colors.overSurface
                      font.pixelSize: fontsizeButton
                    }
                  }

                  ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: 0
                    spacing: 4
                    
                    Rectangle {
                      Layout.fillWidth: true
                      height: buttonHeight
                      color: Colors.isDark ? Colors.overTertiary : Colors.primaryFixed
                      radius: 6

                      property bool bluetoothModeOn: false

                      Text {
                        anchors.centerIn: parent
                        text: "󰓃"
                        color: Colors.isDark ? Colors.tertiary : Colors.secondary                        
                        font.pixelSize: iconsizeButton + 8
                      }

                      MouseArea {
                        anchors.fill: parent
                        onClicked: root.openAudio()
                      }
                    }
                    Text {
                      Layout.alignment: Qt.AlignHCenter
                      text: "Audio Devices"
                      color: Colors.overSurface
                      font.pixelSize: fontsizeButton
                    }
                  }
                }
              }

              Rectangle {
                Layout.fillWidth: true 
                height: 2 
                color: Colors.isDark ? Colors.outlineVariant : Colors.primary
              }

              Rectangle {
                Layout.fillWidth: true
                height: 65
                color: "transparent"
                radius: 8

                Process {
                  id: panelGetVolume
                  command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf \"%.0f\", $2 * 100}'"]
                  running: true
                  stdout: StdioCollector {
                    onStreamFinished: {
                      let vol = parseInt(text.trim())
                      if (!isNaN(vol)) panelVolumeSlider.value = vol
                    }
                  }
                }

                Process {
                  id: panelGetBrightness
                  command: ["bash", "-c", "brightnessctl get | awk -v max=$(brightnessctl max) '{print int($1*100/max)}'"]
                  running: true
                  stdout: StdioCollector {
                    onStreamFinished: {
                      let bright = parseInt(text.trim())
                      if (!isNaN(bright)) panelBrightnessSlider.value = bright
                    }
                  }
                }

                Process { id: panelSetVolume; running: false }
                Process { id: panelSetBrightness; running: false }

                ColumnLayout {
                  anchors.fill: parent
                  anchors.margins: 0
                  spacing: 0

                  // Brightness
                  RowLayout {
                    Layout.fillWidth: true
                    spacing: 16 

                    Rectangle {
                      Layout.alignment: Qt.AlignHCenter
                      width: 22
                      height: 22
                      color: "transparent"

                      Text {
                        anchors.centerIn: parent
                        text: "󰃠"
                        font.pixelSize: 20
                        color: Colors.overSurface
                      }
                    }
                    Slider {
                      id: panelBrightnessSlider
                      Layout.preferredWidth: 160
                      from: 1; to: 100; value: 50
                      onMoved: {
                        panelSetBrightness.command = ["brightnessctl", "s", Math.round(value) + "%"]
                        panelSetBrightness.running = true
                      }
                      background: Rectangle {
                        x: panelBrightnessSlider.leftPadding
                        y: panelBrightnessSlider.topPadding + panelBrightnessSlider.availableHeight / 2 - height / 2
                        implicitHeight: 4
                        width: panelBrightnessSlider.availableWidth
                        height: implicitHeight
                        radius: 2
                        color: Colors.isDark ? Colors.surfaceContainerHigh : Colors.surfaceContainerHighest
                        Rectangle {
                          width: panelBrightnessSlider.position * parent.width
                          height: parent.height
                          color: Colors.isDark ? Colors.primaryContainer : Colors.inversePrimary
                          radius: 2
                        }
                      }
                      handle: Rectangle {
                        x: panelBrightnessSlider.leftPadding + panelBrightnessSlider.position * panelBrightnessSlider.availableWidth - width / 2
                        y: panelBrightnessSlider.topPadding + panelBrightnessSlider.availableHeight / 2 - height / 2
                        implicitWidth: 20
                        implicitHeight: 20
                        width: implicitWidth
                        height: implicitHeight
                        radius: 10
                        color: panelBrightnessSlider.pressed
                          ? Colors.isDark ? Colors.overPrimary : Colors.primaryFixedDim
                          : Colors.isDark ? Colors.primaryContainer : Colors.secondaryFixedDim
                        border.color: "transparent"
                        border.width: 2
                        Text {
                          x: (parent.width - width) / 2
                          y: (parent.height - height) / 2
                          text: Math.round(panelBrightnessSlider.value) + ""
                          font.pixelSize: 10
                          font.bold: true
                          color: panelBrightnessSlider.pressed 
                          ? Colors.overSurface 
                          : Colors.isDark ? Colors.primary : Colors.secondary 
                        }
                      }
                    }
                  }

                  // Volume
                  RowLayout {
                    Layout.fillWidth: true
                    spacing: 16 

                    Rectangle {
                      Layout.alignment: Qt.AlignHCenter
                      width: 22
                      height: 22
                      color: "transparent"

                      Text {
                        anchors.centerIn: parent
                        text: "󰕾"
                        font.pixelSize: 20
                        color: Colors.overSurface
                      }
                    }
                    Slider {
                      id: panelVolumeSlider
                      Layout.preferredWidth: 160
                      from: 0; to: 100; value: 50
                      onMoved: {
                        let vol = value / 100.0
                        panelSetVolume.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", vol.toFixed(2)]
                        panelSetVolume.running = true
                      }

                      background: Rectangle {
                        x: panelVolumeSlider.leftPadding
                        y: panelVolumeSlider.topPadding + panelVolumeSlider.availableHeight / 2 - height / 2
                        implicitHeight: 4
                        width: panelVolumeSlider.availableWidth
                        height: implicitHeight
                        color: Colors.isDark ? Colors.surfaceContainerHigh : Colors.surfaceContainerHighest
                        radius: 2
                        Rectangle {
                          width: panelVolumeSlider.position * parent.width
                          height: parent.height
                          color: Colors.isDark ? Colors.tertiaryContainer : Colors.tertiaryFixedDim
                          radius: 2
                        }
                      }

                      handle: Rectangle {
                        x: panelVolumeSlider.leftPadding + panelVolumeSlider.position * panelVolumeSlider.availableWidth - width / 2
                        y: panelVolumeSlider.topPadding + panelVolumeSlider.availableHeight / 2 - height / 2
                        implicitWidth: 20
                        implicitHeight: 20
                        width: implicitWidth
                        height: implicitHeight
                        radius: 10
                        color: panelVolumeSlider.pressed 
                          ? Colors.isDark ? Colors.overTertiary : Colors.tertiaryFixedDim 
                          : Colors.isDark ? Colors.tertiaryContainer : Colors.primaryFixedDim
                        border.color: "transparent"
                        border.width: 2
                        Text {
                          x: (parent.width - width) / 2
                          y: (parent.height - height) / 2
                          text: Math.round(panelVolumeSlider.value) + ""
                          font.pixelSize: 10
                          font.bold: true
                          color: panelVolumeSlider.pressed 
                          ? Colors.overSurface 
                          : Colors.isDark ? Colors.primary : Colors.secondary 
                        }
                      }
                    }
                  }
                }
              }

              Rectangle {
                Layout.fillWidth: true 
                height: 2 
                color: Colors.isDark ? Colors.outlineVariant : Colors.primary
              }

              Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
                radius: 8
                
                ColumnLayout {
                  anchors.fill: parent
                  anchors.margins: 0
                  spacing: 6

                  // Header
                  RowLayout {
                    Layout.fillWidth: true
                    Text {
                      text: "Notifications"
                      color: Colors.primary 
                      font.pixelSize: 13
                      font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                      width: 18; height: 18
                      color: notifHeaderBtn.containsMouse
                        ? Colors.isDark ? Colors.primaryContainer : Colors.secondaryFixed
                        : "transparent"
                      radius: 4

                      Text {
                        anchors.centerIn: parent
                        text: ""
                        color: Colors.overSurface
                        font.pixelSize: 14
                      }

                      MouseArea {
                        id: notifHeaderBtn
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.openNotifications()
                      }
                    }
                  }

                  // List
                  ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true  
                    clip: true
                    spacing: 6
                    model: notifHistory

                    Text {
                      anchors.centerIn: parent
                      text: "No new notifications"
                      color: Colors.overSurface
                      font.pixelSize: 12
                      visible: notifHistory.length === 0
                    }

                    delegate: Rectangle {
                      width: ListView.view.width
                      height: notifItemHeight
                      color: Colors.isDark ? Colors.surfaceContainerHigh : Colors.surfaceContainerHighest
                      radius: 6

                      Column {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 2
                        RowLayout {
                          width: parent.width
                          Text { 
                            text: modelData.appName
                            color: Colors.tertiary
                            font.pixelSize: 10
                          }
                          Item { Layout.fillWidth: true }
                          Text { 
                            text: modelData.time
                            color: Colors.overSurfaceVariant
                            font.pixelSize: 10
                          }
                        }
                        Text {
                          text: modelData.summary
                          color: Colors.secondary
                          font.pixelSize: 11
                          elide: Text.ElideRight
                          width: parent.width
                        }
                      }
                    }
                  }
                }
              }
            }
          }

          Rectangle {
            id: rightPatch
            width: 14
            height: parent.height
            gradient: Gradient {
              orientation: Gradient.Vertical 
              GradientStop { position: 0.01; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim }
              GradientStop { position: 0.2; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim  }
              GradientStop { position: 0.90; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim }
            }
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
            anchors.rightMargin: -1
            z: 10
            onPaint: {
              var ctx = getContext("2d")
              ctx.reset()
              ctx.fillStyle = Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim
              ctx.beginPath()
              ctx.moveTo(0, 0)
              ctx.lineTo(0, 2)
              ctx.arc(0, 14, 12, Math.PI / 2, 0, false)
              ctx.lineTo(12, 14)
              ctx.lineTo(14, 14)
              ctx.lineTo(14, 0)
              ctx.closePath()
              ctx.fill()
            }
          }

          Canvas {
            id: rightWing1
            width: 14; height: 14
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.bottomMargin: -12
            anchors.rightMargin: -1
            z: 10
            onPaint: {
              var ctx = getContext("2d")
              ctx.reset()
              ctx.fillStyle = Colors.outlineVariant
              ctx.beginPath()
              ctx.moveTo(0, 0)
              ctx.lineTo(0, 2)
              ctx.arc(0, 14, 12, Math.PI / 2, 0, false)
              ctx.lineTo(12, 14)
              ctx.lineTo(14, 14)
              ctx.arc(0, 14, 14, 0, Math.PI / 2, true)
              ctx.closePath()
              ctx.fill()
            }
          }
        }
      }
      Canvas {
        id: leftWing
        width: 14; height: 14
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: -12
        z: 10
        onPaint: {
          var ctx = getContext("2d")
          ctx.reset()
          ctx.fillStyle = Colors.isDark ? Colors.surface : Colors.surface
          ctx.beginPath()
          ctx.moveTo(0, 0)
          ctx.lineTo(0, 2)
          ctx.arc(0, 14, 12, Math.PI / 2, 0, false)
          ctx.lineTo(12, 14)
          ctx.lineTo(14, 14)
          ctx.lineTo(14, 0)
          ctx.closePath()
          ctx.fill()
        }
      }

      Canvas {
        id: leftWing1
        width: 14; height: 14
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: -12
        z: 10
        onPaint: {
          var ctx = getContext("2d")
          ctx.reset()
          ctx.fillStyle = Colors.outlineVariant
          ctx.beginPath()
          ctx.moveTo(0, 0)
          ctx.lineTo(0, 2)
          ctx.arc(0, 14, 12, Math.PI / 2, 0, false)
          ctx.lineTo(12, 14)
          ctx.lineTo(14, 14)
          ctx.arc(0, 14, 14, 0, Math.PI / 2, true)
          ctx.closePath()
          ctx.fill()
        }
      }
    }
  }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

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
    
  property var filteredApps: []
  property bool isShowing: false 
  signal requestClose()
    
  onVisibleChanged: {
    if (visible) {
      isShowing = true
      searchInput.text = ""
      searchInput.forceActiveFocus()
      updateFilteredApps()
    }
  }
    
  function updateFilteredApps() {
    var query = searchInput.text.toLowerCase()
        
    if (query === "") {
      filteredApps = DesktopEntries.applications.values
    } 
    else {
      filteredApps = DesktopEntries.applications.values.filter(function(app) {
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
    
  Rectangle {
    id: launcherBackground
    anchors {
      bottom: parent.bottom
      left: parent.left
      leftMargin: 15 
      bottomMargin: 15
    }
    width: 430
    height: Math.max(100, Math.min(400, 97 + (Math.min(filteredApps.length, 4) * 50)))
    radius: 14

    property real screenHeight: Quickshell.screens[0].height
    property real topBarHeight: 30   
    property real bottomMargin: 15   
    property real effectiveBottom: screenHeight - bottomMargin  
    property real wEnd: (effectiveBottom - topBarHeight) / (screenHeight - topBarHeight)  
    property real wStart: wEnd - (height / (screenHeight - topBarHeight))

    function leftbarColorAt(p) {
        var stops = [
            {pos: 0.0, color: Colors.isDark ? Colors.surfaceDim        : Colors.surface},
            {pos: 0.2, color: Colors.isDark ? Colors.surface            : Colors.surface},
            {pos: 0.3, color: Colors.isDark ? Colors.surface            : Colors.surface},
            {pos: 0.4, color: Colors.isDark ? Colors.surface           : Colors.surface},
            {pos: 0.46, color: Colors.isDark ? Colors.surface           : Colors.surface},
            {pos: 0.6, color: Colors.isDark ? Colors.overPrimaryFixed : Colors.primaryFixedDim},
            {pos: 0.7, color: Colors.isDark ? Colors.overPrimaryFixed : Colors.primaryFixedDim},
            {pos: 0.8, color: Colors.isDark ? Colors.surface            : Colors.surface},
            {pos: 0.9, color: Colors.isDark ? Colors.overPrimaryFixed : Colors.primaryFixed},
            {pos: 1.0, color: Colors.isDark ? Colors.overPrimaryFixed : Colors.primaryFixed},
        ]
        if (p <= 0) return stops[0].color
        if (p >= 1) return stops[stops.length-1].color
        for (var i = 0; i < stops.length - 1; i++) {
            if (p >= stops[i].pos && p <= stops[i+1].pos) {
                var t = (p - stops[i].pos) / (stops[i+1].pos - stops[i].pos)
                return Qt.rgba(
                    stops[i].color.r + t * (stops[i+1].color.r - stops[i].color.r),
                    stops[i].color.g + t * (stops[i+1].color.g - stops[i].color.g),
                    stops[i].color.b + t * (stops[i+1].color.b - stops[i].color.b),
                    1.0
                )
            }
        }
    }

    gradient: Gradient {
      orientation: Gradient.Vertical
      GradientStop { position: 0.0;  color: launcherBackground.leftbarColorAt(launcherBackground.wStart) }
      GradientStop { position: (0.2  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.2) }
      GradientStop { position: (0.3  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.3) }
      GradientStop { position: (0.4  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.4) }
      GradientStop { position: (0.46 - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.46) }
      GradientStop { position: (0.6  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.6) }
      GradientStop { position: (0.7 - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.72) }
      GradientStop { position: (0.8  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.8) }
      GradientStop { position: (0.9  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.9) }
      GradientStop { position: 1.0;  color: launcherBackground.leftbarColorAt(launcherBackground.wEnd) }
    }
    border.color: Colors.outlineVariant
    border.width: 2

    opacity: launcherWindow.visible ? 1 : 0
    
    Behavior on opacity {
      NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    transform: Translate {
      y: isShowing ? 0 : 550
      Behavior on y {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
      }
    }

    Behavior on height {
      NumberAnimation { duration: 200 }
    }
        
    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 12
      spacing: 8 
            
      Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: 8
        color: Colors.isDark ? Qt.alpha(Colors.surfaceContainerHigh, 0.8) : Qt.alpha(Colors.surfaceContainerHighest, 0.8)
                
        ColumnLayout {
          anchors.fill: parent
          spacing: 0
                    
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
                text: filteredApps.length + " apps"
                font.pixelSize: 12
                color: Colors.overSurface
              }
                            
              Item { Layout.fillWidth: true }
                            
              Text {
                text: "↑↓ Navigate • Enter Launch • Esc Close"
                font.pixelSize: 11
                color: Colors.overSurface
              }
            }
          }
                    
          ListView {
            id: appListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 2
                        
            model: ScriptModel {
              values: filteredApps
            }
                        
            highlight: Rectangle {
              color: "transparent"
              radius: 6
            }

            highlightMoveDuration: 100
                        
            delegate: Rectangle {
              required property var modelData
              required property int index
                            
              width: appListView.width 
              height: 48
              x: 8
              color: "transparent"
              radius: 6
                            
              Rectangle {
                anchors.fill: parent
                color: appListView.currentIndex === index 
                ? Colors.isDark ? Colors.overSecondary : Qt.alpha(Colors.primary, 0.5)
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
                  border.color: Colors.outlineVariant
                  border.width: 1

                  color: Colors.isDark ? Colors.surfaceContainerHighest : Colors.surfaceContainerHighest
                                    
                  Image {
                    anchors.centerIn: parent
                    width: 24
                    height: 24
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
                      if (status === Image.Error) {
                        source = "image://icon/application-x-executable"
                      }
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
                    color: Colors.overSurface
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                  }
                                    
                  Text {
                    text: modelData.description || modelData.genericName || ""
                    font.pixelSize: 10
                    color: Colors.overSurfaceVariant
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                  }
                }
              }
            }
          }
        } 
      }
            
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 36
        radius: 16
        color: Colors.isDark ? Qt.alpha(Colors.surfaceContainerLow, 0.8) : Qt.alpha(Colors.surfaceContainerHighest, 0.8)
        border.color: searchInput.activeFocus ? Colors.outlineVariant : Colors.outline
        border.width: 2
                
        Behavior on border.color {
          ColorAnimation { duration: 150 }
        }
                
        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: 12
          spacing: 12
                    
          Text {
            text: "󰍉"
            font.pixelSize: 20
            color: Colors.overSurfaceVariant
          }
                    
          TextInput {
            id: searchInput
            Layout.fillWidth: true
            font.pixelSize: 15
            color: Colors.overSurface
            selectionColor: Colors.isDark ? Colors.primary : Colors.secondaryFixed
            selectedTextColor: Colors.isDark ? Colors.surfaceContainer : Colors.surface 
                        
            onTextChanged: updateFilteredApps()
                        
            Keys.onPressed: (event) => {
              if (event.key === Qt.Key_Escape) {
                requestClose()
                event.accepted = true
              } 
              else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (filteredApps.length > 0) {
                  launcherWindow.launchApp(filteredApps[appListView.currentIndex])
                }
                event.accepted = true
              } 
              else if (event.key === Qt.Key_Down) {
                if (appListView.currentIndex < filteredApps.length - 1) {
                  appListView.currentIndex++
                  appListView.positionViewAtIndex(appListView.currentIndex, ListView.Contain)
                }
                event.accepted = true
              } 
              else if (event.key === Qt.Key_Up) {
                if (appListView.currentIndex > 0) {
                  appListView.currentIndex--
                  appListView.positionViewAtIndex(appListView.currentIndex, ListView.Contain)
                }
                event.accepted = true
              }
            }
                        
            Text {
              visible: parent.text === ""
              text: "Type for search an applications..."
              color: Colors.isDark ? Colors.primary : Colors.overPrimaryFixedVariant
              font.pixelSize: parent.font.pixelSize
            }
          }
        }
      }
    }
    
    Rectangle {
      Layout.leftMargin: -12 
      z: 1
      width: 12; 
      height: parent.height; 
      gradient: Gradient {
        orientation: Gradient.Vertical
        GradientStop { position: 0.0;  color: launcherBackground.leftbarColorAt(launcherBackground.wStart) }
        GradientStop { position: (0.2  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.2) }
        GradientStop { position: (0.3  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.3) }
        GradientStop { position: (0.4  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.4) }
        GradientStop { position: (0.46 - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.46) }
        GradientStop { position: (0.6  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.6) }
        GradientStop { position: (0.7 - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.72) }
        GradientStop { position: (0.8  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.8) }
        GradientStop { position: (0.9  - launcherBackground.wStart) / (launcherBackground.wEnd - launcherBackground.wStart); color: launcherBackground.leftbarColorAt(0.9) }
        GradientStop { position: 1.0;  color: launcherBackground.leftbarColorAt(launcherBackground.wEnd) }
      }
    }

    Rectangle {
      anchors {
        bottom: parent.bottom
        left: parent.left
        right: parent.right
      }
      Layout.leftMargin: -12 
      z: 1
      width: parent.width; 
      height: 12; 
      gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0.01; color: Colors.isDark ? Colors.overPrimaryFixed : Colors.primaryFixed  }
        GradientStop { position: 0.1; color: Colors.isDark ? Colors.overPrimaryFixed : Colors.primaryFixed }
        GradientStop { position: 0.60; color: Colors.isDark ? Colors.surface : Colors.surface  }
        GradientStop { position: 1.0; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.primaryFixed }
      }
    }

    Connections {
      target: launcherBackground
      function onWStartChanged() {
        lefttopLauncher.requestPaint()
      }
    }

    Canvas {
      id: lefttopLauncher
      width: 14; height: 14
      anchors {
        bottom: parent.top
        left: parent.left
      }

      anchors.bottomMargin: -2

      transform: Scale {
          origin.x: 7
          origin.y: 7
          yScale: -1
      }
      
      z: 1
      onPaint: {
          var ctx = getContext("2d")
          ctx.reset()
          ctx.fillStyle = launcherBackground.leftbarColorAt(launcherBackground.wStart).toString()
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
      id: lefttopLauncher1
      width: 14; height: 14
      anchors {
        bottom: parent.top
        left: parent.left
      }

      anchors.bottomMargin: -2

      transform: Scale {
          origin.x: 7
          origin.y: 7
          yScale: -1
      }
      
      z: 1
      onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        ctx.fillStyle = Colors.outlineVariant
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
      id: rightbottomLauncher
      width: 14; height: 14
      anchors {
        bottom: parent.bottom
        right: parent.right
      }

      anchors.rightMargin: -12

      transform: Scale {
          origin.x: 7
          origin.y: 7
          yScale: -1
      }
      
      z: 1
      onPaint: {
          var ctx = getContext("2d")
          ctx.reset()
          ctx.fillStyle = Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixed
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
      id: rightbottomLauncher1
      width: 14; height: 14
      anchors {
        bottom: parent.bottom
        right: parent.right
      }

      anchors.rightMargin: -12

      transform: Scale {
          origin.x: 7
          origin.y: 7
          yScale: -1
      }
      
      z: 1
      onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        ctx.fillStyle = Colors.outlineVariant
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
  }
}

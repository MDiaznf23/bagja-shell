import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
  id: bottomBar
  anchors { bottom: true; left: true; right: true }
  implicitHeight: 15 
  color: "transparent"
  
  property bool isLaunching: false
  property bool isShowing: false

  Rectangle {
    anchors.fill: parent
    antialiasing: true
    layer.enabled: true
    
    gradient: Gradient {
      orientation: Gradient.Horizontal 
      GradientStop { position: 0.0; color: Colors.isDark ? Colors.overPrimaryFixed : Colors.primaryFixed }
      GradientStop { position: 0.2; color: Colors.isDark ? Colors.surface : Colors.surface  }
      GradientStop { position: 0.3; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.primaryFixed }
      GradientStop { position: 0.5; color: Colors.isDark ? Colors.surface : Colors.surface }
      GradientStop { position: 0.8; color: Colors.isDark ? Colors.overPrimaryFixed : Colors.primaryFixedDim  }
      GradientStop { position: 1.0; color: Colors.isDark ? Colors.overPrimaryFixed : Colors.primaryFixedDim }
    }
        
    Rectangle {
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right
      height: 2             
      border.width: 2 
      border.color: Colors.outlineVariant
      anchors.leftMargin: 13 
      anchors.rightMargin: 13
    }
  }

  MouseArea {
    id: hoverArea
    anchors.fill: parent
    hoverEnabled: true
    
    onEntered: {
      hideTimer.stop()
      closeDelayTimer.stop()
      isShowing = true
      appPopup.visible = true
    }
    
    onExited: {
      hideTimer.restart()
    }
  }

  Timer {
    id: hideTimer
    interval: 300
    onTriggered: {
      if (!popupHoverArea.containsMouse && !isLaunching) {
        isShowing = false
        closeDelayTimer.start()
      }
    }
  }
  
  Timer {
    id: closeDelayTimer
    interval: 200
    onTriggered: appPopup.visible = false
  }
  
  Timer {
    id: resetLaunchTimer
    interval: 600
    onTriggered: bottomBar.isLaunching = false
  }

  PopupWindow {
    id: appPopup
    visible: false

    anchor {
      window: bottomBar
      edges: Edges.Top
      rect: Qt.rect((bottomBar.width - implicitWidth) / 2 - implicitWidth / 2, -implicitHeight + 2, implicitWidth, 0)
    }

    implicitWidth: listContent.implicitWidth + 25 + 15
    implicitHeight: listContent.implicitHeight + 20
    color: "transparent"

    Item {
      id: popupContent
      anchors.fill: parent
      
      opacity: appPopup.visible ? 1 : 0
      
      Behavior on opacity {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
      }
      
      transform: Translate {
        y: isShowing ? 0 : 80
        Behavior on y {
          NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
      }

      MouseArea {
        id: popupHoverArea
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        
        onEntered: {
          hideTimer.stop()
          closeDelayTimer.stop()
        }
        
        onExited: {
          hideTimer.restart()
        }

        Item {
          anchors.fill: parent
          anchors.leftMargin: 10
          anchors.rightMargin: 10

          Connections {
            target: listAppsRect
            function onWStartChanged() {
              leftListApps.requestPaint()
              rightListApps.requestPaint()
            }
          }

          Rectangle {
            id: topPatch
            height: 4
            gradient: Gradient {
              orientation: Gradient.Horizontal
              GradientStop { position: 0.0;  color: listAppsRect.bottombarColorAt(listAppsRect.wStart) }
              GradientStop { position: (0.2 - listAppsRect.wStart) / (listAppsRect.wEnd - listAppsRect.wStart); color: listAppsRect.bottombarColorAt(0.2) }
              GradientStop { position: (0.3 - listAppsRect.wStart) / (listAppsRect.wEnd - listAppsRect.wStart); color: listAppsRect.bottombarColorAt(0.3) }
              GradientStop { position: (0.5 - listAppsRect.wStart) / (listAppsRect.wEnd - listAppsRect.wStart); color: listAppsRect.bottombarColorAt(0.5) }
              GradientStop { position: (0.8 - listAppsRect.wStart) / (listAppsRect.wEnd - listAppsRect.wStart); color: listAppsRect.bottombarColorAt(0.8) }
              GradientStop { position: 1.0;  color: listAppsRect.bottombarColorAt(listAppsRect.wEnd) }
            }
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            z: 10
          }

          Canvas {
            id: leftListApps
            width: 18
            height: 14
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: -10
            anchors.bottomMargin: -2
            z: 10

            transform: Scale { 
              origin.x: 9  
              origin.y: 7  
              xScale: -1   
            }

            onPaint: {
              var ctx = getContext("2d")
              ctx.reset()
              ctx.fillStyle = listAppsRect.bottombarColorAt(listAppsRect.wStart).toString()
              ctx.lineWidth = 2
              ctx.beginPath()
              ctx.moveTo(4, 0)
              ctx.lineTo(18, 0)
              ctx.arc(18, 0, 10, 0, Math.PI/2, true)
              ctx.lineTo(18, 10)
              ctx.lineTo(18, 12)
              ctx.lineTo(0, 12)
              ctx.lineTo(0, 0)
              
              ctx.closePath()
              ctx.fill()
            }
          }

          Canvas {
            id: leftListApps1
            width: 14
            height: 14
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: -12
            anchors.bottomMargin: -2
            z: 10

            transform: Scale { 
              origin.x: 7  
              origin.y: 7  
              xScale: -1   
            }

            onPaint: {
              var ctx = getContext("2d")
              ctx.reset()
              ctx.fillStyle = Colors.outlineVariant
              ctx.lineWidth = 2
              ctx.beginPath()
              ctx.moveTo(0, 0)
              ctx.lineTo(2, 0)
              ctx.arc(12, 0, 10, 0, Math.PI/2, true)
              ctx.lineTo(12, 10)
              ctx.lineTo(12, 12)
              ctx.arc(12, 0, 12, Math.PI/2, 0, false)          
              ctx.lineTo(0, 0)
              
              ctx.closePath()
              ctx.fill()
            }
          }

          Canvas {
            id: rightListApps
            width: 18
            height: 14
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: -10
            anchors.bottomMargin: -2
            z: 10

            onPaint: {
              var ctx = getContext("2d")
              ctx.reset()
              ctx.fillStyle = listAppsRect.bottombarColorAt(listAppsRect.wEnd).toString()
              ctx.lineWidth = 2
              ctx.beginPath()
              ctx.moveTo(4, 0)
              ctx.lineTo(18, 0)
              ctx.arc(18, 0, 10, 0, Math.PI/2, true)
              ctx.lineTo(18, 10)
              ctx.lineTo(18, 12)
              ctx.lineTo(0, 12)
              ctx.lineTo(0, 0)
              
              ctx.closePath()
              ctx.fill()
            }
          }

          Canvas {
            id: rightListApps1
            width: 14
            height: 14
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: -12
            anchors.bottomMargin: -2
            z: 10

            onPaint: {
              var ctx = getContext("2d")
              ctx.reset()
              ctx.fillStyle = Colors.outlineVariant
              ctx.lineWidth = 2
              ctx.beginPath()
              ctx.moveTo(0, 0)
              ctx.lineTo(2, 0)
              ctx.arc(12, 0, 10, 0, Math.PI/2, true)
              ctx.lineTo(12, 10)
              ctx.lineTo(12, 12)
              ctx.arc(12, 0, 12, Math.PI/2, 0, false)          
              ctx.lineTo(0, 0)
              
              ctx.closePath()
              ctx.fill()
            }
          }

          Rectangle {
            id: listAppsRect
            anchors.fill: parent

            property real screenWidth: 1366
            property real wStart: (screenWidth - width) / 2 / screenWidth
            property real wEnd: 1 - wStart

            function bottombarColorAt(p) {
              var stops = [
                  {pos: 0.0, color: Colors.isDark ? Colors.overPrimaryFixed : Colors.primaryFixed},
                  {pos: 0.2, color: Colors.isDark ? Colors.surface            : Colors.surface},
                  {pos: 0.3, color: Colors.isDark ? Colors.overSecondaryFixed : Colors.primaryFixed},
                  {pos: 0.5, color: Colors.isDark ? Colors.surface            : Colors.surface},
                  {pos: 0.8, color: Colors.isDark ? Colors.overPrimaryFixed : Colors.primaryFixedDim},
                  {pos: 1.0, color: Colors.isDark ? Colors.overPrimaryFixed : Colors.primaryFixedDim},
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
              orientation: Gradient.Horizontal
              GradientStop { position: 0.0;  color: listAppsRect.bottombarColorAt(listAppsRect.wStart) }
              GradientStop { position: (0.2 - listAppsRect.wStart) / (listAppsRect.wEnd - listAppsRect.wStart); color: listAppsRect.bottombarColorAt(0.2) }
              GradientStop { position: (0.3 - listAppsRect.wStart) / (listAppsRect.wEnd - listAppsRect.wStart); color: listAppsRect.bottombarColorAt(0.3) }
              GradientStop { position: (0.5 - listAppsRect.wStart) / (listAppsRect.wEnd - listAppsRect.wStart); color: listAppsRect.bottombarColorAt(0.5) }
              GradientStop { position: (0.8 - listAppsRect.wStart) / (listAppsRect.wEnd - listAppsRect.wStart); color: listAppsRect.bottombarColorAt(0.8) }
              GradientStop { position: 1.0;  color: listAppsRect.bottombarColorAt(listAppsRect.wEnd) }
            }
            radius: 10
            border.color: Colors.outlineVariant
            border.width: 2

            ListApps {
              id: listContent
              anchors.centerIn: parent
              
              onAppLaunched: {
                bottomBar.isLaunching = true
                resetLaunchTimer.restart()
              }
            }
          }
        }
      }
    }
  }
}

import QtQuick
import Quickshell
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects
import "."

PanelWindow {
  id: leftBar
  anchors { top: true; bottom: true; left: true }
  implicitWidth: 15
  color: "transparent"

  property bool isShowing: false
  property bool menuVisible: false
  property bool launcherVisible: false

  function closeMediaPopup() {
    mediaPopup.visible = false
  }

  Connections {
    target: leftBar
    function onMenuVisibleChanged() {
      if (menuVisible) mediaPopup.visible = false
    }
    function onLauncherVisibleChanged() {
      if (launcherVisible) mediaPopup.visible = false
    }
  } 

  Rectangle {
    anchors.fill: parent
    antialiasing: true
    layer.enabled: true
    
    gradient: Gradient {
      orientation: Gradient.Vertical
      GradientStop { position: 0.0; color: Colors.isDark ? Colors.surfaceDim : Colors.surface }
      GradientStop { position: 0.2; color: Colors.isDark ? Colors.surface : Colors.surface   }
      GradientStop { position: 0.3; color: Colors.isDark ? Colors.surface : Colors.surface  }
      GradientStop { position: 0.4; color: Colors.isDark ? Colors.surface : Colors.surface  }
      GradientStop { position: 0.46; color: Colors.isDark ? Colors.surface : Colors.surface  }
      GradientStop { position: 0.6; color: Colors.isDark ? Colors.overPrimaryFixed : Colors.primaryFixedDim  }
      GradientStop { position: 0.7; color: Colors.isDark ? Colors.overPrimaryFixed : Colors.primaryFixedDim  }
      GradientStop { position: 0.8; color: Colors.isDark ? Colors.surface : Colors.surface  }
      GradientStop { position: 0.9; color: Colors.isDark ? Colors.overPrimaryFixed : Colors.primaryFixed  }
      GradientStop { position: 1.0; color: Colors.isDark ? Colors.overPrimaryFixed : Colors.primaryFixed  }
    }

    Rectangle {
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      width: 2
      border.width: 2 
      border.color: Colors.outlineVariant
      anchors.topMargin: 13
      anchors.bottomMargin: 13
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
      if (!menuVisible && !launcherVisible)
        mediaPopup.visible = true
    }

    onExited: {
      hideTimer.restart()
    }
  }

  Timer {
    id: hideTimer
    interval: 200
    onTriggered: {
      if (!popupHoverArea.containsMouse && !mediaContent.showDropdown) {
        isShowing = false
        closeDelayTimer.start()
      }
    }
  }

  Timer {
    id: closeDelayTimer
    interval: 200
    onTriggered: {
      if (!mediaContent.showDropdown) {
        mediaPopup.visible = false
      }
    }
  }

  PopupWindow {
    id: mediaPopup
    visible: false
    implicitWidth: mediaContent.implicitWidth + 30
    implicitHeight: mediaContent.implicitHeight + 30 + 12
    color: "transparent"

    anchor {
      window: leftBar
      edges: Edges.Right
      rect: Qt.rect(
        -2, 
        (leftBar.height - implicitHeight) / 2 - (implicitHeight / 2), 
        leftBar.implicitWidth, 
        implicitHeight
      )
    }

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

    property real screenHeight: Quickshell.screens[0].height
    property real popupY: (screenHeight - mediaPopup.implicitHeight) / 2
    property real wStart: Math.max(0, popupY / screenHeight)
    property real wEnd: Math.min(1, (popupY + mediaPopup.implicitHeight) / screenHeight)

    Item {
      id: animatedContainer
      anchors.fill: parent
      anchors.topMargin: 12
      anchors.bottomMargin: 12

      opacity: mediaPopup.visible ? 1 : 0

      Behavior on opacity {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
      }

      Item {
        id: slideContent
        anchors.fill: parent

        transform: Translate {
          x: isShowing ? 0 : -200
          Behavior on x {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
          }
        }

        MouseArea {
          id: popupHoverArea
          anchors.fill: parent
          anchors.bottomMargin: -12
          hoverEnabled: true

          onEntered: {
            hideTimer.stop()
            closeDelayTimer.stop()
          }

          onExited: {
            if (!mediaContent.showDropdown) {
              hideTimer.restart()
            }
          }
        }

        Rectangle {
          anchors.fill: parent
          antialiasing: true
          layer.enabled: true

          gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0;   color: mediaPopup.leftbarColorAt(mediaPopup.wStart) }
            GradientStop { position: (0.2  - mediaPopup.wStart) / (mediaPopup.wEnd - mediaPopup.wStart); color: mediaPopup.leftbarColorAt(0.2) }
            GradientStop { position: (0.3  - mediaPopup.wStart) / (mediaPopup.wEnd - mediaPopup.wStart); color: mediaPopup.leftbarColorAt(0.3) }
            GradientStop { position: (0.4 - mediaPopup.wStart) / (mediaPopup.wEnd - mediaPopup.wStart); color: mediaPopup.leftbarColorAt(0.4) }
            GradientStop { position: (0.46 - mediaPopup.wStart) / (mediaPopup.wEnd - mediaPopup.wStart); color: mediaPopup.leftbarColorAt(0.46) }
            GradientStop { position: (0.6  - mediaPopup.wStart) / (mediaPopup.wEnd - mediaPopup.wStart); color: mediaPopup.leftbarColorAt(0.6) }
            GradientStop { position: (0.7  - mediaPopup.wStart) / (mediaPopup.wEnd - mediaPopup.wStart); color: mediaPopup.leftbarColorAt(0.7) }
            GradientStop { position: (0.8  - mediaPopup.wStart) / (mediaPopup.wEnd - mediaPopup.wStart); color: mediaPopup.leftbarColorAt(0.8) }
            GradientStop { position: (0.9  - mediaPopup.wStart) / (mediaPopup.wEnd - mediaPopup.wStart); color: mediaPopup.leftbarColorAt(0.9) }
            GradientStop { position: 1.0;   color: mediaPopup.leftbarColorAt(mediaPopup.wEnd) }
          }
          radius: 12
          border.color: Colors.outlineVariant
          border.width: 2
          clip: true

          Media {
            id: mediaContent
            anchors.centerIn: parent
          }
        }

        Rectangle {
          id: leftMedia
          height: parent.height
          width: 12
          antialiasing: true
          layer.enabled: true

          gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0;   color: mediaPopup.leftbarColorAt(mediaPopup.wStart) }
            GradientStop { position: (0.2  - mediaPopup.wStart) / (mediaPopup.wEnd - mediaPopup.wStart); color: mediaPopup.leftbarColorAt(0.2) }
            GradientStop { position: (0.3  - mediaPopup.wStart) / (mediaPopup.wEnd - mediaPopup.wStart); color: mediaPopup.leftbarColorAt(0.3) }
            GradientStop { position: (0.4 - mediaPopup.wStart) / (mediaPopup.wEnd - mediaPopup.wStart); color: mediaPopup.leftbarColorAt(0.4) }
            GradientStop { position: (0.46 - mediaPopup.wStart) / (mediaPopup.wEnd - mediaPopup.wStart); color: mediaPopup.leftbarColorAt(0.46) }
            GradientStop { position: (0.6  - mediaPopup.wStart) / (mediaPopup.wEnd - mediaPopup.wStart); color: mediaPopup.leftbarColorAt(0.6) }
            GradientStop { position: (0.7  - mediaPopup.wStart) / (mediaPopup.wEnd - mediaPopup.wStart); color: mediaPopup.leftbarColorAt(0.7) }
            GradientStop { position: (0.8  - mediaPopup.wStart) / (mediaPopup.wEnd - mediaPopup.wStart); color: mediaPopup.leftbarColorAt(0.8) }
            GradientStop { position: (0.9  - mediaPopup.wStart) / (mediaPopup.wEnd - mediaPopup.wStart); color: mediaPopup.leftbarColorAt(0.9) }
            GradientStop { position: 1.0;   color: mediaPopup.leftbarColorAt(mediaPopup.wEnd) }
          }
          anchors.top: parent.top
          anchors.left: parent.left
          z: 10
        }

        Canvas {
          id: bottomwingMedia
          width: 14
          height: 14
          anchors.bottom: parent.bottom
          anchors.left: parent.left
          anchors.leftMargin: -2
          anchors.bottomMargin: -12
          z: 10
          transform: Scale {
            origin.x: 7
            origin.y: 7
            xScale: -1
          }
          onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = Colors.isDark ? Colors.overSecondaryFixed : Colors.primaryFixedDim
            ctx.lineWidth = 2
            ctx.beginPath()
            ctx.moveTo(0, 0)
            ctx.lineTo(0, 2)
            ctx.arc(0, 12, 10, Math.PI/2, 0, false)
            ctx.lineTo(10, 12)
            ctx.lineTo(12, 12)
            ctx.lineTo(12, 0)
            ctx.lineTo(0, 0)
            ctx.closePath()
            ctx.fill()
          }
        }

        Canvas {
          id: bottomwingMedia1
          width: 14
          height: 14
          anchors.bottom: parent.bottom
          anchors.left: parent.left
          anchors.leftMargin: -2
          anchors.bottomMargin: -12
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
            ctx.lineTo(0, 2)
            ctx.arc(0, 12, 10, Math.PI/2, 0, false)
            ctx.lineTo(10, 12)
            ctx.lineTo(12, 12)
            ctx.arc(0, 12, 12, 0, Math.PI/2, true)
            ctx.lineTo(0, 0)
            ctx.closePath()
            ctx.fill()
          }
        }

        Canvas {
          id: topwingMedia
          width: 14
          height: 14
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.leftMargin: -2
          anchors.topMargin: -12
          z: 10
          transform: Scale {
            origin.x: 7
            origin.y: 7
            xScale: -1
            yScale: -1
          }
          onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = Colors.isDark ? Colors.surface : Colors.surface
            ctx.lineWidth = 2
            ctx.beginPath()
            ctx.moveTo(0, 0)
            ctx.lineTo(0, 2)
            ctx.arc(0, 12, 10, Math.PI/2, 0, false)
            ctx.lineTo(10, 12)
            ctx.lineTo(12, 12)
            ctx.lineTo(12, 0)
            ctx.lineTo(0, 0)
            ctx.closePath()
            ctx.fill()
          }
        }

        Canvas {
          id: topwingMedia1
          width: 14
          height: 14
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.leftMargin: -2
          anchors.topMargin: -12
          z: 10
          transform: Scale {
            origin.x: 7
            origin.y: 7
            xScale: -1
            yScale: -1
          }
          onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = Colors.outlineVariant
            ctx.lineWidth = 2
            ctx.beginPath()
            ctx.moveTo(0, 0)
            ctx.lineTo(0, 2)
            ctx.arc(0, 12, 10, Math.PI/2, 0, false)
            ctx.lineTo(10, 12)
            ctx.lineTo(12, 12)
            ctx.arc(0, 12, 12, 0, Math.PI/2, true)
            ctx.lineTo(0, 0)
            ctx.closePath()
            ctx.fill()
          }
        }
      }
    }
  }
}

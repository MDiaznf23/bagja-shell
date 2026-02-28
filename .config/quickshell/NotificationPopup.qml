import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
  id: notifWindow
  
  required property var notificationServer
  property real totalContentHeight: contentColumn.implicitHeight + 20
  
  property bool shouldAnimate: false
  property bool isHiding: false
  property bool isHovering: false
  property bool dndActive: false 
  
  anchors {
    top: true
    right: true
  }
  
  margins {
    top: 28
    right: 13 
  }
  
  property bool panelVisible: false
  visible: (notificationServer.notifications.length > 0 || isHiding) && !panelVisible && !dndActive
  
  implicitWidth: 300 + 14
  implicitHeight: Math.max(110, contentColumn.implicitHeight + 20) + 16 
  
  color: "transparent"
  
  exclusionMode: ExclusionMode.Ignore
  
  WlrLayershell.layer: WlrLayer.Top
  
  onVisibleChanged: {
    if (visible && notificationServer.notifications.length > 0) {
      isHiding = false
      shouldAnimate = false
      showTimer.start()
      autoDismissTimer.restart()
    } else if (!visible) {
      autoDismissTimer.stop()
      isHiding = false
      shouldAnimate = false
      isHovering = false
    }
  }
  
  Timer {
    id: showTimer
    interval: 50
    onTriggered: {
      shouldAnimate = true
    }
  }
  
  Timer {
    id: autoDismissTimer
    interval: 3000
    running: false
    onTriggered: {
      if (notificationServer.notifications.length > 0) {
        isHiding = true
        shouldAnimate = false
        clearTimer.start()
      }
    }
  }
  
  Timer {
    id: clearTimer
    interval: 350
    onTriggered: {
      notificationServer.clearAll()
      isHiding = false
    }
  }
  
  Connections {
    target: notificationServer
    function onNotificationsChanged() {
      if (notificationServer.notifications.length > 0) {
        if (isHiding) {
          clearTimer.stop()
          isHiding = false
          shouldAnimate = true
        }
        if (!isHovering) {
          autoDismissTimer.restart()
        }
      } else {
        isHiding = false
      }
    }
  }
  
  MouseArea {
    id: hoverArea
    anchors.fill: parent
    hoverEnabled: true
    propagateComposedEvents: true
    
    onContainsMouseChanged: {
      isHovering = containsMouse
      
      if (containsMouse) {
        if (autoDismissTimer.running) {
          autoDismissTimer.stop()
        }
      } else {
        if (notificationServer.notifications.length > 0 && !isHiding) {
          autoDismissTimer.restart()
        }
      }
    }
    
    onClicked: function(mouse) {
      mouse.accepted = false
    }
  }
  
  Rectangle {
    id: mainRect
    x: 14  
    y: shouldAnimate ? 0 : -(notifWindow.height + 50)
    width: 300
    height: notifWindow.height - 14
    border.width: 2
    border.color: Colors.outlineVariant 

    property real screenHeight: 768
    property real topMargin: 28  
    property real wStart: topMargin / screenHeight
    property real wEnd: (topMargin + height) / screenHeight

    function rightbarColorAt(p) {
        var stops = [
            {pos: 0.0,  color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim},
            {pos: 0.48, color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim},
            {pos: 0.6,  color: Colors.isDark ? Colors.surface            : Colors.surface},
            {pos: 0.87, color: Colors.isDark ? Colors.surface            : Colors.surface},
            {pos: 0.9,  color: Colors.isDark ? Colors.overPrimaryFixed : Colors.primaryFixed},
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
      GradientStop { position: 0.18; color: Colors.isDark ? Colors.surface : Colors.surface }
      GradientStop { position: 0.99; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim }
    }
    radius: 12
    
    opacity: shouldAnimate ? 1 : 0
    
    Behavior on y {
      NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }
    
    Behavior on opacity {
      NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
    
    Behavior on height {
      NumberAnimation { duration: 200 }
    }
    
    Column {
      id: contentColumn
      anchors {
        left: parent.left
        right: parent.right
        top: parent.top
        leftMargin: 12 
        rightMargin: 12 
        topMargin: 12
        bottomMargin: 12
      }
      spacing: 10
      
      Repeater {
        model: Math.min(notificationServer.notifications.length, 3)
        
        delegate: NotificationItem {
          required property int index
          
          width: contentColumn.width
          
          notification: notificationServer.notifications[index]
          
          onDismissClicked: {
            notificationServer.dismiss(notificationServer.notifications[index])
          }
        }
      }
    }
  }

  Rectangle {
    id: topPatch
    height: 10
    gradient: Gradient {
      orientation: Gradient.Horizontal 
      GradientStop { position: 0.18; color: Colors.isDark ? Colors.surface : Colors.surface }
      GradientStop { position: 0.99; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim }
    }
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: 16
    opacity: mainRect.opacity
  }

  Rectangle {
    id: rightPatch
    height: parent.height - 14
    width: 10 
    gradient: Gradient {
      orientation: Gradient.Vertical
      GradientStop { position: 0.0;   color: mainRect.rightbarColorAt(mainRect.wStart) }
      GradientStop { position: (0.48 - mainRect.wStart) / (mainRect.wEnd - mainRect.wStart); color: mainRect.rightbarColorAt(0.48) }
      GradientStop { position: (0.6  - mainRect.wStart) / (mainRect.wEnd - mainRect.wStart); color: mainRect.rightbarColorAt(0.6) }
      GradientStop { position: (0.87 - mainRect.wStart) / (mainRect.wEnd - mainRect.wStart); color: mainRect.rightbarColorAt(0.87) }
      GradientStop { position: 0.9;   color: mainRect.rightbarColorAt(mainRect.wEnd) }
    }
    anchors.top: parent.top
    anchors.right: parent.right
    opacity: mainRect.opacity
  }

  Canvas {
    id: leftWing
    width: 14
    height: 14
    anchors.top: parent.top
    anchors.right: parent.left
    anchors.rightMargin: -16
    z: 10
    opacity: mainRect.opacity
    
    onOpacityChanged: requestPaint()
    
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      ctx.fillStyle = Colors.isDark ? Colors.surface : Colors.surface
      ctx.globalAlpha = opacity
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
    width: 14
    height: 14
    anchors.top: parent.top
    anchors.right: parent.left
    anchors.rightMargin: -16
    z: 11
    opacity: mainRect.opacity
    
    onOpacityChanged: requestPaint()
    
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      ctx.fillStyle = Colors.outlineVariant
      ctx.globalAlpha = opacity
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

  Connections {
    target: Colors
    function onDChanged() { 
      rightWing.requestPaint() 
      rightWing1.requestPaint()
      leftWing.requestPaint()
      leftWing1.requestPaint()
    }
  }

  Connections {
    target: mainRect
    function onWEndChanged() { 
      rightWing.requestPaint() 
    }
  }

  Canvas {
    id: rightWing
    width: 14
    height: 14
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    anchors.bottomMargin: 2 
    z: 10
    opacity: mainRect.opacity
    
    onOpacityChanged: requestPaint()
    
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      ctx.fillStyle = mainRect.rightbarColorAt(mainRect.wEnd).toString()
      ctx.globalAlpha = opacity
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
    width: 14
    height: 14
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    anchors.bottomMargin: 2 
    z: 11
    opacity: mainRect.opacity
    
    onOpacityChanged: requestPaint()
    
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      ctx.fillStyle = Colors.outlineVariant
      ctx.globalAlpha = opacity
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

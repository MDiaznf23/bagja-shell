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

  property bool blockingPanelOpen: false
  property bool shiftDownPanelOpen: false 

  anchors {
    top: !shiftDownPanelOpen
    bottom: shiftDownPanelOpen
    right: true
  }
  
  margins {
    top: shiftDownPanelOpen ? 0 : 28
    bottom: shiftDownPanelOpen ? 13 : 0
    right: 13 
  }
  
  property bool panelVisible: false
  visible: (notificationServer.notifications.length > 0 || isHiding) && !dndActive && !blockingPanelOpen
  
  implicitWidth: 300 + 14
  implicitHeight: Math.max(110, contentColumn.implicitHeight + 25) + 14  
  
  color: "transparent"
  
  exclusionMode: ExclusionMode.Ignore
  
  WlrLayershell.layer: WlrLayer.Top

  onShiftDownPanelOpenChanged: {
    shouldAnimate = false
    showTimer.restart()
  }
  
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

  HoverHandler {
    id: hoverHandler
    onHoveredChanged: {
      notifWindow.isHovering = hovered
      if (hovered) {
        autoDismissTimer.stop()
      } else {
        if (notificationServer.notifications.length > 0 && !notifWindow.isHiding) {
          autoDismissTimer.restart()
        }
      }
    }
  }
  
  Rectangle {
    id: mainRect
    x: 14  
    y: shouldAnimate ? (shiftDownPanelOpen ? 14 : 0) : (shiftDownPanelOpen ? notifWindow.height : -(mainRect.height))
    width: 300
    height: contentColumn.implicitHeight + 25
    border.width: 2
    border.color: Colors.outline_variant 

    property real screenHeight: 768
    property real topMargin: 28  
    property real wStart: topMargin / screenHeight
    property real wEnd: (topMargin + height) / screenHeight

    function rightbarColorAt(p) {
        var stops = [
            {pos: 0.0,  color: Colors.rightbar_gradient1},
            {pos: 0.48, color: Colors.rightbar_gradient2},
            {pos: 0.6,  color: Colors.rightbar_gradient3},
            {pos: 0.87, color: Colors.rightbar_gradient4},
            {pos: 0.9,  color: Colors.rightbar_gradient5},
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
      GradientStop { position: 0.18; color: Colors.topbar_gradient5 }
      GradientStop { position: 0.99; color: Colors.topbar_gradient6 }
    }
    radius: 12
    
    opacity: shouldAnimate ? 1 : 0
    
    Behavior on y {
      enabled: notifWindow.shouldAnimate
      NumberAnimation { duration: 200; easing.type: Easing.InOutCubic }
    }
    
    Behavior on opacity {
      NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
    
    Behavior on height {
      enabled: !notifWindow.shiftDownPanelOpen
      NumberAnimation { duration: 200 }
    }
    
    Column {
      id: contentColumn
      anchors {
        left: parent.left
        right: parent.right
        leftMargin: 12
        rightMargin: 12
      }
      anchors.top: parent.top
      anchors.topMargin: 12

      spacing: 10

      states: State {
        name: "bottom"
        when: notifWindow.shiftDownPanelOpen
        AnchorChanges {
          target: contentColumn
          anchors.top: undefined
          anchors.bottom: mainRect.bottom
        }
        PropertyChanges {
          target: contentColumn
          anchors.topMargin: 0
          anchors.bottomMargin: 12
        }
      }
      
      Repeater {
        model: Math.min(notificationServer.notifications.length, 3)
        
        delegate: NotificationItem {
          id: delegateItem
          required property int index
          
          width: contentColumn.width 
          
          property var rawNotif: (index < notificationServer.notifications.length) ? notificationServer.notifications[index] : null
          notification: (rawNotif && rawNotif.appName !== undefined) ? rawNotif : null
          
          visible: notification !== null
          opacity: notification ? 1 : 0

          onDismissClicked: {
            notification.dismiss()
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
      GradientStop { position: 0.18; color: Colors.topbar_gradient5 }
      GradientStop { position: 0.99; color: Colors.topbar_gradient6 }
    }
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: 16
    opacity: mainRect.opacity

    states: State {
      name: "bottom"
      when: notifWindow.shiftDownPanelOpen
      AnchorChanges {
        target: topPatch
        anchors.top: undefined
        anchors.bottom: parent.bottom
      }
    }
    AnchorChanges {
      id: topPatchDefault
    }

    anchors.top: parent.top
  }

  Rectangle {
    id: rightPatch
    width: 10 
    height: parent.height - 14
    anchors.right: parent.right
    opacity: mainRect.opacity

    anchors.top: parent.top

    states: State {
      name: "bottom"
      when: notifWindow.shiftDownPanelOpen
      AnchorChanges {
        target: rightPatch
        anchors.top: undefined
        anchors.bottom: parent.bottom
      }
    }
    
    gradient: Gradient {
      orientation: Gradient.Vertical
      GradientStop { 
        position: 0.0
        color: mainRect.rightbarColorAt(notifWindow.shiftDownPanelOpen ? mainRect.wEnd : mainRect.wStart) 
      }
      GradientStop { 
        position: Math.abs((0.48 - (notifWindow.shiftDownPanelOpen ? mainRect.wEnd : mainRect.wStart)) / (mainRect.wEnd - mainRect.wStart))
        color: mainRect.rightbarColorAt(0.48) 
      }
      GradientStop { 
        position: Math.abs((0.6 - (notifWindow.shiftDownPanelOpen ? mainRect.wEnd : mainRect.wStart)) / (mainRect.wEnd - mainRect.wStart))
        color: mainRect.rightbarColorAt(0.6) 
      }
      GradientStop { 
        position: Math.abs((0.87 - (notifWindow.shiftDownPanelOpen ? mainRect.wEnd : mainRect.wStart)) / (mainRect.wEnd - mainRect.wStart))
        color: mainRect.rightbarColorAt(0.87) 
      }
      GradientStop { 
        position: 1.0
        color: mainRect.rightbarColorAt(notifWindow.shiftDownPanelOpen ? mainRect.wStart : mainRect.wEnd) 
      }
    }
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
    visible: !shiftDownPanelOpen
    
    onOpacityChanged: requestPaint()
    
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      ctx.fillStyle = Colors.topbar_gradient5
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
    visible: !shiftDownPanelOpen
    
    onOpacityChanged: requestPaint()
    
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      ctx.fillStyle = Colors.outline_variant
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
    id: leftbottom
    width: 14; height: 14
    anchors {
      bottom: parent.bottom
      left: parent.left
    }
    anchors.bottomMargin: 0
    anchors.leftMargin: 2
    opacity: mainRect.opacity
    visible: shiftDownPanelOpen
    onOpacityChanged: requestPaint()
    transform: Scale {
      origin.x: 7
      origin.y: 7
      yScale: -1
      xScale: -1
    }
    z: 1
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      ctx.fillStyle = Colors.bottombar_gradient5
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

  Canvas  {
    id: leftbottom1
    width: 14; height: 14
    anchors {
      bottom: parent.bottom
      left: parent.left
    }
    anchors.bottomMargin: 0
    anchors.leftMargin: 2
    opacity: mainRect.opacity
    visible: shiftDownPanelOpen
    onOpacityChanged: requestPaint()
    transform: Scale {
      origin.x: 7
      origin.y: 7
      yScale: -1
      xScale: -1
    }
    z: 1
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
    id: rightTop
    width: 14; height: 14
    anchors {
      top: parent.top
      right: parent.right
    }
    visible: shiftDownPanelOpen
    opacity: mainRect.opacity
    onOpacityChanged: requestPaint()
    anchors.topMargin: 2
    transform: Scale {
      origin.x: 7
      origin.y: 7
      yScale: -1
      xScale: -1
    }
    z: 10
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      ctx.fillStyle = mainRect.rightbarColorAt(mainRect.wStart).toString()
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
    id: rightTop1
    width: 14; height: 14
    anchors {
      top: parent.top
      right: parent.right
    }
    visible: shiftDownPanelOpen
    opacity: mainRect.opacity
    onOpacityChanged: requestPaint()
    anchors.topMargin: 2
    transform: Scale {
      origin.x: 7
      origin.y: 7
      yScale: -1
      xScale: -1
    }
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
    id: rightWing
    width: 14
    height: 14
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    anchors.bottomMargin: 2 
    z: 10
    opacity: mainRect.opacity
    visible: !shiftDownPanelOpen
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
    visible: !shiftDownPanelOpen
    onOpacityChanged: requestPaint()
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      ctx.fillStyle = Colors.outline_variant
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

import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

PanelWindow {
  id: wallpaperPicker
  property var screen: Quickshell.screens[0]
  property bool isShowing: false
    
  visible: true
  implicitWidth: 160
  implicitHeight: 524
  color: "transparent"
  
  anchors {
    right: true
    top: true
  }
  
  margins {
    right: -2
    top: (screen.height - height) / 2 - 30
  }
  
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

  onVisibleChanged: {
    if (visible) {
      isShowing = true
      wallpaperList.forceActiveFocus()
      if (wallpaperModel.count === 0) {
        thumbGenProcess.running = true
      }
    }
  }

  signal requestClose()

  Process {
    id: setWallpaperProcess
    running: false
  }

  property int lastFileCount: 0

  Process {
    id: watcherProcess
    command: ["bash", "-c", 
      "inotifywait -m -e create,delete,moved_to,moved_from '" + 
      Quickshell.env("HOME") + "/Pictures/Wallpapers' --format '%e %f' 2>/dev/null"]
    running: true
    stdout: SplitParser {
      onRead: data => {
        thumbAndAppendProcess.running = true
      }
    }
  }

  Process {
    id: thumbAndAppendProcess
    command: ["bash", Quickshell.shellDir + "/scripts/generate-thumbs.sh"]
    running: false
    onRunningChanged: {
      if (!running) appendNewProcess.running = true
    }
  }

  Process {
    id: appendNewProcess
    command: ["bash", "-c",
      "find " + Quickshell.env("HOME") + "/Pictures/Wallpapers -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) | sort | while read f; do thumb=\"/tmp/wallpaper-thumbs/$(basename \"$f\").jpg\"; echo \"$thumb|$f\"; done"]
    running: false
    stdout: SplitParser {
      onRead: data => {
        var parts = data.trim().split("|")
        if (parts.length !== 2 || parts[0] === "" || parts[1] === "") return
        for (var i = 0; i < wallpaperModel.count; i++) {
          if (wallpaperModel.get(i).wallpath === parts[1]) return
        }
        // sort alphabet
        var insertAt = wallpaperModel.count
        for (var j = 0; j < wallpaperModel.count; j++) {
          if (parts[1] < wallpaperModel.get(j).wallpath) {
            insertAt = j
            break
          }
        }
        wallpaperModel.insert(insertAt, { thumbpath: parts[0], wallpath: parts[1] })
      }
    }
  }

  Process {
    id: thumbGenProcess
    command: ["bash", Quickshell.shellDir + "/scripts/generate-thumbs.sh"]
    running: true
    onRunningChanged: {
      if (!running) scanProcess.running = true
    }
  }

  Process {
    id: scanProcess
    command: ["bash", "-c",
    "find " + Quickshell.env("HOME") + "/Pictures/Wallpapers -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) | sort | while read f; do thumb=\"/tmp/wallpaper-thumbs/$(basename \"$f\").jpg\"; echo \"$thumb|$f\"; done"]
    running: false
    stdout: SplitParser {
      onRead: data => {
        var parts = data.trim().split("|")
        if (parts.length === 2 && parts[0] !== "" && parts[1] !== "") {
          wallpaperModel.append({ thumbpath: parts[0], wallpath: parts[1] })
        }
      }
    }
  }

  Item {
    anchors.fill: parent
    anchors.bottomMargin: 12
    anchors.topMargin: 12
    
    opacity: wallpaperPicker.visible ? 1 : 0
    
    Behavior on opacity {
      NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }
    
    Item {
      id: slideContent
      anchors.fill: parent
      
      transform: Translate {
        x: isShowing ? 0 : 200
        Behavior on x {
          NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
      }

      Rectangle {
        id: mainRect
        anchors.fill: parent
        
        gradient: Gradient {
          orientation: Gradient.Vertical 
          GradientStop { position: 0.08; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim }
          GradientStop { position: 0.52; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim }
          GradientStop { position: 0.67; color: Colors.isDark ? Colors.surface : Colors.surface  }
          GradientStop { position: 0.99; color: Colors.isDark ? Colors.surface : Colors.surface  }
        }
        radius: 12
        border.color: Colors.outlineVariant
        border.width: 2 

        Column {
          anchors.fill: parent
          anchors.margins: 10
          clip: true

          ListView {
            id: wallpaperList
            width: parent.width
            height: parent.height
            clip: true
            focus: true
            keyNavigationEnabled: true
            keyNavigationWraps: true
            highlightMoveDuration: 80
            spacing: 5
            highlightRangeMode: ListView.StrictlyEnforceRange
            preferredHighlightBegin: 0
            preferredHighlightEnd: height

            model: ListModel {
              id: wallpaperModel
            }

            populate: Transition {
              NumberAnimation {
                properties: "opacity"
                from: 0
                to: 1
                duration: 200
              }
            }

            delegate: Item {
              width: wallpaperList.width
              height: 90
              property bool pressed: false

              Rectangle {
                id: delegateRect
                anchors.fill: parent
                anchors.margins: wallpaperList.currentIndex === index ? 0 : 5

                Behavior on anchors.margins {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }
                color: wallpaperList.currentIndex === index ? Colors.surfaceContainer : Colors.surface
                radius: 8
                border.color: wallpaperList.currentIndex === index ? Colors.outline : Colors.outlineVariant
                border.width: wallpaperList.currentIndex === index ? 3 : 2
 
                transform: Translate {
                  y: delegateRect.parent.pressed ? 4 : 0
                  Behavior on y { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
                }

                Image {
                  id: thumbImage
                  anchors.fill: parent
                  anchors.margins: 2
                  source: "file://" + model.thumbpath
                  fillMode: Image.PreserveAspectCrop
                  smooth: true
                  asynchronous: true
                  visible: false

                  opacity: status === Image.Ready ? 1 : 0
                }

                Item {
                  id: maskItem
                  anchors.fill: thumbImage
                  layer.enabled: true
                  visible: false
                  Rectangle {
                    anchors.fill: parent
                    radius: 7
                    color: "black"
                  }
                }

                MultiEffect {
                  anchors.fill: thumbImage
                  source: thumbImage
                  maskEnabled: true
                  maskSource: maskItem

                  opacity: thumbImage.opacity
                  Behavior on opacity {
                    NumberAnimation { duration: 100 }
                  }
                }
              }
            }  

            Keys.onReturnPressed: {
              var item = wallpaperModel.get(currentIndex)
              if (item) {
                var delegate = wallpaperList.itemAtIndex(currentIndex)
                if (delegate) {
                  delegate.pressed = true
                  pressResetTimer.delegate = delegate
                  pressResetTimer.start()
                }
                var cmd = "m3wal '" + item.wallpath + "'"
                setWallpaperProcess.command = ["bash", "-c", cmd]
                setWallpaperProcess.running = true
              }
            }

            Timer {
              id: pressResetTimer
              interval: 200
              property var delegate: null
              onTriggered: if (delegate) delegate.pressed = false
            }

            Keys.onEscapePressed: {
              wallpaperPicker.requestClose()
            }
          }
        }

        Connections {
          target: Colors
          function onDChanged() {
            bottomwingWallpaper.requestPaint()
            bottomwingWallpaper1.requestPaint()
            topwingWallpaper.requestPaint()
            topwingWallpaper1.requestPaint()
          }
        }

        Rectangle {
          id: leftWallpaper
          height: 500
          width: 10
          gradient: Gradient {
            orientation: Gradient.Vertical 
            GradientStop { position: 0.08; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim}
            GradientStop { position: 0.52; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim}
            GradientStop { position: 0.67; color: Colors.isDark ? Colors.surface : Colors.surface  }
            GradientStop { position: 0.99; color: Colors.isDark ? Colors.surface : Colors.surface  }
          }
          anchors.top: parent.top
          anchors.right: parent.right
          z: 10
        }

        Canvas {
          id: bottomwingWallpaper
          width: 14
          height: 14
          anchors.bottom: parent.bottom
          anchors.right: parent.right
          anchors.rightMargin: -2
          anchors.bottomMargin: -12
          z: 10
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
          id: bottomwingWallpaper1
          width: 14
          height: 14
          anchors.bottom: parent.bottom
          anchors.right: parent.right
          anchors.rightMargin: -2
          anchors.bottomMargin: -12
          z: 10
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
          id: topwingWallpaper
          width: 14
          height: 14
          anchors.top: parent.top
          anchors.right: parent.right
          anchors.rightMargin: -2
          anchors.topMargin: -12
          z: 10
          transform: Scale {
            origin.x: 7
            origin.y: 7
            yScale: -1
          }
          onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim 
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
          id: topwingWallpaper1
          width: 14
          height: 14
          anchors.top: parent.top
          anchors.right: parent.right
          anchors.rightMargin: -2
          anchors.topMargin: -12
          z: 10
          transform: Scale {
            origin.x: 7
            origin.y: 7
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

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
      "inotifywait -m -e create,moved_to,delete,moved_from '" +
      Quickshell.env("HOME") + "/Pictures/Wallpapers' --format '%e %f' 2>/dev/null"]
    running: true
    stdout: SplitParser {
      onRead: data => {
        var parts = data.trim().split(" ")
        if (parts.length < 2) return
        var event = parts[0]
        var filename = parts.slice(1).join(" ")  
        var fullpath = Quickshell.env("HOME") + "/Pictures/Wallpapers/" + filename

        if (event === "DELETE" || event === "MOVED_FROM") {
          // Langsung remove dari model
          for (var i = 0; i < wallpaperModel.count; i++) {
            if (wallpaperModel.get(i).wallpath === fullpath) {
              wallpaperModel.remove(i)
              break
            }
          }
        } else if (event === "CREATE" || event === "MOVED_TO") {
          watcherDebounce.restart()
        }
      }
    }
  }

  Timer {
    id: watcherDebounce
    interval: 1500
    onTriggered: {
      watcherThumbProcess.running = false
      watcherThumbProcess.running = true
    }
  }

  Process {
    id: watcherThumbProcess
    command: ["bash", Quickshell.shellDir + "/scripts/generate-thumbs.sh"]
    running: false
    stdout: SplitParser {
      onRead: data => {
        var parts = data.trim().split("|")
        if (parts.length !== 2 || parts[0] === "" || parts[1] === "") return

        for (var i = 0; i < wallpaperModel.count; i++) {
          if (wallpaperModel.get(i).wallpath === parts[1]) {
            wallpaperModel.setProperty(i, "isLoading", false)
            return
          }
        }

        var insertAt = wallpaperModel.count
        for (var j = 0; j < wallpaperModel.count; j++) {
          if (parts[1] < wallpaperModel.get(j).wallpath) {
            insertAt = j
            break
          }
        }
        wallpaperModel.insert(insertAt, { 
          thumbpath: parts[0] + "?t=" + Date.now(),
          wallpath: parts[1], 
          isLoading: false 
        })
      }
    }
  } 

  Process {
    id: thumbGenProcess
    command: ["bash", Quickshell.shellDir + "/scripts/generate-thumbs.sh"]
    running: false
    stdout: SplitParser {
      onRead: data => {
        // Sama persis dengan watcherThumbProcess
        var parts = data.trim().split("|")
        if (parts.length !== 2 || parts[0] === "" || parts[1] === "") return
        var insertAt = wallpaperModel.count
        for (var j = 0; j < wallpaperModel.count; j++) {
          if (parts[1] < wallpaperModel.get(j).wallpath) {
            insertAt = j
            break
          }
        }
        wallpaperModel.insert(insertAt, { thumbpath: parts[0], wallpath: parts[1], isLoading: false })
      }
    }
    onRunningChanged: {
      if (!running) scanProcess.running = true
    }
  }

  Process {
    id: scanProcess
    command: ["bash", "-c",
    "find " + Quickshell.env("HOME") + "/Pictures/Wallpapers -maxdepth 1 -type f " +
    "\\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \\) | sort | " +
    "while read f; do " +
    "  base=$(basename \"$f\" | sed 's/\\.[^.]*$//'); " +
    "  thumb=\"/tmp/wallpaper-thumbs/$base.jpg\"; " +
    "  [ -f \"$thumb\" ] && echo \"$thumb|$f\"; " + 
    "done"]
    running: false
    stdout: SplitParser {
      onRead: data => {
        var parts = data.trim().split("|")
        if (parts.length !== 2 || parts[0] === "" || parts[1] === "") return

        for (var i = 0; i < wallpaperModel.count; i++) {
          if (wallpaperModel.get(i).wallpath === parts[1]) return
        }

        wallpaperModel.append({ thumbpath: parts[0], wallpath: parts[1], isLoading: false })
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
          GradientStop { position: 0.08; color: Colors.rightbar_gradient1 }
          GradientStop { position: 0.52; color: Colors.rightbar_gradient2 }
          GradientStop { position: 0.67; color: Colors.rightbar_gradient3  }
          GradientStop { position: 0.99; color: Colors.rightbar_gradient4  }
        }
        radius: 12
        border.color: Colors.outline_variant
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
              property bool isGif: model.wallpath.toLowerCase().endsWith(".gif")
              property bool isActive: wallpaperList.currentIndex === index
              property bool useGif: isGif && isActive && gifImage.status === Image.Ready

              Rectangle {
                id: delegateRect
                anchors.fill: parent
                anchors.margins: isActive ? 0 : 5

                Behavior on anchors.margins {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }
                color: isActive ? Colors.wallpaper_item_active_bg : Colors.wallpaper_item_inactive_bg
                radius: 8
                border.color: isActive ? Colors.wallpaper_item_active_border : Colors.wallpaper_item_inactive_border
                border.width: isActive ? 3 : 2

                transform: Translate {
                  y: delegateRect.parent.pressed ? 4 : 0
                  Behavior on y { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
                }

                Image {
                  id: thumbImage
                  anchors.fill: parent
                  anchors.margins: 2
                  source: (isGif && isActive) ? "" : "file://" + model.thumbpath
                  fillMode: Image.PreserveAspectCrop
                  smooth: true
                  asynchronous: true
                  visible: false
                  opacity: status === Image.Ready ? 1 : 0

                  onStatusChanged: {
                    if (status === Image.Error) {
                      var base = model.thumbpath.split("?")[0]
                      wallpaperModel.setProperty(index, "thumbpath", base + "?t=" + Date.now())
                    }
                  }
                }

                AnimatedImage {
                  id: gifImage
                  anchors.fill: parent
                  anchors.margins: 2
                  source: (isGif && isActive) ? "file://" + model.wallpath : ""
                  fillMode: Image.PreserveAspectCrop
                  smooth: true
                  asynchronous: true
                  visible: false
                  playing: isGif && isActive
                  cache: false
                  sourceSize: Qt.size(130, 90)
                  opacity: status === Image.Ready ? 1 : 0
                }

                Item {
                  id: maskItem
                  anchors.fill: useGif ? gifImage : thumbImage
                  layer.enabled: true
                  visible: false
                  Rectangle {
                    anchors.fill: parent
                    radius: 7
                    color: "black"
                  }
                }

                MultiEffect {
                  anchors.fill: useGif ? gifImage : thumbImage
                  source: useGif ? gifImage : thumbImage
                  maskEnabled: true
                  maskSource: maskItem

                  opacity: useGif ? gifImage.opacity : thumbImage.opacity
                  Behavior on opacity {
                    NumberAnimation { duration: 100 }
                  }
                }

                Rectangle {
                  id: loadingPlaceholder
                  anchors.fill: parent
                  anchors.margins: 2
                  radius: 7
                  color: Colors.wallpaper_placeholder_bg
                  visible: useGif ? gifImage.status !== Image.Ready : thumbImage.status !== Image.Ready
                  property real shimmerPos: 0.0

                  SequentialAnimation on shimmerPos {
                    loops: Animation.Infinite
                    running: loadingPlaceholder.visible
                    NumberAnimation { from: -0.5; to: 1.5; duration: 1200 }
                  }

                  Rectangle {
                    anchors.fill: parent
                    radius: 7
                    gradient: Gradient {
                      orientation: Gradient.Horizontal
                      GradientStop { position: 0.0; color: "transparent" }
                      GradientStop { position: Math.max(0, Math.min(1, loadingPlaceholder.shimmerPos)); color: Qt.rgba(1,1,1,0.08) }
                      GradientStop { position: 1.0; color: "transparent" }
                    }
                  }

                  Text {
                    anchors.centerIn: parent
                    text: "🖼"
                    font.pixelSize: 18
                    opacity: 0.3
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
                var cmd = StateGlobals.colorEngine + " '" + item.wallpath + "'"
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
            GradientStop { position: 0.08; color: Colors.rightbar_gradient1 }
            GradientStop { position: 0.52; color: Colors.rightbar_gradient2 }
            GradientStop { position: 0.67; color: Colors.rightbar_gradient3 }
            GradientStop { position: 0.99; color: Colors.rightbar_gradient4 }
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
            ctx.fillStyle = Colors.rightbar_gradient3 
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
            ctx.fillStyle = Colors.outline_variant
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
            ctx.fillStyle = Colors.rightbar_gradient2 
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
            ctx.fillStyle = Colors.outline_variant
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

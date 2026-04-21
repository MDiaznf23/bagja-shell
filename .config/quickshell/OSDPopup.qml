import QtQuick
import QtQuick.Controls 
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
  id: osdPopup
  
  anchors {
    bottom: true
    right: true
  }
  
  margins {
    bottom: 5   
    right: 2
  }
    
  implicitWidth: 130
  implicitHeight: 275
    
  color: "transparent"
  
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
  
  exclusionMode: ExclusionMode.Ignore
  property bool isShowing: false
  
  signal requestClose()  
    
  Timer {
    id: hideTimer
    interval: 3000
    onTriggered: {
      isShowing = false
      closeDelayTimer.start()
    }  
  }

  Timer {
    id: closeDelayTimer
    interval: 300
    onTriggered: requestClose()
  }
    
  Process {
    id: getVolumeProc
    command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf \"%.0f\", $2 * 100}'"]
    running: false
    
    stdout: StdioCollector {
      onStreamFinished: {
        let vol = parseInt(this.text.trim())
        if (!isNaN(vol)) {
            volumeSlider.value = vol
        }
      }
    }
  }
    
  Process {
    id: getBrightnessProc
    command: ["bash", "-c", "brightnessctl get | awk -v max=$(brightnessctl max) '{print int($1*100/max)}'"]
    running: false
    
    stdout: StdioCollector {
      onStreamFinished: {
        let bright = parseInt(this.text.trim())
        if (!isNaN(bright)) {
          brightnessSlider.value = bright
        }
      }
    }
  }
    
  Rectangle {
    anchors.centerIn: parent
    width: 110
    height: 260
    gradient: Gradient {
      orientation: Gradient.Vertical
      GradientStop { position: 0.67; color: Colors.rightbar_gradient4 }
      GradientStop { position: 0.78; color: Colors.rightbar_gradient5 }
    } 
    radius: 12
    border.color: Colors.outline_variant
    border.width: 2

    transform: Translate {
      y: isShowing ? 0 : 300
      Behavior on y {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
      }
    }
      
    RowLayout {
      anchors.fill: parent
      anchors.rightMargin: 0
      anchors.topMargin: 12
      anchors.bottomMargin: 12 
      anchors.leftMargin: 12
      spacing: 0
      
      // --- VOLUME SLIDER ---
      ColumnLayout {
        Layout.fillHeight: true
        Layout.fillWidth: true
        spacing: 10
        
        Rectangle {
          Layout.alignment: Qt.AlignHCenter
          width: 36
          height: 36
          color: "transparent"

          Text {
            anchors.centerIn: parent
            text: ""
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 18
            color: Colors.osd_icon 
          }
        }
          
        Slider {
          id: volumeSlider
          Layout.fillHeight: true
          Layout.preferredWidth: 40
          Layout.alignment: Qt.AlignHCenter
          orientation: Qt.Vertical
              
          from: 0
          to: 100
          value: 50
          
          onMoved: {
            let vol = value / 100.0
            setVolumeProcess.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", vol.toFixed(2)]
            setVolumeProcess.running = true
            hideTimer.restart()
          }
                  
          background: Rectangle {
            x: volumeSlider.leftPadding + volumeSlider.availableWidth / 2 - width / 2
            y: volumeSlider.topPadding
            width: 4
            height: volumeSlider.availableHeight
            radius: 2
            color: Colors.osd_slider_track_bg
            
            Rectangle {
              y: parent.height * (1 - volumeSlider.position)
              width: parent.width
              height: parent.height * volumeSlider.position
              color: Colors.osd_slider_track_fill
              radius: 2
            }
          }
                  
          handle: Rectangle {
            x: volumeSlider.leftPadding + volumeSlider.availableWidth / 2 - width / 2
            y: volumeSlider.topPadding + volumeSlider.availableHeight * (1 - volumeSlider.position) - height / 2
            width: 16
            height: 16
            radius: 8
            color: Colors.osd_slider_handle
            border.color: "transparent"
            border.width: 2
          }
        }
              
        Text {
          text: Math.round(volumeSlider.value) + "%"
          font.pixelSize: 12
          font.bold: true
          color: Colors.osd_value_text
          Layout.alignment: Qt.AlignHCenter
        }
      }
          

      ColumnLayout {
        Layout.fillHeight: true
        Layout.fillWidth: true
        spacing: 10
              
        Rectangle {
          Layout.alignment: Qt.AlignHCenter
          width: 36
          height: 36
          color: "transparent"

          Text {
            anchors.centerIn: parent
            text: ""
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 18
            color: Colors.osd_brightness_icon
          }
        }
              
        Slider {
          id: brightnessSlider
          Layout.fillHeight: true
          Layout.preferredWidth: 40
          Layout.alignment: Qt.AlignHCenter
          orientation: Qt.Vertical
              
          from: 0
          to: 100
          value: 50
            
          onMoved: {
            setBrightnessProcess.command = ["brightnessctl", "s", Math.round(value) + "%"]
            setBrightnessProcess.running = true
            hideTimer.restart()
          }
                  
          background: Rectangle {
            x: brightnessSlider.leftPadding + brightnessSlider.availableWidth / 2 - width / 2
            y: brightnessSlider.topPadding
            width: 4
            height: brightnessSlider.availableHeight
            radius: 2
            color: Colors.osd_brightness_slider_track_bg
            
            Rectangle {
              y: parent.height * (1 - brightnessSlider.position)
              width: parent.width
              height: parent.height * brightnessSlider.position
              color: Colors.osd_brightness_slider_track_fill
              radius: 2
            }
          }
                  
          handle: Rectangle {
            x: brightnessSlider.leftPadding + brightnessSlider.availableWidth / 2 - width / 2
            y: brightnessSlider.topPadding + brightnessSlider.availableHeight * (1 - brightnessSlider.position) - height / 2
            width: 16
            height: 16
            radius: 8
            color: Colors.osd_brightness_slider_handle
            border.color: "transparent"
            border.width: 2
          }
        }
              
        Text {
          text: Math.round(brightnessSlider.value) + "%"
          font.pixelSize: 12
          font.bold: true
          color: Colors.osd_brightness_value_text 
          Layout.alignment: Qt.AlignHCenter
        }
      }
    }

    Rectangle {
      anchors {
        top: parent.top
        right: parent.right
      }
      z: 1
      width: 12; 
      height: parent.height; 
      gradient: Gradient {
        orientation: Gradient.Vertical
        GradientStop { position: 0.67; color: Colors.rightbar_gradient4 }
        GradientStop { position: 0.78; color: Colors.rightbar_gradient5 }
      } 
    }

    Rectangle {
      anchors {
        bottom: parent.bottom
        right: parent.right
      }
      z: 1
      width: parent.width; 
      height: 12; 
      color: Colors.bottombar_gradient6
    }

    Canvas {
      id: righttopOSD
      width: 14; height: 14
      anchors {
        top: parent.top
        right: parent.right
      }

      anchors.topMargin: -12

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
        ctx.fillStyle = Colors.rightbar_gradient4
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
    id: righttopOSD1
    width: 14; height: 14
    anchors {
      top: parent.top
      right: parent.right
    }

    anchors.topMargin: -12

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
    id: leftbottomOSD
    width: 14; height: 14
    anchors {
      bottom: parent.bottom
      left: parent.left
    }

    anchors.bottomMargin: 1
    anchors.leftMargin: -12

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

    Canvas {
      id: leftbottomOSD1
      width: 14; height: 14
      anchors {
        bottom: parent.bottom
        left: parent.left
      }

      anchors.bottomMargin: 1
      anchors.leftMargin: -12

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
  }
    
  Process {
    id: setVolumeProcess
    running: false
  }
    
  Process {
    id: setBrightnessProcess
    running: false
  }

  function restartTimer() {
    hideTimer.restart()
    getVolumeProc.running = true
    getBrightnessProc.running = true
  }
  
  onVisibleChanged: {
    if (visible) {
      isShowing = true
      getVolumeProc.running = true
      getBrightnessProc.running = true
      hideTimer.restart()
    }
  }
} 

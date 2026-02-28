import QtQuick
import Quickshell
import Quickshell.Io

Item {
  implicitWidth: 190
  implicitHeight: 80

  property string ssid: "..."
  property string signal: "..."
  property string security: "..."

  property real tooltipStart: 0.0
  property real tooltipEnd: 1.0

  function topbarColorAt(p) {
    // stops topbar
    var stops = [
      {pos: 0.0, color: Colors.isDark ? Colors.surfaceDim        : Colors.surface},
      {pos: 0.2, color: Colors.isDark ? Colors.overSecondaryFixed : Colors.primaryFixed},
      {pos: 0.4, color: Colors.isDark ? Colors.surface            : Colors.surface},
      {pos: 0.6, color: Colors.isDark ? Colors.overPrimaryFixed : Colors.primaryFixed},
      {pos: 0.8, color: Colors.isDark ? Colors.surface            : Colors.surface},
      {pos: 1.0, color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim},
    ]
    if (!Colors.surface) return "#000000"
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


  Process {
    command: ["bash", Quickshell.shellDir + "/scripts/connected_wifi.sh"]
    running: true
    stdout: SplitParser {
      onRead: (data) => {
        try {
          var res = JSON.parse(data)
          if (res.length > 0) {
            ssid = res[0].ssid
            signal = res[0].signal + "%"
            security = res[0].security
          }
        } 
        catch (e) {
          console.log("Wifi JSON Error: " + e)
        }
      }
    }
  }

  Rectangle {
    anchors.fill: parent
    antialiasing: true
    layer.enabled: true
    
    gradient: Gradient {
      orientation: Gradient.Horizontal
      GradientStop { position: 0.0; color: topbarColorAt(tooltipStart) ?? Colors.surface }
      GradientStop { position: (0.2 - tooltipStart) / (tooltipEnd - tooltipStart); color: topbarColorAt(0.2) ?? Colors.surface }
      GradientStop { position: (0.4 - tooltipStart) / (tooltipEnd - tooltipStart); color: topbarColorAt(0.4) ?? Colors.surface }
      GradientStop { position: (0.6 - tooltipStart) / (tooltipEnd - tooltipStart); color: topbarColorAt(0.6) ?? Colors.surface }
      GradientStop { position: (0.8 - tooltipStart) / (tooltipEnd - tooltipStart); color: topbarColorAt(0.8) ?? Colors.surface }
      GradientStop { position: 1.0; color: topbarColorAt(tooltipEnd) ?? Colors.surface }
    }
    radius: 10
    border.width: 2
    border.color: Colors.outlineVariant

    Column {
      anchors.centerIn: parent
      width: parent.width - 20
      spacing: 4

      Text {
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: "Connected to " + ssid
        color: Colors.overSurface
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12
        font.bold: true
      }
      Text {
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: "Signal Strength: " + signal
        color: Colors.overSurfaceVariant
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12
      }
      Text {
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: "Security: " + security
        color: Colors.overSurface
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12
      }
    }
  }

  Rectangle {
    id: topPatch
    height: 10
    antialiasing: true
    layer.enabled: true
    
    gradient: Gradient {
      orientation: Gradient.Horizontal
      GradientStop { position: 0.0; color: topbarColorAt(tooltipStart) ?? Colors.surface }
      GradientStop { position: (0.2 - tooltipStart) / (tooltipEnd - tooltipStart); color: topbarColorAt(0.2) ?? Colors.surface }
      GradientStop { position: (0.4 - tooltipStart) / (tooltipEnd - tooltipStart); color: topbarColorAt(0.4) ?? Colors.surface }
      GradientStop { position: (0.6 - tooltipStart) / (tooltipEnd - tooltipStart); color: topbarColorAt(0.6) ?? Colors.surface }
      GradientStop { position: (0.8 - tooltipStart) / (tooltipEnd - tooltipStart); color: topbarColorAt(0.8) ?? Colors.surface }
      GradientStop { position: 1.0; color: topbarColorAt(tooltipEnd) ?? Colors.surface }
    }
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
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
      ctx.fillStyle = wifiTooltipContent.topbarColorAt(wifiTooltipContent.tooltipStart).toString()
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

  Canvas {
    id: rightWing
    width: 14; height: 14
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.rightMargin: -12
    z: 10

    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      ctx.fillStyle = wifiTooltipContent.topbarColorAt(wifiTooltipContent.tooltipEnd).toString()
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
    id: rightWing1
    width: 14; height: 14
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.rightMargin: -12
    z: 10

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

import QtQuick
import Quickshell
import Quickshell.Io

Item {
  implicitWidth: 175
  implicitHeight: 70

  property string batteryName: "..."
  property string profile: "..."

  property real tooltipStart: 0.0
  property real tooltipEnd: 1.0

  function topbarColorAt(p) {
    var stops = [
      {pos: 0.0, color: Colors.topbar_gradient1},
      {pos: 0.2, color: Colors.topbar_gradient2},
      {pos: 0.4, color: Colors.topbar_gradient3},
      {pos: 0.6, color: Colors.topbar_gradient4},
      {pos: 0.8, color: Colors.topbar_gradient5},
      {pos: 1.0, color: Colors.topbar_gradient6},
    ]
    if (!Colors.background) return "#000000"
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

  Rectangle {
    anchors.fill: parent
    antialiasing: true
    layer.enabled: true
    
    gradient: Gradient {
      orientation: Gradient.Horizontal
      GradientStop { position: 0.0; color: topbarColorAt(tooltipStart) ?? Colors.background }
      GradientStop { position: (0.2 - tooltipStart) / (tooltipEnd - tooltipStart); color: topbarColorAt(0.2) ?? Colors.background }
      GradientStop { position: (0.4 - tooltipStart) / (tooltipEnd - tooltipStart); color: topbarColorAt(0.4) ?? Colors.background }
      GradientStop { position: (0.6 - tooltipStart) / (tooltipEnd - tooltipStart); color: topbarColorAt(0.6) ?? Colors.background }
      GradientStop { position: (0.8 - tooltipStart) / (tooltipEnd - tooltipStart); color: topbarColorAt(0.8) ?? Colors.background }
      GradientStop { position: 1.0; color: topbarColorAt(tooltipEnd) ?? Colors.background }
    }
    radius: 12
    border.width: 2
    border.color: Colors.outline_variant

    Column {
      anchors.centerIn: parent
      width: parent.width - 20
      spacing: 4

      Text {
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: "Model: " + StateGlobals.batModel
        color: Colors.text
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12
        font.bold: true
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
      GradientStop { position: 0.0; color: topbarColorAt(tooltipStart) ?? Colors.background }
      GradientStop { position: (0.2 - tooltipStart) / (tooltipEnd - tooltipStart); color: topbarColorAt(0.2) ?? Colors.background }
      GradientStop { position: (0.4 - tooltipStart) / (tooltipEnd - tooltipStart); color: topbarColorAt(0.4) ?? Colors.background }
      GradientStop { position: (0.6 - tooltipStart) / (tooltipEnd - tooltipStart); color: topbarColorAt(0.6) ?? Colors.background }
      GradientStop { position: (0.8 - tooltipStart) / (tooltipEnd - tooltipStart); color: topbarColorAt(0.8) ?? Colors.background }
      GradientStop { position: 1.0; color: topbarColorAt(tooltipEnd) ?? Colors.background }
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
      ctx.fillStyle = batteryTooltipContent.topbarColorAt(batteryTooltipContent.tooltipStart).toString()
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
      ctx.fillStyle = Colors.outline_variant
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
      ctx.fillStyle = batteryTooltipContent.topbarColorAt(batteryTooltipContent.tooltipEnd).toString()
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
      ctx.fillStyle = Colors.outline_variant
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

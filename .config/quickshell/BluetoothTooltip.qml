import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
  id: btTooltipContent
  implicitWidth: 200
  implicitHeight: Math.max(70, contentCol.implicitHeight + 20)

  property string ipAddress: "..."
  property real tooltipStart: 0.0
  property real tooltipEnd: 1.0

  Process {
    command: ["bash", "-c", "hostname -I | awk '{print $1}'"]
    running: true
    stdout: SplitParser {
      onRead: (data) => { ipAddress = data.trim() }
    }
  }

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
      id: contentCol
      anchors.centerIn: parent
      width: parent.width - 20
      spacing: 8

      // MAC Address
      Row {
        spacing: 6
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
          text: "󰂱"
          color: Colors.text_variant4
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: 11
          anchors.verticalCenter: parent.verticalCenter
        }

        Text {
          text: BluetoothService.connectedDevices.length > 0 
            ? BluetoothService.connectedDevices[0].mac 
            : "No device"
          color: Colors.text
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: 11
          anchors.verticalCenter: parent.verticalCenter
        }
      }

      // Connected devices from script
      Repeater {
        model: BluetoothService.connectedDevices

        Row {
          required property var modelData
          spacing: 6
          anchors.horizontalCenter: parent.horizontalCenter

          Text {
            text: {
              switch(modelData.type) {
                case "headphone": return "󰋋"
                case "phone":     return "󰄜"
                case "keyboard":  return "󰌌"
                case "mouse":     return "󰍽"
                default:          return "󰂱"
              }
            }
            color: Colors.text_variant4
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
            anchors.verticalCenter: parent.verticalCenter
          }

          Text {
            text: modelData.name
            color: Colors.text
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
          }
        }
      }

      // No device
      Text {
        visible: !BluetoothService.hasConnected
        text: "No devices connected"
        color: Colors.text_variant1
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 11
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
      }
    }
  }

  // Top patch
  Rectangle {
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

  // Wings
  Canvas {
    width: 14; height: 14
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.leftMargin: -12
    z: 10
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      ctx.fillStyle = btTooltipContent.topbarColorAt(btTooltipContent.tooltipStart).toString()
      ctx.beginPath()
      ctx.moveTo(0, 0); ctx.lineTo(0, 2)
      ctx.arc(0, 14, 12, Math.PI / 2, 0, false)
      ctx.lineTo(12, 14); ctx.lineTo(14, 14); ctx.lineTo(14, 0)
      ctx.closePath(); ctx.fill()
    }
  }

  Canvas {
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
      ctx.moveTo(0, 0); ctx.lineTo(0, 2)
      ctx.arc(0, 14, 12, Math.PI / 2, 0, false)
      ctx.lineTo(12, 14); ctx.lineTo(14, 14)
      ctx.arc(0, 14, 14, 0, Math.PI / 2, true)
      ctx.closePath(); ctx.fill()
    }
  }

  // Wings right
  Canvas {
    width: 14; height: 14
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.rightMargin: -12
    z: 10
    onPaint: {
      var ctx = getContext("2d")
      ctx.reset()
      ctx.fillStyle = btTooltipContent.topbarColorAt(btTooltipContent.tooltipEnd).toString()
      ctx.beginPath()
      ctx.moveTo(14, 0); ctx.lineTo(14, 2)
      ctx.arc(14, 14, 12, Math.PI / 2, Math.PI, true)
      ctx.lineTo(2, 14); ctx.lineTo(0, 14); ctx.lineTo(0, 0)
      ctx.closePath(); ctx.fill()
    }
  }

  Canvas {
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
      ctx.moveTo(14, 0); ctx.lineTo(14, 2)
      ctx.arc(14, 14, 12, Math.PI / 2, Math.PI, true)
      ctx.lineTo(2, 14); ctx.lineTo(0, 14)
      ctx.arc(14, 14, 14, Math.PI, Math.PI / 2, false)
      ctx.closePath(); ctx.fill()
    }
  }
}

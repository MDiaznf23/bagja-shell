// WeatherTooltip.qml
import QtQuick
import Quickshell
import Quickshell.Io

Item {
  implicitWidth: 260
  implicitHeight: 150
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
      anchors.fill: parent
      anchors.margins: 10
      spacing: 8

      Rectangle {
        width: parent.width
        height: (parent.height - 8) / 2
        color: "transparent"
        radius: 2

        Row {
          anchors.fill: parent
          anchors.margins: 0
          spacing: 8

          Rectangle {
            id: cityTempRect
            width: (parent.width - 8) / 2
            height: parent.height
            color: "transparent"
            radius: 6

            Column {
              anchors.fill: parent
              anchors.topMargin: 0
              spacing: 0

              Text {
                anchors.left: parent.left
                text: StateGlobals.weatherCity
                color: Colors.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
              }

              Text {
                anchors.left: parent.left
                text: StateGlobals.weatherTemp
                color: Colors.text_variant6
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 36
                font.bold: true
              }
            }
          }

          Rectangle {
            id: weatherInfoRect
            width: (parent.width - 8) / 2
            height: parent.height
            color: "transparent"
            radius: 6

            Column {
              anchors.fill: parent
              spacing: 2

              Text {
                anchors.right: parent.right
                text: StateGlobals.weatherIcon
                color: Colors.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 20
              }
              Text {
                anchors.right: parent.right
                text: StateGlobals.weatherText
                color: Colors.text_variant6
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 10
              }
              Row {
                anchors.right: parent.right
                spacing: 4
                Text {
                  text: StateGlobals.weatherLat
                  color: Colors.text_variant1
                  font.family: "JetBrainsMono Nerd Font"
                  font.pixelSize: 9
                }
                Text {
                  text: StateGlobals.weatherLong
                  color: Colors.text_variant1
                  font.family: "JetBrainsMono Nerd Font"
                  font.pixelSize: 9
                }
              }
            }
          }
        }
      }

      Rectangle {
        id: forecastRect
        width: parent.width
        height: (parent.height - 8) / 2
        color: "transparent"
        radius: 8

        Row {
          anchors.centerIn: parent
          spacing: 8

          Repeater {
            model: StateGlobals.weatherForecast

            Column {
              spacing: 2
              width: (forecastRect.width - 16) / 5

              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: modelData.day
                color: Colors.text_variant1
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 9
              }
              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: modelData.icon
                color: Colors.text_variant3
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
              }
              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: modelData.max
                color: Colors.text_variant2
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 10
                font.bold: true
              }
            }
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

  Connections {
    target: weatherContent
    function onTooltipStartChanged() {
      leftWing.requestPaint()
      rightWing.requestPaint()
    }
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
      ctx.fillStyle = weatherContent.topbarColorAt(weatherContent.tooltipStart).toString()
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
      ctx.fillStyle = weatherContent.topbarColorAt(weatherContent.tooltipEnd).toString()
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

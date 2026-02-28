import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets

Item {
  id: root
  implicitWidth: mediaColumn.width
  implicitHeight: mediaColumn.height

  property bool showDropdown: false

  function formatTime(us) {
    var s = Math.floor((us || 0) / 1000000)
    var m = Math.floor(s / 60)
    return m + ":" + String(s % 60).padStart(2, "0")
  }

  Column {
    id: mediaColumn
    spacing: 10

    Item {
      width: 120
      height: 20
      anchors.horizontalCenter: parent.horizontalCenter

      MouseArea {
        id: dropdownToggle
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.showDropdown = !root.showDropdown

        Row {
          anchors.centerIn: parent
          spacing: 4

          Text {
            text: MediaState.mediaData.player || "No Player"
            color: Colors.overSurface
            font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter
          }

          Text {
            text: root.showDropdown ? " ▲" : " ▼"
            color: Colors.outline
            font.pixelSize: 8
            anchors.verticalCenter: parent.verticalCenter
          }
        }
      }
    }

    Item {
      width: 120
      height: 120
      anchors.horizontalCenter: parent.horizontalCenter

      Rectangle {
        anchors.fill: parent
        color: Colors.surface
        radius: 8
        z: 0
      }

      ClippingWrapperRectangle {
        width: 120
        height: 120
        radius: 8
        z: 1

        Image {
          id: coverImage
          width: 120
          height: 120
          source: MediaState.mediaData.cover ? "file://" + MediaState.mediaData.cover : ""
          visible: MediaState.mediaData.cover !== undefined && MediaState.mediaData.cover !== ""
          fillMode: Image.PreserveAspectCrop
          smooth: true
          opacity: 0
          Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
          }
          onVisibleChanged: opacity = visible ? 1 : 0
        }
      }
    }

    Column {
      spacing: 4
      width: 120
      anchors.horizontalCenter: parent.horizontalCenter

      Text {
        text: MediaState.mediaData.title || "No Song Playing"
        color: Colors.overSurfaceVariant
        font.pixelSize: 12
        width: parent.width
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
      }
      Text {
        text: MediaState.mediaData.artist || "Unknown Artist"
        color: Colors.overSurface
        font.pixelSize: 10
        width: parent.width
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
      }
      Text {
        text: MediaState.mediaData.status || ""
        color: MediaState.mediaData.status === "Playing" 
        ? Colors.isDark ? Colors.primary : Colors.secondary 
        : Colors.overSurface
        font.pixelSize: 9
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
      }
    }

    // --- TIMER ---
    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 4

      Text {
        text: root.formatTime(MediaState.mediaData.position)
        color: Colors.overSurfaceVariant
        font.pixelSize: 9
      }
      Text {
        text: "/"
        color: Colors.overSurface
        font.pixelSize: 9
      }
      Text {
        text: root.formatTime(MediaState.mediaData.length)
        color: Colors.overSurfaceVariant
        font.pixelSize: 9
      }
    }

    // --- PROGRESS BAR + BUTTONS ---
    Column {
      spacing: 4
      anchors.horizontalCenter: parent.horizontalCenter

      // --- PROGRESS BAR SINUS ---
      Item {
        id: progressWrapper
        width: 120
        height: 20 
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
          id: remainingBar
          x: waveCanvas.currentW
          width: parent.width - x
          height: 2
          radius: 1
          anchors.verticalCenter: parent.verticalCenter
          color: Colors.isDark ? Colors.surfaceContainerHighest : Colors.surfaceContainerHigh 
        }

        Canvas {
          id: waveCanvas
          anchors.fill: parent
          antialiasing: true

          property int marginLeft: 4
          property real currentW: Math.max(marginLeft, width * progress)
          property real phase: 0
          property bool isPlaying: MediaState.mediaData.status === "Playing" 
          
          property real rawProgress: (MediaState.mediaData.length > 0) 
            ? Math.min((MediaState.mediaData.position / MediaState.mediaData.length), 1.0) 
            : 0 

          property real progress: rawProgress
          Behavior on progress {
            NumberAnimation { duration: 1000; easing.type: Easing.Linear } 
          }

          NumberAnimation on phase {
            from: 0; to: Math.PI * 2
            duration: 3000 
            loops: Animation.Infinite
            running: waveCanvas.isPlaying
          }

          onPhaseChanged: requestPaint()
          onProgressChanged: requestPaint()
          onIsPlayingChanged: requestPaint()

          onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            
            var w = currentW; 
            var h = height / 2;
            var amplitude = isPlaying ? 3 : 0; 
            var frequency = 0.2;

            ctx.beginPath();
            ctx.lineWidth = 2.5;
            ctx.lineCap = "round";
            ctx.strokeStyle = Colors.isDark ? Colors.tertiary : Colors.overPrimaryFixedVariant; 

            ctx.moveTo(0, h); 

            for (var x = 0; x <= w; x++) {
              var fadeIn = (x < 15) ? x / 15 : 1;
              
              var fadeOut = (w - x < 10) ? (w - x) / 10 : 1; 
              
              var y = h + Math.sin(x * frequency - phase) * (amplitude * fadeIn * fadeOut);
              ctx.lineTo(x, y);
            }

            ctx.stroke();
          }
        }

      // Handle
        Rectangle {
          width: 4
          height: 12
          radius: 2
          x: waveCanvas.currentW - (width / 2)
          anchors.verticalCenter: parent.verticalCenter
          color: Colors.isDark ? Colors.tertiary : Colors.overPrimaryFixedVariant 
          border.width: 1
          border.color: "transparent"
        }
      }

      Row {
        spacing: 15
        anchors.horizontalCenter: parent.horizontalCenter

        MouseArea {
          width: prevText.width
          height: prevText.height
          cursorShape: Qt.PointingHandCursor
          onClicked: MediaState.executePlayerctl("previous")
          Text {
            id: prevText
            text: "󰒮"
            color: parent.containsMouse 
            ? Colors.isDark ? Colors.overSurface : Colors.secondary 
            : Colors.isDark ? Colors.tertiary : Colors.secondary 
            font.pixelSize: 20
          }
        }

        MouseArea {
          width: playText.width
          height: playText.height
          cursorShape: Qt.PointingHandCursor
          onClicked: MediaState.executePlayerctl("play-pause")
          Text {
            id: playText
            text: MediaState.mediaData.status === "Playing" ? "󰏤" : "󰐊"
            color: parent.containsMouse 
            ? Colors.isDark ? Colors.overSurface : Colors.secondary 
            : Colors.isDark ? Colors.tertiary : Colors.secondary 
            font.pixelSize: 20
          }
        }

        MouseArea {
          width: nextText.width
          height: nextText.height
          cursorShape: Qt.PointingHandCursor
          onClicked: MediaState.executePlayerctl("next")
          Text {
            id: nextText
            text: "󰒭"
            color: parent.containsMouse 
            ? Colors.isDark ? Colors.overSurface : Colors.secondary 
            : Colors.isDark ? Colors.tertiary : Colors.secondary 
            font.pixelSize: 20
          }
        }
      }
    }
  }

  // Dropdown
  Rectangle {
    visible: root.showDropdown && MediaState.playerList.length > 0
    width: 120
    height: MediaState.playerList.length * 24
    color: Colors.isDark ? Colors.surface : Colors.surfaceContainer
    radius: 6
    z: 9999
    border.color: Colors.outlineVariant
    border.width: 1
    anchors.top: mediaColumn.top
    anchors.horizontalCenter: mediaColumn.horizontalCenter
    anchors.topMargin: 22

    Column {
      anchors.fill: parent
      anchors.margins: 2

      Repeater {
        model: MediaState.playerList

        MouseArea {
          width: 116
          height: 24
          cursorShape: Qt.PointingHandCursor
          hoverEnabled: true

          onClicked: {
            MediaState.selectedPlayer = modelData.player
            root.showDropdown = false
          }

          Rectangle {
            anchors.fill: parent
            color: parent.containsMouse 
            ? Colors.isDark ? Colors.surfaceContainerHigh : Colors.surfaceContainerHighest 
            : "transparent"
            radius: 4
          }

          Row {
            anchors.centerIn: parent
            spacing: 6
            Text {
              text: modelData.player
              color: MediaState.selectedPlayer === modelData.player 
              ? Colors.isDark ? Colors.primary : Colors.secondary 
              : Colors.overSurfaceVariant
              font.pixelSize: 11
              anchors.verticalCenter: parent.verticalCenter
            }
            Text {
              text: "●"
              color: modelData.status === "Playing" 
              ? Colors.isDark ? Colors.primaryContainer : Colors.inversePrimary
              : Colors.isDark ? Colors.overSurfaceVariant : Colors.overPrimaryFixed
              font.pixelSize: 8
              anchors.verticalCenter: parent.verticalCenter
            }
          }
        }
      }
    }
  }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
  id: root

  implicitWidth: 300
  implicitHeight: 360

  property bool isShowing: false
  property var notifServer
  property string activeTab: "Recent"

  property var groupedList: {
    if (!notifServer || !notifServer.history) return []
    var now = Date.now()
    var oneHour = 60 * 60 * 1000
    var groups = {}
    var order = []

    for (var i = 0; i < notifServer.history.length; i++) {
      var item = notifServer.history[i]
      var app = item.appName || "Unknown"
      if (!groups[app]) {
        groups[app] = { appName: app, items: [], latestTimestamp: 0 }
        order.push(app)
      }
      groups[app].items.push({ originalIndex: i, data: item })
      if ((item.timestamp || 0) > groups[app].latestTimestamp)
        groups[app].latestTimestamp = item.timestamp || 0
    }

    var result = []
    for (var j = 0; j < order.length; j++) {
      var g = groups[order[j]]
      var isRecent = (now - g.latestTimestamp) < oneHour
      result.push({
        type: "group",
        appName: g.appName,
        items: g.items,
        section: isRecent ? "Recent" : "Earlier",
        count: g.items.length
      })
    }
    return result
  }

  property var filteredList: root.groupedList.filter(g => g.section === root.activeTab)

  Timer {
    id: showTimer
    interval: 16
    onTriggered: root.isShowing = true
  }

  onVisibleChanged: {
    if (visible) {
      isShowing = false
      showTimer.start()
    } else {
      isShowing = false
    }
  }

  anchors {
    top: true
    right: true
  }

  margins {
    top: 28
    right: 13
  }

  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

  signal requestClose()

  Rectangle {
    id: mainRect
    anchors.fill: parent
    color: "transparent"

    Rectangle {
      id: topPatch
      height: 12
      antialiasing: true
      layer.enabled: true
      gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0.1; color: Colors.isDark ? Colors.surface : Colors.surface }
        GradientStop { position: 0.99; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim }
      }
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.leftMargin: 12
      z: 5
    }

    opacity: root.isShowing ? 1 : 0
    Behavior on opacity {
      NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
    }

    transform: Translate {
      y: root.isShowing ? 0 : -(root.implicitHeight + 50)
      Behavior on y {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
      }
    }

    Rectangle {
      anchors.fill: parent
      anchors.leftMargin: 12
      anchors.bottomMargin: 12
      gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0.1; color: Colors.isDark ? Colors.surface : Colors.surface }
        GradientStop { position: 0.99; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim }
      }
      radius: 12
      border.color: Colors.outlineVariant
      border.width: 2

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        // Header
        RowLayout {
          Layout.fillWidth: true

          Text {
            text: "Notifications"
            color: Colors.overSurfaceVariant
            font.pixelSize: 14
            font.bold: true
            Layout.fillWidth: true
          }

          Rectangle {
            width: 20; height: 20
            color: clearArea.containsMouse
              ? Colors.isDark ? Colors.primaryContainer : Colors.secondaryFixed
              : "transparent"
            radius: 4
            Text {
              anchors.centerIn: parent
              text: "󰃢"
              color: Colors.overSurface
              font.pixelSize: 14
            }
            MouseArea {
              id: clearArea
              anchors.fill: parent
              hoverEnabled: true
              onClicked: notifServer.clearHistory()
            }
          }

          Rectangle {
            width: 20; height: 20
            color: closeArea.containsMouse
              ? Colors.isDark ? Colors.overSecondary : Colors.secondary
              : "transparent"
            radius: 4
            Text {
              anchors.centerIn: parent
              text: "✕"
              color: Colors.overSurface
              font.pixelSize: 12
            }
            MouseArea {
              id: closeArea
              anchors.fill: parent
              hoverEnabled: true
              onClicked: root.requestClose()
            }
          }
        }

        Rectangle {
          Layout.fillWidth: true
          height: 2 
          color: Colors.outlineVariant
        }

        // Tab buttons
        RowLayout {
          Layout.fillWidth: true
          spacing: 4

          Repeater {
            model: ["Recent", "Earlier"]
            delegate: Rectangle {
              required property string modelData
              Layout.fillWidth: true
              height: 28
              radius: 6
              color: root.activeTab === modelData
                ? Colors.isDark ? Colors.overPrimary : Colors.primaryFixedDim
                : Colors.isDark ? Colors.surfaceContainer : Colors.surfaceContainerHigh

              Behavior on color { ColorAnimation { duration: 150 } }

              Text {
                anchors.centerIn: parent
                text: modelData
                font.pixelSize: 11
                font.bold: root.activeTab === modelData
                color: root.activeTab === modelData
                  ? Colors.isDark ? Colors.primary : Colors.primary
                  : Colors.overSurface
              }

              MouseArea {
                anchors.fill: parent
                onClicked: root.activeTab = modelData
              }
            }
          }
        }

        // List
        ListView {
          id: groupList
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true
          spacing: 4
          model: root.filteredList

          Text {
            anchors.centerIn: parent
            text: "No Notifications"
            color: Colors.overSurface
            font.pixelSize: 12
            visible: groupList.count === 0
          }

          delegate: Item {
            id: groupDelegate
            required property int index
            required property var modelData

            width: groupList.width
            height: groupColumn.implicitHeight

            Column {
              id: groupColumn
              width: parent.width
              spacing: 3

              // App header 
              Rectangle {
                width: parent.width
                height: 24
                color: "transparent"
                visible: groupDelegate.modelData.count > 1

                RowLayout {
                  anchors.fill: parent
                  anchors.leftMargin: 8
                  anchors.rightMargin: 8

                  Rectangle {
                    width: 6; height: 6
                    radius: 3
                    color: Colors.isDark ? Colors.primary : Colors.secondary
                    Layout.alignment: Qt.AlignVCenter
                  }

                  Text {
                    text: groupDelegate.modelData.appName
                    color: Colors.isDark ? Colors.primary : Colors.secondary
                    font.pixelSize: 10
                    font.bold: true
                    Layout.fillWidth: true
                  }

                  Text {
                    text: groupDelegate.modelData.count + " notifications"
                    color: Colors.overSurfaceVariant
                    font.pixelSize: 9
                  }
                }
              }

              // Notif items in group
              Repeater {
                model: groupDelegate.modelData.items

                delegate: Rectangle {
                  id: notifItem
                  required property var modelData

                  width: groupColumn.width
                  height: itemContent.implicitHeight + 16
                  color: notifArea.containsMouse
                    ? Colors.isDark ? Colors.surfaceContainerHigh : Colors.primaryFixedDim
                    : Colors.isDark ? Colors.surfaceContainer : Colors.surfaceContainerHigh
                  radius: 6

                  Behavior on color {
                    ColorAnimation { duration: 100 }
                  }

                  // Dismiss button 
                  Rectangle {
                    width: 16; height: 16
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 5
                    anchors.rightMargin: 5
                    color: dismissArea.containsMouse
                      ? Colors.isDark ? Colors.overSecondary : Colors.secondary
                      : "transparent"
                    radius: 3
                    z: 2

                    Text {
                      anchors.centerIn: parent
                      text: "✕"
                      color: Colors.overSurface
                      font.pixelSize: 9
                    }

                    MouseArea {
                      id: dismissArea
                      anchors.fill: parent
                      hoverEnabled: true
                      onClicked: notifServer.removeFromHistory(notifItem.modelData.originalIndex)
                    }
                  }

                  RowLayout {
                    id: itemContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.leftMargin: 10
                    anchors.rightMargin: 26
                    anchors.topMargin: 8
                    spacing: 8

                    // App icon 
                    Rectangle {
                      visible: groupDelegate.modelData.count === 1
                      width: 42; height: 42
                      radius: 8
                      color: Colors.isDark ? Colors.primaryContainer : Colors.secondaryFixed
                      Layout.alignment: Qt.AlignVCenter

                      Text {
                        anchors.centerIn: parent
                        text: "󰂚"
                        color: Colors.isDark ? Colors.primary : Colors.secondary
                        font.pixelSize: 16
                      }
                    }

                    ColumnLayout {
                      Layout.fillWidth: true
                      spacing: 1

                      // App name + time 
                      RowLayout {
                        Layout.fillWidth: true
                        visible: groupDelegate.modelData.count === 1

                        Text {
                          text: notifItem.modelData.data.appName
                          color: Colors.isDark ? Colors.primary : Colors.secondary
                          font.pixelSize: 10
                          font.bold: true
                          Layout.fillWidth: true
                          elide: Text.ElideRight
                        }

                        Text {
                          text: notifItem.modelData.data.time
                          color: Colors.overSurface
                          font.pixelSize: 9
                        }
                      }

                      // Time 
                      Text {
                        visible: groupDelegate.modelData.count > 1
                        text: notifItem.modelData.data.time
                        color: Colors.overSurfaceVariant
                        font.pixelSize: 9
                      }

                      Text {
                        text: notifItem.modelData.data.summary
                        color: Colors.overSurface
                        font.pixelSize: 11
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                      }

                      Text {
                        text: notifItem.modelData.data.body
                        color: Colors.overSurfaceVariant
                        font.pixelSize: 10
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        visible: text !== ""
                      }
                    }
                  }

                  MouseArea {
                    id: notifArea
                    anchors.fill: parent
                    hoverEnabled: true
                    propagateComposedEvents: true
                    onClicked: (mouse) => { mouse.accepted = false }
                  }
                }
              }
            }
          }
        }
      }

      Rectangle {
        id: rightPatch
        width: 12
        height: parent.height
        gradient: Gradient {
          orientation: Gradient.Horizontal
          GradientStop { position: 0.1; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim }
          GradientStop { position: 0.78; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim }
        }
        anchors.right: parent.right
        anchors.rightMargin: -2
        z: 5
      }

      Canvas {
        id: rightWing
        width: 14; height: 14
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: -12
        anchors.rightMargin: 0
        z: 10
        onPaint: {
          var ctx = getContext("2d")
          ctx.reset()
          ctx.fillStyle = Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim
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
        width: 14; height: 14
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: -12
        anchors.rightMargin: 0
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
    }

    Canvas {
      id: leftWing
      width: 14; height: 14
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.leftMargin: 0
      z: 10
      onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        ctx.fillStyle = Colors.isDark ? Colors.surface : Colors.surface
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
      anchors.leftMargin: 0
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
  }
}

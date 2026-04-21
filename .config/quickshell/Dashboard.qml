import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import Quickshell.Widgets

PopupWindow {
  id: root

  implicitWidth: 700
  implicitHeight: 700

  property bool isShowing: false

  onVisibleChanged: {
    if (visible) {
      isShowing = true    
    } else {
      isShowing = false 
    }
  }

  color: "transparent"
  property int currentTab: 1

  Item {
    anchors.fill: parent

    Rectangle {
      id: mainRect
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: parent.top
      anchors.topMargin: -10
      width: contentLayout.implicitWidth + 24
      height: contentLayout.implicitHeight + 24

      property real screenWidth: 1366
      property real wStart: (screenWidth - width) / 2 / screenWidth
      property real wEnd: 1 - wStart

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

      gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0.0;   color: mainRect.topbarColorAt(mainRect.wStart) }
        GradientStop { position: (0.2 - mainRect.wStart) / (mainRect.wEnd - mainRect.wStart); color: mainRect.topbarColorAt(0.2) }
        GradientStop { position: (0.4 - mainRect.wStart) / (mainRect.wEnd - mainRect.wStart); color: mainRect.topbarColorAt(0.4) }
        GradientStop { position: (0.6 - mainRect.wStart) / (mainRect.wEnd - mainRect.wStart); color: mainRect.topbarColorAt(0.6) }
        GradientStop { position: (0.8 - mainRect.wStart) / (mainRect.wEnd - mainRect.wStart); color: mainRect.topbarColorAt(0.8) }
        GradientStop { position: 1.0;   color: mainRect.topbarColorAt(mainRect.wEnd) }
      }

      opacity: root.visible ? 1 : 0
      Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
      }

      transform: Translate {
        y: isShowing ? 0 : -700    
        Behavior on y {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }
      }

      radius: 12
      border.color: Colors.outline_variant
      border.width: 2

      Behavior on width  { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
      Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

      ColumnLayout {
        id: contentLayout
        anchors.centerIn: parent
        spacing: 10

        Item {
          id: tabBar
          Layout.fillWidth: true
          height: 40

          property int totalTab: 3
          property real totalTabWidth: tab0.width + tab1.width + tab2.width
          property real spacerWidth: (width - totalTabWidth) / (totalTab + 1)

          Row {
            anchors.fill: parent

            Item { width: tabBar.spacerWidth; height: 1 }
            Item {
              id: tab0
              width: tab0Text.width
              height: tabBar.height + 10

              Column {
                anchors.top: parent.top
                anchors.topMargin: 2  
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 2

                Text {
                  text: "󰒓"
                  color: (currentTab === 0 ? Colors.text_variant2 : Colors.text_variant1) 
                  font.family: "Iosevka Nerd Font"
                  font.pixelSize: 14
                  anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                  id: tab0Text
                  text: "System"
                  color: (currentTab === 0 ? Colors.text_variant2 : Colors.text_variant1)  
                  font.bold: currentTab === 0
                  font.pixelSize: 13
                }
              }

              Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: currentTab === 0 ? parent.width + 4 : 0
                height: 2
                radius: 2
                color: Colors.text_variant1

                Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
              }

              MouseArea {
                  anchors.fill: parent
                  onClicked: currentTab = 0
              }
            }
            Item { width: tabBar.spacerWidth; height: 1 }
            Item {
              id: tab1
              width: tab1Text.width
              height: tabBar.height + 10

              Column {
                anchors.top: parent.top
                anchors.topMargin: 2  
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 2

                Text {
                  text: "󰕮"
                  color: (currentTab === 1 ? Colors.text_variant2 : Colors.text_variant1) 
                  font.family: "Iosevka Nerd Font"
                  font.pixelSize: 14
                  anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                  id: tab1Text
                  text: "Dashboard"
                  color: (currentTab === 1 ? Colors.text_variant2 : Colors.text_variant1) 
                  font.bold: currentTab === 1
                  font.pixelSize: 13
                }
              }

              Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: currentTab === 1 ? parent.width + 4 : 0
                height: 2
                radius: 2
                color: Colors.text_variant1

                Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
              }

              MouseArea {
                anchors.fill: parent
                onClicked: currentTab = 1
              }
            }
            Item { width: tabBar.spacerWidth; height: 1 }
            Item {
              id: tab2
              width: tab2Text.width
              height: tabBar.height + 10

              Column {
                anchors.top: parent.top
                anchors.topMargin: 2  
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 2

                Text {
                  text: "󰀉"
                  color: (currentTab === 2 ? Colors.text_variant2 : Colors.text_variant1)
                  font.family: "Iosevka Nerd Font"
                  font.pixelSize: 14
                  anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                  id: tab2Text
                  text: "Profile"
                  color: (currentTab === 2 ? Colors.text_variant2 : Colors.text_variant1) 
                  font.bold: currentTab === 2
                  font.pixelSize: 13
                }
              }

              Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: currentTab === 2 ? parent.width + 4 : 0
                height: 2
                radius: 2
                color: Colors.text_variant1

                Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
              }

              MouseArea {
                anchors.fill: parent
                onClicked: currentTab = 2
              }
            }
            Item { width: tabBar.spacerWidth; height: 1 }
          }
        }

        Rectangle {
          Layout.fillWidth: true
          height: 1
          color: Colors.outline_variant
        }

        StackLayout {
          id: stack
          currentIndex: currentTab

          Layout.preferredWidth:  itemAt(currentIndex)?.implicitWidth  ?? 0
          Layout.preferredHeight: itemAt(currentIndex)?.implicitHeight ?? 0

          Behavior on Layout.preferredWidth  { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
          Behavior on Layout.preferredHeight { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

          Item {
            implicitWidth: 450
            implicitHeight: 170

            Process {
              id: sysinfoProc
              command: ["python3", "-u", Quickshell.shellDir + "/scripts/sys_info.py"]

              property var data: ({
                "cpu_usage": "0", "cpu_temp": "0",
                "mem_used": "0", "mem_total": "0", "mem_perc": "0",
                "disk_used": "0", "disk_total": "0", "disk_perc": "0"
              })

              stdout: SplitParser {
                onRead: data => {
                  try { sysinfoProc.data = JSON.parse(data) } catch(e) {}
                }
              }
            }

            Timer {
              interval: 2000
              running: true
              repeat: true
              triggeredOnStart: true
              onTriggered: sysinfoProc.running = true
            }

            component CircleWidget: Item {
              property int size: 100
              property string label: ""
              property int value: 0          
              property string valueText: ""  
              property string subText: ""    
              property string arcColor: Colors.arcColor

              width: size
              height: size

              Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: Colors.isDark ? Qt.alpha(Colors.circle_arc, 0.7) : Qt.alpha(Colors.circle_arc, 0.5)
              }

              Canvas {
                id: arcCanvas
                anchors.fill: parent

                property real progress: value / 100.0

                onProgressChanged: requestPaint()

                onPaint: {
                  var ctx = getContext("2d")
                  ctx.reset()

                  var cx = width / 2
                  var cy = height / 2
                  var r = width / 2 - 5
                  var lineW = 4

                  // Track (background arc)
                  ctx.beginPath()
                  ctx.arc(cx, cy, r, 0, Math.PI * 2)
                  ctx.strokeStyle = Colors.background_arc
                  ctx.lineWidth = lineW
                  ctx.stroke()

                  // Progress arc 
                  var startAngle = -Math.PI / 2
                  var endAngle = startAngle + (Math.PI * 2 * progress)

                  ctx.beginPath()
                  ctx.arc(cx, cy, r, startAngle, endAngle)
                  ctx.strokeStyle = arcColor
                  ctx.lineWidth = lineW
                  ctx.lineCap = "round"
                  ctx.stroke()
                }
              }

              Column {
                anchors.centerIn: parent
                spacing: 2

                Text {
                  anchors.horizontalCenter: parent.horizontalCenter
                  text: label
                  color: Colors.text
                  font.pixelSize: size > 110 ? 13 : 11
                  font.bold: true
                }
                Text {
                  anchors.horizontalCenter: parent.horizontalCenter
                  text: valueText
                  color: arcColor
                  font.pixelSize: size > 110 ? 22 : 18
                  font.bold: true
                }
                Text {
                  anchors.horizontalCenter: parent.horizontalCenter
                  text: subText
                  color: Colors.text_variant1
                  font.pixelSize: 9
                  visible: subText !== ""
                }
              }
            }

            Rectangle {
              anchors.fill: parent
              color: "transparent"
              radius: 8

              RowLayout {
                anchors.centerIn: parent
                spacing: 12

                // CPU
                CircleWidget {
                  size: 120
                  label: "CPU"
                  value: parseInt(sysinfoProc.data.cpu_usage)
                  valueText: sysinfoProc.data.cpu_usage + "%"
                  subText: sysinfoProc.data.cpu_temp + "°C"
                  arcColor: {
                    var v = parseInt(sysinfoProc.data.cpu_usage)
                    return v > 80 
                    ? Qt.alpha(Colors.gauge_critical, 0.6)
                    : v > 50 
                        ? (Colors.gauge_warning)
                        : (Colors.isDark ? Colors.gauge_normal : Qt.alpha(Colors.gauge_normal, 0.6))
                  }
                }

                // RAM
                CircleWidget {
                  size: 150
                  label: "RAM"
                  value: parseInt(sysinfoProc.data.mem_perc)
                  valueText: sysinfoProc.data.mem_perc + "%"
                  subText: sysinfoProc.data.mem_used + " / " + sysinfoProc.data.mem_total
                  arcColor: {
                    var v = parseInt(sysinfoProc.data.mem_perc)
                    return v > 80 
                    ? Qt.alpha(Colors.gauge_critical, 0.6)
                    : v > 50 
                        ? (Colors.gauge_warning)
                        : (Colors.isDark ? Colors.gauge_normal : Qt.alpha(Colors.gauge_normal, 0.6))

                  }
                }

                // Disk
                CircleWidget {
                  size: 120
                  label: "Disk"
                  value: parseInt(sysinfoProc.data.disk_perc)
                  valueText: sysinfoProc.data.disk_perc + "%"
                  subText: sysinfoProc.data.disk_used + " / " + sysinfoProc.data.disk_total
                  arcColor: {
                    var v = parseInt(sysinfoProc.data.disk_perc)
                    return v > 80 
                    ? Qt.alpha(Colors.gauge_critical, 0.6)
                    : v > 50 
                        ? (Colors.gauge_warning)
                        : (Colors.isDark ? Colors.gauge_normal : Qt.alpha(Colors.gauge_normal, 0.6))
                  }
                }
              }
            }
          }

          Item {
            implicitWidth:  590
            implicitHeight: 290
            Rectangle {
              anchors.fill: parent
              color: "transparent"
              radius: 8
              RowLayout {
                anchors.fill: parent
                anchors.margins: 0
                spacing: 10

                ColumnLayout {
                  Layout.fillWidth: true
                  Layout.fillHeight: true
                  spacing: 10

                  RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10

                    Rectangle {
                      Layout.preferredHeight: 100
                      Layout.preferredWidth: 220
                      color: Colors.isDark ? Qt.alpha(Colors.container_level_1_variant1, 0.7) : Qt.alpha(Colors.container_level_1_variant1, 0.5)
                      radius: 6

                      Process {
                        id: profileProc
                        running: true
                        command: [Quickshell.shellDir + "/scripts/profile.sh", "json"]
                        
                        property var data: ({})
                        
                        stdout: SplitParser {
                          onRead: data => {
                            try {
                                profileProc.data = JSON.parse(data)
                            } catch(e) {}
                          }
                        }
                      }

                      Timer {
                        interval: 30000  
                        running: true
                        repeat: true
                        triggeredOnStart: true
                        onTriggered: profileProc.running = true
                      }
                      
                      RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10
                        
                        Rectangle {
                          Layout.preferredWidth: 75
                          Layout.preferredHeight: 75
                          color: "transparent"
                          
                          Image {
                            anchors.fill: parent
                            source: Qt.resolvedUrl(Quickshell.shellDir + "/assets/profile.jpg")
                            fillMode: Image.PreserveAspectCrop
                            layer.enabled: true
                            layer.effect: OpacityMask {
                              maskSource: Rectangle {
                                width: 75
                                height: 75
                                radius: 8
                              }
                            }
                          }
                        }
                        
                        ColumnLayout {
                          spacing: 7

                          RowLayout {
                            spacing: 7

                            Text { 
                              text: "";
                              font.family: "JetBrainsMono Nerd Font"
                              color: Colors.text_variant2
                              font.pixelSize: 12
                            }

                            Text { 
                              text: profileProc.data.username || ""; 
                              color: Colors.text
                              font.family: "JetBrainsMono Nerd Font"
                              font.pixelSize: 12
                              Layout.fillWidth: true
                            }
                          }
                          
                          RowLayout {
                            spacing: 7
                            Text { 
                              text:"";
                              font.family: "JetBrainsMono Nerd Font"
                              color: Colors.text_variant2
                              font.pixelSize: 12
                            }
                            Text { 
                              text: profileProc.data.wm || ""; 
                              color: Colors.text
                              font.family: "JetBrainsMono Nerd Font"
                              font.pixelSize: 12
                              Layout.fillWidth: true
                            }
                          }
                          
                          RowLayout {
                            spacing: 7
                            Text { 
                              text: "" ;
                              font.family: "JetBrainsMono Nerd Font"
                              color: Colors.text_variant2
                              font.pixelSize: 12
                            }
                            Text { 
                              text: profileProc.data.uptime || ""; 
                              color: Colors.text
                              font.family: "JetBrainsMono Nerd Font"
                              font.pixelSize: 12
                              Layout.fillWidth: true
                            }
                          }
                        }
                      }
                    }

                    Rectangle {
                      Layout.fillWidth: true
                      Layout.preferredHeight: 100
                      color: Colors.isDark ? Qt.alpha(Colors.container_level_1_variant1, 0.7) : Qt.alpha(Colors.container_level_1_variant1, 0.5)
                      radius: 6
                      
                      RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15 
                        anchors.topMargin: 10 
                        anchors.bottomMargin: 10
                        anchors.rightMargin: 10
                        spacing: 0
                        
                        Rectangle {
                          Layout.preferredWidth: 80
                          Layout.fillHeight: true
                          color: "transparent"
                          radius: 4
                          Text { 
                            anchors.centerIn: parent
                            text: StateGlobals.weatherIcon
                            color: Colors.text_variant2
                            font.pixelSize: 63
                            font.family: "JetBrainsMono Nerd Font"
                          }
                        }
                          
                        Rectangle {
                          Layout.fillWidth: true
                          Layout.fillHeight: true
                          color: "transparent"
                          radius: 4
                          
                          ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 5
                            
                            Text { 
                              text: {
                                let d = StateGlobals.weatherCity
                                return d.length > 12 ? d.substring(0, 12) + "…" : d
                              }
                              color: Colors.text_variant1
                              font.pixelSize: 20
                              Layout.fillWidth: true  
                              elide: Text.ElideRight
                              font.family: "JetBrainsMono Nerd Font"
                              font.bold: true
                              horizontalAlignment: Text.AlignHCenter
                              Layout.alignment: Qt.AlignHCenter
                            }

                            Text { 
                              text: {
                                let d = StateGlobals.weatherText
                                return d.length > 14 ? d.substring(0, 14) + "…" : d
                              }
                              color: Colors.text
                              font.pixelSize: 12
                              font.family: "JetBrainsMono Nerd Font"
                              horizontalAlignment: Text.AlignHCenter
                              Layout.alignment: Qt.AlignHCenter
                            }
                          }
                        } 
                      }
                    }
                  }

                  RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10

                    Rectangle {
                      id: clockRect
                      Layout.preferredWidth: 80
                      Layout.fillHeight: true
                      color: Colors.isDark ? Qt.alpha(Colors.container_level_1_variant1, 0.7) : Qt.alpha(Colors.container_level_1_variant1, 0.5)
                      radius: 6

                      ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 4

                        ColumnLayout {
                          Layout.alignment: Qt.AlignHCenter
                          spacing: 0

                          Text {
                            text: Qt.formatTime(StateGlobals.clockDate, "HH")
                            color: Colors.text_hour
                            font.pixelSize: 36
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter
                          }

                          Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            width: 40
                            height: 20
                            color: "transparent"
                            Text {
                              anchors.centerIn: parent
                              text: "•••"
                              color: Colors.text_dots
                              font.pixelSize: 36
                              horizontalAlignment: Text.AlignHCenter
                              verticalAlignment: Text.AlignVCenter
                            }
                          }

                          Text {
                            text: Qt.formatTime(StateGlobals.clockDate, "mm")
                            color: Colors.text_minute
                            font.pixelSize: 36
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter
                          }
                        }

                        Text {
                          text: Qt.formatDate(StateGlobals.clockDateMin, "ddd, dd MMM")
                          color: Colors.text_date
                          font.pixelSize: 11
                          font.bold: true
                          Layout.alignment: Qt.AlignHCenter
                        }
                      }
                    }

                    Rectangle {
                      Layout.preferredWidth: 200
                      Layout.fillHeight: true
                      color: Colors.isDark ? Qt.alpha(Colors.container_level_1_variant1, 0.7) : Qt.alpha(Colors.container_level_1_variant1, 0.5)
                      radius: 6

                      property int todayDate: StateGlobals.clockDateMin.getDate()
                      property int currentMonth: StateGlobals.clockDateMin.getMonth()
                      property int currentYear: StateGlobals.clockDateMin.getFullYear()
                      property int firstDay: {
                        var d = new Date(currentYear, currentMonth, 1).getDay()
                        return (d === 0) ? 6 : d - 1
                      }
                      property int daysInMonth: new Date(currentYear, currentMonth + 1, 0).getDate()
                      property int daysInPrevMonth: new Date(currentYear, currentMonth, 0).getDate()
                      property int totalCells: Math.ceil((firstDay + daysInMonth) / 7) * 7

                      ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 0

                        Text {
                          text: Qt.formatDate(StateGlobals.clockDateMin, "MMMM yyyy")
                          color: Colors.text
                          font.pixelSize: 12
                          font.bold: true
                          Layout.fillWidth: true
                          Layout.bottomMargin: 10
                          horizontalAlignment: Text.AlignHCenter
                        }

                        GridLayout {
                          Layout.fillWidth: true
                          Layout.fillHeight: true
                          columns: 7
                          rowSpacing: 0
                          columnSpacing: 0

                          // Header day
                          Repeater {
                              model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                              Text {
                                  text: modelData
                                  color: Colors.text_variant1
                                  font.pixelSize: 9
                                  Layout.fillWidth: true
                                  horizontalAlignment: Text.AlignHCenter
                                  Layout.bottomMargin: 3
                              }
                          }

                          // Date
                          Repeater {
                            model: parent.parent.parent.totalCells

                            Rectangle {
                              Layout.fillWidth: true
                              Layout.fillHeight: true
                              radius: 4

                              property bool isPrev: index < parent.parent.parent.firstDay
                              property bool isNext: index >= parent.parent.parent.firstDay + parent.parent.parent.daysInMonth
                              property int dayNum: {
                                if (isPrev)
                                    return parent.parent.parent.daysInPrevMonth - parent.parent.parent.firstDay + index + 1
                                else if (isNext)
                                    return index - parent.parent.parent.firstDay - parent.parent.parent.daysInMonth + 1
                                else
                                    return index - parent.parent.parent.firstDay + 1
                              }

                              property bool isToday: !isPrev && !isNext && dayNum === parent.parent.parent.todayDate

                              color: isToday ? Colors.calendar_today_bg : "transparent"

                              Text {
                                anchors.centerIn: parent
                                text: dayNum
                                color: isToday
                                ? Colors.calendar_today_text
                                : (isPrev || isNext)
                                  ? Colors.calendar_muted_text
                                  : Colors.calendar_normal_text
                                font.pixelSize: 9
                                font.bold: isToday
                              }
                            }
                          }
                        }
                      }
                    }

                    Rectangle {
                      id: pomodoroRoot
                      Layout.fillWidth: true
                      Layout.fillHeight: true
                      color: Colors.isDark ? Qt.alpha(Colors.container_level_1_variant1, 0.7) : Qt.alpha(Colors.container_level_1_variant1, 0.5)
                      radius: 6
                      
                      property int totalSeconds: 15 * 60
                      property int remaining: 15 * 60
                      property bool running: false
                      property bool finished: false
                      property real progress: 1.0 - (remaining / totalSeconds)
                      
                      // Custom duration 
                      property int customMinutes: 15
                      
                      Process {
                        id: pomodoroFinishedNotify
                        command: ["notify-send", "Pomodoro", "Session Over! Let's Rest!"]
                      }
                      
                      Process {
                        id: pomodoroStartNotify
                        command: ["notify-send", "Pomodoro", "Focus Session Start! Good Luck."]
                      }
                      
                      Timer {
                        interval: 1000
                        repeat: true
                        running: pomodoroRoot.running
                        onTriggered: {
                          if (pomodoroRoot.remaining > 0) {
                            pomodoroRoot.remaining--
                          } else {
                            pomodoroRoot.running = false
                            pomodoroRoot.finished = true
                            pomodoroFinishedNotify.running = true
                          }
                        }
                      }
                      
                      ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 0
                        
                        // Canvas tree
                        Canvas {
                          id: treeCanvas
                          Layout.fillWidth: true
                          Layout.preferredHeight: 60
                          
                          Connections {
                            target: pomodoroRoot
                            function onProgressChanged() {
                              treeCanvas.requestPaint()
                            }
                          }
                          
                          onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            
                            var p = pomodoroRoot.progress
                            var cx = width / 2
                            var groundY = height - 4
                            var maxStemH = height * 0.68
                            
                            // Ground
                            ctx.fillStyle = "#585b70"
                            ctx.beginPath()
                            ctx.rect(cx - 22, groundY, 44, 4)
                            ctx.fill()
                            
                            // Fase 0-20%: 
                            if (p < 0.2) {
                              var sproutP = p / 0.2
                              
                              // tree
                              var stemH = 8 + 4 * sproutP
                              ctx.strokeStyle = Colors.isDark ? "#a6e3a1" : "#40a02b"
                              ctx.lineWidth = 2
                              ctx.lineCap = "round"
                              ctx.beginPath()
                              ctx.moveTo(cx, groundY)
                              ctx.lineTo(cx, groundY - stemH)
                              ctx.stroke()
                              
                              // elips leaf
                              var leafSize = 0.8 + 0.2 * sproutP
                              ctx.fillStyle = Colors.isDark ? "#a6e3a1" : "#40a02b"
                              
                              // left leaf
                              ctx.save()
                              ctx.translate(cx - 7, groundY - stemH + 1)
                              ctx.rotate(-0.4)
                              ctx.beginPath()
                              ctx.ellipse(0, 0, 9 * leafSize, 5 * leafSize, 0, 0, Math.PI * 2)
                              ctx.fill()
                              ctx.restore()
                              
                              // right leaf
                              ctx.save()
                              ctx.translate(cx + 1, groundY - stemH + 1)
                              ctx.rotate(0.4)
                              ctx.beginPath()
                              ctx.ellipse(0, 0, 9 * leafSize, 5 * leafSize, 0, 0, Math.PI * 2)
                              ctx.fill()
                              ctx.restore()
                              
                              return
                            }
                            
                            // Fase 20-100%: 
                            var treeP = (p - 0.2) / 0.8
                            var stemH = maxStemH * treeP
                            
                            // tree layout
                            ctx.strokeStyle = "#89664c"
                            ctx.lineWidth = 4
                            ctx.lineCap = "round"
                            ctx.beginPath()
                            ctx.moveTo(cx, groundY)
                            ctx.lineTo(cx, groundY - stemH)
                            ctx.stroke()
                            
                            // branch
                            if (treeP > 0.3) {
                              ctx.strokeStyle = "#89664c"
                              ctx.lineWidth = 2.5
                              
                              var mainBranches = [
                                {y: 0.5, angle: -0.5, len: 18, subBranches: 2},
                                {y: 0.5, angle: 0.5, len: 18, subBranches: 2},
                                {y: 0.7, angle: -0.4, len: 20, subBranches: 3},
                                {y: 0.7, angle: 0.4, len: 20, subBranches: 3}
                              ]
                              
                              for (var i = 0; i < mainBranches.length; i++) {
                                var mb = mainBranches[i]
                                var showAt = 0.3 + (i / mainBranches.length) * 0.4
                                if (treeP < showAt) continue
                                
                                var localP = Math.min((treeP - showAt) / (1 - showAt), 1.0)
                                var by = groundY - stemH * mb.y
                                var blen = mb.len * localP
                                var bx = cx + Math.sin(mb.angle) * blen
                                var by2 = by - Math.cos(mb.angle) * blen * 0.7
                                
                                // main branch
                                ctx.beginPath()
                                ctx.moveTo(cx, by)
                                ctx.lineTo(bx, by2)
                                ctx.stroke()
                                
                                // Sub-branch
                                if (localP > 0.5) {
                                  ctx.lineWidth = 1.5
                                  for (var j = 0; j < mb.subBranches; j++) {
                                    var subAngle = mb.angle + (j - 1) * 0.3
                                    var subLen = 8 * localP
                                    var sbx = bx + Math.sin(subAngle) * subLen
                                    var sby = by2 - Math.cos(subAngle) * subLen * 0.5
                                    
                                    ctx.beginPath()
                                    ctx.moveTo(bx, by2)
                                    ctx.lineTo(sbx, sby)
                                    ctx.stroke()
                                    
                                    // leaf
                                    if (localP > 0.7) {
                                      ctx.fillStyle = Colors.isDark ? "#a6e3a1" : "#40a02b"
                                      ctx.beginPath()
                                      ctx.arc(sbx, sby, 3.5, 0, Math.PI * 2)
                                      ctx.fill()
                                    }
                                  }
                                  ctx.lineWidth = 2.5
                                }
                              }
                            }
                            
                            // leaf in the top
                            if (treeP > 0.8) {
                              var topP = (treeP - 0.8) / 0.2
                              ctx.fillStyle = Colors.isDark ? "#a6e3a1" : "#40a02b"
                              ctx.beginPath()
                              ctx.arc(cx, groundY - stemH, 4 * topP, 0, Math.PI * 2)
                              ctx.fill()
                            }
                          }
                        }
                        
                        // Countdown
                        Text {
                          Layout.alignment: Qt.AlignHCenter
                          Layout.topMargin: 4
                          text: {
                            var m = Math.floor(pomodoroRoot.remaining / 60)
                            var s = pomodoroRoot.remaining % 60
                            return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s
                          }
                          color: pomodoroRoot.finished ? Colors.text_variant4 : Colors.text
                          font.pixelSize: 24
                          font.bold: true
                        }
                        
                        // BUTTON LAYOUT (CONTAINER BUTTON)
                        RowLayout {
                          Layout.alignment: Qt.AlignHCenter
                          Layout.topMargin: 2
                          spacing: 20
                          
                          Text {
                            text: pomodoroRoot.running ? "󰏤" : "󰐊"
                            color: Colors.text_variant5
                            font.pixelSize: 22
                            visible: !pomodoroRoot.finished
                            MouseArea {
                              anchors.fill: parent
                              cursorShape: Qt.PointingHandCursor
                              onClicked: {
                                if (!pomodoroRoot.running) {
                                  pomodoroStartNotify.running = true
                                }
                                pomodoroRoot.running = !pomodoroRoot.running
                              }
                            }
                          }

                          // RESET BUTTON PODOMORO
                          Text {
                            text: "󰑖"
                            color: Colors.text_variant4
                            font.pixelSize: 22
                            MouseArea {
                              anchors.fill: parent
                              cursorShape: Qt.PointingHandCursor
                              onClicked: {
                                pomodoroRoot.running = false
                                pomodoroRoot.finished = false
                                pomodoroRoot.totalSeconds = pomodoroRoot.customMinutes * 60
                                pomodoroRoot.remaining = pomodoroRoot.totalSeconds
                              }
                            }
                          }
                          
                          // BUTTON MIN FOR DECREASE PODOMORO
                          Text {
                            text: "−"
                            color: Colors.text_variant2
                            font.pixelSize: 22
                            visible: !pomodoroRoot.running && !pomodoroRoot.finished
                            MouseArea {
                              anchors.fill: parent
                              cursorShape: Qt.PointingHandCursor
                              onClicked: {
                                if (pomodoroRoot.customMinutes > 1) {
                                  pomodoroRoot.customMinutes -= 1
                                  pomodoroRoot.totalSeconds = pomodoroRoot.customMinutes * 60
                                  pomodoroRoot.remaining = pomodoroRoot.totalSeconds
                                }
                              }
                            }
                          }

                          // BUTTON PLUS FOR INCREASE PODOMORO
                          Text {
                            text: "+"
                            color: Colors.text_variant5 
                            font.pixelSize: 22
                            visible: !pomodoroRoot.running && !pomodoroRoot.finished
                            MouseArea {
                              anchors.fill: parent
                              cursorShape: Qt.PointingHandCursor
                              onClicked: {
                                if (pomodoroRoot.customMinutes < 60) {
                                  pomodoroRoot.customMinutes += 1
                                  pomodoroRoot.totalSeconds = pomodoroRoot.customMinutes * 60
                                  pomodoroRoot.remaining = pomodoroRoot.totalSeconds
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }

                ColumnLayout {
                  Layout.preferredWidth: 130
                  Layout.fillHeight: true
                  spacing: 10

                  Rectangle {
                    Layout.preferredWidth: 130
                    Layout.preferredHeight: 200
                    color: Colors.isDark ? Qt.alpha(Colors.container_level_1_variant1, 0.7) : Qt.alpha(Colors.container_level_1_variant1, 0.5)
                    radius: 6

                    Column {
                      anchors.centerIn: parent
                      spacing: 7
                      topPadding: 8

                      // Cover
                      Rectangle {
                        width: 90
                        height: 90
                        radius: 6
                        color: Colors.background 
                        anchors.horizontalCenter: parent.horizontalCenter

                        ClippingWrapperRectangle {
                          width: 90
                          height: 90
                          radius: 6

                          Image {
                            id: dashCover
                            anchors.fill: parent
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

                      // Title & Artist
                      Column {
                        spacing: 2
                        width: 100
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                          text: MediaState.mediaData.player || ""
                          color: Colors.text
                          font.pixelSize: 9
                          width: parent.width
                          elide: Text.ElideRight
                          horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                          text: MediaState.mediaData.title || "No Song Playing"
                          color: Colors.text_variant1
                          font.pixelSize: 11
                          width: parent.width
                          elide: Text.ElideRight
                          horizontalAlignment: Text.AlignHCenter
                        }
                        Text {
                          text: MediaState.mediaData.artist || "Unknown Artist"
                          color: Colors.text
                          font.pixelSize: 9
                          width: parent.width
                          elide: Text.ElideRight
                          horizontalAlignment: Text.AlignHCenter
                        }
                      }

                      // Buttons
                      Row {
                        spacing: 12
                        anchors.horizontalCenter: parent.horizontalCenter

                        MouseArea {
                          width: dashPrev.width; height: dashPrev.height
                          cursorShape: Qt.PointingHandCursor
                          onClicked: MediaState.executePlayerctl("previous")
                          Text { 
                            id: dashPrev; 
                            text: "󰒮"; 
                            color: Colors.text_variant2 
                            font.pixelSize: 18 
                          }
                        }
                        MouseArea {
                          width: dashPlay.width; height: dashPlay.height
                          cursorShape: Qt.PointingHandCursor
                          onClicked: MediaState.executePlayerctl("play-pause")
                          Text { 
                            id: dashPlay; 
                            text: MediaState.mediaData.status === "Playing" ? "󰏤" : "󰐊"; 
                            color: Colors.text_variant2      
                            font.pixelSize: 18 
                          }
                        }
                        MouseArea {
                          width: dashNext.width; height: dashNext.height
                          cursorShape: Qt.PointingHandCursor
                          onClicked: MediaState.executePlayerctl("next")
                          Text { 
                            id: dashNext; 
                            text: "󰒭"; 
                            color: Colors.text_variant2  
                            font.pixelSize: 18 
                          }
                        }
                      }
                    }
                  }
                  
                  // BARS
                  Rectangle {
                    Layout.preferredWidth: 130
                    Layout.fillHeight: true
                    color: Colors.isDark ? Qt.alpha(Colors.container_level_1_variant1, 0.7) : Qt.alpha(Colors.container_level_1_variant1, 0.5)
                    radius: 6
                    clip: true

                    Process {
                      id: fakeCava
                      running: true
                      command: ["bash", Quickshell.shellDir + "/scripts/cava.sh"]
                      Component.onDestruction: running = false
                      stdout: SplitParser {
                        splitMarker: "\n"
                        onRead: data => {
                          var parts = data.trim().split(";").filter(v => v !== "")
                          var newBars = parts.map(v => parseInt(v)).filter(v => !isNaN(v))
                          if (newBars.length > 0) {
                            cavaCanvas.bars = newBars
                            cavaCanvas.requestPaint()
                          }
                        }
                      }
                    }

                    Canvas {
                      id: cavaCanvas
                      anchors.fill: parent
                      anchors.margins: 6
                      property var bars: []
                      property var smoothBars: []

                      onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        var n = bars.length
                        if (n === 0) return

                        var gap = 2
                        var barW = (width - gap * (n - 1)) / n
                        var r = 1

                        for (var i = 0; i < n; i++) {
                          var barH = Math.max(2, (bars[i] / 100.0) * height)
                          var grad = ctx.createLinearGradient(0, height, 0, height - barH)
                          grad.addColorStop(0, Colors.text_variant5 )
                          grad.addColorStop(1, Colors.text_variant2 )
                          ctx.fillStyle = grad

                          var x = i * (barW + gap)
                          var y = height - barH
                          var rr = Math.min(r, barW / 2, barH / 2)

                          ctx.beginPath()
                          ctx.moveTo(x + rr, y)
                          ctx.lineTo(x + barW - rr, y)
                          ctx.arcTo(x + barW, y, x + barW, y + rr, rr)
                          ctx.lineTo(x + barW, height)
                          ctx.lineTo(x, height)
                          ctx.arcTo(x, y, x + rr, y, rr)
                          ctx.closePath()
                          ctx.fill()
                        }
                      }
                    }
                  }
                }
              }
            }
          }

          Item {
            implicitWidth: 400
            implicitHeight: 270

            Process {
              id: laptopInfoProc
              command: [Quickshell.shellDir + "/scripts/get-laptop-info.sh"]
              property var data: ({})
              stdout: SplitParser {
                onRead: data => {
                  try { laptopInfoProc.data = JSON.parse(data) } catch(e) {}
                }
              }
            }

            Timer {
              interval: 100
              running: true
              repeat: false
              triggeredOnStart: true
              onTriggered: laptopInfoProc.running = true
            }

            Rectangle {
              anchors.fill: parent
              color: Colors.isDark ? Qt.alpha(Colors.container_level_1_variant1, 0.7) : Qt.alpha(Colors.container_level_1_variant1, 0.5)
              radius: 8

              ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                RowLayout {
                  Layout.fillWidth: true
                  spacing: 12

                  // Logo
                  Image {
                    id: brandLogo
                    source: laptopInfoProc.data.logo_path ? "file://" + laptopInfoProc.data.logo_path : ""
                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 44
                    sourceSize.width: 44
                    sourceSize.height: 44
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    visible: status === Image.Ready
                  }

                  Rectangle {
                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 44
                    radius: 6
                    color: Colors.text_variant4
                    visible: brandLogo.status !== Image.Ready
                    Text {
                      anchors.centerIn: parent
                      text: ""
                      color: Colors.text
                      font.pixelSize: 20
                    }
                  }

                  // Brand + Model
                  ColumnLayout {
                    spacing: 2
                    Layout.preferredWidth: 100

                    Text {
                      text: (laptopInfoProc.data.brand || "Unknown").toUpperCase()
                      color: Colors.text_variant6
                      font.pixelSize: 16
                      font.bold: true
                      elide: Text.ElideRight
                      Layout.fillWidth: true
                    }
                    Text {
                      text: laptopInfoProc.data.model || "Loading..."
                      color: Colors.text
                      font.pixelSize: 14
                      elide: Text.ElideRight
                      Layout.fillWidth: true
                    }
                  }

                  Rectangle {
                    width: 1
                    Layout.preferredHeight: 60
                    color: Colors.outline_variant
                  }

                  ColumnLayout {
                    spacing: 4
                    Layout.fillWidth: true

                    RowLayout {
                      Layout.fillWidth: true
                      spacing: 6
                      Text { text: "OS"; font.bold: true; color: Colors.text; font.pixelSize: 12 }
                      Text {
                        text: laptopInfoProc.data.distro || "-"
                        color: Colors.text_variant1
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                      }
                    }

                    RowLayout {
                      spacing: 6
                      Text { text: "Kernel"; font.bold: true; color: Colors.text; font.pixelSize: 12 }
                      Text {
                        text: laptopInfoProc.data.kernel || "-"
                        color: Colors.text_variant1
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                      }
                    }
                  }
                }

                // Divider horizontal
                Rectangle {
                  Layout.fillWidth: true
                  height: 1
                  color: Colors.outline_variant
                }

                // ROW BOTTOM: GPU + another info
                GridLayout {
                  Layout.fillWidth: true
                  columns: 2
                  rowSpacing: 6
                  columnSpacing: 8
                  Text { text: "CPU"; font.bold: true; color: Colors.text_variant1; font.pixelSize: 12; Layout.preferredWidth: 50 }
                  Text { text: laptopInfoProc.data.cpu     || "-"; color: Colors.text; font.pixelSize: 12; elide: Text.ElideRight; Layout.fillWidth: true }
                  Text { text: "GPU"; font.bold: true; color: Colors.text_variant1; font.pixelSize: 12; Layout.preferredWidth: 50 }
                  Text { text: laptopInfoProc.data.gpu     || "-"; color: Colors.text; font.pixelSize: 12; elide: Text.ElideRight; Layout.fillWidth: true }
                  Text { text: "RAM"; font.bold: true; color: Colors.text_variant1; font.pixelSize: 12; Layout.preferredWidth: 50 }
                  Text { text: laptopInfoProc.data.ram     || "-"; color: Colors.text; font.pixelSize: 12 }
                  Text { text: "Swap"; font.bold: true; color: Colors.text_variant1; font.pixelSize: 12; Layout.preferredWidth: 50 }
                  Text { text: laptopInfoProc.data.swap    || "-"; color: Colors.text; font.pixelSize: 12 }
                  Text { text: "Disk"; font.bold: true; color: Colors.text_variant1; font.pixelSize: 12; Layout.preferredWidth: 50 }
                  Text { text: laptopInfoProc.data.disk    || "-"; color: Colors.text; font.pixelSize: 12 }
                  Text { text: "Display"; font.bold: true; color: Colors.text_variant1; font.pixelSize: 12; Layout.preferredWidth: 50 }
                  Text { text: laptopInfoProc.data.display || "-"; color: Colors.text; font.pixelSize: 12 }
                  Text { text: "Battery"; font.bold: true; color: Colors.text_variant1; font.pixelSize: 12; Layout.preferredWidth: 50 }
                  Text { text: laptopInfoProc.data.battery || "-"; color: Colors.text; font.pixelSize: 12 }
                }
              }
            }
          }
        }
      }

      Canvas {
        id: leftWing
        width: 14; height: 14
        anchors.top: mainRect.top
        anchors.right: mainRect.left
        anchors.rightMargin: -2
        anchors.topMargin: 10
        z: 10

        Connections {
          target: Colors
          function onIsDarkChanged() { leftWing.requestPaint() }
        }

        Connections {
          target: mainRect
          function onWStartChanged() { leftWing.requestPaint() }
        }

        onPaint: {
          var ctx = getContext("2d")
          ctx.reset()
          ctx.fillStyle = mainRect.topbarColorAt(mainRect.wStart).toString()
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
        anchors.top: mainRect.top
        anchors.right: mainRect.left
        anchors.rightMargin: -2
        anchors.topMargin: 10
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
        anchors.top: mainRect.top
        anchors.left: mainRect.right
        anchors.leftMargin: -2
        anchors.topMargin: 10

        Connections {
          target: Colors
          function onIsDarkChanged() { rightWing.requestPaint() }
        }

        Connections {
          target: mainRect
          function onWEndChanged() { rightWing.requestPaint() }
        }

        z: 10
        onPaint: {
          var ctx = getContext("2d")
          ctx.reset()
          ctx.fillStyle = mainRect.topbarColorAt(mainRect.wEnd).toString()
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
        anchors.top: mainRect.top
        anchors.left: mainRect.right
        anchors.leftMargin: -2
        anchors.topMargin: 10

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

      Rectangle {
        id: topPatch
        height: 12
        gradient: Gradient {
          orientation: Gradient.Horizontal
          GradientStop { position: 0.0;   color: mainRect.topbarColorAt(mainRect.wStart) }
          GradientStop { position: (0.2 - mainRect.wStart) / (mainRect.wEnd - mainRect.wStart); color: mainRect.topbarColorAt(0.2) }
          GradientStop { position: (0.4 - mainRect.wStart) / (mainRect.wEnd - mainRect.wStart); color: mainRect.topbarColorAt(0.4) }
          GradientStop { position: (0.6 - mainRect.wStart) / (mainRect.wEnd - mainRect.wStart); color: mainRect.topbarColorAt(0.6) }
          GradientStop { position: (0.8 - mainRect.wStart) / (mainRect.wEnd - mainRect.wStart); color: mainRect.topbarColorAt(0.8) }
          GradientStop { position: 1.0;   color: mainRect.topbarColorAt(mainRect.wEnd) }
        }
        anchors.top: mainRect.top
        anchors.left: mainRect.left
        anchors.right: mainRect.right
      }
    }
  }
}

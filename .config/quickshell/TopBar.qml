import QtQuick
import Quickshell.Io
import QtQuick.Layouts 
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray

PanelWindow {
  id: topBar
  signal toggleClicked()
  signal menuClicked()
  signal panelClicked()
  signal weatherHovered()
  signal weatherUnhovered()
  signal clipboardClicked()
  property bool isOpen: false
  property bool isMenuOpen: false
  property bool anyPanelOpen: false
  anchors { top: true; left: true; right: true }
  implicitHeight: 30 
  color: "transparent"
  property int borderHeight: 2

  Timer {
    id: batteryHideTimer
    interval: 200
    onTriggered: batteryPopup.visible = false
  }

  Timer {
    id: btHideTimer
    interval: 200
    onTriggered: btPopup.visible = false
  }


  Timer {
    id: weatherHideTimer
    interval: 200
    onTriggered: weatherPopup.visible = false
  }

  Timer {
    id: wifiHideTimer
    interval: 200
    onTriggered: wifiPopup.visible = false
  }

  // Background 
  Rectangle {
    id: topPanel
    anchors.fill: parent
    antialiasing: true
    layer.enabled: true
    
    gradient: Gradient {
      orientation: Gradient.Horizontal 
      GradientStop { position: 0.0; color: Colors.isDark ? Colors.surface : Colors.surface }
      GradientStop { position: 0.2; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.primaryFixed   }
      GradientStop { position: 0.4; color: Colors.isDark ? Colors.surfaceContainerLow : Colors.surface  }
      GradientStop { position: 0.6; color: Colors.isDark ? Colors.overPrimaryFixed : Colors.primaryFixed  }
      GradientStop { position: 0.8; color: Colors.isDark ? Colors.surface : Colors.surface  }
      GradientStop { position: 1.0; color: Colors.isDark ? Colors.overSecondaryFixed : Colors.secondaryFixedDim  }
    }
        
    Rectangle {
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      height: topBar.borderHeight            
      border.width: 2 
      border.color: Colors.outlineVariant

      anchors.leftMargin: 28 
      anchors.rightMargin: 28
    }

    RowLayout {
      anchors.fill: parent
      anchors.leftMargin: 15 
      anchors.rightMargin: 15
      spacing: 11
      transform: Translate { y: -1 }

      Text {
        id: leftWidget
        text: " "
        font.pixelSize: 14
        color: Colors.isDark ? Colors.primary : Colors.overPrimaryFixedVariant
        font.bold: true

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: topBar.menuClicked()
        }
      }

      RowLayout {
        spacing: 4

        Rectangle {
          id: workspaceRect
          Layout.alignment: Qt.AlignVCenter
          Layout.preferredWidth: workspaceLayout.width + 10 
          height: 20
          color: Colors.isDark ? Colors.surfaceContainerHigh : Qt.alpha(Colors.tertiaryFixedDim, 0.5)
          radius: 14
          
          property var workspaceList: []

          Process {
            id: hyprDispatch
            running: false 
            command: []    
          }

          Process {
            id: workProc
            running: true
            command: ["bash", Quickshell.shellDir + "/scripts/get-workspaces.sh"]
            
            stdout: SplitParser {
              onRead: function(data) {
                try {
                  if (data.trim() !== "") {
                    var newList = JSON.parse(data).sort((a, b) => a.id - b.id)
                    if (JSON.stringify(newList) !== JSON.stringify(workspaceRect.workspaceList)) {
                      workspaceRect.workspaceList = newList
                    }
                  }
                } 
                catch(e) {
                  console.log("JSON Error: " + e)
                }
              }
            } 
          }

          RowLayout {
            id: workspaceLayout
            anchors.centerIn: parent
            spacing: 7 

            Repeater {
              id: workspaceRepeater
              model: workspaceRect.workspaceList

              Item {
                id: workspaceItem
                width: hasApp ? (appRow.width+6) : (modelData.focused ? 14 : 10)
                height: 14

                property var workspaceData: modelData 
                property bool isFocused: modelData.focused
                property bool hasApp: modelData.apps && modelData.apps.length > 0

                property int offset: 0
                property int maxVisible: 3
                property var visibleApps: {
                  var all = workspaceData.apps
                  if (!all || all.length <= maxVisible) return all ?? []
                  var result = []
                  for (var i = 0; i < maxVisible; i++) {
                      result.push(all[(offset + i) % all.length])
                  }
                  return result
                }

                Timer {
                  interval: 5000
                  running: workspaceItem.workspaceData.apps && workspaceItem.workspaceData.apps.length > workspaceItem.maxVisible
                  repeat: true
                  onTriggered: workspaceItem.offset = (workspaceItem.offset + 1) % workspaceItem.workspaceData.apps.length
                }

                Rectangle{
                  anchors.fill: appRow
                  anchors.topMargin: -1    
                  anchors.bottomMargin: -1
                  anchors.leftMargin: -5 
                  anchors.rightMargin: -5
                  radius: 14
                  visible: parent.hasApp

                  color: workspaceItem.isFocused 
                    ? Colors.isDark ? Qt.alpha(Colors.primaryContainer, 0.8) : Qt.alpha(Colors.primary, 0.4)
                    : Qt.alpha(Colors.isDark ? Colors.secondaryContainer : Colors.surfaceContainerHigh, 0.8)
                  Behavior on color { ColorAnimation { duration: 200 } }
                }

                Row {
                  id: appRow
                  anchors.centerIn: parent
                  spacing: 3 
                  visible: parent.hasApp

                  Repeater {
                    model: workspaceItem.visibleApps

                    Image {
                      width: 14
                      height: 14
                      fillMode: Image.PreserveAspectFit
                      smooth: true
                      sourceSize: Qt.size(14, 14)
                      source: {
                        var cls = modelData.class.toLowerCase()
                        
                        var entry = DesktopEntries.byId(cls)
                        if (!entry) {
                          var all = DesktopEntries.applications.values
                          for (var i = 0; i < all.length; i++) {
                            if (all[i].id.toLowerCase() === cls || 
                              all[i].name.toLowerCase() === cls) {
                              entry = all[i]
                              break
                            }
                          }
                        }
                        
                        if (entry && entry.icon) {
                          var path = Quickshell.iconPath(entry.icon, true)
                          if (path) return path
                        }
                        
                        var path2 = Quickshell.iconPath(cls, true)
                        if (path2) return path2
                        
                        return Qt.resolvedUrl(Quickshell.shellDir + "/assets/error.png")
                      }
                      opacity: workspaceItem.isFocused ? 1.0 : 0.5
                      Behavior on opacity { NumberAnimation { duration: 300 } }
                    }          
                  }
                }

                Rectangle {
                  anchors.centerIn: parent
                  width: modelData.focused ? 14 : 8
                  height: modelData.focused ? 14 : 8
                  radius: 10
              
                  visible: !parent.hasApp 

                  color: modelData.focused 
                    ? Qt.alpha(Colors.isDark ? Colors.primaryContainer : Colors.primary, 0.8) 
                    : Qt.alpha(Colors.isDark ? Colors.primary : Colors.overPrimaryFixedVariant, 0.7)
              
                  Behavior on width { NumberAnimation { duration: 200 } }
                  Behavior on color { ColorAnimation { duration: 200 } }
                }

                MouseArea {
                  anchors.fill: parent
                  hoverEnabled: true
                  onClicked: {
                    hyprDispatch.command = ["hyprctl", "dispatch", "workspace", modelData.id.toString()]
                    hyprDispatch.running = true
                  }
                }
              } 
            }
          }
        }

        Rectangle {
          width: dateLayout.implicitWidth + 15
          Layout.alignment: Qt.AlignVCenter
          height: 20
          color: Colors.isDark ? Qt.alpha(Colors.surfaceContainerHigh, 0.9) : Qt.alpha(Colors.tertiaryFixedDim, 0.7)
          radius: 15

          Text {
            id: dateLayout
            anchors.centerIn: parent
            text: Qt.formatDate(new Date(), "ddd, dd MMM")
            color: Colors.overSurfaceVariant
            font.pixelSize: 11
            font.family: "JetBrainsMono Nerd Font"
          }
        }
      }

      RowLayout {
        id: weatherRow
        spacing: 4
        Layout.alignment: Qt.AlignVCenter
        property string wIcon: ""
        property string wText: "Loading..."
        property string wColor: Colors.overSurfaceVariant

        Timer {
          interval: 600000
          running: true
          repeat: true
          triggeredOnStart: true
          onTriggered: weatherProc.running = true
        }

        Process {
          id: weatherProc
          command: ["bash", Quickshell.shellDir + "/scripts/weather-wrapper.sh", "json"]
          stdout: SplitParser {
            onRead: (data) => {
              try {
                var res = JSON.parse(data)
                weatherRow.wIcon = res.icon
                weatherRow.wColor = res.color
                weatherRow.wText = res.text
              } 
              catch (e) {
                console.log("Weather JSON Error: " + e)
              }
            }
          }
        }

        Text {
          id: iconText
          text: weatherRow.wIcon
          color: Colors.isDark ? Colors.overSurfaceVariant : Colors.overPrimaryFixedVariant
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: 14
        }

        Text {
          id: labelText
          text: weatherRow.wText
          color: Colors.isDark ? Colors.overSurfaceVariant : Colors.overPrimaryFixedVariant
          font.family: "JetBrainsMono Nerd Font"
          font.pixelSize: 10
          font.bold: true
          HoverHandler {
            onHoveredChanged: {
              if (hovered && !topBar.isOpen && !topBar.isMenuOpen) {
                weatherPopup.visible = true
                weatherPopup.isShowing = true
              } 
              else {
                weatherPopup.isShowing = false
                weatherHideTimer.start()
              }
            }
          }
        }
      }

      // Spacer
      Item { 
        Layout.fillWidth: true 
      }

      Row {
        id: trayRow
        spacing: 4
        Layout.alignment: Qt.AlignVCenter

        property int minVisible: 3
        property int maxVisible: 5
        property bool expanded: false
        property int offset: 0

        property var visibleItems: {
          var all = SystemTray.items.values
          if (!all || all.length === 0) return []
          if (!expanded) return all.slice(0, minVisible)
          if (all.length <= maxVisible) return all
          var result = []
          for (var i = 0; i < maxVisible; i++) {
              result.push(all[(offset + i) % all.length])
          }
          return result
        }

        // left : expand (default) or scroll left (expanded)
        Item {
          width: SystemTray.items.values.length > trayRow.minVisible ? 16 : 0
          height: 14
          clip: true

          Text {
            anchors.centerIn: parent
            text: "‹"
            color: trayRow.expanded ? Colors.primary : Colors.overSurface
            font.pixelSize: 16
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (!trayRow.expanded) {
                trayRow.expanded = true
                trayRow.offset = 0
              } 
              else {
                var all = SystemTray.items.values
                trayRow.offset = (trayRow.offset - 1 + all.length) % all.length
              }
            }
          }
        }

        // Icons
        Repeater {
          model: trayRow.visibleItems

          Item {
            width: 14
            height: 14
            clip: true

            Image {
              anchors.centerIn: parent
              width: 12
              height: 12
              source: modelData.icon
              fillMode: Image.PreserveAspectFit
              smooth: true
              sourceSize: Qt.size(12, 12)
            }

            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton | Qt.RightButton
              onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) modelData.display()
                else modelData.activate()
              }
            }
          }
        }

        // for collapse
        Item {
          width: trayRow.expanded ? 16 : 0
          height: 14
          clip: true

          Text {
            anchors.centerIn: parent
            text: "›"
            color: Colors.overSurface
            font.pixelSize: 16
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                trayRow.expanded = false
                trayRow.offset = 0
            }
          }
        }
      }

      Row {
        spacing: 4

        Rectangle {
          id: wifiRect
          width: wifiLayout.width + 20
          height: 20
          color: Colors.isDark ? Qt.alpha(Colors.surfaceContainerHigh, 0.9) : Qt.alpha(Colors.tertiaryFixedDim, 0.7)
          radius: 15

          property string wifiData: "..."

          Timer {
            interval: 2000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: wifiProc.running = true
          }

          Process {
            id: wifiProc
            command: ["bash", Quickshell.shellDir + "/scripts/wifi-status.sh"]
            stdout: SplitParser {
              onRead: (data) => {
                try {
                  var result = JSON.parse(data)
                  wifiRect.wifiData = result.wifi
                } 
                catch (e) {
                  console.log("JSON Error: " + e)
                }
              }
            }
          }

          RowLayout {
            id: wifiLayout
            anchors.centerIn: parent
            Text {
              text: wifiRect.wifiData
              color: Colors.overSurfaceVariant
              font.family: "JetBrainsMono Nerd Font"
              font.pixelSize: 9
            }

            HoverHandler {
              id: wifiHover
              onHoveredChanged: {
                if (hovered && !topBar.isOpen && !topBar.anyPanelOpen) {
                  var globalX = wifiRect.mapToGlobal(wifiRect.width, 0).x 
                  wifiPopup.globalAnchorX = globalX

                  var centerX = globalX - (wifiPopup.implicitWidth / 2 + wifiRect.width / 2)
                  var tooltipWidth = wifiTooltipContent.implicitWidth + 28
                  wifiTooltipContent.tooltipStart = centerX / topBar.width
                  wifiTooltipContent.tooltipEnd = (centerX + tooltipWidth) / topBar.width

                  wifiPopup.visible = true
                  wifiPopup.isShowing = true
                } else {
                  wifiPopup.isShowing = false
                  wifiHideTimer.start()
                }
              }
            }
          }
        }

        // Rectangle 2: Battery
        Rectangle {
          id: batteryRect
          width: batLayout.width + 20
          height: 20
          color: Colors.isDark ? Qt.alpha(Colors.surfaceContainerHigh, 0.9) : Qt.alpha(Colors.tertiaryFixedDim, 0.7)
          radius: 15

          property string batData: "..."

          Timer {
            interval: 2000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: batProc.running = true
          }

          Process {
            id: batProc
            command: ["bash", Quickshell.shellDir + "/scripts/wifi-status.sh"]
            stdout: SplitParser {
              onRead: (data) => {
                try {
                  var result = JSON.parse(data)
                  batteryRect.batData = result.battery
                } catch (e) {
                  console.log("JSON Error: " + e)
                }
              }
            }
          }

          RowLayout {
            id: batLayout
            anchors.centerIn: parent
            spacing: 8

            Text {
              text: batteryRect.batData
              color: Colors.overSurfaceVariant
              font.family: "JetBrainsMono Nerd Font"
              font.pixelSize: 9
              HoverHandler {
                onHoveredChanged: {
                  if (hovered && !topBar.anyPanelOpen) {
                    var globalX = batteryRect.mapToGlobal(batteryRect.width, 0).x 
                    batteryPopup.globalAnchorX = globalX

                    var centerX = globalX - (batteryPopup.implicitWidth / 2 + batteryRect.width / 2)
                    var tooltipWidth = batteryTooltipContent.implicitWidth + 28
                    batteryTooltipContent.tooltipStart = centerX / topBar.width
                    batteryTooltipContent.tooltipEnd = (centerX + tooltipWidth) / topBar.width

                    batteryPopup.visible = true
                    batteryPopup.isShowing = true
                  } else {
                    batteryPopup.isShowing = false
                    batteryHideTimer.start()
                  }
                }
              }
            }
          }
        }

        Rectangle {
          id: btRect
          width: btLayout.implicitWidth + 19
          height: 20
          color: Colors.isDark ? Qt.alpha(Colors.surfaceContainerHigh, 0.9) : Qt.alpha(Colors.tertiaryFixedDim, 0.7)
          radius: 15

          RowLayout {
            id: btLayout
            anchors.centerIn: parent
            spacing: 0

            Text {
              text: BluetoothService.icon
              color: Colors.overSurfaceVariant
              font.pixelSize: 12
              font.family: "JetBrainsMono Nerd Font"
              Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
              HoverHandler {
                onHoveredChanged: {
                  if (hovered  && !topBar.anyPanelOpen) {
                    var globalX = btRect.mapToGlobal(btRect.width, 0).x
                    btPopup.globalAnchorX = globalX
                    var centerX = globalX - (btPopup.implicitWidth / 2 + btRect.width / 2)
                    var tooltipWidth = btTooltipContent.implicitWidth + 28
                    btTooltipContent.tooltipStart = centerX / topBar.width
                    btTooltipContent.tooltipEnd = (centerX + tooltipWidth) / topBar.width
                    btPopup.visible = true
                    btPopup.isShowing = true
                  } 
                  else {
                    btPopup.isShowing = false
                    btHideTimer.start()
                  }
                }
              }
            }
          }
        }

        Rectangle {
          width: 28
          height: 20
          color: Colors.isDark ? Qt.alpha(Colors.surfaceContainerHigh, 0.9) : Qt.alpha(Colors.tertiaryFixedDim, 0.7)
          radius: 15
          Layout.alignment: Qt.AlignVCenter

          Text {
            anchors.centerIn: parent
            text: "󰅍"
            color: Colors.overSurfaceVariant
            font.pixelSize: 12
            font.family: "JetBrainsMono Nerd Font"
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              topBar.clipboardClicked()
            }
          }
        }

        Rectangle {
          id: sysStatusRect
          width: sysLayout.width + 15
          height: 20
          color: Colors.isDark ? Qt.alpha(Colors.surfaceContainerHigh, 0.9) : Qt.alpha(Colors.tertiaryFixedDim, 0.7)
          radius: 15

          property string brightIcon: "..."
          property string volIcon: "..."

          Timer {
            interval: 2000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: sysProc.running = true
          }

          Process {
            id: sysProc
            command: ["bash", Quickshell.shellDir + "/scripts/wifi-status.sh"]
            stdout: SplitParser {
              onRead: (data) => {
                try {
                  var result = JSON.parse(data)
                  sysStatusRect.brightIcon = result.brightness
                  sysStatusRect.volIcon = result.volume
                } catch (e) {
                  console.log("JSON Error: " + e)
                }
              }
            }
          }

          RowLayout {
            id: sysLayout
            anchors.centerIn: parent
            spacing: 8

            Row {
              spacing: 6
              Text {
                text: sysStatusRect.brightIcon
                color: Colors.overSurfaceVariant
                font.pixelSize: 10
                font.family: "JetBrainsMono Nerd Font"
              }
              Text {
                text: sysStatusRect.volIcon
                color: Colors.overSurfaceVariant
                font.pixelSize: 10
                font.family: "JetBrainsMono Nerd Font"
              }
            }
          }
        }
      }

      Row {
        Layout.alignment: Qt.AlignVCenter
        spacing: 4

        Text {
          text: "󰃭"           
          color: Colors.overSurface 
          font.family: "JetBrainsMono Nerd Font" 
          font.pixelSize: 13
          anchors.verticalCenter: parent.verticalCenter
        }

        Text {
          id: clock
          color: Colors.overSurfaceVariant
          font.family: "Iosevka Nerd Font"
          font.pixelSize: 12
          font.bold: true
          text: Qt.formatDateTime(new Date(), "hh:mm")
          anchors.verticalCenter: parent.verticalCenter

          Timer {
            interval: 1000; running: true; repeat: true
            onTriggered: parent.text = Qt.formatDateTime(new Date(), "hh:mm")
          }
        }
      }

      Text {
        text: ""
        color: Colors.overSurfaceVariant
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: topBar.panelClicked()
        }
      }
    }

    Rectangle {
      id: centerWidget
      anchors.centerIn: parent 
      transform: Translate { y: -1 } 
      width: Math.min(300, windowTitle.contentWidth + 24)
      height: 22
      color: "transparent"
      radius: 12

      Row {
        anchors.centerIn: parent
        spacing: 5

        Text {
          anchors.verticalCenter: parent.verticalCenter
          font.family: "Iosevka Nerd Font"
          text: " "
          color: Colors.isDark ? Colors.primaryFixed : Colors.overPrimaryFixed
          font.pixelSize: 12
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          id: windowTitle
          font.family: "Iosevka Nerd Font"
          text: "Desktop"
          color: Colors.isDark ? Colors.primaryFixed : Colors.overPrimaryFixed
          font.pixelSize: 12
          font.bold: true

          Process {
            command: ["bash", Quickshell.shellDir + "/scripts/xwindow-clickable.sh"]
            running: true
            stdout: SplitParser {
              onRead: (data) => { windowTitle.text = data }
            }
          }
        }
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
          topBar.toggleClicked()
        }
      }
    }
  }

  PopupWindow {
    id: wifiPopup
    visible: false
    property bool isShowing: false
    property real anchorX: 0
    property real globalAnchorX: 0

    anchor {
      window: topBar
      edges: Edges.Bottom
      rect: Qt.rect(
        wifiPopup.globalAnchorX - (wifiPopup.implicitWidth / 2 + wifiRect.width / 2 ),
        0,
        0,
        topBar.implicitHeight - topBar.borderHeight
      )
    }

    implicitWidth: wifiTooltipContent.implicitWidth + 28
    implicitHeight: wifiTooltipContent.implicitHeight
    color: "transparent"

    Item {
      anchors.fill: parent

      opacity: wifiPopup.isShowing ? 1 : 0

      Behavior on opacity {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
      }

      transform: Translate {
        y: wifiPopup.isShowing ? 0 : -10
        Behavior on y {
          NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
      }

      WifiTooltip {
        id: wifiTooltipContent
        anchors.centerIn: parent
        
      }
    }
  }

  PopupWindow {
    id: weatherPopup
    visible: false
    property bool isShowing: false

    anchor {
      window: topBar
      edges: Edges.Bottom
      rect: Qt.rect(
        weatherRow.x,
        0,
        0,
        topBar.implicitHeight - topBar.borderHeight
      )
    }

    implicitWidth: weatherContent.implicitWidth + 28
    implicitHeight: weatherContent.implicitHeight
    color: "transparent"

    Item {
      id: animatedContainer
      anchors.fill: parent

      opacity: weatherPopup.isShowing ? 1 : 0
      Behavior on opacity {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
      }

      transform: Translate {
        y: weatherPopup.isShowing ? 0 : -10
        Behavior on y {
          NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
      }

      WeatherTooltip {
        id: weatherContent
        anchors.centerIn: parent
        tooltipStart: weatherRow.x / topPanel.width
        tooltipEnd: (weatherRow.x + 260) / topPanel.width
      }
    }
  } 


  PopupWindow {
    id: batteryPopup
    visible: false
    property bool isShowing: false
    property real anchorX: 0
    property real globalAnchorX: 0

    anchor {
      window: topBar
      edges: Edges.Bottom
      rect: Qt.rect(
        batteryPopup.globalAnchorX - (batteryPopup.implicitWidth / 2 + batteryRect.width / 2 ),
        0,
        0,
        topBar.implicitHeight - topBar.borderHeight
      )
    }

    implicitWidth: batteryTooltipContent.implicitWidth + 28
    implicitHeight: batteryTooltipContent.implicitHeight
    color: "transparent"

    Item {
      anchors.fill: parent

      opacity: batteryPopup.isShowing ? 1 : 0
      Behavior on opacity {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
      }

      transform: Translate {
        y: batteryPopup.isShowing ? 0 : -10
        Behavior on y {
          NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
      }

      BatteryTooltip {
        id: batteryTooltipContent
        anchors.centerIn: parent
      }
    }
  }

  PopupWindow {
    id: btPopup
    visible: false
    property bool isShowing: false
    property real globalAnchorX: 0

    anchor {
      window: topBar
      edges: Edges.Bottom
      rect: Qt.rect(
        btPopup.globalAnchorX - (btPopup.implicitWidth / 2 + btRect.width / 2),
        0,
        0,
        topBar.implicitHeight - topBar.borderHeight
      )
    }

    implicitWidth: btTooltipContent.implicitWidth + 28
    implicitHeight: btTooltipContent.implicitHeight
    color: "transparent"

    Item {
      anchors.fill: parent
      opacity: btPopup.isShowing ? 1 : 0
      Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
      transform: Translate {
        y: btPopup.isShowing ? 0 : -10
        Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
      }

      BluetoothTooltip {
        id: btTooltipContent
        anchors.centerIn: parent
      }
    }
  }
}

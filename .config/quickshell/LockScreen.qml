import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam

Rectangle {
  id: root
  signal unlocked()
  anchors.fill: parent
  color: "#000000"

  property string lockState: "idle"
  property var lockStatus: ({})

  Image {
    id: wallpaperImage
    anchors.fill: parent
    fillMode: Image.PreserveAspectCrop
    source: "file://" + Quickshell.env("HOME") + "/.config/m3-colors/current_wallpaper"

    layer.enabled: root.lockState === "login" || root.lockState === "unlocking"
    layer.effect: MultiEffect {
      blurEnabled: true
      blur: 1.0
      blurMax: 64
    }
  }

  Rectangle {
    anchors.fill: parent
    color: "#000000"
    opacity: root.lockState === "unlocking" ? 1 : root.lockState === "login" ? 0.55 : 0.45

    Behavior on opacity {
      NumberAnimation { duration: 400; easing.type: Easing.InOutQuad }
    }
  }

  // Process for reach status
  Process {
      id: statusProcess
      command: ["bash", Quickshell.shellDir + "/scripts/lock-status.sh"]
      running: true

    stdout: SplitParser {
      onRead: data => {
        try {
          root.lockStatus = JSON.parse(data)
        } 
        catch(e) {
          console.log("JSON parse error:", e, data)
        }
      }
    }
  }

  Timer {
    running: true
    repeat: true
    interval: 5000
    onTriggered: statusProcess.running = true
  }

  // Status icons 
  Row {
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.margins: 30
    spacing: 16

    Text {
      text: root.lockStatus.wifi ?? ""
      color: Colors.isDark ? Colors.overSurface : Colors.surface
      font.pixelSize: 14
      width: 14
      horizontalAlignment: Text.AlignHCenter
    }

    Text {
      text: root.lockStatus.battery ?? ""
      color: Colors.isDark ? Colors.overSurface : Colors.surface
      font.pixelSize: 14
      width: 14
      horizontalAlignment: Text.AlignHCenter
    }

    Text {
      text: root.lockStatus.volume ?? ""
      color: Colors.isDark ? Colors.overSurface : Colors.surface
      font.pixelSize: 14
      width: 14
    }
  }

  // Date Status
  Row {
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.margins: 30
    spacing: 4

    Text {
      text: Qt.formatDate(new Date(), "dddd") + "," 
      color: Colors.isDark ? Colors.overSurface : Colors.surface
      font.pixelSize: 14
      font.bold: true
    }

    Text {
      text: Qt.formatDate(new Date(), "dd MMMM yyyy")
      color: Colors.isDark ? Colors.overSurface : Colors.surface
      font.pixelSize: 14 
      font.bold: true

    }
  }

  // STATE 1: Idle 
  Column {
    id: idleView
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    spacing: 0
    opacity: root.lockState === "idle" ? 1 : 0
    anchors.verticalCenterOffset: root.lockState === "idle" ? 0 : 60

    Behavior on opacity {
      NumberAnimation { duration: 350; easing.type: Easing.InOutQuad }
    }
    Behavior on anchors.verticalCenterOffset {
      NumberAnimation { duration: 350; easing.type: Easing.InOutQuad }
    }

    property var now: new Date()

    Timer {
      running: true; repeat: true; interval: 1000
      onTriggered: idleView.now = new Date()
    }

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      color: Colors.isDark ? Colors.primary : Colors.primaryFixed
      font.family: "Iosevka Nerd Font"
      font.pixelSize: 110
      topPadding: 0
      bottomPadding: 0
      text: idleView.now.getHours().toString().padStart(2, '0')
    }

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      color: Colors.isDark ? Colors.overSurface : Colors.overPrimary
      font.family: "Iosevka Nerd Font"
      font.pixelSize: 110
      topPadding: 0
      bottomPadding: 0
      text: idleView.now.getMinutes().toString().padStart(2, '0')
    }
  }

  // Press any key 
  Text {
    id: pressAnyKey
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 20
    text: "Press any key to unlock"
    color: Colors.isDark ? Colors.overSurface : Colors.primaryFixed
    font.pixelSize: 14
    opacity: 0

    SequentialAnimation {
      running: root.lockState === "idle"
      loops: Animation.Infinite
      onRunningChanged: {
        if (!running) pressAnyKey.opacity = 0
      }

      NumberAnimation {
        target: pressAnyKey
        property: "opacity"
        from: 0; to: 1
        duration: 1000
        easing.type: Easing.InOutQuad
      }
      PauseAnimation { duration: 1500 }
      NumberAnimation {
        target: pressAnyKey
        property: "opacity"
        from: 1; to: 0
        duration: 1000
        easing.type: Easing.InOutQuad
      }
      PauseAnimation { duration: 500 }
    }
  }

    // STATE 2: Login
  Rectangle {
    id: loginView
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: root.lockState === "login" ? 0 : -60

    width: 300
    height: loginColumn.implicitHeight + 48
    color: Qt.rgba(1, 1, 1, 0.06)
    radius: 16

    opacity: root.lockState === "login" ? 1 : 0

    Behavior on opacity {
      enabled: root.lockState !== "unlocking"
      NumberAnimation { duration: 350; easing.type: Easing.InOutQuad }
    }

    Behavior on anchors.verticalCenterOffset {
      enabled: root.lockState !== "unlocking"
      NumberAnimation { duration: 350; easing.type: Easing.InOutQuad }
    }

    Column {
      id: loginColumn
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      spacing: 16

      Image {
        anchors.horizontalCenter: parent.horizontalCenter
        source: "file://" + Quickshell.shellDir + "/assets/profile.jpg"
        width: 90
        height: 90
        fillMode: Image.PreserveAspectCrop
        layer.enabled: true
        layer.effect: MultiEffect {
          maskEnabled: true
          maskSource: ShaderEffectSource {
            sourceItem: Rectangle {
              width: 90; height: 90
              radius: 45
            }
          }
        }
      }

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Quickshell.env("USER")
        color: "white"
        font.pixelSize: 16
      }

      TextField {
        id: passwordField
        width: 252
        placeholderText: "Password..."
        echoMode: TextInput.Password
        placeholderTextColor: "#aaaaaa"

        palette.text: "white"
        palette.base: "transparent"
        palette.highlight: Qt.rgba(1, 1, 1, 0.06)
        palette.highlightedText: "white"

        background: Rectangle {
          color: Qt.rgba(1, 1, 1, 0.06)
          radius: 8
        }

        Keys.onPressed: event => {
          if (event.key === Qt.Key_Escape) {
            event.accepted = true
            switchToIdle()
          }
        }

        onAccepted: {
          if (passwordField.text === "") return
          errorText.visible = false
          pam.start()
        }
      }

      Text {
        id: errorText
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Wrong password!"
        color: Colors.error
        visible: false
      }

      Timer {
        id: errorTimer
        interval: 2000
        onTriggered: errorText.visible = false
      }
    }
  }

  SequentialAnimation {
    id: unlockAnimation

    ScriptAction {
      script: root.lockState = "unlocking"
    }

    ParallelAnimation {
      NumberAnimation {
        target: loginView
        property: "anchors.verticalCenterOffset"
        to: -80
        duration: 350
        easing.type: Easing.InOutQuad
      }
      NumberAnimation {
        target: loginView
        property: "opacity"
        to: 0
        duration: 350
        easing.type: Easing.InOutQuad
      }
    }

    PauseAnimation { duration: 150 }

    ScriptAction {
      script: root.unlocked()
    }
  }

  MouseArea {
    anchors.fill: parent
    enabled: root.lockState === "idle"
    onClicked: switchToLogin()
  }

  Keys.onPressed: event => {
    if (root.lockState === "idle") {
      switchToLogin()
      event.accepted = true
    }
  }
  focus: true

  function switchToLogin() {
    root.lockState = "login"
    passwordField.forceActiveFocus()
  }

  function switchToIdle() {
    root.lockState = "idle"
    passwordField.clear()
    errorText.visible = false
    errorTimer.stop()
    pam.abort()
  }

  PamContext {
    id: pam
    configDirectory: Qt.resolvedUrl("pam").toString().replace("file://", "")
    config: "password.conf"

    onPamMessage: {
      if (this.responseRequired) {
          this.respond(passwordField.text)
      }
    }

    onCompleted: result => {
      if (root.lockState !== "login") return
      if (result === PamResult.Success) {
        unlockAnimation.start()
      } else {
        passwordField.clear()
        errorText.visible = true
        errorTimer.start()
      }
    }
  }
}

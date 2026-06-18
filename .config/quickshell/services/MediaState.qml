pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property var mediaData: ({})
  property var playerList: []
  property string selectedPlayer: ""

  function executePlayerctl(action) {
    if (mediaData.player) {
      controlProcess.command = ["playerctl", "-p", mediaData.player, action]
      controlProcess.running = true
    }
  }

  Process {
    id: mediaProcess
    command: root.selectedPlayer !== ""
    ? [Quickshell.shellDir + "/scripts/media_listener.py", "--watch", root.selectedPlayer]
    : [Quickshell.shellDir + "/scripts/media_listener.py", "--watch"]
    running: true
    stdout: SplitParser {
      onRead: data => {
        try { root.mediaData = JSON.parse(data) }
        catch (e) { console.log("MediaState parse error:", e) }
      }
    }
  }

  Process {
    id: listProcess
    command: [Quickshell.shellDir + "/scripts/media_listener.py", "--list"]
    running: true
    stdout: SplitParser {
      onRead: data => {
        try { root.playerList = JSON.parse(data) }
        catch (e) { console.log("MediaState list error:", e) }
      }
    }
  }

  Timer {
    interval: 3000
    running: true
    repeat: true
    onTriggered: {
      listProcess.running = false
      listProcess.running = true
    }
  }

  Process {
    id: controlProcess
    running: false
  }

  onSelectedPlayerChanged: {
    mediaProcess.running = false
    mediaProcess.running = true
  }
}

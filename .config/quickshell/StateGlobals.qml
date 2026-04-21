pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property string colorEngine: "warnaza"
  property bool ready: false

  property string configPath: colorEngine === "m3wal"
  ? Quickshell.env("HOME") + "/.config/m3-colors/m3-colors.conf"
  : Quickshell.env("HOME") + "/.config/warnaza/warnaza.conf"

  Component.onCompleted: readProcess.running = true

  Process {
    id: readProcess
    command: ["bash", "-c",
      "grep '^color_engine = ' " + Quickshell.env("HOME") +
      "/.config/bagja-shell/config.conf | awk '{print $3}'"]
    running: false
    stdout: SplitParser {
      onRead: data => {
        var v = data.trim()
        if (v !== "") root.colorEngine = v
        root.ready = true
      }
    }
  }

  onColorEngineChanged: {
    if (!ready) return
    saveProcess.command = ["bash", "-c",
      "mkdir -p " + Quickshell.env("HOME") + "/.config/bagja-shell && " +
      "grep -q '^color_engine = ' " + Quickshell.env("HOME") + "/.config/bagja-shell/config.conf" +
      " && sed -i 's/^color_engine = .*/color_engine = " + colorEngine + "/' " +
      Quickshell.env("HOME") + "/.config/bagja-shell/config.conf" +
      " || echo 'color_engine = " + colorEngine + "' >> " +
      Quickshell.env("HOME") + "/.config/bagja-shell/config.conf"]
    saveProcess.running = true
  }

  Process { id: saveProcess; running: false }

  // Date and Time

  SystemClock {
    id: globalClockSec
    precision: SystemClock.Seconds
  }

  SystemClock {
    id: globalClockMin
    precision: SystemClock.Minutes
  }

  readonly property var clockDate: globalClockSec.date
  readonly property var clockDateMin: globalClockMin.date

  // System Status
  property string wifiIcon: ""
  property string wifiDesc: ""
  property string wifiSSID: ""
  property string wifiSignal: ""
  property string wifiSecurity: ""
  property string btDevices: ""
  property string btConnected: ""
  property string btPowered: ""
  property bool wifiConnected: false
  property string batIcon: ""
  property string batDesc: ""
  property string batModel: ""
  property int batCapacity: 0
  property bool batCharging: false
  property string brightIcon: ""
  property string brightDesc: ""
  property int brightPct: 0
  property string volIcon: ""
  property string volDesc: ""
  property int volPct: 0
  property bool volMuted: false

  Process {
    id: systemProc
    command: ["python3", "-u", Quickshell.shellDir + "/scripts/system-status.py"]
    running: true 

    stdout: SplitParser {
      onRead: (data) => {
        try {
          var res = JSON.parse(data)
          root.wifiIcon      = res.wifi_icon
          root.wifiDesc      = res.wifi_desc
          root.wifiConnected = res.wifi_connected
          root.wifiSSID      = res.wifi_ssid
          root.wifiSignal    = res.wifi_signal
          root.wifiSecurity  = res.wifi_security
          root.btDevices     = res.bt_devices
          root.btConnected   = res.bt_connected
          root.btPowered     = res.bt_powered
          root.batIcon       = res.bat_icon
          root.batDesc       = res.bat_desc
          root.batModel      = res.bat_model
          root.batCapacity   = res.bat_capacity
          root.batCharging   = res.bat_charging
          root.brightIcon    = res.bright_icon
          root.brightDesc    = res.bright_desc
          root.brightPct     = res.bright_pct
          root.volIcon       = res.vol_icon
          root.volDesc       = res.vol_desc
          root.volPct        = res.vol_pct
          root.volMuted      = res.vol_muted
        } catch (e) {
          console.log("System Status JSON Error: " + e)
        }
      }
    }
  }

  // Weather state
  property string weatherIcon: ""
  property string weatherText: "Loading..."
  property string weatherColor: ""
  property string weatherCity: ""
  property string weatherLat: ""
  property string weatherLong: ""
  property string weatherTemp: ""

  Timer {
    interval: (root.weatherText === "Offline" || root.weatherText === "Loading...") ? 30000 : 600000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      weatherProcess.running = true
      restart()
    }
  }

  Process {
    id: weatherProcess
    command: ["bash", Quickshell.shellDir + "/scripts/weather-wrapper.sh", "json"]
    stdout: SplitParser {
      onRead: (data) => {
        try {
          var res = JSON.parse(data)
          root.weatherIcon = res.icon
          root.weatherColor = res.color
          root.weatherText = res.text
          root.weatherCity = res.city
          root.weatherLat = res.lat 
          root.weatherLong = res.lon
          root.weatherTemp = res.temp
        } catch (e) {}
      }
    }
  }

  // Weather Forecast
  property var weatherForecast: []

  Timer {
    interval: root.weatherForecast.length === 0 ? 30000 : 600000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      forecastProc.running = true
      restart() 
    }
  }

  Process {
    id: forecastProc
    command: ["bash", Quickshell.shellDir + "/scripts/weather_wrapper_forecast.sh", "json"]
    stdout: SplitParser {
      onRead: (data) => {
        try {
          var res = JSON.parse(data)
          root.weatherForecast = res
        } catch (e) {
          console.log("Forecast JSON Error: " + e)
        }
      }
    }
  }
}

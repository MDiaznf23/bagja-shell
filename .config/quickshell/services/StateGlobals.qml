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

  // System Status (data dari scripts/system-status.py)
  property bool wifiConnected: false
  property bool wifiPowered: false
  property int wifiSignal: 0
  property string wifiDesc: ""
  property string wifiSSID: ""
  property string wifiSecurity: ""

  property string batDesc: ""
  property string batModel: ""
  property int batCapacity: 0
  property bool batCharging: false

  property string brightDesc: ""
  property int brightPct: 0

  property string volDesc: ""
  property int volPct: 0
  property bool volMuted: false

  // Ikon SVG (diturunkan dari state di atas, lihat Icons.qml)
  readonly property url wifiIconSource:   Icons.wifi(wifiConnected, wifiPowered, wifiSignal)
  readonly property url batIconSource:    Icons.battery(batCapacity, batCharging)
  readonly property url brightIconSource: Icons.brightness(brightPct)
  readonly property url volIconSource:    Icons.volume(volPct, volMuted)

  Process {
    id: systemProc
    command: ["python3", "-u", Quickshell.shellDir + "/scripts/system-status.py"]
    running: true

    stdout: SplitParser {
      onRead: (data) => {
        try {
          var res = JSON.parse(data)
          root.wifiConnected = res.wifi_connected
          root.wifiPowered   = res.wifi_powered
          root.wifiSignal    = res.wifi_signal
          root.wifiDesc      = res.wifi_desc
          root.wifiSSID      = res.wifi_ssid
          root.wifiSecurity  = res.wifi_security
          root.batDesc       = res.bat_desc
          root.batModel      = res.bat_model
          root.batCapacity   = res.bat_capacity
          root.batCharging   = res.bat_charging
          root.brightDesc    = res.bright_desc
          root.brightPct     = res.bright_pct
          root.volDesc       = res.vol_desc
          root.volPct        = res.vol_pct
          root.volMuted      = res.vol_muted
        } catch (e) {
          console.log("System Status JSON Error: " + e)
        }
      }
    }
  }

  property int weatherCode: 3
  property bool weatherIsDay: true
  property string weatherText: "Loading..."
  property string weatherCity: ""
  property string weatherLat: ""
  property string weatherLong: ""
  property string weatherTemp: ""
  property var weatherForecast: []

  readonly property url weatherIconSource: Icons.weather(weatherCode, weatherIsDay)

  Timer {
    interval: (root.weatherText === "Offline" || root.weatherText === "Loading...") ? 30000 : 600000
    running: true; repeat: true; triggeredOnStart: true
    onTriggered: { weatherProc.running = true; restart() }
  }

  Process {
    id: weatherProc
    command: ["python3", Quickshell.shellDir + "/scripts/weather.py"]
    stdout: SplitParser {
      onRead: data => {
        try {
          var r = JSON.parse(data)
          if (r.error) { root.weatherText = "Offline"; return }
          root.weatherCode = r.code
          root.weatherIsDay = r.is_day
          root.weatherText = r.text
          root.weatherCity = r.city
          root.weatherLat = r.lat
          root.weatherLong = r.lon
          root.weatherTemp = r.temp
          root.weatherForecast = r.forecast.map(f => Object.assign(f, { iconSource: Icons.weather(f.code, true) }))
        } catch (e) { console.log("Weather JSON Error: " + e) }
      }
    }
  }
}

pragma Singleton
import QtQuick
import Quickshell

Singleton {
  id: root

  function url(name) {
    return "file://" + Quickshell.shellDir + "/assets/icons/" + name + ".svg"
  }

  function wifi(connected, powered, signal) {
    if (!powered) return url("wifi-off")
    if (!connected) return url("wifi-off")
    if (signal <= 25) return url("wifi-zero")
    if (signal <= 50) return url("wifi-low")
    if (signal <= 75) return url("wifi-high")
    return url("wifi")
  }

  function bluetooth(powered, connected) {
    if (!powered) return url("bluetooth-off")
    return url(connected ? "bluetooth-connected" : "bluetooth")
  }

  function battery(pct, charging) {
    if (charging) return url("battery-charging")
    if (pct <= 10) return url("battery-warning")
    if (pct <= 30) return url("battery-low")
    if (pct <= 70) return url("battery-medium")
    return url("battery-full")
  }

  function brightness(pct) {
    if (pct <= 33) return url("sun-dim")
    if (pct <= 66) return url("sun-medium")
    return url("sun")
  }

  function volume(pct, muted) {
    if (muted) return url("volume-x")
    if (pct <= 0) return url("volume")
    if (pct <= 50) return url("volume-1")
    return url("volume-2")
  }

  function weather(code, isDay) {
    var n = "cloud"
    if (code === 0)                                 n = isDay ? "sun" : "moon"
    else if (code <= 2)                             n = isDay ? "cloud-sun" : "cloud-moon"
    else if (code === 45 || code === 48)            n = "cloud-fog"
    else if (code >= 51 && code <= 57)              n = "cloud-drizzle"
    else if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) n = "cloud-rain"
    else if ((code >= 71 && code <= 77) || code === 85 || code === 86) n = "cloud-snow"
    else if (code >= 95)                            n = "cloud-lightning"
    return url(n)
  }
}

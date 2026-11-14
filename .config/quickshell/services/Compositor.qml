pragma Singleton
import QtQuick
import Quickshell

// Detects which Wayland compositor the shell is running under and exposes
// a compositor-neutral API. QML files call Compositor.xxx() and never need
// to know whether it is Hyprland or niri. All compositor-specific commands
// live in scripts/wm.sh.
Singleton {
  id: root

  readonly property string name:
    Quickshell.env("NIRI_SOCKET") ? "niri"
    : Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") ? "hyprland"
    : "unknown"

  readonly property bool isNiri: name === "niri"
  readonly property bool isHyprland: name === "hyprland"

  // Feature flags: things that only exist on some compositors.
  // Sessions (workflow launcher / snapshot) rely on Hyprland's master layout.
  readonly property bool hasSessions: isHyprland

  readonly property string wmScript: Quickshell.shellDir + "/scripts/wm.sh"

  function run(args) {
    Quickshell.execDetached(["bash", wmScript].concat(args))
  }

  function focusWorkspace(id) {
    run(["focus-workspace", String(id)])
  }

  function moveWindow(address, workspaceId) {
    run(["move-window", String(address), String(workspaceId)])
  }

  function closeWindow(address) {
    run(["close-window", String(address)])
  }

  function logout() {
    run(["logout"])
  }
}

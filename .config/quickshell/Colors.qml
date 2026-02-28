pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var d: ({})

    // ================================================================
    // PRIMARY
    // ================================================================
    readonly property color primary:                d["m3primary"]                ?? "#c6bfff"
    readonly property color overPrimary:            d["m3onPrimary"]              ?? "#2b188a"
    readonly property color primaryContainer:       d["m3primaryContainer"]       ?? "#4437a3"
    readonly property color overPrimaryContainer:   d["m3onPrimaryContainer"]     ?? "#b7afff"
    readonly property color primaryFixed:           d["m3primaryFixed"]           ?? "#e4dfff"
    readonly property color primaryFixedDim:        d["m3primaryFixedDim"]        ?? "#c6bfff"
    readonly property color overPrimaryFixed:       d["m3onPrimaryFixed"]         ?? "#160066"
    readonly property color overPrimaryFixedVariant: d["m3onPrimaryFixedVariant"] ?? "#4235a1"

    // ================================================================
    // SECONDARY
    // ================================================================
    readonly property color secondary:                d["m3secondary"]                ?? "#c7c1f2"
    readonly property color overSecondary:            d["m3onSecondary"]              ?? "#2f2b53"
    readonly property color secondaryContainer:       d["m3secondaryContainer"]       ?? "#48446e"
    readonly property color overSecondaryContainer:   d["m3onSecondaryContainer"]     ?? "#b9b3e3"
    readonly property color secondaryFixed:           d["m3secondaryFixed"]           ?? "#e4dfff"
    readonly property color secondaryFixedDim:        d["m3secondaryFixedDim"]        ?? "#c7c1f2"
    readonly property color overSecondaryFixed:       d["m3onSecondaryFixed"]         ?? "#1a163d"
    readonly property color overSecondaryFixedVariant: d["m3onSecondaryFixedVariant"] ?? "#46426b"

    // ================================================================
    // TERTIARY
    // ================================================================
    readonly property color tertiary:                d["m3tertiary"]                ?? "#ffb59b"
    readonly property color overTertiary:            d["m3onTertiary"]              ?? "#5c1a00"
    readonly property color tertiaryContainer:       d["m3tertiaryContainer"]       ?? "#852a01"
    readonly property color overTertiaryContainer:   d["m3onTertiaryContainer"]     ?? "#ffa07f"
    readonly property color tertiaryFixed:           d["m3tertiaryFixed"]           ?? "#ffdbcf"
    readonly property color tertiaryFixedDim:        d["m3tertiaryFixedDim"]        ?? "#ffb59b"
    readonly property color overTertiaryFixed:       d["m3onTertiaryFixed"]         ?? "#380d00"
    readonly property color overTertiaryFixedVariant: d["m3onTertiaryFixedVariant"] ?? "#822800"

    // ================================================================
    // ERROR
    // ================================================================
    readonly property color error:              d["m3error"]             ?? "#ffb4ab"
    readonly property color overError:          d["m3onError"]           ?? "#690005"
    readonly property color errorContainer:     d["m3errorContainer"]    ?? "#93000a"
    readonly property color overErrorContainer: d["m3onErrorContainer"]  ?? "#ffdad6"

    // ================================================================
    // SURFACE
    // ================================================================
    readonly property color surface:                 d["m3surface"]                 ?? "#131319"
    readonly property color overSurface:             d["m3onSurface"]               ?? "#e5e1eb"
    readonly property color surfaceVariant:          d["m3surfaceVariant"]          ?? "#474552"
    readonly property color overSurfaceVariant:      d["m3onSurfaceVariant"]        ?? "#c8c4d4"
    readonly property color surfaceDim:              d["m3surfaceDim"]              ?? "#131319"
    readonly property color surfaceBright:           d["m3surfaceBright"]           ?? "#3a3840"
    readonly property color surfaceContainerLowest:  d["m3surfaceContainerLowest"]  ?? "#0e0d14"
    readonly property color surfaceContainerLow:     d["m3surfaceContainerLow"]     ?? "#1c1b22"
    readonly property color surfaceContainer:        d["m3surfaceContainer"]        ?? "#201f26"
    readonly property color surfaceContainerHigh:    d["m3surfaceContainerHigh"]    ?? "#2a2930"
    readonly property color surfaceContainerHighest: d["m3surfaceContainerHighest"] ?? "#35343b"

    // ================================================================
    // BACKGROUND
    // ================================================================
    readonly property color background:    d["m3background"]   ?? "#131319"
    readonly property color overBackground: d["m3onBackground"] ?? "#e5e1eb"

    // ================================================================
    // OUTLINE
    // ================================================================
    readonly property color outline:        d["m3outline"]        ?? "#928f9e"
    readonly property color outlineVariant: d["m3outlineVariant"] ?? "#474552"

    // ================================================================
    // INVERSE
    // ================================================================
    readonly property color inverseSurface:    d["m3inverseSurface"]   ?? "#e5e1eb"
    readonly property color overInverseSurface: d["m3inverseOnSurface"] ?? "#312f37"
    readonly property color inversePrimary:    d["m3inversePrimary"]   ?? "#5a4fba"

    // ================================================================
    // MISC
    // ================================================================
    readonly property color shadow: d["m3shadow"] ?? "#000000"
    readonly property color scrim:  d["m3scrim"]  ?? "#000000"

    // ================================================================
    // MODE
    // ================================================================
    readonly property string mode: d["mode"] ?? "dark"
    readonly property bool isDark: mode === "dark"

    // ================================================================
    // LOADER
    // ================================================================
    FileView {
        id: colorFile
        path: Quickshell.shellDir + "/colors/colors.json"
        watchChanges: true
        onFileChanged: reloadTimer.restart()
    }

    Timer {
        id: reloadTimer
        interval: 200
        repeat: false
        onTriggered: root.loadColors()
    }

    Process {
        id: readProcess
        command: ["cat", Quickshell.shellDir + "/colors/colors.json"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var parsed = JSON.parse(text.trim())
                    root.d = parsed
                } catch(e) {
                    console.error("Error parsing colors:", e)
                }
            }
        }
    }

    Component.onCompleted: root.loadColors()

    function loadColors() {
        if (!readProcess.running) readProcess.running = true
    }
}

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// MELLOW's own state and cache directories (XDG), created on startup.
// Config creates the config directory when a setting is first saved.
Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string state: (Quickshell.env("XDG_STATE_HOME") || home + "/.local/state") + "/mellow"
    readonly property string config: (Quickshell.env("XDG_CONFIG_HOME") || home + "/.config") + "/mellow"
    readonly property string cache: (Quickshell.env("XDG_CACHE_HOME") || home + "/.cache") + "/mellow"

    // Expands a leading "~" to the home directory.
    function expand(path) {
        return path.startsWith("~") ? home + path.slice(1) : path;
    }

    Process {
        running: true
        command: ["mkdir", "-p", root.state, root.cache]
    }
}

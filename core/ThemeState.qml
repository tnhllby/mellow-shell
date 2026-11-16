pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.core

// Persistent theme choice: light/dark mode and the active colour scheme
// (role maps for both modes, e.g. derived from a wallpaper). Stored in
// $XDG_STATE_HOME/mellow/theme.json; the built-in scheme is the fallback.
Singleton {
    id: root

    readonly property string mode: store.mode === "light" ? "light" : "dark"
    readonly property bool dark: mode === "dark"
    // Role maps of the active scheme, or null for the built-in one.
    readonly property var scheme: store.scheme && store.scheme.dark ? store.scheme : null
    readonly property string seed: scheme?.seed ?? ColorScheme.seed
    readonly property string source: scheme?.source ?? "builtin"

    readonly property var roles: scheme ? scheme[mode] : (dark ? ColorScheme.dark : ColorScheme.light)
    readonly property var fallbackRoles: dark ? ColorScheme.dark : ColorScheme.light

    function setMode(newMode) {
        store.mode = newMode === "light" ? "light" : "dark";
    }

    function toggleMode() {
        setMode(dark ? "light" : "dark");
    }

    // scheme: { dark: {role: "#hex"}, light: {...}, seed: "#hex", source: string }
    function setScheme(newScheme) {
        store.scheme = newScheme;
    }

    function resetScheme() {
        store.scheme = null;
    }

    Timer {
        id: writeDelay
        interval: 200
        onTriggered: file.writeAdapter()
    }

    FileView {
        id: file
        path: Paths.state + "/theme.json"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onAdapterUpdated: writeDelay.restart()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                writeDelay.restart();
        }

        JsonAdapter {
            id: store
            property string mode: Config.theme.mode
            property var scheme: null
        }
    }
}

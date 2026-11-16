pragma Singleton
import QtQuick
import Quickshell

// User-facing settings. M0 keeps them static; a validated config file
// (~/.config/mellow/config.json) is planned for M6.
Singleton {
    readonly property QtObject theme: QtObject {
        // "dark" | "light"
        readonly property string mode: "dark"
    }

    readonly property QtObject clock: QtObject {
        // Qt date/time format strings.
        readonly property string timeFormat: "HH:mm"
        readonly property string dateFormat: "ddd, d MMM"
    }

    readonly property QtObject panel: QtObject {
        readonly property int height: 56
        readonly property bool showActiveWindow: true
    }

    readonly property QtObject frame: QtObject {
        readonly property bool enabled: true
        readonly property int thickness: 4
        // "hide": frame disappears while the monitor's active workspace has a
        // fullscreen window. "show": frame stays.
        readonly property string fullscreenPolicy: "hide"
    }

    readonly property QtObject dock: QtObject {
        readonly property bool autoHide: true
        // Width of the invisible activation strip on the left screen edge.
        readonly property int triggerWidth: 2
        readonly property int hideDelay: 450
        // Desktop entry ids; entries that are not installed are skipped.
        readonly property var pinned: [
            "kitty", "foot", "org.gnome.Nautilus", "org.kde.dolphin", "thunar",
            "firefox", "chromium", "code", "org.gnome.TextEditor"
        ]
    }

    readonly property QtObject motion: QtObject {
        readonly property bool reduced: false
    }
}

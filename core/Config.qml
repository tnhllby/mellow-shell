pragma Singleton
import QtQuick
import Quickshell

// User-facing settings. M0 keeps them static; a validated config file
// (~/.config/mellow/config.json) is planned for M6.
Singleton {
    readonly property QtObject theme: QtObject {
        // Initial "dark" | "light"; the current choice is persisted by ThemeState.
        readonly property string mode: "dark"
    }

    readonly property QtObject clock: QtObject {
        // Qt date/time format strings.
        readonly property string timeFormat: "HH:mm"
        readonly property string dateFormat: "ddd, d MMM"
    }

    readonly property QtObject panel: QtObject {
        readonly property int height: 52
        readonly property bool showActiveWindow: true
    }

    readonly property QtObject island: QtObject {
        readonly property int compactMaxWidth: 360
        readonly property int expandedWidth: 440
        // Media mode lingers this long after playback pauses (ms).
        readonly property int pausedGrace: 120000
        // Ambient system statistics refresh interval (ms).
        readonly property int statsInterval: 3000
    }

    readonly property QtObject wallpaper: QtObject {
        // Draw the wallpaper chosen in Wallpaper Studio. Turn off to keep using
        // another wallpaper tool.
        readonly property bool draw: true
        readonly property var folders: ["~/Pictures/Wallpapers", "~/Pictures"]
        // matugen scheme type for wallpaper-derived colours.
        readonly property string schemeType: "scheme-tonal-spot"
        // Seeds offered next to the wallpaper's own colours.
        readonly property var presetSeeds: ["#5E8C7A", "#4A6FA5", "#8E6CB8", "#C0597A", "#C7774A", "#B59A3A"]
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

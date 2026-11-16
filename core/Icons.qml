pragma Singleton
import QtQuick
import Quickshell

// Icon-theme lookups. Never passes an empty name to Quickshell.iconPath(),
// which would produce an invalid "?fallback=" request.
Singleton {
    readonly property string fallbackApp: "application-x-executable"

    // Path for an application icon, falling back to a generic one.
    function app(name) {
        return Quickshell.iconPath(name || fallbackApp, fallbackApp);
    }

    // Path for an icon only if the theme has it, otherwise "".
    function optional(name) {
        return name ? Quickshell.iconPath(name, true) : "";
    }
}

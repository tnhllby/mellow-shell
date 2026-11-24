pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.core

// Themes other apps from MELLOW's colours (scripts/apply-app-theme.sh) when
// theming.apps is on, at startup and whenever the theme changes.
Singleton {
    id: root

    readonly property bool enabled: Config.theming.apps && WallpaperService.matugenAvailable
    readonly property var args: [ThemeState.seed, ThemeState.mode, Config.wallpaper.schemeType]

    onEnabledChanged: delay.restart()
    onArgsChanged: delay.restart()

    // Lets the shell finish its own transition and quick toggles settle.
    Timer {
        id: delay
        interval: 800
        onTriggered: {
            if (!root.enabled)
                return;
            if (script.running) {
                restart();
                return;
            }
            script.command = [Quickshell.shellPath("scripts/apply-app-theme.sh")].concat(root.args);
            script.running = true;
        }
    }

    Process {
        id: script
        stderr: StdioCollector {
            id: errors
        }
        onExited: code => {
            if (code !== 0)
                console.warn(`app theming failed (${code}): ${errors.text.trim()}`);
        }
    }
}

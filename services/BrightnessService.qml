pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Built-in display backlight. Reads /sys/class/backlight and writes through
// logind's Session.SetBrightness (no root, no extra tools). External monitors
// (DDC/CI) are not supported.
Singleton {
    id: root

    property string device: ""
    property int maximum: 0
    property int current: 0
    readonly property bool available: device !== "" && maximum > 0
    readonly property real value: available ? current / maximum : 0

    property real pending: -1

    // sysfs does not notify about brightness changes made elsewhere (keys,
    // other tools); call this when the value becomes visible.
    function refresh() {
        if (device)
            currentFile.reload();
    }

    // Throttled: the slider can move faster than logind needs to be called.
    function setValue(fraction) {
        if (!available)
            return;
        pending = Math.max(0.01, Math.min(1, fraction));
        if (!writeTimer.running)
            writeTimer.start();
    }

    Timer {
        id: writeTimer
        interval: 50
        onTriggered: {
            if (root.pending < 0)
                return;
            const raw = Math.round(root.pending * root.maximum);
            root.pending = -1;
            root.current = raw;
            writer.command = ["busctl", "call", "org.freedesktop.login1", "/org/freedesktop/login1/session/auto",
                "org.freedesktop.login1.Session", "SetBrightness", "ssu", "backlight", root.device, String(raw)];
            writer.running = true;
        }
    }

    Process {
        id: writer
        onExited: code => {
            if (code !== 0)
                console.warn("BrightnessService: logind SetBrightness failed with code", code);
        }
    }

    Process {
        running: true
        command: ["sh", "-c", "for d in /sys/class/backlight/*; do [ -r \"$d/max_brightness\" ] && basename \"$d\" && break; done"]
        stdout: StdioCollector {
            onStreamFinished: root.device = text.trim()
        }
    }

    FileView {
        path: root.device ? `/sys/class/backlight/${root.device}/max_brightness` : ""
        onLoaded: root.maximum = Number(text().trim()) || 0
    }

    FileView {
        id: currentFile
        path: root.device ? `/sys/class/backlight/${root.device}/brightness` : ""
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.current = Number(text().trim()) || 0
    }
}

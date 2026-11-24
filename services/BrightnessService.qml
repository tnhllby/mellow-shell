pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Display brightness per monitor (keyed by connector name, e.g. "eDP-1").
// - Built-in panel: reads /sys/class/backlight and writes through logind's
//   Session.SetBrightness (no root, no extra tools).
// - External monitors: DDC/CI through ddcutil (optional; needs the i2c-dev
//   module and access to /dev/i2c-*). Monitors without DDC/CI are unavailable.
Singleton {
    id: root

    // ---- Built-in backlight ----
    property string backlight: ""
    property int maximum: 0
    property int current: 0
    property real pending: -1

    // ---- DDC/CI: { "<connector>": { bus, value, max } } ----
    property var ddc: ({})
    // Commands run one at a time: [{ args, done(text, ok) }].
    property var ddcQueue: []
    property var ddcCurrent: null
    // Pending writes per connector (fraction), flushed by ddcTimer.
    property var ddcPending: ({})

    function isInternal(name) {
        return /^(eDP|LVDS|DSI)/.test(name ?? "");
    }

    function available(name) {
        if (isInternal(name))
            return backlight !== "" && maximum > 0;
        return ddc[name] !== undefined && ddc[name].max > 0;
    }

    function value(name) {
        if (isInternal(name))
            return maximum > 0 ? current / maximum : 0;
        const d = ddc[name];
        return d && d.max > 0 ? d.value / d.max : 0;
    }

    // Re-read values (changes made elsewhere are not announced).
    function refresh() {
        if (backlight)
            currentFile.reload();
        for (const name in ddc)
            readDdc(name);
    }

    // Throttled: the slider can move faster than logind or DDC/CI need to be called.
    function setValue(name, fraction) {
        if (!available(name))
            return;
        const f = Math.max(0.01, Math.min(1, fraction));
        if (isInternal(name)) {
            pending = f;
            if (!writeTimer.running)
                writeTimer.start();
        } else {
            const d = Object.assign({}, ddc[name]);
            d.value = Math.round(f * d.max);
            const next = Object.assign({}, ddc);
            next[name] = d;
            ddc = next;
            const p = Object.assign({}, ddcPending);
            p[name] = d.value;
            ddcPending = p;
            if (!ddcTimer.running)
                ddcTimer.start();
        }
    }

    function runDdc(args, done) {
        ddcQueue = ddcQueue.concat([{ args, done }]);
        nextDdc();
    }

    function nextDdc() {
        if (ddcCurrent || ddcQueue.length === 0)
            return;
        ddcCurrent = ddcQueue[0];
        ddcQueue = ddcQueue.slice(1);
        ddcProcess.command = ["ddcutil"].concat(ddcCurrent.args);
        ddcProcess.running = true;
    }

    function readDdc(name) {
        const bus = ddc[name]?.bus;
        if (bus === undefined)
            return;
        runDdc(["--bus", bus, "getvcp", "10", "--brief"], (text, ok) => {
            // "VCP 10 C <current> <max>"
            const m = text.match(/VCP 10 C (\d+) (\d+)/);
            if (!ok || !m)
                return;
            const next = Object.assign({}, ddc);
            next[name] = { bus, value: Number(m[1]), max: Number(m[2]) };
            ddc = next;
        });
    }

    // ---- Backlight I/O ----

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
                "org.freedesktop.login1.Session", "SetBrightness", "ssu", "backlight", root.backlight, String(raw)];
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
            onStreamFinished: root.backlight = text.trim()
        }
    }

    FileView {
        path: root.backlight ? `/sys/class/backlight/${root.backlight}/max_brightness` : ""
        onLoaded: root.maximum = Number(text().trim()) || 0
    }

    FileView {
        id: currentFile
        path: root.backlight ? `/sys/class/backlight/${root.backlight}/brightness` : ""
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.current = Number(text().trim()) || 0
    }

    // ---- DDC/CI I/O ----

    Timer {
        id: ddcTimer
        interval: 150
        onTriggered: {
            const pending = root.ddcPending;
            root.ddcPending = {};
            for (const name in pending) {
                const bus = root.ddc[name]?.bus;
                if (bus !== undefined)
                    root.runDdc(["--bus", bus, "--noverify", "setvcp", "10", String(pending[name])], (text, ok) => {
                        if (!ok)
                            console.warn("BrightnessService: ddcutil setvcp failed for", name);
                    });
            }
        }
    }

    Process {
        id: ddcProcess
        stdout: StdioCollector {
            id: ddcOut
        }
        onExited: code => {
            const job = root.ddcCurrent;
            root.ddcCurrent = null;
            job.done(ddcOut.text, code === 0);
            root.nextDdc();
        }
    }

    // Find DDC/CI-capable monitors once. Without ddcutil this prints nothing.
    // "Display N" blocks list "I2C bus: /dev/i2c-N" and "DRM connector: cardX-<name>";
    // monitors without DDC/CI are reported as "Invalid display" and skipped.
    Process {
        running: true
        command: ["sh", "-c", "command -v ddcutil >/dev/null && ddcutil detect --brief 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                const found = {};
                for (const block of text.split(/\n\s*\n/)) {
                    if (!/^Display \d+/.test(block.trim()))
                        continue;
                    const bus = block.match(/I2C bus:\s*\/dev\/i2c-(\d+)/);
                    const connector = block.match(/DRM connector:\s*card\d+-(\S+)/);
                    if (bus && connector && !root.isInternal(connector[1]))
                        found[connector[1]] = { bus: bus[1], value: 0, max: 0 };
                }
                root.ddc = found;
                for (const name in found)
                    root.readDdc(name);
            }
        }
    }
}

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
import qs.services

// CPU load, memory use and CPU temperature: in the Island's ambient state, on
// the bar while the Island shows media, and on the Dashboard. A metric is null when
// its source is unavailable, and the UI hides it.
Singleton {
    id: root


    property var cpu: null          // percent
    property var memory: null       // percent
    property var temperature: null  // degrees Celsius

    property var lastCpu: null
    property string temperaturePath: ""

    function sample() {
        statFile.reload();
        memFile.reload();
        if (temperaturePath)
            tempFile.reload();
    }

    function parseCpu(text) {
        const fields = text.split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
        if (fields.length < 4)
            return;
        const idle = fields[3] + (fields[4] ?? 0);
        const total = fields.reduce((a, b) => a + b, 0);
        if (lastCpu && total > lastCpu.total)
            cpu = Math.round(100 * (1 - (idle - lastCpu.idle) / (total - lastCpu.total)));
        lastCpu = { idle, total };
    }

    function parseMemory(text) {
        const total = Number(/MemTotal:\s+(\d+)/.exec(text)?.[1]);
        const available = Number(/MemAvailable:\s+(\d+)/.exec(text)?.[1]);
        memory = total > 0 && available >= 0 ? Math.round(100 * (1 - available / total)) : null;
    }

    Timer {
        interval: Config.island.statsInterval
        repeat: true
        triggeredOnStart: true
        running: true
        onTriggered: root.sample()
    }

    FileView {
        id: statFile
        path: "/proc/stat"
        onLoaded: root.parseCpu(text())
        onLoadFailed: root.cpu = null
    }

    FileView {
        id: memFile
        path: "/proc/meminfo"
        onLoaded: root.parseMemory(text())
        onLoadFailed: root.memory = null
    }

    FileView {
        id: tempFile
        path: root.temperaturePath
        onLoaded: {
            const milli = Number(text().trim());
            root.temperature = Number.isFinite(milli) ? Math.round(milli / 1000) : null;
        }
        onLoadFailed: root.temperature = null
    }

    // One-shot lookup of a CPU temperature sensor, best match first.
    Process {
        running: true
        command: ["sh", "-c", "for d in /sys/class/hwmon/hwmon*; do [ -r \"$d/temp1_input\" ] && echo \"$(cat \"$d/name\") $d/temp1_input\"; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                const preferred = ["coretemp", "k10temp", "zenpower", "cpu_thermal", "acpitz"];
                const sensors = text.trim().split("\n").map(line => line.split(" ")).filter(s => s.length === 2);
                for (const name of preferred) {
                    const match = sensors.find(s => s[0] === name);
                    if (match) {
                        root.temperaturePath = match[1];
                        return;
                    }
                }
            }
        }
    }
}

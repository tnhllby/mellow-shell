pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.core

// Static facts about this computer and user for the Dashboard, read when it
// opens. Missing values stay "" and are hidden.
Singleton {
    id: root

    property var facts: ({})
    readonly property string user: Quickshell.env("USER") || ""

    function refresh() {
        query.running = true;
    }

    function duration(seconds) {
        const m = Math.floor(seconds / 60), h = Math.floor(m / 60), d = Math.floor(h / 24);
        return d > 0 ? `${d} d ${h % 24} h` : h > 0 ? `${h} h ${m % 60} min` : `${m} min`;
    }

    Process {
        id: query
        command: ["sh", "-c", `
            . /etc/os-release 2>/dev/null; echo "os=$PRETTY_NAME"
            echo "host=$(cat /proc/sys/kernel/hostname)"
            echo "kernel=$(uname -r)"
            echo "uptime=$(cut -d. -f1 /proc/uptime)"
            echo "cpu=$(sed -n 's/^model name[^:]*: //p' /proc/cpuinfo | head -n1)"
            echo "memory=$(sed -n 's/^MemTotal: *\\([0-9]*\\).*/\\1/p' /proc/meminfo)"
            echo "disk=$(df -Pk / | awk 'NR==2 {print $3, $2}')"
            echo "name=$(getent passwd "$(id -un)" | cut -d: -f5 | cut -d, -f1)"
            for f in "$HOME/.face" "$HOME/.face.icon" "/var/lib/AccountsService/icons/$(id -un)"; do
                [ -r "$f" ] && [ -f "$f" ] && { echo "avatar=$f"; break; }
            done; true`]
        stdout: StdioCollector {
            onStreamFinished: {
                const facts = {};
                for (const line of text.split("\n")) {
                    const i = line.indexOf("=");
                    if (i > 0)
                        facts[line.slice(0, i)] = line.slice(i + 1).trim();
                }
                root.facts = facts;
            }
        }
    }
}

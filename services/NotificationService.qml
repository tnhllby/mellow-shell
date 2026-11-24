pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs.core

// Desktop notifications (org.freedesktop.Notifications). Only one program per
// session can receive them: if another one already does, the server waits and
// takes over once that program exits, and the list stays empty until then.
Singleton {
    id: root

    // Newest first.
    readonly property var list: [...server.trackedNotifications.values].reverse()

    // Process that receives notifications; 0 when there is none.
    property int ownerPid: 0
    readonly property bool active: ownerPid === Quickshell.processId

    // Arrival time (ms) by notification id. Unknown after a config reload.
    property var arrivals: ({})

    // Re-reads the owner (no bus signal is exposed to QML for it).
    function refreshOwner() {
        ownerQuery.running = true;
    }

    function age(notification, now) {
        const at = arrivals[notification.id];
        if (!at)
            return "";
        const minutes = Math.floor((now - at) / 60000);
        return minutes < 1 ? "now" : minutes < 60 ? minutes + " min" : minutes < 1440 ? Math.floor(minutes / 60) + " h" : Math.floor(minutes / 1440) + " d";
    }

    // Local image for a notification, or "". Remote URLs are never loaded.
    function image(notification) {
        for (const source of [notification.image, notification.appIcon]) {
            if (source.startsWith("/"))
                return "file://" + source;
            if (source.startsWith("file:") || source.startsWith("image:"))
                return source;
            if (source && !source.includes(":")) {
                const path = Icons.optional(source);
                if (path)
                    return path;
            }
        }
        return Icons.optional(DesktopEntries.heuristicLookup(notification.desktopEntry || notification.appName)?.icon ?? "");
    }

    function defaultAction(notification) {
        return notification.actions.find(a => a.identifier === "default") ?? null;
    }

    function otherActions(notification) {
        return notification.actions.filter(a => a.identifier !== "default" && a.text !== "");
    }

    function clearAll() {
        for (const notification of [...list])
            notification.dismiss();
    }

    NotificationServer {
        id: server

        actionsSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: notification => {
            root.ownerPid = Quickshell.processId;
            // Transient ones ask not to be kept, and there are no popups.
            if (notification.transient)
                return;
            notification.tracked = true;

            const arrivals = {};
            for (const n of root.list)
                arrivals[n.id] = root.arrivals[n.id];
            if (!notification.lastGeneration)
                arrivals[notification.id] = Date.now();
            root.arrivals = arrivals;

            const excess = root.list.slice(Config.notifications.maxKept);
            for (const n of excess)
                n.expire();
        }
    }

    Process {
        id: ownerQuery
        running: true
        command: ["busctl", "--user", "--json=short", "call", "org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus", "GetConnectionUnixProcessID", "s", "org.freedesktop.Notifications"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.ownerPid = JSON.parse(text).data[0];
                } catch (e) {
                    root.ownerPid = 0;
                }
            }
        }
    }
}

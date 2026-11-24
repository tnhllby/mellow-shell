pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs.core
import qs.integrations.hyprland

// Desktop notifications (org.freedesktop.Notifications). Only one program per
// session can receive them: if another one already does, the server waits and
// takes over once that program exits, and the list stays empty until then.
Singleton {
    id: root

    // Newest first.
    readonly property var list: server.trackedNotifications.values.filter(n => !n.transient).reverse()

    // Shown as pop-ups, newest first. Transient ones live only as long as theirs.
    property var popupIds: []
    readonly property int maxPopups: 3
    readonly property var popups: server.trackedNotifications.values.filter(n => popupIds.includes(n.id)).reverse().slice(0, maxPopups)
    // Monitor the pop-ups are on: the configured one, or the one focused when
    // the first appeared.
    property string popupMonitor: ""

    // Do Not Disturb: no pop-ups except critical ones; the list still fills.
    readonly property bool doNotDisturb: store.doNotDisturb

    function toggleDoNotDisturb() {
        store.doNotDisturb = !store.doNotDisturb;
        if (store.doNotDisturb) {
            for (const n of popups.filter(n => n.urgency !== NotificationUrgency.Critical))
                hidePopup(n);
        }
    }

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

    // How long a pop-up stays (ms), or 0 until it is dismissed.
    function popupDuration(notification) {
        if (notification.urgency === NotificationUrgency.Critical || notification.expireTimeout === 0)
            return 0;
        return notification.expireTimeout > 0 ? notification.expireTimeout : Config.notifications.popupTimeout;
    }

    function hidePopup(notification) {
        popupIds = popupIds.filter(id => id !== notification.id);
        if (notification.transient)
            notification.expire();
    }

    function hidePopups() {
        for (const n of server.trackedNotifications.values.filter(n => popupIds.includes(n.id)))
            hidePopup(n);
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
            // Open in the Control Center already, or kept across a config reload.
            const silenced = root.doNotDisturb && notification.urgency !== NotificationUrgency.Critical;
            const popup = Config.notifications.popups && !silenced && ShellState.controlCenterMonitor === "" && !notification.lastGeneration;
            // Transient ones ask not to be kept.
            if (notification.transient && !popup)
                return;
            notification.tracked = true;
            if (popup) {
                if (root.popups.length === 0)
                    root.popupMonitor = Quickshell.screens.find(s => s.name === Config.notifications.monitor)?.name ?? HyprlandService.focusedMonitor?.name ?? Quickshell.screens[0]?.name ?? "";
                const alive = server.trackedNotifications.values.map(n => n.id);
                root.popupIds = [...root.popupIds.filter(id => alive.includes(id) && id !== notification.id), notification.id];
                // Those pushed out by newer ones are done popping up.
                for (const n of server.trackedNotifications.values.filter(n => root.popupIds.slice(0, -root.maxPopups).includes(n.id)))
                    root.hidePopup(n);
            }
            if (notification.transient)
                return;

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

    // The Control Center lists them, so pop-ups would only cover it.
    Connections {
        target: ShellState

        function onControlCenterMonitorChanged() {
            if (ShellState.controlCenterMonitor !== "")
                root.hidePopups();
        }
    }

    Timer {
        id: writeDelay
        interval: 200
        onTriggered: file.writeAdapter()
    }

    FileView {
        id: file
        path: Paths.state + "/notifications.json"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onAdapterUpdated: writeDelay.restart()

        JsonAdapter {
            id: store
            property bool doNotDisturb: false
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

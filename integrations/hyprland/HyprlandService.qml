pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

// The single entry point for Hyprland state. Widgets bind to this service
// instead of talking to Hyprland or spawning hyprctl themselves. State is
// event-driven through Quickshell's Hyprland IPC integration.
Singleton {
    id: root

    readonly property bool available: Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") !== ""
    readonly property var focusedMonitor: Hyprland.focusedMonitor
    readonly property var focusedWorkspace: Hyprland.focusedWorkspace

    // All workspaces with a positive id (special workspaces are negative), by id.
    readonly property var workspaces: Hyprland.workspaces.values
        .filter(ws => ws.id > 0)
        .sort((a, b) => a.id - b.id)

    function monitorFor(screen) {
        return screen ? Hyprland.monitorFor(screen) : null;
    }

    function workspacesOn(monitor) {
        if (!monitor)
            return [];
        return workspaces.filter(ws => ws.monitor === monitor);
    }

    function activate(workspace) {
        if (workspace && !workspace.focused)
            workspace.activate();
    }

    // Step to the previous/next workspace in the given list (direction -1 / +1).
    function cycle(list, current, direction) {
        if (list.length === 0)
            return;
        const index = Math.max(0, list.indexOf(current));
        activate(list[(index + direction + list.length) % list.length]);
    }
}

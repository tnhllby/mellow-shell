pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// The single entry point for Hyprland state and actions. Widgets bind to this
// service instead of talking to Hyprland or spawning hyprctl themselves.
// State is event-driven through Quickshell's Hyprland IPC integration; outside
// Hyprland every list is empty and every action is a no-op.
Singleton {
    id: root

    readonly property bool available: Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") !== ""

    // Monitors, left to right.
    readonly property var monitors: Hyprland.monitors.values.slice().sort((a, b) => a.x - b.x || a.y - b.y)
    readonly property var focusedMonitor: Hyprland.focusedMonitor

    // Regular workspaces (special workspaces have negative ids), by id.
    readonly property var workspaces: Hyprland.workspaces.values
        .filter(ws => ws.id > 0)
        .sort((a, b) => a.id - b.id)
    readonly property var focusedWorkspace: Hyprland.focusedWorkspace

    // All mapped windows, and the focused one.
    readonly property var windows: Hyprland.toplevels.values
    readonly property var activeWindow: Hyprland.activeToplevel

    // Whether the compositor blurs surfaces (decoration:blur:enabled). Read at
    // startup and after each config reload; assumed off until known.
    property bool blurEnabled: false

    // True when a window on `workspace` is real fullscreen. Hyprland's
    // `hasfullscreen` is also set for maximized windows, so the per-window
    // fullscreen mode (bit 2 = fullscreen, bit 1 = maximized) decides.
    function hasRealFullscreen(workspace) {
        return (workspace?.hasFullscreen ?? false)
            && windowsOn(workspace).some(w => ((w.lastIpcObject?.fullscreen ?? 0) & 2) !== 0);
    }

    function monitorFor(screen) {
        return screen ? Hyprland.monitorFor(screen) : null;
    }

    function workspacesOn(monitor) {
        if (!monitor)
            return [];
        return workspaces.filter(ws => ws.monitor === monitor);
    }

    function windowsOn(workspace) {
        return workspace ? workspace.toplevels.values : [];
    }

    // Application id of a window (e.g. "firefox"), or "" if unknown.
    function appIdOf(window) {
        return window?.wayland?.appId ?? window?.lastIpcObject?.class ?? "";
    }

    // ---- Actions -----------------------------------------------------------

    // Hyprland 0.56+ may run a Lua config, where dispatchers are Lua calls.
    function dispatch(classic, lua) {
        if (!available)
            return;
        Hyprland.dispatch(Hyprland.usingLua ? lua : classic);
    }

    function activate(workspace) {
        if (workspace && !workspace.focused)
            workspace.activate();
    }

    // Focus workspace `id` (positive integer), creating it if it does not exist.
    function focusWorkspace(id) {
        const n = Number(id);
        if (!Number.isInteger(n) || n < 1) {
            console.warn("HyprlandService: invalid workspace id", id);
            return;
        }
        const existing = workspaces.find(ws => ws.id === n);
        if (existing)
            activate(existing);
        else
            dispatch(`workspace ${n}`, `hl.dsp.focus({ workspace = "${n}" })`);
    }

    // Step to the previous/next workspace in the given list (direction -1 / +1).
    function cycle(list, current, direction) {
        if (list.length === 0)
            return;
        const index = Math.max(0, list.indexOf(current));
        activate(list[(index + direction + list.length) % list.length]);
    }

    function windowSelector(window) {
        const address = String(window?.address ?? "").replace(/^0x/, "");
        return /^[0-9a-f]+$/i.test(address) ? `address:0x${address}` : "";
    }

    function focusWindow(window) {
        const selector = windowSelector(window);
        if (selector)
            dispatch(`focuswindow ${selector}`, `hl.dsp.focus({ window = "${selector}" })`);
    }

    function closeWindow(window) {
        const selector = windowSelector(window);
        if (selector)
            dispatch(`closewindow ${selector}`, `hl.dsp.window.close({ window = "${selector}" })`);
    }

    // Move a window to workspace `id` without following it.
    function moveWindowToWorkspace(window, id) {
        const selector = windowSelector(window);
        const n = Number(id);
        if (selector && Number.isInteger(n) && n > 0)
            dispatch(`movetoworkspacesilent ${n},${selector}`,
                `hl.dsp.window.move({ workspace = "${n}", follow = false, window = "${selector}" })`);
    }

    // Window IPC data (fullscreen mode) is not pushed by events; refresh it
    // when fullscreen state changes.
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "fullscreen")
                Hyprland.refreshToplevels();
            else if (event.name === "configreloaded")
                blurQuery.running = true;
        }
    }

    Process {
        id: blurQuery
        running: root.available
        command: ["hyprctl", "-j", "getoption", "decoration:blur:enabled"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const option = JSON.parse(text);
                    root.blurEnabled = (option.int ?? (option.bool ? 1 : 0)) !== 0;
                } catch (e) {
                    root.blurEnabled = false;
                }
            }
        }
    }

    Component.onCompleted: if (available) Hyprland.refreshToplevels()
}

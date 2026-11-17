import QtQuick
import Quickshell
import qs.core
import qs.components
import qs.integrations.hyprland

// Overview layout: the monitor's workspaces as cards, each showing its windows
// where they are. Keyboard: arrows/Tab select a window, Up/Down change
// workspace, Return focuses, Delete closes, 1–9 open a workspace,
// Shift+1–9 move the selected window there, Escape closes.
// Pointer: click a window to focus it, an empty area to open the workspace;
// drag a window onto another workspace (or "New") to move it; middle click
// or the close button closes it.
FocusScope {
    id: root

    required property ShellScreen screen
    signal closeRequested

    readonly property var monitor: HyprlandService.monitorFor(screen)
    readonly property var workspaces: HyprlandService.workspacesOn(monitor)
    // A free id for the "New workspace" slot.
    readonly property int newWorkspaceId: HyprlandService.workspaces.reduce((max, ws) => Math.max(max, ws.id), 0) + 1
    // Windows in keyboard order: by workspace, then left to right, top to bottom.
    readonly property var windows: workspaces.reduce((list, ws) => list.concat(sortedWindows(ws)), [])
    property var selected: HyprlandService.activeWindow
    property bool dragging: false

    readonly property real aspect: screen.width / Math.max(1, screen.height)
    readonly property int columns: Math.max(1, Math.min(workspaces.length + 1, 4))
    readonly property real cardWidth: Math.min(420, (width - 2 * Theme.spacing.x10 - (columns - 1) * Theme.spacing.x6) / columns)

    function sortedWindows(workspace) {
        return HyprlandService.windowsOn(workspace).slice().sort((a, b) => {
            const pa = a.lastIpcObject?.at ?? [0, 0];
            const pb = b.lastIpcObject?.at ?? [0, 0];
            return pa[0] - pb[0] || pa[1] - pb[1];
        });
    }

    function focusWindow(window) {
        HyprlandService.focusWindow(window);
        closeRequested();
    }

    function openWorkspace(id) {
        HyprlandService.focusWorkspace(id);
        closeRequested();
    }

    function step(delta) {
        if (windows.length === 0)
            return;
        const index = windows.indexOf(selected);
        selected = windows[(index + delta + windows.length) % windows.length];
    }

    function stepWorkspace(delta) {
        const withWindows = workspaces.filter(ws => HyprlandService.windowsOn(ws).length > 0);
        if (withWindows.length === 0)
            return;
        const index = withWindows.indexOf(selected?.workspace);
        const target = withWindows[(index + delta + withWindows.length) % withWindows.length];
        selected = sortedWindows(target)[0];
    }

    // Previews re-capture when this changes (each time the Overview opens).
    property int captureGeneration: 0

    // Called on every open: the content is kept between opens.
    function opened() {
        selected = HyprlandService.activeWindow;
        if (!windows.includes(selected))
            selected = windows[0] ?? null;
        captureGeneration++;
        forceActiveFocus();
    }
    onWindowsChanged: if (!windows.includes(selected)) selected = windows[0] ?? null

    focus: true
    Keys.onEscapePressed: closeRequested()
    Keys.onLeftPressed: step(-1)
    Keys.onRightPressed: step(1)
    Keys.onTabPressed: step(1)
    Keys.onBacktabPressed: step(-1)
    Keys.onUpPressed: stepWorkspace(-1)
    Keys.onDownPressed: stepWorkspace(1)
    Keys.onReturnPressed: if (selected) focusWindow(selected)
    Keys.onEnterPressed: if (selected) focusWindow(selected)
    Keys.onDeletePressed: if (selected) HyprlandService.closeWindow(selected)
    Keys.onPressed: event => {
        // Digits by physical key (xkb keycodes 10–18 = keys 1–9), so Shift+digit
        // and non-Latin layouts work too.
        const code = event.nativeScanCode;
        const shifted = event.modifiers & Qt.ShiftModifier;
        const digit = code >= 10 && code <= 18 ? code - 9 : 0;
        if (digit < 1)
            return;
        if (shifted && selected)
            HyprlandService.moveWindowToWorkspace(selected, digit);
        else if (!shifted)
            openWorkspace(digit);
        event.accepted = true;
    }

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacing.x6

        // Text sits on surfaces, not on the scrim, so it stays readable in
        // both modes and over any window content.
        Surface {
            anchors.horizontalCenter: parent.horizontalCenter
            width: title.width + 2 * Theme.spacing.x5
            height: title.implicitHeight + 2 * Theme.spacing.x2
            radius: Theme.shape.pill

            MText {
                id: title
                anchors.centerIn: parent
                role: Typography.titleMedium
                color: Theme.color.contentSurface
                text: root.selected ? (root.selected.title || HyprlandService.appIdOf(root.selected)) : "No windows"
                width: Math.min(implicitWidth, root.width - 2 * Theme.spacing.x10)
            }
        }

        Flow {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(root.width - 2 * Theme.spacing.x10, root.columns * root.cardWidth + (root.columns - 1) * spacing)
            spacing: Theme.spacing.x6

            Repeater {
                model: root.workspaces

                WorkspaceCard {
                    required property var modelData
                    workspace: modelData
                    workspaceId: modelData.id
                    overview: root
                    width: root.cardWidth
                    height: root.cardWidth / root.aspect
                }
            }

            // Empty slot: click to open a new workspace, drop a window to move it there.
            WorkspaceCard {
                workspace: null
                workspaceId: root.newWorkspaceId
                overview: root
                width: root.cardWidth
                height: root.cardWidth / root.aspect
            }
        }

        Surface {
            anchors.horizontalCenter: parent.horizontalCenter
            width: hint.implicitWidth + 2 * Theme.spacing.x4
            height: hint.implicitHeight + 2 * Theme.spacing.x2
            radius: Theme.shape.pill
            color: Theme.color.surfaceContainer

            MText {
                id: hint
                anchors.centerIn: parent
                role: Typography.labelMedium
                color: Theme.color.contentSurfaceVariant
                text: "Return focus · Delete close · 1–9 workspace · Shift+1–9 move · drag to move"
            }
        }
    }
}

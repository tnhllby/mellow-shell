import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.core
import qs.integrations.hyprland
import qs.modules.ControlCenter
import qs.modules.Island

// Full-width top panel: workspaces and active window (left), Island (centre),
// system controls (right).
// It never takes keyboard focus; it only receives pointer input inside its own
// rectangle, which Hyprland keeps clear of windows via the exclusive zone.
PanelWindow {
    id: root

    readonly property var monitor: HyprlandService.monitorFor(screen)
    readonly property bool controlCenterOpen: ShellState.controlCenterMonitor === screen?.name

    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: Config.panel.height
    exclusiveZone: Config.panel.height
    color: "transparent"

    WlrLayershell.namespace: "mellow:panel"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Rounded top corners match the frame's bottom corners: one continuous chrome.
    Rectangle {
        anchors.fill: parent
        color: Theme.chrome
        topLeftRadius: Theme.chromeShape.outerRadius
        topRightRadius: Theme.chromeShape.outerRadius
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacing.x3
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacing.x4

        WorkspaceStrip {
            id: workspaces
            anchors.verticalCenter: parent.verticalCenter
            monitor: root.monitor
        }

        ActiveWindow {
            anchors.verticalCenter: parent.verticalCenter
            monitor: root.monitor
            // Space left of the Island that the workspace strip does not use.
            maximumWidth: Math.max(0, root.width / 2 - island.width / 2 - workspaces.width - 3 * Theme.spacing.x4)
            visible: Config.panel.showActiveWindow && maximumWidth > 60 && window !== null
                && window.monitor === monitor && window.title !== ""
        }
    }

    IslandCompact {
        id: island
        anchors.centerIn: parent
        // Never overlap the side zones on narrow monitors.
        maximumWidth: Math.max(0, parent.width - 2 * Math.max(workspaces.width, status.width) - 4 * Theme.spacing.x4)
    }

    StatusArea {
        id: status
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacing.x3
        anchors.verticalCenter: parent.verticalCenter
        controlCenterOpen: root.controlCenterOpen
        onControlCenterToggled: ShellState.toggleControlCenter(root.screen.name)
    }

    ControlCenterPopup {
        panel: root
        anchorItem: status
        open: root.controlCenterOpen
        onDismissed: if (root.controlCenterOpen) ShellState.controlCenterMonitor = ""
    }
}

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.core
import qs.modules.ControlCenter
import qs.modules.Island

// Full-width top panel: workspaces (left), Island (centre), system controls (right).
// It never takes keyboard focus; it only receives pointer input inside its own
// rectangle, which Hyprland keeps clear of windows via the exclusive zone.
PanelWindow {
    id: root

    property bool controlCenterOpen: false

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

    Rectangle {
        anchors.fill: parent
        color: Theme.chrome
    }

    WorkspaceStrip {
        id: workspaces
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacing.x3
        anchors.verticalCenter: parent.verticalCenter
        screen: root.screen
    }

    IslandCompact {
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
        onControlCenterToggled: root.controlCenterOpen = !root.controlCenterOpen
    }

    ControlCenterPopup {
        panel: root
        anchorItem: status
        open: root.controlCenterOpen
        onDismissed: root.controlCenterOpen = false
    }
}

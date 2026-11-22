import QtQuick
import qs.core
import qs.components
import qs.integrations.hyprland

// One workspace in the Overview: a miniature of the monitor with its windows
// at their real positions. `workspace` is null for the "New workspace" slot
// and for default workspaces that do not exist yet (shown empty).
Item {
    id: root

    required property var workspace
    required property int workspaceId
    required property var overview

    property bool isNew: false
    readonly property bool active: workspace !== null && workspace === overview.monitor?.activeWorkspace
    readonly property real scaleFactor: width / Math.max(1, overview.screen.width)
    readonly property bool dropTarget: drop.containsDrag

    // Drawn above the other cards while one of its windows is dragged.
    z: windowsLayer.children.some(c => c.dragActive) ? 10 : 0

    Rectangle {
        id: card
        anchors.fill: parent
        radius: Theme.shape.lg
        topLeftRadius: root.active ? Theme.shape.organic : Theme.shape.lg
        color: root.isNew ? Qt.alpha(Theme.color.surfaceContainerLow, 0.85) : Theme.color.surfaceContainerLow
        border.width: root.dropTarget ? 3 : root.active ? 2 : root.isNew ? 2 : 1
        border.color: root.dropTarget || root.active ? Theme.color.primary : Theme.color.outlineVariant

        Behavior on border.width {
            NumberAnimation { duration: Motion.hover }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.overview.openWorkspace(root.workspaceId)
        }

        Column {
            anchors.centerIn: parent
            spacing: Theme.spacing.x1
            visible: root.isNew

            MaterialIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                icon: "add"
                size: 28
                color: Theme.color.contentSurfaceVariant
            }

            MText {
                role: Typography.labelLarge
                color: Theme.color.contentSurfaceVariant
                text: "New workspace"
            }
        }
    }

    Item {
        id: windowsLayer
        anchors.fill: parent

        Repeater {
            model: root.workspace ? root.overview.sortedWindows(root.workspace) : []

            WindowCard {
                required property var modelData
                window: modelData
                overview: root.overview
                workspaceCard: root
            }
        }
    }

    // Workspace number badge.
    Rectangle {
        x: Theme.spacing.x2
        y: -height / 2
        width: Math.max(height, label.implicitWidth + 2 * Theme.spacing.x2)
        height: 24
        radius: height / 2
        color: root.active ? Theme.color.primary : Theme.color.surfaceContainerHighest
        visible: !root.isNew

        MText {
            id: label
            anchors.centerIn: parent
            role: Typography.labelLarge
            color: root.active ? Theme.color.contentPrimary : Theme.color.contentSurface
            text: root.workspace?.name ?? root.workspaceId
        }
    }

    DropArea {
        id: drop
        anchors.fill: parent
        keys: ["mellow-window"]
        // Not a target for windows already on this workspace.
        onEntered: drag => {
            if (drag.source?.window?.workspace === root.workspace && !root.isNew)
                drag.accepted = false;
        }
    }
}

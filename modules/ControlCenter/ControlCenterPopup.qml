import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.core
import qs.components

// M0 Control Center surface: opens from the panel trigger and closes on
// Escape, on the trigger, or on a click outside. Real quick settings land in
// M3; until then it says so instead of showing toggles that do nothing.
PopupWindow {
    id: root

    required property var panel
    required property Item anchorItem
    property bool open: false
    signal dismissed

    anchor.window: panel
    anchor.item: anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.margins.top: Theme.spacing.x2

    visible: open
    implicitWidth: 320
    implicitHeight: card.implicitHeight
    color: "transparent"

    // Keeps keyboard focus in the popup and dismisses it on outside clicks.
    // The panel is included so its trigger can toggle the popup closed.
    HyprlandFocusGrab {
        active: root.visible
        windows: [root, root.panel]
        onCleared: root.dismissed()
    }

    Surface {
        id: card
        anchors.fill: parent
        implicitHeight: column.implicitHeight + 2 * Theme.spacing.x5
        radius: Theme.shape.xl
        topRightRadius: Theme.shape.md
        color: Theme.color.surfaceContainer
        border.width: 1
        border.color: Theme.color.outlineVariant

        focus: true
        Keys.onEscapePressed: root.dismissed()

        Column {
            id: column
            anchors.fill: parent
            anchors.margins: Theme.spacing.x5
            spacing: Theme.spacing.x2

            MText {
                role: Typography.titleLarge
                text: "Control Center"
            }

            MText {
                width: parent.width
                role: Typography.bodyMedium
                color: Theme.color.contentSurfaceVariant
                wrapMode: Text.WordWrap
                text: "Quick settings for network, audio, Bluetooth and power arrive in milestone M3."
            }
        }
    }
}

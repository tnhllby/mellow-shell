import QtQuick
import qs.core
import qs.components

// Right panel zone. M0 holds only the Control Center trigger: status
// indicators appear once their services exist (M3). No placeholder icons
// pretend to show system state.
Surface {
    id: root

    property bool controlCenterOpen: false
    signal controlCenterToggled

    implicitWidth: trigger.implicitWidth + 2 * Theme.spacing.x1
    implicitHeight: 40
    radius: Theme.shape.pill
    color: Theme.color.surfaceContainerHigh

    IconButton {
        id: trigger
        anchors.centerIn: parent
        implicitWidth: 48
        implicitHeight: 32
        icon: "tune"
        label: "Control Center"
        variant: "tonal"
        toggled: root.controlCenterOpen
        onClicked: root.controlCenterToggled()
    }
}

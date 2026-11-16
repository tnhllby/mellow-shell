import QtQuick
import Quickshell
import qs.core
import qs.components

// Right panel zone: clock and the Control Center trigger. Status indicators
// appear once their services exist (M3); no placeholder icons pretend to show
// system state.
Surface {
    id: root

    property bool controlCenterOpen: false
    signal controlCenterToggled

    implicitWidth: row.implicitWidth + Theme.spacing.x4 + Theme.spacing.x1
    implicitHeight: 40
    radius: Theme.shape.pill
    color: Theme.color.surfaceContainerHigh

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Row {
        id: row
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacing.x1
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacing.x3

        MText {
            anchors.verticalCenter: parent.verticalCenter
            role: Typography.labelLarge
            color: Theme.color.contentSurfaceVariant
            text: Qt.formatDate(clock.date, Config.clock.dateFormat)
        }

        MText {
            anchors.verticalCenter: parent.verticalCenter
            role: Typography.titleMedium
            tabular: true
            text: Qt.formatTime(clock.date, Config.clock.timeFormat)
        }

        IconButton {
            id: trigger
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: 48
            implicitHeight: 32
            icon: "tune"
            label: "Control Center"
            variant: "tonal"
            toggled: root.controlCenterOpen
            onClicked: root.controlCenterToggled()
        }
    }
}

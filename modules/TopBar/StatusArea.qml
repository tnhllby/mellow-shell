import QtQuick
import Quickshell
import qs.core
import qs.components
import qs.services

// Right panel zone: clock and the Control Center trigger, which shows live
// status (network, Bluetooth, mute, battery). Indicators appear only when
// their service reports something real.
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

        // Control Center trigger with status icons.
        Rectangle {
            id: trigger

            readonly property color contentColor: root.controlCenterOpen ? Theme.color.contentSecondaryContainer : Theme.color.contentSurfaceVariant

            anchors.verticalCenter: parent.verticalCenter
            width: icons.implicitWidth + 2 * Theme.spacing.x3
            height: 32
            radius: root.controlCenterOpen ? Theme.shape.md : Theme.shape.pill
            color: root.controlCenterOpen ? Theme.color.secondaryContainer : Theme.color.surfaceContainerHighest
            Accessible.role: Accessible.Button
            Accessible.name: "Control Center"

            Behavior on radius {
                NumberAnimation { duration: Motion.card }
            }

            StateLayer {
                color: trigger.contentColor
                hovered: mouse.containsMouse
                pressed: mouse.pressed
            }

            Row {
                id: icons
                anchors.centerIn: parent
                spacing: Theme.spacing.x2

                MaterialIcon {
                    icon: NetworkService.icon
                    size: 18
                    color: trigger.contentColor
                    visible: NetworkService.available
                }

                MaterialIcon {
                    icon: "bluetooth_connected"
                    size: 18
                    color: trigger.contentColor
                    visible: BluetoothService.connectedDevices.length > 0
                }

                MaterialIcon {
                    icon: "volume_off"
                    size: 18
                    color: trigger.contentColor
                    visible: AudioService.sinkAvailable && AudioService.muted
                }

                MaterialIcon {
                    icon: PowerService.batteryIcon
                    size: 18
                    color: PowerService.percent <= 15 && !PowerService.charging ? Theme.color.error : trigger.contentColor
                    visible: PowerService.hasBattery
                }

                // Shown when no indicator applies, so the trigger never looks empty.
                MaterialIcon {
                    icon: "tune"
                    size: 18
                    color: trigger.contentColor
                    visible: !NetworkService.available && !PowerService.hasBattery
                }
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.controlCenterToggled()
            }
        }
    }
}

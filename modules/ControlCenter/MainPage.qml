import QtQuick
import QtQuick.Layouts
import qs.core
import qs.components
import qs.services

// Control Center main page: battery header, sliders, quick tiles and the
// Wallpaper & style entry.
FocusScope {
    id: root

    required property string monitorName
    signal pageRequested(string name)

    function focusFirst() {
        (brightness.visible ? brightness : volume.visible ? volume : grid.children[0])?.forceActiveFocus();
    }

    implicitHeight: column.implicitHeight

    Column {
        id: column
        width: parent.width
        spacing: Theme.spacing.x3

        // Header: title and battery.
        Item {
            width: parent.width
            height: 32

            MText {
                anchors.verticalCenter: parent.verticalCenter
                role: Typography.titleLarge
                text: "Quick settings"
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacing.x1
                visible: PowerService.hasBattery

                MaterialIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: PowerService.batteryIcon
                    size: 20
                    color: PowerService.percent <= 15 && !PowerService.charging ? Theme.color.error : Theme.color.contentSurfaceVariant
                }

                MText {
                    anchors.verticalCenter: parent.verticalCenter
                    role: Typography.labelLarge
                    tabular: true
                    color: Theme.color.contentSurfaceVariant
                    text: PowerService.percent + "%" + (PowerService.charging ? " · Charging" : PowerService.full ? " · Full" : "")
                }
            }
        }

        ExpressiveSlider {
            id: brightness
            width: parent.width
            // Brightness of the display this Control Center opened on.
            visible: BrightnessService.available(root.monitorName)
            icon: "brightness_6"
            label: "Brightness, " + root.monitorName
            value: BrightnessService.value(root.monitorName)
            onMoved: v => BrightnessService.setValue(root.monitorName, v)
        }

        ExpressiveSlider {
            id: volume
            width: parent.width
            visible: AudioService.sinkAvailable
            icon: AudioService.muted ? "volume_off" : AudioService.volume < 0.4 ? "volume_down" : "volume_up"
            label: "Volume, " + AudioService.sinkName + (AudioService.muted ? ", muted" : "")
            value: AudioService.muted ? 0 : AudioService.volume
            onMoved: v => AudioService.setVolume(v)
            onIconClicked: AudioService.toggleMute()
        }

        MText {
            width: parent.width
            role: Typography.labelMedium
            color: Theme.color.contentSurfaceVariant
            text: AudioService.sinkName
            visible: AudioService.sinkAvailable && text !== ""
        }

        GridLayout {
            id: grid
            width: parent.width
            columns: 2
            columnSpacing: Theme.spacing.x2
            rowSpacing: Theme.spacing.x2

            QuickTile {
                Layout.fillWidth: true
                visible: NetworkService.available
                icon: NetworkService.icon
                title: "Internet"
                subtitle: NetworkService.label
                active: NetworkService.connected || NetworkService.wifiEnabled
                hasDetails: NetworkService.wifiAvailable
                onActivated: NetworkService.wifiAvailable ? NetworkService.setWifiEnabled(!NetworkService.wifiEnabled) : root.pageRequested("wifi")
                onDetailsRequested: root.pageRequested("wifi")
            }

            QuickTile {
                Layout.fillWidth: true
                visible: BluetoothService.available
                icon: BluetoothService.enabled ? (BluetoothService.connectedDevices.length > 0 ? "bluetooth_connected" : "bluetooth") : "bluetooth_disabled"
                title: "Bluetooth"
                subtitle: BluetoothService.label
                active: BluetoothService.enabled
                hasDetails: true
                onActivated: BluetoothService.setEnabled(!BluetoothService.enabled)
                onDetailsRequested: root.pageRequested("bluetooth")
            }

            QuickTile {
                Layout.fillWidth: true
                visible: AudioService.sourceAvailable
                icon: AudioService.micMuted ? "mic_off" : "mic"
                title: "Microphone"
                subtitle: AudioService.micMuted ? "Muted" : "On"
                active: !AudioService.micMuted
                onActivated: AudioService.toggleMicMute()
            }

            QuickTile {
                Layout.fillWidth: true
                visible: PowerService.profilesAvailable
                icon: PowerService.profileIcon(PowerService.profile)
                title: "Power mode"
                subtitle: PowerService.profileName(PowerService.profile)
                active: !PowerService.balanced
                onActivated: PowerService.cycleProfile()
            }

            QuickTile {
                Layout.fillWidth: true
                icon: "dark_mode"
                title: "Dark theme"
                subtitle: ThemeState.dark ? "On" : "Off"
                active: ThemeState.dark
                onActivated: ThemeState.toggleMode()
            }
        }

        // Prominent entry to Wallpaper Studio.
        Rectangle {
            id: studioButton
            width: parent.width
            height: 52
            radius: Theme.shape.lg
            topLeftRadius: Theme.shape.organic
            color: Theme.color.secondaryContainer
            activeFocusOnTab: true
            Accessible.role: Accessible.Button
            Accessible.name: "Wallpaper and style"
            Keys.onReturnPressed: ShellState.openStudio(root.monitorName)
            Keys.onSpacePressed: ShellState.openStudio(root.monitorName)

            StateLayer {
                color: Theme.color.contentSecondaryContainer
                hovered: studioMouse.containsMouse
                pressed: studioMouse.pressed
                focused: studioButton.activeFocus
            }

            FocusRing {
                shown: studioButton.activeFocus
            }

            Row {
                anchors.centerIn: parent
                spacing: Theme.spacing.x2

                MaterialIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "palette"
                    size: 22
                    filled: true
                    color: Theme.color.contentSecondaryContainer
                }

                MText {
                    anchors.verticalCenter: parent.verticalCenter
                    role: Typography.labelLarge
                    color: Theme.color.contentSecondaryContainer
                    text: "Wallpaper & style"
                }
            }

            MouseArea {
                id: studioMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: ShellState.openStudio(root.monitorName)
            }
        }
    }
}

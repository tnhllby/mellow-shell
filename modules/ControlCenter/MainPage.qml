import QtQuick
import QtQuick.Layouts
import qs.core
import qs.components
import qs.services

// Control Center main page: battery header, sliders and quick tiles stay at
// the top; media controls and notifications scroll below them.
FocusScope {
    id: root

    required property string monitorName
    signal pageRequested(string name)
    signal closeRequested

    function focusFirst() {
        (brightness.visible ? brightness : volume.visible ? volume : grid.children[0])?.forceActiveFocus();
    }

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

            IconButton {
                id: gear
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                icon: "settings"
                label: "Settings"
                onClicked: {
                    ShellState.settingsOpen = true;
                    root.closeRequested();
                }
            }

            Row {
                anchors.right: gear.left
                anchors.rightMargin: Theme.spacing.x1
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacing.x1
                visible: PowerService.hasBattery

                MaterialIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: PowerService.batteryIcon
                    size: Theme.icon.control
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
            visible: Config.controlCenter.brightnessSlider && BrightnessService.available(root.monitorName)
            icon: "brightness_6"
            label: "Brightness, " + root.monitorName
            value: BrightnessService.value(root.monitorName)
            onMoved: v => BrightnessService.setValue(root.monitorName, v)
        }

        ExpressiveSlider {
            id: volume
            width: parent.width
            visible: Config.controlCenter.volumeSlider && AudioService.sinkAvailable
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
            visible: volume.visible && text !== ""
        }

        GridLayout {
            id: grid

            readonly property int tileCount: 3 + [NetworkService.available, BluetoothService.available, AudioService.sourceAvailable, PowerService.profilesAvailable].filter(v => v).length

            width: parent.width
            columns: Config.controlCenter.tileColumns
            uniformCellWidths: true
            columnSpacing: Theme.spacing.x2
            rowSpacing: Theme.spacing.x2

            QuickTile {
                Layout.fillWidth: true
                visible: NetworkService.available
                icon: NetworkService.icon
                title: "Internet"
                subtitle: NetworkService.label
                label: NetworkService.connected ? NetworkService.label : title
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
                label: subtitle
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

            QuickTile {
                Layout.fillWidth: true
                enabled: NotificationService.active
                icon: NotificationService.doNotDisturb ? "notifications_off" : "notifications"
                title: "Do Not Disturb"
                label: "Silent"
                subtitle: !NotificationService.active ? "Another program notifies" : NotificationService.doNotDisturb ? "On" : "Off"
                active: enabled && NotificationService.doNotDisturb
                onActivated: NotificationService.toggleDoNotDisturb()
            }

            QuickTile {
                Layout.fillWidth: true
                icon: "coffee"
                title: "Keep awake"
                subtitle: KeepAwakeService.active ? "On" : "Off"
                active: KeepAwakeService.active
                onActivated: KeepAwakeService.toggle()
            }

            // Wallpaper Studio; fills the rest of its row.
            QuickTile {
                Layout.fillWidth: true
                Layout.columnSpan: grid.columns - grid.tileCount % grid.columns
                icon: "palette"
                title: "Wallpaper"
                subtitle: "Style and colors"
                onActivated: ShellState.openStudio(root.monitorName)
            }
        }
    }

    Flickable {
        id: flick

        // Room for the focus rings, which the clip would cut.
        readonly property int pad: Theme.focusRing.offset + Theme.focusRing.width

        anchors.top: column.bottom
        anchors.topMargin: Theme.spacing.x3 - pad
        anchors.bottom: parent.bottom
        x: -pad
        width: parent.width + 2 * pad
        contentHeight: lower.implicitHeight + 2 * pad
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        // Keep the keyboard-focused control in view.
        readonly property Item focusedItem: Window.activeFocusItem
        onFocusedItemChanged: {
            let item = focusedItem;
            while (item && item !== lower)
                item = item.parent;
            if (!item || focusedItem === lower)
                return;
            const top = focusedItem.mapToItem(contentItem, 0, 0).y - pad;
            const bottom = top + focusedItem.height + 2 * pad;
            if (top < contentY)
                contentY = top;
            else if (bottom > contentY + height)
                contentY = Math.min(top, bottom - height);
        }

        Column {
            id: lower
            x: flick.pad
            y: flick.pad
            width: root.width
            spacing: Theme.spacing.x2

            MediaCard {
                width: parent.width
                visible: MediaService.activePlayer !== null
            }

            NotificationList {
                width: parent.width
                onActionInvoked: root.closeRequested()
            }
        }
    }
}

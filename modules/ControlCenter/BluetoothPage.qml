import QtQuick
import qs.core
import qs.components
import qs.services

// Bluetooth details: on/off switch and paired devices (connect/disconnect).
FocusScope {
    id: root

    signal back

    onVisibleChanged: if (visible) Qt.callLater(() => header.focusBack())

    function status(device) {
        if (device.pairing)
            return "Pairing…";
        const battery = device.batteryAvailable ? ` · ${Math.round(device.battery * 100)}%` : "";
        return (device.connected ? "Connected" : "Paired") + battery;
    }

    Column {
        id: column
        width: parent.width
        spacing: Theme.spacing.x2

        PageHeader {
            id: header
            title: "Bluetooth"
            showSwitch: true
            checked: BluetoothService.enabled
            onBack: root.back()
            onToggled: BluetoothService.setEnabled(!BluetoothService.enabled)
        }

        MText {
            width: parent.width
            role: Typography.bodyMedium
            color: Theme.color.contentSurfaceVariant
            wrapMode: Text.WordWrap
            text: !BluetoothService.enabled ? "Bluetooth is off."
                : BluetoothService.devices.length === 0 ? "No paired devices." : ""
            visible: text !== ""
        }

        ListView {
            id: list
            width: parent.width
            height: Math.min(contentHeight, Math.max(120, root.height - y - (pairHint.height + column.spacing)))
            clip: true
            spacing: Theme.spacing.x1
            visible: BluetoothService.enabled
            model: BluetoothService.devices
            boundsBehavior: Flickable.StopAtBounds

            delegate: ListRow {
                required property var modelData
                width: list.width
                icon: BluetoothService.iconFor(modelData)
                title: modelData.name
                subtitle: root.status(modelData)
                highlighted: modelData.connected
                onActivated: BluetoothService.toggleDevice(modelData)
            }
        }

        MText {
            id: pairHint
            width: parent.width
            role: Typography.bodySmall
            color: Theme.color.contentSurfaceVariant
            wrapMode: Text.WordWrap
            text: "Pair new devices with a Bluetooth manager (e.g. bluetoothctl)."
            visible: BluetoothService.enabled
        }
    }
}

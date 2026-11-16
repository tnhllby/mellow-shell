pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

// Bluetooth through BlueZ (Quickshell.Bluetooth). Shows paired devices;
// pairing new devices is left to a dedicated Bluetooth manager for now.
Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property var devices: Bluetooth.devices.values
        .filter(d => d.paired)
        .sort((a, b) => (b.connected - a.connected) || a.name.localeCompare(b.name))
    readonly property var connectedDevices: devices.filter(d => d.connected)
    readonly property string label: !enabled ? "Off" : connectedDevices.length === 1 ? connectedDevices[0].name
        : connectedDevices.length > 1 ? connectedDevices.length + " devices" : "On"

    function setEnabled(value) {
        if (adapter)
            adapter.enabled = value;
    }

    function toggleDevice(device) {
        if (device.connected)
            device.disconnect();
        else
            device.connect();
    }

    // Material Symbol for a device's freedesktop icon name.
    function iconFor(device) {
        const name = device.icon ?? "";
        if (name.includes("headset") || name.includes("headphone"))
            return "headphones";
        if (name.includes("audio") || name.includes("speaker"))
            return "speaker";
        if (name.includes("gaming"))
            return "sports_esports";
        if (name.includes("keyboard"))
            return "keyboard";
        if (name.includes("mouse"))
            return "mouse";
        if (name.includes("phone"))
            return "smartphone";
        return "bluetooth";
    }
}

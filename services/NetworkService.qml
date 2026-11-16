pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Networking

// Network state through NetworkManager (Quickshell.Networking).
Singleton {
    id: root

    readonly property bool available: Networking.backend === NetworkBackendType.NetworkManager
    readonly property var devices: Networking.devices.values
    readonly property var wifiDevice: devices.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wiredDevice: devices.find(d => d.type === DeviceType.Wired && d.connected) ?? null

    readonly property bool wifiAvailable: available && wifiDevice !== null && Networking.wifiHardwareEnabled
    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property var activeWifi: wifiDevice?.networks.values.find(n => n.connected) ?? null
    // Visible networks, connected first, then by signal strength.
    readonly property var wifiNetworks: (wifiDevice?.networks.values ?? []).slice()
        .sort((a, b) => (b.connected - a.connected) || (b.signalStrength - a.signalStrength))

    readonly property bool connected: wiredDevice !== null || activeWifi !== null
    readonly property string label: wiredDevice ? "Ethernet" : activeWifi?.name ?? (wifiEnabled ? "Not connected" : "Off")

    // Material Symbols for the current connection.
    readonly property string icon: {
        if (wiredDevice)
            return "lan";
        if (!wifiEnabled)
            return "wifi_off";
        if (!activeWifi)
            return "signal_wifi_statusbar_not_connected";
        const s = activeWifi.signalStrength;
        return s > 0.75 ? "network_wifi" : s > 0.5 ? "network_wifi_3_bar" : s > 0.25 ? "network_wifi_2_bar" : "network_wifi_1_bar";
    }

    function setWifiEnabled(enabled) {
        if (available)
            Networking.wifiEnabled = enabled;
    }

    // Scan for networks while a network list is visible.
    function setScanning(scanning) {
        if (wifiDevice)
            wifiDevice.scannerEnabled = scanning;
    }

    function isOpen(network) {
        return network.security === WifiSecurityType.Open || network.security === WifiSecurityType.Owe;
    }

    // Networks joinable with just a password.
    function needsPassword(network) {
        return [WifiSecurityType.WpaPsk, WifiSecurityType.Wpa2Psk, WifiSecurityType.Sae, WifiSecurityType.StaticWep]
            .includes(network.security);
    }

    function signalIcon(network) {
        const s = network.signalStrength;
        return s > 0.75 ? "network_wifi" : s > 0.5 ? "network_wifi_3_bar" : s > 0.25 ? "network_wifi_2_bar" : "network_wifi_1_bar";
    }
}

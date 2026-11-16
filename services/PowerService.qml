pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

// Battery (UPower) and power profiles (power-profiles-daemon).
Singleton {
    id: root

    readonly property var battery: UPower.displayDevice
    readonly property bool hasBattery: battery?.isLaptopBattery === true && battery.isPresent
    readonly property int percent: Math.round((battery?.percentage ?? 0) * 100)
    readonly property bool charging: battery?.state === UPowerDeviceState.Charging
    readonly property bool full: battery?.state === UPowerDeviceState.FullyCharged
    readonly property bool onBattery: UPower.onBattery

    readonly property string batteryIcon: {
        if (charging)
            return "battery_charging_full";
        if (full || percent >= 95)
            return "battery_full";
        const bars = Math.max(0, Math.min(6, Math.floor(percent / 100 * 7)));
        return percent <= 10 ? "battery_alert" : `battery_${bars}_bar`;
    }

    property bool profilesAvailable: false
    readonly property int profile: PowerProfiles.profile
    readonly property bool balanced: profile === PowerProfile.Balanced
    readonly property var profiles: PowerProfiles.hasPerformanceProfile
        ? [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]
        : [PowerProfile.PowerSaver, PowerProfile.Balanced]

    function profileName(p) {
        return p === PowerProfile.PowerSaver ? "Power saver" : p === PowerProfile.Performance ? "Performance" : "Balanced";
    }

    function profileIcon(p) {
        return p === PowerProfile.PowerSaver ? "energy_savings_leaf" : p === PowerProfile.Performance ? "speed" : "balance";
    }

    function cycleProfile() {
        if (!profilesAvailable)
            return;
        const index = profiles.indexOf(profile);
        PowerProfiles.profile = profiles[(index + 1) % profiles.length];
    }

    // power-profiles-daemon is optional: detect it once on the system bus.
    Process {
        running: true
        command: ["busctl", "status", "org.freedesktop.UPower.PowerProfiles"]
        onExited: code => root.profilesAvailable = code === 0
    }
}

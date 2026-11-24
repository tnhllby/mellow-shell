pragma Singleton
import QtQuick
import Quickshell
import qs.core

// Battery notifications at the configured levels (0 = off), once per level
// until the charger is connected. Only while MELLOW receives notifications:
// otherwise the other shell is in charge of them.
Singleton {
    id: root

    readonly property bool active: NotificationService.active && PowerService.hasBattery
    readonly property int percent: PowerService.percent
    readonly property bool draining: active && PowerService.onBattery
    readonly property bool full: active && PowerService.full && !PowerService.onBattery
    // Lowest level already announced.
    property int announced: 101

    function send(urgency, title, body) {
        Quickshell.execDetached(["notify-send", "-a", "MELLOW", "-u", urgency, title, body]);
    }

    function check() {
        if (!draining) {
            announced = 101;
            return;
        }
        const critical = Config.battery.critical, low = Config.battery.low;
        if (critical > 0 && percent <= critical && announced > critical) {
            announced = critical;
            send("critical", "Battery is almost empty", percent + "% left. Connect the charger.");
        } else if (low > 0 && percent <= low && announced > low) {
            announced = low;
            send("normal", "Battery is low", percent + "% left");
        }
    }

    onPercentChanged: check()
    onDrainingChanged: check()
    onFullChanged: {
        if (full && Config.battery.fullAlert)
            send("normal", "Battery is full", "You can disconnect the charger");
    }
}

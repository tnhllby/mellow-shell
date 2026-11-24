pragma Singleton
import QtQuick
import Quickshell

// Keep system awake: while on, the bars hold Wayland idle inhibitors
// (TopBar), so idle programs do not dim, lock or suspend. Survives a config
// reload but not a restart, so it is never left on by accident.
Singleton {
    id: root

    readonly property bool active: persist.active

    function toggle() {
        persist.active = !persist.active;
    }

    PersistentProperties {
        id: persist
        reloadableId: "keepAwake"
        property bool active: false
    }
}

pragma Singleton
import QtQuick
import Quickshell

// Shell-wide UI state shared between surfaces and entry points (pointer,
// global shortcuts, IPC). Monitors are identified by connector name ("eDP-1").
Singleton {
    // Monitor showing the Control Center, or "" when closed.
    property string controlCenterMonitor: ""
    // Monitor whose Dock was opened from the keyboard, or "" when closed.
    property string dockMonitor: ""

    function toggleControlCenter(monitor) {
        controlCenterMonitor = controlCenterMonitor === monitor ? "" : monitor;
    }

    function toggleDock(monitor) {
        dockMonitor = dockMonitor === monitor ? "" : monitor;
    }

    function closeAll() {
        controlCenterMonitor = "";
        dockMonitor = "";
    }
}

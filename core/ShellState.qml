pragma Singleton
import QtQuick
import Quickshell

// Shell-wide UI state shared between surfaces and entry points (pointer,
// global shortcuts, IPC). Monitors are identified by connector name ("eDP-1").
Singleton {
    // Monitor showing the Control Center, or "" when closed.
    property string controlCenterMonitor: ""
    // Whether the Control Center was opened from the keyboard.
    property bool controlCenterFromKeyboard: false
    // Monitor whose Dock was opened from the keyboard, or "" when closed.
    property string dockMonitor: ""
    // Monitor showing the expanded Island (media player), or "" when compact.
    property string islandMonitor: ""
    // Monitor showing Wallpaper Studio, or "" when closed.
    property string studioMonitor: ""
    // Whether the Island was expanded from the keyboard (shows the focus ring at once).
    property bool islandFromKeyboard: false

    function toggleControlCenter(monitor, fromKeyboard) {
        controlCenterFromKeyboard = fromKeyboard === true;
        controlCenterMonitor = controlCenterMonitor === monitor ? "" : monitor;
    }

    function toggleDock(monitor) {
        dockMonitor = dockMonitor === monitor ? "" : monitor;
    }

    function toggleIsland(monitor, fromKeyboard) {
        islandFromKeyboard = fromKeyboard === true;
        islandMonitor = islandMonitor === monitor ? "" : monitor;
    }

    function openStudio(monitor) {
        controlCenterMonitor = "";
        studioMonitor = monitor;
    }

    function closeAll() {
        studioMonitor = "";
        controlCenterMonitor = "";
        dockMonitor = "";
        islandMonitor = "";
    }
}

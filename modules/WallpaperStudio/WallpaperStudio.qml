import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.core
import qs.components
import qs.services

// Wallpaper Studio: pick a wallpaper, preview it per monitor with its colour
// scheme on a miniature MELLOW desktop, then apply or revert.
// Opened from the Control Center ("Wallpaper & style") or the `mellow:studio`
// shortcut; Escape, Close or a click on the backdrop closes it.
// The surface stays mapped (input region and keyboard focus only while open)
// so the focus grab never races the surface being created.
PanelWindow {
    id: root

    readonly property bool open: ShellState.studioMonitor === screen?.name

    function close() {
        if (open)
            ShellState.studioMonitor = "";
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    mask: Region {
        item: root.open ? backdrop : null
    }

    WlrLayershell.namespace: "mellow:studio"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    HyprlandFocusGrab {
        active: root.open
        windows: [root]
        onCleared: root.close()
    }

    Rectangle {
        id: backdrop
        anchors.fill: parent
        visible: root.open
        color: Qt.alpha(Theme.color.scrim, 0.45)

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }

    // Content exists only while open (no folder scanning in the background).
    Loader {
        anchors.centerIn: parent
        width: Math.min(1080, root.width - 2 * Theme.spacing.x8)
        height: Math.min(720, root.height - 2 * Theme.spacing.x8)
        active: root.open
        focus: true
        sourceComponent: StudioContent {
            monitorName: root.screen?.name ?? ""
            aspect: root.width / Math.max(1, root.height)
            onCloseRequested: root.close()
        }
    }
}

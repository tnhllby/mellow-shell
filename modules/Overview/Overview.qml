import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.core
import qs.integrations.hyprland

// Workspace / window Overview (Meta+Tab) for one monitor. The surface stays
// mapped (input region and keyboard focus only while open); its content, with
// window previews, exists only while open.
PanelWindow {
    id: root

    readonly property bool open: ShellState.overviewMonitor === screen?.name

    function close() {
        if (open)
            ShellState.overviewMonitor = "";
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

    WlrLayershell.namespace: "mellow:overview"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    HyprlandFocusGrab {
        active: root.open
        windows: [root]
        onCleared: root.close()
    }

    // Window geometry (IPC data) is refreshed on open and on window events.
    onOpenChanged: if (open) {
        Hyprland.refreshWorkspaces();
        Hyprland.refreshToplevels();
    }

    Connections {
        target: Hyprland
        enabled: root.open

        function onRawEvent(event) {
            if (["openwindow", "closewindow", "movewindowv2", "changefloatingmode", "fullscreen", "workspacev2"].includes(event.name))
                refreshDelay.restart();
        }
    }

    Timer {
        id: refreshDelay
        interval: 120
        onTriggered: Hyprland.refreshToplevels()
    }

    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Qt.alpha(Theme.color.scrim, 0.55)
        opacity: root.open ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation { duration: Motion.workspace }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }

    Loader {
        anchors.fill: parent
        active: root.open
        focus: true
        sourceComponent: OverviewContent {
            screen: root.screen
            onCloseRequested: root.close()
        }
    }
}

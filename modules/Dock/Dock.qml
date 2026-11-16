import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.core
import qs.components

// Left-edge Dock. Hidden, it only accepts input on a thin strip along the
// screen edge; pointing at that strip slides the pinned apps in.
// The `mellow:dock` shortcut opens it with keyboard focus: Up/Down/Tab move,
// Enter/Space launch, Escape or a click elsewhere closes it.
PanelWindow {
    id: root

    readonly property bool keyboardOpen: ShellState.dockMonitor === screen?.name
    readonly property bool shown: !Config.dock.autoHide || keyboardOpen || zone.containsMouse || hideTimer.running

    function closeKeyboard() {
        if (keyboardOpen)
            ShellState.dockMonitor = "";
    }

    onKeyboardOpenChanged: if (keyboardOpen) Qt.callLater(() => column.children[0]?.forceActiveFocus())

    // Re-evaluated when the desktop entry database (re)loads.
    readonly property var apps: {
        DesktopEntries.applications.values;
        return Config.dock.pinned.map(id => DesktopEntries.byId(id)).filter(entry => entry && !entry.noDisplay);
    }

    anchors {
        top: true
        bottom: true
        left: true
    }
    margins.top: Config.panel.height
    implicitWidth: card.width + Config.frame.thickness + 2 * Theme.spacing.x2
    exclusionMode: Config.dock.autoHide ? ExclusionMode.Ignore : ExclusionMode.Normal
    exclusiveZone: Config.dock.autoHide ? 0 : implicitWidth
    color: "transparent"
    visible: apps.length > 0

    WlrLayershell.namespace: "mellow:dock"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: keyboardOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    HyprlandFocusGrab {
        active: root.keyboardOpen
        windows: [root]
        onCleared: root.closeKeyboard()
    }

    // The input region is exactly the hover zone. It grows from the edge strip
    // to the whole dock column, so the pointer stays inside it when the dock
    // opens, whether it rests on the edge or moves onto the card.
    mask: Region {
        item: zone
    }

    Timer {
        id: hideTimer
        interval: Config.dock.hideDelay
    }

    MouseArea {
        id: zone

        width: root.shown ? root.width : Config.dock.triggerWidth
        height: parent.height
        hoverEnabled: true
        Keys.onEscapePressed: root.closeKeyboard()
        onContainsMouseChanged: if (!containsMouse && Config.dock.autoHide) hideTimer.restart()

        Surface {
            id: card

            x: root.shown ? Config.frame.thickness + Theme.spacing.x2 : -width - Theme.spacing.x4
            anchors.verticalCenter: parent.verticalCenter
            width: 64
            height: column.implicitHeight + 2 * Theme.spacing.x2
            radius: Theme.shape.lg
            topRightRadius: Theme.shape.organic
            color: Theme.color.surfaceContainerHigh
            border.width: 1
            border.color: Theme.color.outlineVariant

            Behavior on x {
                NumberAnimation {
                    duration: Motion.module
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: root.shown ? Motion.emphasizedDecelerate : Motion.emphasizedAccelerate
                }
            }

            Column {
                id: column
                anchors.centerIn: parent
                spacing: Theme.spacing.x1

                Repeater {
                    model: root.apps

                    delegate: DockItem {
                        onLaunched: {
                            hideTimer.stop();
                            root.closeKeyboard();
                        }
                    }
                }
            }
        }
    }
}

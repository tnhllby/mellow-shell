import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.core
import qs.components
import qs.services

// Left-edge Dock, built from two surfaces:
//  - an edge trigger: a thin strip on the screen edge whose input region never
//    changes, so the pointer keeps hovering it even when pushed against the edge;
//  - the dock itself: input only while shown, starting right next to the strip
//    so the pointer can move from the edge onto the apps without a gap.
// The `mellow:dock` shortcut opens it with keyboard focus: Up/Down/Tab move,
// Enter/Space launch, Escape or a click elsewhere closes it.
Scope {
    id: root

    required property ShellScreen screen

    readonly property bool keyboardOpen: ShellState.dockMonitor === screen?.name
    readonly property bool hovered: edgeArea.containsMouse || dockArea.containsMouse
    readonly property bool shown: !Config.dock.autoHide || keyboardOpen || hovered || hideTimer.running

    // Pinned applications, then running applications that are not pinned.
    readonly property var pinnedItems: AppService.pinned.map(entry => ({ entry, appId: entry.id, pinned: true }))
    readonly property var runningItems: AppService.runningUnpinned.map(item => Object.assign({ pinned: false }, item))
    readonly property var apps: pinnedItems.concat(runningItems)

    function closeKeyboard() {
        if (keyboardOpen)
            ShellState.dockMonitor = "";
    }

    onHoveredChanged: if (!hovered && Config.dock.autoHide) hideTimer.restart()
    onKeyboardOpenChanged: if (keyboardOpen) Qt.callLater(() => column.children[0]?.forceActiveFocus())

    Timer {
        id: hideTimer
        interval: Config.dock.hideDelay
    }

    PanelWindow {
        id: edge

        screen: root.screen
        visible: Config.dock.autoHide && root.apps.length > 0
        anchors {
            top: true
            bottom: true
            left: true
        }
        margins.top: Config.panel.height
        implicitWidth: Config.dock.triggerWidth
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        WlrLayershell.namespace: "mellow:dock-edge"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        MouseArea {
            id: edgeArea
            anchors.fill: parent
            hoverEnabled: true
        }
    }

    PanelWindow {
        id: dock

        screen: root.screen
        visible: root.apps.length > 0
        anchors {
            top: true
            bottom: true
            left: true
        }
        margins.top: Config.panel.height
        implicitWidth: card.width + Config.frame.thickness + 2 * Theme.spacing.x2
        // Auto-hide floats over windows; a pinned dock reserves its width. (Setting
        // exclusiveZone explicitly would override Ignore, so Auto sizes the zone.)
        exclusionMode: Config.dock.autoHide ? ExclusionMode.Ignore : ExclusionMode.Auto
        color: "transparent"

        WlrLayershell.namespace: "mellow:dock"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: root.keyboardOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        // No input while hidden; while shown, everything right of the edge strip.
        mask: Region {
            item: root.shown ? dockArea : null
        }
        BackgroundEffect.blurRegion: Region {
            item: Theme.effects.blurOn ? card : null
            radius: card.radius
            topRightRadius: card.topRightRadius
        }

        HyprlandFocusGrab {
            active: root.keyboardOpen
            windows: [dock]
            onCleared: root.closeKeyboard()
        }

        MouseArea {
            id: dockArea

            x: Config.dock.triggerWidth
            width: parent.width - x
            height: parent.height
            hoverEnabled: true
            Keys.onEscapePressed: root.closeKeyboard()

            Surface {
                id: card

                x: root.shown ? Config.frame.thickness + Theme.spacing.x2 - dockArea.x : -width - dockArea.x - Theme.spacing.x4
                anchors.verticalCenter: parent.verticalCenter
                width: 64
                height: column.implicitHeight + 2 * Theme.spacing.x2
                radius: Theme.shape.lg
                topRightRadius: Theme.shape.organic
                color: Theme.glass(Theme.color.surfaceContainerHigh)
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
                        model: root.pinnedItems

                        delegate: DockItem {
                            onActivated: {
                                hideTimer.stop();
                                root.closeKeyboard();
                            }
                        }
                    }

                    // Divider between pinned and other running applications.
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 28
                        height: 2
                        radius: 1
                        color: Theme.color.outlineVariant
                        visible: root.pinnedItems.length > 0 && root.runningItems.length > 0
                    }

                    Repeater {
                        model: root.runningItems

                        delegate: DockItem {
                            onActivated: {
                                hideTimer.stop();
                                root.closeKeyboard();
                            }
                        }
                    }
                }
            }
        }
    }
}

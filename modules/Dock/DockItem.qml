import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.core
import qs.components
import qs.services
import qs.integrations.hyprland

// One Dock application: pinned and/or running. A pill on the left shows that
// it runs (longer when one of its windows is focused).
// Click / Return: launch it, or focus its window (again: cycle its windows).
// Middle click / Shift+Return: open a new instance.
Rectangle {
    id: root

    // { entry: DesktopEntry | null, appId: string, pinned: bool }
    required property var modelData
    readonly property var entry: modelData.entry
    readonly property var windows: AppService.windowsFor(entry, modelData.appId)
    readonly property bool running: windows.length > 0
    readonly property bool focusedApp: windows.includes(HyprlandService.activeWindow)
    readonly property string name: entry?.name ?? modelData.appId
    signal activated

    function activate() {
        if (!running) {
            AppService.launch(entry);
        } else {
            const index = windows.indexOf(HyprlandService.activeWindow);
            HyprlandService.focusWindow(windows[(index + 1) % windows.length]);
        }
        activated();
    }

    function launchNew() {
        if (entry) {
            AppService.launch(entry);
            activated();
        }
    }

    width: 48
    height: 48
    radius: Theme.shape.md
    color: "transparent"

    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: name + (running ? ", running" : "")
    Keys.onReturnPressed: event => (event.modifiers & Qt.ShiftModifier) ? launchNew() : activate()
    Keys.onEnterPressed: activate()
    Keys.onSpacePressed: activate()
    Keys.onUpPressed: nextItemInFocusChain(false).forceActiveFocus()
    Keys.onDownPressed: nextItemInFocusChain(true).forceActiveFocus()

    StateLayer {
        hovered: mouse.containsMouse
        pressed: mouse.pressed
        focused: root.activeFocus
    }

    FocusRing {
        shown: root.activeFocus
    }

    // Running indicator, in the card's left padding.
    Rectangle {
        x: -7
        anchors.verticalCenter: parent.verticalCenter
        width: 4
        height: root.focusedApp ? 22 : root.running ? 8 : 0
        radius: 2
        color: root.focusedApp ? Theme.color.primary : Theme.color.contentSurfaceVariant
        visible: height > 0

        Behavior on height {
            NumberAnimation {
                duration: Motion.card
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Motion.emphasizedDecelerate
            }
        }
    }

    IconImage {
        anchors.centerIn: parent
        implicitSize: 36
        source: Icons.app(root.entry?.icon || root.modelData.appId)
        scale: mouse.pressed ? 0.9 : 1

        Behavior on scale {
            NumberAnimation { duration: Motion.press }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => mouse.button === Qt.MiddleButton ? root.launchNew() : root.activate()
    }
}

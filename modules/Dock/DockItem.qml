import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.core
import qs.components

// One pinned application. Uses the app's own icon from the icon theme.
Rectangle {
    id: root

    required property DesktopEntry modelData
    signal launched

    function launch() {
        modelData.execute();
        launched();
    }

    width: 48
    height: 48
    radius: Theme.shape.md
    color: "transparent"

    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: modelData.name
    Keys.onReturnPressed: launch()
    Keys.onEnterPressed: launch()
    Keys.onSpacePressed: launch()
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

    IconImage {
        anchors.centerIn: parent
        implicitSize: 36
        source: Quickshell.iconPath(root.modelData.icon, "application-x-executable")
        scale: mouse.pressed ? 0.9 : 1

        Behavior on scale {
            NumberAnimation { duration: Motion.press }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.launch()
    }
}

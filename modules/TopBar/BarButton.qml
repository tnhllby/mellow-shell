import QtQuick
import qs.core
import qs.components

// Round button on the bar, with a tooltip from TopBar.
Rectangle {
    id: root

    property string icon
    property string label
    property bool toggled: false
    readonly property bool hovered: mouse.containsMouse
    signal clicked

    readonly property color contentColor: toggled ? Theme.color.contentSecondaryContainer : Theme.color.contentSurfaceVariant

    width: Theme.barPill.height
    height: Theme.barPill.height
    radius: toggled ? Theme.shape.sm : Theme.shape.pill
    color: toggled ? Theme.color.secondaryContainer : Theme.glass(Theme.color.surfaceContainerHigh)
    Accessible.role: Accessible.Button
    Accessible.name: label

    Behavior on radius {
        MotionNumber { duration: Motion.card }
    }

    StateLayer {
        color: root.contentColor
        hovered: root.hovered
        pressed: mouse.pressed
    }

    MaterialIcon {
        anchors.centerIn: parent
        icon: root.icon
        size: Theme.icon.inline
        filled: root.toggled
        color: root.contentColor
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}

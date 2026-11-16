import QtQuick
import qs.core

// Pixel-style Quick Settings tile: icon, title and status. Clicking (or
// Return/Space) runs the main action; tiles with details show a chevron that
// opens them (also Right arrow).
Rectangle {
    id: root

    property string icon
    property string title
    property string subtitle
    property bool active: false
    property bool hasDetails: false

    signal activated
    signal detailsRequested

    readonly property color contentColor: active ? Theme.color.contentPrimaryContainer : Theme.color.contentSurface

    implicitHeight: 64
    radius: active ? Theme.shape.lg : Theme.shape.xl
    color: active ? Theme.color.primaryContainer : Theme.color.surfaceContainerHighest

    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: title + ", " + subtitle
    Keys.onReturnPressed: activated()
    Keys.onSpacePressed: activated()
    Keys.onRightPressed: if (hasDetails) detailsRequested()

    Behavior on color {
        ColorAnimation { duration: Motion.hover }
    }
    Behavior on radius {
        NumberAnimation { duration: Motion.card }
    }

    StateLayer {
        color: root.contentColor
        hovered: main.containsMouse
        pressed: main.pressed
        focused: root.activeFocus
    }

    FocusRing {
        shown: root.activeFocus
    }

    MouseArea {
        id: main
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }

    Rectangle {
        id: badge
        x: Theme.spacing.x3
        anchors.verticalCenter: parent.verticalCenter
        width: 40
        height: 40
        radius: Theme.shape.md
        color: root.active ? Theme.color.primary : Theme.color.surfaceContainerHigh

        MaterialIcon {
            anchors.centerIn: parent
            icon: root.icon
            size: 22
            filled: root.active
            color: root.active ? Theme.color.contentPrimary : Theme.color.contentSurfaceVariant
        }
    }

    Column {
        anchors.left: badge.right
        anchors.leftMargin: Theme.spacing.x3
        anchors.right: chevron.visible ? chevron.left : parent.right
        anchors.rightMargin: Theme.spacing.x2
        anchors.verticalCenter: parent.verticalCenter

        MText {
            width: parent.width
            role: Typography.labelLarge
            color: root.contentColor
            text: root.title
        }

        MText {
            width: parent.width
            role: Typography.labelMedium
            color: root.contentColor
            opacity: 0.8
            text: root.subtitle
            visible: text !== ""
        }
    }

    Rectangle {
        id: chevron
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacing.x2
        anchors.verticalCenter: parent.verticalCenter
        width: 28
        height: 40
        radius: Theme.shape.sm
        color: "transparent"
        visible: root.hasDetails

        StateLayer {
            color: root.contentColor
            hovered: chevronMouse.containsMouse
            pressed: chevronMouse.pressed
        }

        MaterialIcon {
            anchors.centerIn: parent
            icon: "chevron_right"
            size: 20
            color: root.contentColor
        }

        MouseArea {
            id: chevronMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.detailsRequested()
        }
    }
}

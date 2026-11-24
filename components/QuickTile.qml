import QtQuick
import qs.core

// Compact Quick Settings tile: icon above a short label (the status where it
// says more than the name). Clicking (or Return/Space) runs the main action;
// on tiles with details the label row has a chevron and opens them (also
// right click or the Right arrow).
Rectangle {
    id: root

    property string icon
    property string title
    property string subtitle
    // Shown under the icon.
    property string label: title
    property bool active: false
    property bool hasDetails: false

    signal activated
    signal detailsRequested

    readonly property color contentColor: active ? Theme.color.contentPrimaryContainer : Theme.color.contentSurface

    implicitHeight: 72
    radius: active ? Theme.shape.md : Theme.shape.lg
    color: active ? Theme.color.primaryContainer : Theme.color.surfaceContainerHighest

    activeFocusOnTab: enabled
    opacity: enabled ? 1 : 0.6
    Accessible.role: Accessible.Button
    Accessible.name: title + ", " + subtitle
    Keys.onReturnPressed: activated()
    Keys.onSpacePressed: activated()
    Keys.onRightPressed: if (hasDetails) detailsRequested()

    Behavior on color {
        enabled: !Theme.transitioning
        MotionColor { duration: Motion.hover }
    }
    Behavior on radius {
        MotionNumber { duration: Motion.card }
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
        acceptedButtons: root.hasDetails ? Qt.LeftButton | Qt.RightButton : Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: event => event.button === Qt.RightButton ? root.detailsRequested() : root.activated()
    }

    IconBadge {
        anchors.horizontalCenter: parent.horizontalCenter
        y: Theme.spacing.x2
        implicitWidth: 44
        implicitHeight: 32
        icon: root.icon
        active: root.active
        color: root.active ? Theme.color.primary : Theme.color.surfaceContainerHigh
        iconColor: root.active ? Theme.color.contentPrimary : Theme.color.contentSurfaceVariant
    }

    Rectangle {
        id: details
        anchors.horizontalCenter: parent.horizontalCenter
        y: 42
        width: parent.width - 2 * Theme.spacing.x1
        height: 26
        radius: Theme.shape.sm
        color: "transparent"

        StateLayer {
            color: root.contentColor
            hovered: detailsMouse.containsMouse
            pressed: detailsMouse.pressed
        }

        Row {
            anchors.centerIn: parent

            MText {
                id: name
                width: Math.min(implicitWidth, details.width - (chevron.visible ? chevron.width : 0) - Theme.spacing.x1)
                anchors.verticalCenter: parent.verticalCenter
                role: Typography.labelMedium
                color: root.contentColor
                textFormat: Text.PlainText
                text: root.label
            }

            MaterialIcon {
                id: chevron
                anchors.verticalCenter: parent.verticalCenter
                icon: "chevron_right"
                size: Theme.icon.inline
                color: root.contentColor
                visible: root.hasDetails
            }
        }

        MouseArea {
            id: detailsMouse
            anchors.fill: parent
            enabled: root.hasDetails
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.detailsRequested()
        }
    }
}

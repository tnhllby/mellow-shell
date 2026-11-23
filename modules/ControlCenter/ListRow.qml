import QtQuick
import qs.core
import qs.components

// One row in a Control Center list (network, device).
Rectangle {
    id: root

    property string icon
    property string title
    property string subtitle
    property string trailingIcon
    property bool highlighted: false
    signal activated

    width: parent?.width ?? 0
    height: 56
    radius: Theme.shape.md
    color: highlighted ? Theme.color.secondaryContainer : "transparent"
    activeFocusOnTab: enabled
    opacity: enabled ? 1 : 0.6
    Accessible.role: Accessible.Button
    Accessible.name: title + ", " + subtitle
    Keys.onReturnPressed: activated()
    Keys.onSpacePressed: activated()

    StateLayer {
        color: Theme.color.contentSurface
        hovered: mouse.containsMouse
        pressed: mouse.pressed
        focused: root.activeFocus
    }

    FocusRing {
        shown: root.activeFocus
    }

    IconBadge {
        id: leading
        x: Theme.spacing.x2
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: 36
        implicitHeight: 36
        radius: Theme.shape.sm
        icon: root.icon
        iconSize: 20
        active: root.highlighted
        color: root.highlighted ? Theme.color.secondary : Theme.color.surfaceContainerHigh
        iconColor: root.highlighted ? Theme.color.contentSecondary : Theme.color.contentSurfaceVariant
    }

    Column {
        anchors.left: leading.right
        anchors.leftMargin: Theme.spacing.x3
        anchors.right: trailing.left
        anchors.rightMargin: Theme.spacing.x2
        anchors.verticalCenter: parent.verticalCenter

        MText {
            width: parent.width
            role: Typography.bodyLarge
            color: root.highlighted ? Theme.color.contentSecondaryContainer : Theme.color.contentSurface
            text: root.title
        }

        MText {
            width: parent.width
            role: Typography.bodySmall
            color: Theme.color.contentSurfaceVariant
            text: root.subtitle
            visible: text !== ""
        }
    }

    MaterialIcon {
        id: trailing
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacing.x3
        anchors.verticalCenter: parent.verticalCenter
        icon: root.trailingIcon
        size: 18
        color: Theme.color.contentSurfaceVariant
        visible: root.trailingIcon !== ""
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}

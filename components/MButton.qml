import QtQuick
import qs.core

// Material text button. Variants: "filled", "tonal", "text".
Rectangle {
    id: root

    property string text
    property string icon
    property string variant: "filled"
    signal clicked

    readonly property color contentColor: variant === "filled" ? Theme.color.contentPrimary
        : variant === "tonal" ? Theme.color.contentSecondaryContainer : Theme.color.primary

    implicitWidth: row.implicitWidth + 2 * Theme.spacing.x5
    implicitHeight: 40
    radius: Theme.shape.pill
    color: variant === "filled" ? Theme.color.primary : variant === "tonal" ? Theme.color.secondaryContainer : "transparent"
    opacity: enabled ? 1 : 0.38

    activeFocusOnTab: enabled
    Accessible.role: Accessible.Button
    Accessible.name: text
    Keys.onReturnPressed: clicked()
    Keys.onEnterPressed: clicked()
    Keys.onSpacePressed: clicked()

    StateLayer {
        color: root.contentColor
        hovered: mouse.containsMouse
        pressed: mouse.pressed
        focused: root.activeFocus
    }

    FocusRing {
        shown: root.activeFocus
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.spacing.x2

        MaterialIcon {
            anchors.verticalCenter: parent.verticalCenter
            icon: root.icon
            size: Theme.icon.inline
            color: root.contentColor
            visible: root.icon !== ""
        }

        MText {
            anchors.verticalCenter: parent.verticalCenter
            role: Typography.labelLarge
            color: root.contentColor
            text: root.text
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}

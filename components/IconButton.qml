import QtQuick
import qs.core

// Material icon button. Variants: "standard" (no container), "tonal", "filled".
// Activates with pointer click, Return, Enter or Space.
Rectangle {
    id: root

    property string icon
    property string label: ""
    property string variant: "standard"
    property bool toggled: false
    property int iconSize: 22

    signal clicked

    readonly property color contentColor: {
        if (variant === "filled")
            return toggled ? Theme.color.contentPrimary : Theme.color.primary;
        if (variant === "tonal")
            return toggled ? Theme.color.contentSecondaryContainer : Theme.color.contentSurfaceVariant;
        return toggled ? Theme.color.primary : Theme.color.contentSurfaceVariant;
    }

    opacity: enabled ? 1 : 0.38
    implicitWidth: 40
    implicitHeight: 40
    radius: toggled ? Theme.shape.md : Theme.shape.pill
    color: {
        if (variant === "filled")
            return toggled ? Theme.color.primary : Theme.color.surfaceContainerHighest;
        if (variant === "tonal")
            return toggled ? Theme.color.secondaryContainer : Theme.color.surfaceContainerHighest;
        return "transparent";
    }

    activeFocusOnTab: enabled
    Accessible.role: Accessible.Button
    Accessible.name: label || icon
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            root.clicked();
            event.accepted = true;
        }
    }

    Behavior on radius {
        NumberAnimation {
            duration: Motion.card
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Motion.standard
        }
    }

    StateLayer {
        color: root.contentColor
        hovered: mouse.containsMouse
        pressed: mouse.pressed
        focused: root.activeFocus
    }

    FocusRing {
        shown: root.activeFocus
    }

    MaterialIcon {
        anchors.centerIn: parent
        icon: root.icon
        size: root.iconSize
        filled: root.toggled
        color: root.contentColor
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

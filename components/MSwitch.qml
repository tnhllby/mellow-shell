import QtQuick
import qs.core

// Material 3 switch. Space/Return or a click toggles it.
Rectangle {
    id: root

    property bool checked: false
    property string label
    signal toggled

    implicitWidth: 52
    implicitHeight: 32
    radius: height / 2
    color: checked ? Theme.color.primary : Theme.color.surfaceContainerHighest
    border.width: checked ? 0 : 2
    border.color: Theme.color.outline

    activeFocusOnTab: true
    Accessible.role: Accessible.CheckBox
    Accessible.name: label
    Accessible.checked: checked
    Keys.onSpacePressed: toggled()
    Keys.onReturnPressed: toggled()

    Behavior on color {
        enabled: !Theme.transitioning
        ColorAnimation { duration: Motion.hover }
    }

    Rectangle {
        property int size: root.checked ? 24 : 16
        anchors.verticalCenter: parent.verticalCenter
        x: root.checked ? root.width - size - 4 : 8
        width: size
        height: size
        radius: size / 2
        color: root.checked ? Theme.color.contentPrimary : Theme.color.outline

        Behavior on x {
            NumberAnimation {
                duration: Motion.card
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Motion.standard
            }
        }
        Behavior on size {
            NumberAnimation { duration: Motion.card }
        }
    }

    FocusRing {
        shown: root.activeFocus
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}

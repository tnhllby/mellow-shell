import QtQuick
import qs.core

// Thick Quick Settings slider: a tonal track with a primary fill that carries
// the icon. Pointer drag/click or Left/Right/Up/Down keys change the value.
Item {
    id: root

    property real value: 0              // 0..1
    property string icon
    property string label
    property real step: 0.05
    // Shown at the end of the track; the percentage when empty.
    property string valueText
    signal moved(real value)
    // Optional action on the icon (e.g. mute).
    signal iconClicked

    readonly property real shownValue: drag.pressed ? drag.fraction : Math.max(0, Math.min(1, value))

    implicitHeight: 44
    activeFocusOnTab: true
    Accessible.role: Accessible.Slider
    Accessible.name: label

    Keys.onLeftPressed: moved(Math.max(0, value - step))
    Keys.onDownPressed: moved(Math.max(0, value - step))
    Keys.onRightPressed: moved(Math.min(1, value + step))
    Keys.onUpPressed: moved(Math.min(1, value + step))

    Rectangle {
        id: track
        anchors.fill: parent
        radius: Theme.shape.lg
        color: Theme.color.surfaceContainerHighest
        clip: true

        Rectangle {
            // The fill never gets narrower than the icon area.
            width: Math.max(root.height, root.shownValue * track.width)
            height: parent.height
            radius: Theme.shape.lg
            color: Theme.color.primary

            Behavior on width {
                enabled: !drag.pressed
                MotionNumber { duration: Motion.hover }
            }
        }

        MaterialIcon {
            x: (root.height - width) / 2
            anchors.verticalCenter: parent.verticalCenter
            icon: root.icon
            size: Theme.icon.control
            filled: true
            color: Theme.color.contentPrimary

            MouseArea {
                anchors.fill: parent
                anchors.margins: -8
                cursorShape: Qt.PointingHandCursor
                onClicked: root.iconClicked()
            }
        }

        MText {
            id: percent
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacing.x4
            anchors.verticalCenter: parent.verticalCenter
            role: Typography.labelLarge
            tabular: true
            // Readable on whichever part of the track lies under it.
            color: root.shownValue * track.width > x ? Theme.color.contentPrimary : Theme.color.contentSurfaceVariant
            text: root.valueText || Math.round(root.shownValue * 100) + "%"
        }
    }

    FocusRing {
        shown: root.activeFocus
        radius: Theme.shape.lg
    }

    MouseArea {
        id: drag

        property real fraction: 0

        anchors.fill: parent
        anchors.leftMargin: root.height
        cursorShape: Qt.PointingHandCursor
        preventStealing: true

        function update(mouseX) {
            fraction = Math.max(0, Math.min(1, (mouseX + root.height) / root.width));
            root.moved(fraction);
        }

        onPressed: mouse => update(mouse.x)
        onPositionChanged: mouse => update(mouse.x)
    }

    WheelHandler {
        onWheel: event => root.moved(Math.max(0, Math.min(1, root.value + (event.angleDelta.y > 0 ? root.step : -root.step))))
    }
}

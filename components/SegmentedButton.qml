import QtQuick
import qs.core

// Material segmented button. options: [{ value, label }]; Left/Right move the
// selection when focused.
Row {
    id: root

    property var options: []
    property var current
    property string label
    signal selected(var value)

    spacing: 2
    Accessible.name: label

    Repeater {
        model: root.options

        delegate: Rectangle {
            id: segment

            required property var modelData
            required property int index
            readonly property bool checked: modelData.value === root.current
            readonly property bool first: index === 0
            readonly property bool last: index === root.options.length - 1

            width: Math.max(64, text.implicitWidth + 2 * Theme.spacing.x4)
            height: 36
            topLeftRadius: first ? Theme.shape.pill : Theme.shape.xs
            bottomLeftRadius: first ? Theme.shape.pill : Theme.shape.xs
            topRightRadius: last ? Theme.shape.pill : Theme.shape.xs
            bottomRightRadius: last ? Theme.shape.pill : Theme.shape.xs
            color: checked ? Theme.color.secondaryContainer : Theme.color.surfaceContainerHighest

            activeFocusOnTab: true
            Accessible.role: Accessible.RadioButton
            Accessible.name: modelData.label
            Accessible.checked: checked
            Keys.onReturnPressed: root.selected(modelData.value)
            Keys.onSpacePressed: root.selected(modelData.value)
            Keys.onLeftPressed: if (!first) root.selected(root.options[index - 1].value)
            Keys.onRightPressed: if (!last) root.selected(root.options[index + 1].value)

            Behavior on color {
                ColorAnimation { duration: Motion.hover }
            }

            StateLayer {
                color: text.color
                hovered: mouse.containsMouse
                pressed: mouse.pressed
                focused: segment.activeFocus
            }

            FocusRing {
                shown: segment.activeFocus
                radius: Theme.shape.sm
            }

            MText {
                id: text
                anchors.centerIn: parent
                role: Typography.labelLarge
                color: segment.checked ? Theme.color.contentSecondaryContainer : Theme.color.contentSurface
                text: segment.modelData.label
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.selected(segment.modelData.value)
            }
        }
    }
}

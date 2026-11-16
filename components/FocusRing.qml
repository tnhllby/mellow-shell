import QtQuick
import qs.core

// Visible keyboard-focus indicator drawn just outside the parent's shape.
Rectangle {
    property bool shown: false

    anchors.fill: parent
    anchors.margins: -(Theme.focusRing.offset + Theme.focusRing.width)
    radius: (parent.radius ?? 0) + Theme.focusRing.offset + Theme.focusRing.width
    color: "transparent"
    border.width: Theme.focusRing.width
    border.color: Theme.color.primary
    visible: shown
}

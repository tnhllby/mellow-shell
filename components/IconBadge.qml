import QtQuick
import qs.core

// Tonal container behind a state icon (Quick Settings tiles, list rows): the
// glyph on its own tone with a faint highlight from above, so it separates
// from the card it sits on. Fill, colour and weight follow `active`.
Rectangle {
    id: root

    property string icon
    property int iconSize: 22
    property bool active: false
    property color iconColor: Theme.color.contentSurfaceVariant

    implicitWidth: 40
    implicitHeight: 40
    radius: Theme.shape.md
    color: Theme.color.surfaceContainerHigh

    Behavior on color {
        ColorAnimation { duration: Motion.hover }
    }

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        gradient: Gradient {
            GradientStop { position: 0; color: Theme.iconHighlight }
            GradientStop { position: 0.55; color: "transparent" }
        }
    }

    MaterialIcon {
        anchors.centerIn: parent
        icon: root.icon
        size: root.iconSize
        filled: root.active
        color: root.iconColor
    }
}

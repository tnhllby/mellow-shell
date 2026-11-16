import QtQuick
import qs.core

// Material state layer: a translucent overlay in the content colour that
// signals hover, focus and press. Place it inside the control's shape.
Rectangle {
    property bool hovered: false
    property bool pressed: false
    property bool focused: false

    anchors.fill: parent
    radius: parent.radius ?? 0
    color: Theme.color.contentSurface
    opacity: pressed ? Theme.state.pressed : focused ? Theme.state.focus : hovered ? Theme.state.hover : 0

    Behavior on opacity {
        NumberAnimation {
            duration: Motion.hover
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Motion.standard
        }
    }
}

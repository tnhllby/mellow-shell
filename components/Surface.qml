import QtQuick
import qs.core

// A tonal surface. Elevation is expressed through the container role, not
// through heavy shadows.
Rectangle {
    color: Theme.color.surfaceContainerHigh
    radius: Theme.shape.md

    Behavior on color {
        ColorAnimation {
            duration: Motion.theme
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Motion.standard
        }
    }
}

import QtQuick
import qs.core

// Colour animation for state changes, on the standard curve.
ColorAnimation {
    duration: Motion.hover
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Motion.standard
}

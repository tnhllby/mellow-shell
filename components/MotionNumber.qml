import QtQuick
import qs.core

// Number animation for small state changes, on the standard curve.
NumberAnimation {
    duration: Motion.hover
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Motion.standard
}

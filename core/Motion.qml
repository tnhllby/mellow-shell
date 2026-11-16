pragma Singleton
import QtQuick
import Quickshell
import qs.core

// Motion tokens. With reduced motion every duration collapses to 0 so
// transitions apply instantly and never delay input.
Singleton {
    readonly property bool reduced: Config.motion.reduced

    function d(ms) {
        return reduced ? 0 : ms;
    }

    readonly property int hover: d(120)
    readonly property int press: d(100)
    readonly property int card: d(220)
    readonly property int module: d(320)
    readonly property int workspace: d(360)
    readonly property int theme: d(450)

    // Material 3 easing curves, as Easing.BezierSpline control points.
    readonly property var standard: [0.2, 0, 0, 1, 1, 1]
    readonly property var emphasizedDecelerate: [0.05, 0.7, 0.1, 1, 1, 1]
    readonly property var emphasizedAccelerate: [0.3, 0, 0.8, 0.15, 1, 1]
}

import QtQuick
import qs.core

// A Material Symbols Rounded glyph, addressed by ligature name ("tune", "apps").
// Fill and weight ease between states, so a toggled icon inks in instead of
// swapping; with reduced motion they change instantly.
Text {
    id: root

    property string icon
    property bool filled: false
    property int size: 24
    // Filled (active) glyphs are a little heavier, so state is not carried by
    // fill and colour alone.
    property real weight: filled ? 500 : 400
    // Light glyphs on dark surfaces look bolder than dark-on-light; a negative
    // grade evens that out without changing the glyph's width.
    property int grade: Theme.dark ? -25 : 0

    property real fill: filled ? 1 : 0

    Behavior on fill {
        NumberAnimation {
            duration: Motion.hover
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Motion.standard
        }
    }
    Behavior on weight {
        NumberAnimation {
            duration: Motion.hover
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Motion.standard
        }
    }

    text: Typography.iconsAvailable ? icon : ""
    color: Theme.color.contentSurface
    font.family: Typography.iconFamily
    font.pixelSize: size
    font.variableAxes: ({
            "FILL": root.fill,
            "opsz": Math.max(20, Math.min(48, size)),
            "wght": root.weight,
            "GRAD": root.grade
        })
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering
}

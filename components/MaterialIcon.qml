import QtQuick
import qs.core

// A Material Symbols Rounded glyph, addressed by ligature name ("tune", "apps").
Text {
    property string icon
    property bool filled: false
    property int size: 24

    text: Typography.iconsAvailable ? icon : ""
    color: Theme.color.contentSurface
    font.family: Typography.iconFamily
    font.pixelSize: size
    font.variableAxes: ({
            "FILL": filled ? 1 : 0,
            "opsz": Math.max(20, Math.min(48, size)),
            "wght": 400,
            "GRAD": 0
        })
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering
}

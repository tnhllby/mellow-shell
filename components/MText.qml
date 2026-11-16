import QtQuick
import qs.core

// Text bound to a semantic type role.
Text {
    property var role: Typography.bodyMedium
    // Fixed-width digits, for values that change while visible.
    property bool tabular: false

    color: Theme.color.contentSurface
    font.family: Typography.family
    font.pixelSize: role.size
    font.weight: role.weight
    font.letterSpacing: role.tracking
    font.features: tabular ? { "tnum": 1 } : {}
    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
}

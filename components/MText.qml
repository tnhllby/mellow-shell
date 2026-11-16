import QtQuick
import qs.core

// Text bound to a semantic type role.
Text {
    property var role: Typography.bodyMedium

    color: Theme.color.contentSurface
    font.family: Typography.family
    font.pixelSize: role.size
    font.weight: role.weight
    font.letterSpacing: role.tracking
    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
}

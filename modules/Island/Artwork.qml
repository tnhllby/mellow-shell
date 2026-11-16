import QtQuick
import Quickshell.Widgets
import qs.core
import qs.components
import qs.services

// Track artwork, or a tonal placeholder with a music glyph when there is none.
ClippingRectangle {
    id: root

    property int size: 48

    implicitWidth: size
    implicitHeight: size
    color: Theme.color.secondaryContainer

    MaterialIcon {
        anchors.centerIn: parent
        icon: "music_note"
        size: Math.round(root.size * 0.55)
        filled: true
        color: Theme.color.contentSecondaryContainer
        visible: art.status !== Image.Ready
    }

    Image {
        id: art
        anchors.fill: parent
        source: MediaService.artUrl
        sourceSize.width: root.size * 2
        sourceSize.height: root.size * 2
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: status === Image.Ready
    }
}

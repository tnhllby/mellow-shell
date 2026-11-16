import QtQuick
import qs.core
import qs.components
import qs.services

// Compact media state: artwork, title and artist, with a hairline of progress.
Item {
    id: root

    implicitWidth: row.implicitWidth
    implicitHeight: 40

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacing.x2

        Artwork {
            anchors.verticalCenter: parent.verticalCenter
            size: 26
            radius: Theme.shape.xs
        }

        MText {
            id: title
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(implicitWidth, 200)
            role: Typography.labelLarge
            text: MediaService.title
        }

        MText {
            id: artist
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(implicitWidth, 120)
            role: Typography.labelMedium
            color: Theme.color.contentSurfaceVariant
            text: MediaService.artist
            visible: text !== ""
        }
    }

    // Progress hairline along the bottom of the pill.
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 3
        x: 0
        height: 2
        radius: 1
        width: MediaService.length > 0 ? root.width * Math.min(1, MediaService.position / MediaService.length) : 0
        color: Theme.color.primary
        opacity: 0.7
        visible: MediaService.length > 0
    }
}

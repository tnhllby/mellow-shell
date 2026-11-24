import QtQuick
import qs.core
import qs.components
import qs.services
import qs.modules.Island

// Compact media controls for the Control Center (the Island has the full player).
Surface {
    id: root

    implicitHeight: column.implicitHeight + 2 * Theme.spacing.x3
    radius: Theme.shape.lg
    color: Theme.color.surfaceContainerHighest

    Column {
        id: column
        x: Theme.spacing.x3
        y: Theme.spacing.x3
        width: parent.width - 2 * x
        spacing: Theme.spacing.x2

        Item {
            width: parent.width
            height: art.height

            Artwork {
                id: art
                size: 56
                radius: Theme.shape.md
            }

            Column {
                anchors.left: art.right
                anchors.leftMargin: Theme.spacing.x3
                anchors.right: controls.left
                anchors.rightMargin: Theme.spacing.x2
                anchors.verticalCenter: parent.verticalCenter

                MText {
                    width: parent.width
                    role: Typography.titleMedium
                    textFormat: Text.PlainText
                    text: MediaService.title
                }

                MText {
                    width: parent.width
                    role: Typography.bodySmall
                    color: Theme.color.contentSurfaceVariant
                    textFormat: Text.PlainText
                    text: MediaService.artist || MediaService.identity
                    visible: text !== "" && text !== MediaService.title
                }
            }

            Row {
                id: controls
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacing.x1

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "skip_previous"
                    label: "Previous track"
                    enabled: MediaService.activePlayer?.canGoPrevious ?? false
                    onClicked: MediaService.previous()
                }

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: MediaService.playing ? "pause" : "play_arrow"
                    label: MediaService.playing ? "Pause" : "Play"
                    variant: "filled"
                    toggled: true
                    implicitWidth: 48
                    implicitHeight: 44
                    radius: MediaService.playing ? Theme.shape.md : Theme.shape.lg
                    enabled: MediaService.activePlayer?.canTogglePlaying ?? false
                    onClicked: MediaService.togglePlaying()
                }

                IconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "skip_next"
                    label: "Next track"
                    enabled: MediaService.activePlayer?.canGoNext ?? false
                    onClicked: MediaService.next()
                }
            }
        }

        Item {
            width: parent.width
            height: seek.implicitHeight
            visible: MediaService.length > 0

            MText {
                id: elapsed
                anchors.verticalCenter: parent.verticalCenter
                role: Typography.labelSmall
                tabular: true
                color: Theme.color.contentSurfaceVariant
                text: MediaService.formatTime(MediaService.position)
            }

            WavySeekBar {
                id: seek
                anchors.left: elapsed.right
                anchors.right: total.left
                anchors.margins: Theme.spacing.x2
                value: MediaService.length > 0 ? MediaService.position / MediaService.length : 0
                seekable: MediaService.canSeek
                playing: MediaService.playing && ShellState.controlCenterMonitor !== ""
                step: MediaService.length > 0 ? Math.min(0.1, 5 / MediaService.length) : 0.02
                onSeekRequested: fraction => MediaService.seekTo(fraction * MediaService.length)
            }

            MText {
                id: total
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                role: Typography.labelSmall
                tabular: true
                color: Theme.color.contentSurfaceVariant
                text: MediaService.formatTime(MediaService.length)
            }
        }
    }
}

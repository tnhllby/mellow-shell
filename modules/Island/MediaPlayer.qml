import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.core
import qs.components
import qs.services

// Expanded Island: the full media player.
// Keyboard: Tab moves between controls; Space/K play-pause; Left/Right seek
// 5 s (or step the focused seek bar); N/P next/previous; Escape closes.
FocusScope {
    id: root

    signal closeRequested

    function focusDefault() {
        playButton.forceActiveFocus();
    }

    function formatTime(seconds) {
        const s = Math.max(0, Math.floor(seconds));
        const h = Math.floor(s / 3600);
        const m = Math.floor(s % 3600 / 60);
        const ss = String(s % 60).padStart(2, "0");
        return h > 0 ? `${h}:${String(m).padStart(2, "0")}:${ss}` : `${m}:${ss}`;
    }

    readonly property var sourceEntry: MediaService.desktopEntry ? DesktopEntries.heuristicLookup(MediaService.desktopEntry) : null

    implicitHeight: column.implicitHeight + 2 * Theme.spacing.x5

    Keys.onEscapePressed: closeRequested()
    Keys.onPressed: event => {
        switch (event.key) {
        case Qt.Key_Space:
        case Qt.Key_K:
            MediaService.togglePlaying();
            break;
        case Qt.Key_Left:
            MediaService.seekBy(-5);
            break;
        case Qt.Key_Right:
            MediaService.seekBy(5);
            break;
        case Qt.Key_N:
            MediaService.next();
            break;
        case Qt.Key_P:
            MediaService.previous();
            break;
        default:
            return;
        }
        event.accepted = true;
    }

    Column {
        id: column
        anchors.fill: parent
        anchors.margins: Theme.spacing.x5
        spacing: Theme.spacing.x4

        // Source: player and audio output.
        Row {
            spacing: Theme.spacing.x2

            IconImage {
                anchors.verticalCenter: parent.verticalCenter
                implicitSize: 16
                source: Icons.optional(root.sourceEntry?.icon || MediaService.desktopEntry)
                visible: source != ""
            }

            MText {
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(implicitWidth, column.width - 24)
                role: Typography.labelMedium
                color: Theme.color.contentSurfaceVariant
                text: [MediaService.identity, MediaService.outputName].filter(s => s).join("  ·  ")
            }
        }

        Row {
            width: parent.width
            spacing: Theme.spacing.x4

            Artwork {
                size: 96
                radius: Theme.shape.lg
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 96 - parent.spacing
                spacing: Theme.spacing.x1

                MText {
                    width: parent.width
                    role: Typography.titleLarge
                    text: MediaService.title
                }

                MText {
                    width: parent.width
                    role: Typography.bodyMedium
                    color: Theme.color.contentSurfaceVariant
                    text: MediaService.artist
                    visible: text !== ""
                }

                MText {
                    width: parent.width
                    role: Typography.bodySmall
                    color: Theme.color.contentSurfaceVariant
                    text: MediaService.album
                    visible: text !== "" && text !== MediaService.title
                }
            }
        }

        Column {
            width: parent.width
            spacing: 0
            visible: MediaService.length > 0

            WavySeekBar {
                width: parent.width
                value: MediaService.length > 0 ? MediaService.position / MediaService.length : 0
                seekable: MediaService.canSeek
                playing: MediaService.playing
                step: MediaService.length > 0 ? Math.min(0.1, 5 / MediaService.length) : 0.02
                onSeekRequested: fraction => MediaService.seekTo(fraction * MediaService.length)
            }

            Item {
                width: parent.width
                height: elapsed.implicitHeight

                MText {
                    id: elapsed
                    role: Typography.labelSmall
                    tabular: true
                    color: Theme.color.contentSurfaceVariant
                    text: root.formatTime(MediaService.position)
                }

                MText {
                    anchors.right: parent.right
                    role: Typography.labelSmall
                    tabular: true
                    color: Theme.color.contentSurfaceVariant
                    text: root.formatTime(MediaService.length)
                }
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacing.x4

            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: "skip_previous"
                label: "Previous track"
                iconSize: 28
                implicitWidth: 48
                implicitHeight: 48
                enabled: MediaService.activePlayer?.canGoPrevious ?? false
                onClicked: MediaService.previous()
            }

            IconButton {
                id: playButton
                anchors.verticalCenter: parent.verticalCenter
                icon: MediaService.playing ? "pause" : "play_arrow"
                label: MediaService.playing ? "Pause" : "Play"
                variant: "filled"
                toggled: true
                iconSize: 32
                implicitWidth: 72
                implicitHeight: 56
                // Expressive shape morph: rounder while paused, squarer while playing.
                radius: MediaService.playing ? Theme.shape.md : Theme.shape.organic
                enabled: MediaService.activePlayer?.canTogglePlaying ?? false
                onClicked: MediaService.togglePlaying()
            }

            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: "skip_next"
                label: "Next track"
                iconSize: 28
                implicitWidth: 48
                implicitHeight: 48
                enabled: MediaService.activePlayer?.canGoNext ?? false
                onClicked: MediaService.next()
            }
        }
    }
}

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.core
import qs.components
import qs.services

// MELLOW Island: one surface centred in the panel that morphs between the
// compact pill (media or ambient) and the expanded media player.
// It lives in its own top-layer window that is tall enough for the expanded
// player; the input region is exactly the Island, everything else is
// click-through.
PanelWindow {
    id: root

    readonly property bool expanded: ShellState.islandMonitor === screen?.name && MediaService.activePlayer !== null
    readonly property bool media: MediaService.mediaMode
    readonly property real compactMaxWidth: Math.min(Config.island.compactMaxWidth, (screen?.width ?? 1000) * 0.34)
    readonly property real expandedWidth: Math.min(Config.island.expandedWidth, (screen?.width ?? 1000) - 2 * Theme.spacing.x4)

    function close() {
        if (ShellState.islandMonitor === screen?.name)
            ShellState.islandMonitor = "";
    }

    anchors.top: true
    implicitWidth: expandedWidth
    implicitHeight: Config.panel.height + player.implicitHeight + Theme.spacing.x4
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    mask: Region {
        item: island
    }
    // The compact Island sits on the opaque bar; only the expanded player
    // floats over windows and uses the blur.
    BackgroundEffect.blurRegion: Region {
        item: Theme.effects.blurOn && root.expanded ? island : null
        radius: island.radius
        topLeftRadius: island.topLeftRadius
        bottomRightRadius: island.bottomRightRadius
    }

    WlrLayershell.namespace: "mellow:island"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: expanded ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    HyprlandFocusGrab {
        active: root.expanded
        windows: [root]
        onCleared: root.close()
    }

    onExpandedChanged: if (expanded) Qt.callLater(() => ShellState.islandFromKeyboard ? player.focusDefault() : player.forceActiveFocus())

    Surface {
        id: island

        readonly property real compactWidth: Math.min(root.compactMaxWidth, (root.media ? mediaCompact.implicitWidth : ambientCompact.implicitWidth) + 2 * Theme.spacing.x4)

        anchors.horizontalCenter: parent.horizontalCenter
        y: (Config.panel.height - 40) / 2
        width: root.expanded ? root.expandedWidth : compactWidth
        height: root.expanded ? player.implicitHeight : 40
        color: root.expanded ? Theme.glass(Theme.color.surfaceContainerHigh) : Theme.color.surfaceContainerHighest
        // Asymmetric organic corners give the Island its silhouette in both states.
        radius: Theme.shape.xl
        topLeftRadius: Theme.shape.organic
        bottomRightRadius: Theme.shape.organic
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: Motion.module
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Motion.emphasizedDecelerate
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: Motion.module
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Motion.emphasizedDecelerate
            }
        }

        // Compact states. Clicking expands the player whenever a player exists.
        MouseArea {
            anchors.fill: parent
            enabled: !root.expanded && MediaService.activePlayer !== null
            cursorShape: Qt.PointingHandCursor
            onClicked: ShellState.toggleIsland(root.screen.name, false)
        }

        MediaCompact {
            id: mediaCompact
            anchors.centerIn: parent
            opacity: root.media && !root.expanded ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation { duration: Motion.card }
            }
        }

        AmbientCompact {
            id: ambientCompact
            anchors.centerIn: parent
            opacity: !root.media && !root.expanded ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation { duration: Motion.card }
            }
        }

        MediaPlayer {
            id: player
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.expandedWidth
            opacity: root.expanded ? 1 : 0
            visible: opacity > 0
            onCloseRequested: root.close()

            Behavior on opacity {
                NumberAnimation { duration: Motion.card }
            }
        }
    }
}

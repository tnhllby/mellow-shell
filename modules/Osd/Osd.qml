import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.core
import qs.components
import qs.services

// Pill at the bottom of the focused monitor after a volume, microphone or
// brightness change. Click-through and always mapped.
PanelWindow {
    id: root

    readonly property bool open: OsdService.shown && OsdService.monitor === screen?.name
    readonly property string kind: OsdService.kind
    readonly property bool muted: kind === "volume" ? AudioService.muted : AudioService.micMuted
    readonly property real value: kind === "brightness" ? BrightnessService.value(OsdService.display)
        : kind === "volume" && !muted ? AudioService.volume : 0

    anchors {
        bottom: true
        left: true
        right: true
    }
    implicitHeight: 120
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    mask: Region {}
    BackgroundEffect.blurRegion: CardBlurRegion {
        card: card
        active: Theme.effects.blurOn && root.open && card.opacity === 1
    }

    WlrLayershell.namespace: "mellow:osd"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        y: 32
        width: root.kind === "microphone" ? status.implicitWidth + 84 : 280
        height: 52
        radius: Theme.shape.pill
        color: Theme.glass(Theme.color.surfaceContainerHigh)
        border.width: Theme.cardEdgeWidth
        border.color: Theme.cardEdge(Theme.color.surfaceContainerHigh)
        opacity: root.open ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            MotionNumber {}
        }

        MaterialIcon {
            x: Theme.spacing.x5
            anchors.verticalCenter: parent.verticalCenter
            icon: root.kind === "brightness" ? "brightness_6" : root.kind === "microphone" ? (root.muted ? "mic_off" : "mic")
                : root.muted ? "volume_off" : root.value < 0.4 ? "volume_down" : "volume_up"
            size: Theme.icon.control
            filled: true
            color: Theme.color.primary
        }

        MText {
            id: status
            x: 56
            anchors.verticalCenter: parent.verticalCenter
            role: Typography.labelLarge
            text: root.muted ? "Microphone muted" : "Microphone on"
            visible: root.kind === "microphone"
        }

        Rectangle {
            id: track
            x: 56
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - x - 64
            height: 8
            radius: 4
            color: Theme.color.secondaryContainer
            visible: root.kind !== "microphone"

            Rectangle {
                width: track.width * Math.max(0, Math.min(1, root.value))
                height: parent.height
                radius: parent.radius
                color: Theme.color.primary

                Behavior on width {
                    MotionNumber { duration: Motion.press }
                }
            }
        }

        MText {
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacing.x5
            anchors.verticalCenter: parent.verticalCenter
            role: Typography.labelLarge
            tabular: true
            text: Math.round(root.value * 100) + "%"
            visible: root.kind !== "microphone"
        }
    }
}

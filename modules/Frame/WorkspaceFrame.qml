import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.core
import qs.integrations.hyprland

// Draws the persistent workspace frame: chrome along the left, right and bottom
// edges with rounded inner corners, continuing the panel's surface.
// Purely visual: an empty input mask lets every click pass through, and it never
// takes keyboard focus. The space it covers is reserved by FrameReservation.
PanelWindow {
    id: root

    readonly property var monitor: HyprlandService.monitorFor(screen)
    readonly property bool fullscreen: monitor?.activeWorkspace?.hasFullscreen ?? false
    readonly property int thickness: Config.frame.thickness
    readonly property int innerRadius: Theme.shape.lg
    // Border width used to paint the frame; large enough to cover any edge.
    readonly property int paint: Math.max(width, height)

    visible: Config.frame.enabled && !(fullscreen && Config.frame.fullscreenPolicy === "hide")

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    margins.top: Config.panel.height
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    mask: Region {}

    WlrLayershell.namespace: "mellow:frame"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Item {
        anchors.fill: parent
        clip: true

        // A rectangle whose inner border edge is the rounded workspace outline;
        // the oversized border fills everything outside it with chrome.
        Rectangle {
            x: root.thickness - root.paint
            y: -root.paint
            width: parent.width - 2 * root.thickness + 2 * root.paint
            height: parent.height - root.thickness + 2 * root.paint
            radius: root.innerRadius + root.paint
            color: "transparent"
            border.width: root.paint
            border.color: Theme.chrome
        }

        // The focused monitor gets a subtle tonal outline on the workspace edge.
        Rectangle {
            x: root.thickness
            y: -root.innerRadius
            width: parent.width - 2 * root.thickness
            height: parent.height - root.thickness + root.innerRadius
            radius: root.innerRadius
            color: "transparent"
            border.width: 1
            border.color: Theme.color.primary
            opacity: root.monitor?.focused ? 0.35 : 0

            Behavior on opacity {
                NumberAnimation { duration: Motion.module }
            }
        }
    }
}

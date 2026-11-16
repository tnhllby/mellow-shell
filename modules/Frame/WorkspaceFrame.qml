import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import qs.core
import qs.integrations.hyprland

// Draws the persistent workspace frame below the panel: a ring of chrome with
// rounded outer screen corners and rounded inner fillets around the workspace,
// continuing the panel's surface.
// Purely visual: an empty input mask lets every click pass through, and it never
// takes keyboard focus. The space it covers is reserved by FrameReservation.
PanelWindow {
    id: root

    readonly property var monitor: HyprlandService.monitorFor(screen)
    readonly property bool fullscreen: monitor?.activeWorkspace?.hasFullscreen ?? false
    readonly property int thickness: Config.frame.thickness
    readonly property int innerRadius: Theme.chromeShape.innerRadius
    readonly property int outerRadius: Theme.chromeShape.outerRadius

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

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        // Outer outline minus the workspace outline (odd-even fill) = the frame ring.
        // The outer rectangle starts above the window so only its bottom corners show.
        ShapePath {
            fillColor: Theme.chrome
            fillRule: ShapePath.OddEvenFill
            strokeWidth: -1

            PathRectangle {
                x: 0
                y: -root.outerRadius
                width: root.width
                height: root.height + root.outerRadius
                bottomLeftRadius: root.outerRadius
                bottomRightRadius: root.outerRadius
            }
            PathRectangle {
                x: root.thickness
                y: 0
                width: root.width - 2 * root.thickness
                height: root.height - root.thickness
                radius: root.innerRadius
            }
        }

        // The focused monitor gets a subtle tonal outline on the workspace edge.
        ShapePath {
            fillColor: "transparent"
            strokeColor: Qt.alpha(Theme.color.primary, root.monitor?.focused ? 0.35 : 0)
            strokeWidth: 1

            PathRectangle {
                x: root.thickness
                y: 0
                width: root.width - 2 * root.thickness
                height: root.height - root.thickness
                radius: root.innerRadius
                strokeAdjustment: 1
            }
        }
    }
}

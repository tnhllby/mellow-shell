import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import qs.core
import qs.components
import qs.integrations.hyprland

// Draws the persistent workspace frame below the panel: chrome along the sides
// and bottom with rounded outer screen corners and rounded inner bottom corners.
// The inner top fillets are drawn by the panel so they always meet its edge.
// Purely visual: an empty input mask lets every click pass through, and it never
// takes keyboard focus. The space it covers is reserved by FrameReservation.
PanelWindow {
    id: root

    readonly property var monitor: HyprlandService.monitorFor(screen)
    readonly property bool fullscreen: HyprlandService.hasRealFullscreen(monitor?.activeWorkspace)
    readonly property int thickness: Config.frame.thickness
    // Concentric with the outer corners, so the line keeps its thickness round the curve.
    readonly property int innerRadius: Math.max(0, outerRadius - thickness)
    readonly property int outerRadius: Theme.chromeShape.outerRadius

    visible: Config.frame.enabled && !(fullscreen && Config.frame.fullscreenPolicy === "hide")

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    // Starts below the panel's fillets (which cover the sides there), so a panel
    // pushed down by another surface overlaps the frame instead of leaving a gap.
    margins.top: Config.panel.height + Theme.chromeShape.innerRadius
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
                topLeftRadius: 0
                topRightRadius: 0
            }
        }
    }

    ScreenCorner {
        y: root.height - height
        corner: "bottomLeft"
    }

    ScreenCorner {
        x: root.width - width
        y: root.height - height
        corner: "bottomRight"
    }
}

import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import qs.core
import qs.components
import qs.integrations.hyprland

// Full-width top panel: workspaces and active window (left), clock and system
// controls (right). The centre belongs to the Island, a separate surface.
// It never takes keyboard focus; it only receives pointer input inside its own
// rectangle, which Hyprland keeps clear of windows via the exclusive zone.
PanelWindow {
    id: root

    readonly property var monitor: HyprlandService.monitorFor(screen)
    readonly property bool controlCenterOpen: ShellState.controlCenterMonitor === screen?.name
    readonly property bool frameShown: Config.frame.enabled
        && !(HyprlandService.hasRealFullscreen(monitor?.activeWorkspace) && Config.frame.fullscreenPolicy === "hide")
    readonly property int frameThickness: Config.frame.thickness
    readonly property int fillet: Theme.chromeShape.innerRadius

    anchors {
        top: true
        left: true
        right: true
    }
    // The surface extends below the bar by the frame's inner radius so the
    // fillets joining bar and frame are drawn here, always aligned with the bar
    // (even when another surface pushes the bar down). Input is the bar only.
    implicitHeight: Config.panel.height + fillet
    exclusiveZone: Config.panel.height
    color: "transparent"
    mask: Region {
        item: bar
    }

    WlrLayershell.namespace: "mellow:panel"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Rounded top corners match the frame's bottom corners: one continuous chrome.
    Rectangle {
        id: bar
        width: parent.width
        height: Config.panel.height
        color: Theme.chrome
        topLeftRadius: Theme.chromeShape.outerRadius
        topRightRadius: Theme.chromeShape.outerRadius
    }

    ScreenCorner {
        corner: "topLeft"
        visible: root.frameShown
    }

    ScreenCorner {
        x: root.width - width
        corner: "topRight"
        visible: root.frameShown
    }

    // Inner fillets: concave corners from the bar down into the frame sides.
    Shape {
        y: Config.panel.height
        width: parent.width
        height: root.fillet
        visible: root.frameShown
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: Theme.chrome
            strokeWidth: -1
            startX: 0
            startY: 0
            PathLine { x: root.frameThickness + root.fillet; y: 0 }
            PathArc {
                x: root.frameThickness
                y: root.fillet
                radiusX: root.fillet
                radiusY: root.fillet
                direction: PathArc.Counterclockwise
            }
            PathLine { x: 0; y: root.fillet }
        }

        ShapePath {
            fillColor: Theme.chrome
            strokeWidth: -1
            startX: root.width
            startY: 0
            PathLine { x: root.width - root.frameThickness - root.fillet; y: 0 }
            PathArc {
                x: root.width - root.frameThickness
                y: root.fillet
                radiusX: root.fillet
                radiusY: root.fillet
                direction: PathArc.Clockwise
            }
            PathLine { x: root.width; y: root.fillet }
        }
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacing.x3
        anchors.verticalCenter: bar.verticalCenter
        spacing: Theme.spacing.x4

        WorkspaceStrip {
            id: workspaces
            anchors.verticalCenter: parent.verticalCenter
            monitor: root.monitor
        }

        ActiveWindow {
            anchors.verticalCenter: parent.verticalCenter
            monitor: root.monitor
            // Space left of the (widest compact) Island that the workspace strip does not use.
            maximumWidth: Math.max(0, root.width / 2 - Math.min(Config.island.compactMaxWidth, root.width * 0.34) / 2
                - workspaces.width - 3 * Theme.spacing.x4)
            visible: Config.panel.showActiveWindow && maximumWidth > 60 && window !== null
                && window.monitor === monitor && window.title !== ""
        }
    }

    StatusArea {
        id: status
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacing.x3
        anchors.verticalCenter: bar.verticalCenter
        controlCenterOpen: root.controlCenterOpen
        onControlCenterToggled: ShellState.toggleControlCenter(root.screen.name)
    }
}

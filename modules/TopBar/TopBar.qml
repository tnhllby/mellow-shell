import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import qs.core
import qs.components
import qs.integrations.hyprland
import qs.services
import qs.modules.Island

// Full-width top panel: workspaces with their apps' icons (left), clock and
// system controls (right). The centre belongs to the Island, a separate surface.
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
    IdleInhibitor {
        window: root
        enabled: KeepAwakeService.active
    }

    // Left edge of the widest compact Island (see Island.qml).
    readonly property real islandLeft: (width - Math.min(Config.island.compactMaxWidth, width * 0.34)) / 2
    // For the tooltip.
    readonly property string hoveredLabel: launcherButton.hovered ? launcherButton.label : overviewButton.hovered ? overviewButton.label
        : tray.hoveredLabel || status.hoveredLabel
    readonly property real hoveredLabelCenter: launcherButton.hovered ? leftZone.x + launcherButton.x + launcherButton.width / 2
        : overviewButton.hovered ? leftZone.x + overviewButton.x + overviewButton.width / 2
        : tray.hoveredLabel ? tray.hoveredCenter : status.x + status.width - 48
    // For the workspace preview.
    readonly property alias hoveredWorkspace: strip.hoveredWorkspace
    readonly property alias hoveredCenter: strip.hoveredCenter

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

    // Blur behind the chrome: the bar with its rounded outer corners, plus the
    // concave fillets (a square minus the rounded workspace corner).
    readonly property Region blurShape: Region {
        width: root.width
        height: Config.panel.height
        topLeftRadius: Theme.chromeShape.outerRadius
        topRightRadius: Theme.chromeShape.outerRadius

        Region {
            y: Config.panel.height
            width: root.frameShown ? root.frameThickness + root.fillet : 0
            height: root.fillet

            Region {
                intersection: Intersection.Subtract
                x: root.frameThickness
                y: Config.panel.height
                width: 2 * root.fillet
                height: 2 * root.fillet
                topLeftRadius: root.fillet
            }
        }

        Region {
            x: root.width - width
            y: Config.panel.height
            width: root.frameShown ? root.frameThickness + root.fillet : 0
            height: root.fillet

            Region {
                intersection: Intersection.Subtract
                x: root.width - root.frameThickness - 2 * root.fillet
                y: Config.panel.height
                width: 2 * root.fillet
                height: 2 * root.fillet
                topRightRadius: root.fillet
            }
        }
    }
    BackgroundEffect.blurRegion: Theme.effects.blurOn ? blurShape : null

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
        id: leftZone
        x: Theme.spacing.x3
        anchors.verticalCenter: bar.verticalCenter
        spacing: Theme.spacing.x2

        BarButton {
            id: launcherButton
            icon: "apps"
            label: "Apps"
            toggled: ShellState.launcherMonitor === root.screen?.name
            onClicked: ShellState.toggleLauncher(root.screen.name)
        }

        WorkspaceStrip {
            id: strip
            monitor: root.monitor
        }

        BarButton {
            id: overviewButton
            icon: "grid_view"
            label: "Overview"
            toggled: ShellState.overviewMonitor === root.screen?.name
            onClicked: ShellState.toggleOverview(root.screen.name)
        }

        // The Island shows these itself while no media plays.
        Surface {
            id: stats
            width: metrics.implicitWidth + 2 * Theme.spacing.x4
            height: Theme.barPill.height
            radius: Theme.shape.pill
            color: Theme.glass(Theme.color.surfaceContainerHigh)
            visible: MediaService.mediaMode && SystemStatsService.cpu !== null && leftZone.x + x + width + Theme.spacing.x3 < root.islandLeft

            AmbientCompact {
                id: metrics
                anchors.centerIn: parent
                showNote: false
            }
        }
    }

    Tray {
        id: tray
        anchors.right: status.left
        anchors.rightMargin: Theme.spacing.x2
        anchors.verticalCenter: bar.verticalCenter
        window: root
        // Only as many as fit between the Island and the status pill.
        maxItems: Math.max(0, Math.min(6, Math.floor((status.x - (root.width - root.islandLeft) - 4 * Theme.spacing.x3) / Theme.barPill.inner)))
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

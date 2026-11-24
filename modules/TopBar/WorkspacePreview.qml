import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.core
import qs.components
import qs.services
import qs.integrations.hyprland

// Preview of a workspace below the bar, shown while the pointer rests on that
// workspace's number: its windows at their positions, as still captures taken
// each time the preview opens. It never takes input, so the pointer stays on
// the bar and moving along the strip switches the preview without flicker.
// Like the other cards it is an always-mapped layer surface.
PanelWindow {
    id: root

    required property var panel

    readonly property var monitor: HyprlandService.monitorFor(screen)
    // The hovered workspace, when it is not the one on screen and has windows.
    readonly property var target: {
        const ws = panel.hoveredWorkspace;
        return Config.panel.workspacePreview && ws && ws !== monitor?.activeWorkspace
            && HyprlandService.windowsOn(ws).length > 0 ? ws : null;
    }
    // What the card shows: follows the target while open, kept while fading out.
    property var workspace: null
    property bool open: false

    readonly property real aspect: (screen?.width ?? 16) / Math.max(1, screen?.height ?? 9)
    readonly property real cardWidth: Config.panel.workspacePreviewWidth
    readonly property real miniWidth: cardWidth - 2 * Theme.spacing.x2
    readonly property real miniHeight: miniWidth / aspect

    onTargetChanged: {
        if (!target) {
            delay.stop();
            open = false;
        } else if (open) {
            workspace = target;
        } else {
            delay.restart();
        }
    }

    Timer {
        id: delay
        interval: Config.panel.workspacePreviewDelay
        onTriggered: {
            HyprlandService.refreshWindows();
            root.workspace = root.target;
            root.open = true;
        }
    }

    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: Config.panel.height + Theme.spacing.x2 + card.height + Theme.spacing.x2
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    mask: Region {}
    // Only once fully open (the region ignores scale and opacity).
    BackgroundEffect.blurRegion: CardBlurRegion {
        card: card
        active: Theme.effects.blurOn && root.open && card.opacity === 1 && card.scale === 1
    }

    WlrLayershell.namespace: "mellow:workspace-preview"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Surface {
        id: card

        // Centred under the hovered number, kept inside the frame.
        x: Math.max(Config.frame.thickness + Theme.spacing.x2,
            Math.min(root.width - width - Config.frame.thickness - Theme.spacing.x2, root.panel.hoveredCenter - width / 2))
        y: Config.panel.height + Theme.spacing.x2
        width: root.cardWidth
        height: column.implicitHeight + 2 * Theme.spacing.x2
        radius: Theme.shape.lg
        topLeftRadius: Theme.shape.md
        color: Theme.glass(Theme.color.surfaceContainer)
        border.width: Theme.cardEdgeWidth
        border.color: Theme.cardEdge(color)

        visible: opacity > 0
        opacity: root.open ? 1 : 0
        scale: root.open ? 1 : 0.96
        transformOrigin: Item.Top
        // Captures are taken by new delegates: drop them once hidden, so the
        // next opening captures again.
        onVisibleChanged: if (!visible) root.workspace = null

        Behavior on opacity {
            MotionNumber { duration: Motion.card }
        }
        Behavior on scale {
            NumberAnimation {
                duration: Motion.card
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Motion.emphasizedDecelerate
            }
        }
        Behavior on x {
            enabled: root.open
            NumberAnimation {
                duration: Motion.card
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Motion.standard
            }
        }

        Column {
            id: column
            x: Theme.spacing.x2
            y: Theme.spacing.x2
            spacing: Theme.spacing.x2

            // The monitor in miniature, windows at their real positions.
            ClippingRectangle {
                id: mini

                readonly property real k: width / Math.max(1, root.screen?.width ?? 1)

                width: root.miniWidth
                height: root.miniHeight
                radius: Theme.shape.md
                color: Theme.color.surfaceContainerLow

                Repeater {
                    model: root.workspace ? HyprlandService.windowsOn(root.workspace) : []

                    delegate: ClippingRectangle {
                        id: win

                        required property var modelData
                        readonly property var ipc: modelData.lastIpcObject ?? ({})

                        x: Math.max(0, Math.min(mini.width - width, ((ipc.at?.[0] ?? 0) - (root.monitor?.x ?? 0)) * mini.k))
                        y: Math.max(0, Math.min(mini.height - height, ((ipc.at?.[1] ?? 0) - (root.monitor?.y ?? 0)) * mini.k))
                        width: Math.max(20, Math.min(mini.width, (ipc.size?.[0] ?? 400) * mini.k))
                        height: Math.max(20, Math.min(mini.height, (ipc.size?.[1] ?? 300) * mini.k))
                        z: ipc.floating ? 1 : 0
                        radius: Theme.shape.xs
                        color: Theme.color.surfaceContainerHigh

                        ScreencopyView {
                            id: capture
                            anchors.fill: parent
                            captureSource: win.modelData.wayland
                            live: false
                            constraintSize: Qt.size(Math.ceil(win.width * 1.5), Math.ceil(win.height * 1.5))
                        }

                        // Shown until (or instead of) the capture.
                        IconImage {
                            anchors.centerIn: parent
                            implicitSize: Math.min(32, win.width * 0.5, win.height * 0.5)
                            source: Icons.app(AppService.entryForWindow(win.modelData)?.icon || HyprlandService.appIdOf(win.modelData))
                            visible: !capture.hasContent
                        }
                    }
                }
            }

            // Workspace number and its main window's title.
            Row {
                id: caption

                readonly property var main: HyprlandService.mainWindowOn(root.workspace)

                width: root.miniWidth
                spacing: Theme.spacing.x2

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.max(height, number.implicitWidth + 2 * Theme.spacing.x2)
                    height: 24
                    radius: height / 2
                    color: Theme.color.secondaryContainer

                    MText {
                        id: number
                        anchors.centerIn: parent
                        role: Typography.labelLarge
                        color: Theme.color.contentSecondaryContainer
                        text: root.workspace?.name ?? ""
                    }
                }

                IconImage {
                    anchors.verticalCenter: parent.verticalCenter
                    implicitSize: 18
                    visible: caption.main !== null
                    source: caption.main ? Icons.app(AppService.entryForWindow(caption.main)?.icon || HyprlandService.appIdOf(caption.main)) : ""
                }

                MText {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - x
                    role: Typography.labelLarge
                    color: Theme.color.contentSurface
                    text: caption.main?.title ?? ""
                }
            }
        }
    }
}

import QtQuick
import Quickshell.Wayland
import Quickshell.Widgets
import qs.core
import qs.components
import qs.services
import qs.integrations.hyprland

// A window inside a workspace card: a still capture of the window (taken when
// the Overview opens) with its icon and, when large enough, its title.
Item {
    id: root

    required property var window
    required property var overview
    required property var workspaceCard

    readonly property var ipc: window.lastIpcObject ?? ({})
    readonly property real k: workspaceCard.scaleFactor
    readonly property var origin: [overview.monitor?.x ?? 0, overview.monitor?.y ?? 0]
    readonly property bool selected: overview.selected === window
    readonly property bool focusedWindow: window === HyprlandService.activeWindow
    readonly property bool dragActive: mouse.drag.active
    readonly property bool hovered: mouse.containsMouse || closeMouse.containsMouse

    // Home position, from the window's geometry; clamped into the card.
    readonly property real homeX: Math.max(0, Math.min(workspaceCard.width - width, ((ipc.at?.[0] ?? 0) - origin[0]) * k))
    readonly property real homeY: Math.max(0, Math.min(workspaceCard.height - height, ((ipc.at?.[1] ?? 0) - origin[1]) * k))

    x: homeX
    y: homeY
    width: Math.max(28, Math.min(workspaceCard.width, (ipc.size?.[0] ?? 400) * k))
    height: Math.max(28, Math.min(workspaceCard.height, (ipc.size?.[1] ?? 300) * k))
    z: dragActive ? 2 : ipc.floating ? 1 : 0
    scale: dragActive ? 1.05 : 1

    Drag.active: dragActive
    Drag.keys: ["mellow-window"]
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2
    Drag.source: root

    Behavior on scale {
        NumberAnimation { duration: Motion.hover }
    }

    ClippingRectangle {
        id: frame
        anchors.fill: parent
        radius: Theme.shape.sm
        color: Theme.color.surfaceContainerHigh
        border.width: root.selected || root.focusedWindow ? 2 : 0
        border.color: root.selected ? Theme.color.primary : Theme.color.outline

        ScreencopyView {
            id: preview
            anchors.fill: parent
            captureSource: root.window.wayland
            live: false
            // Card-sized captures: cheaper than full-size window buffers.
            constraintSize: Qt.size(Math.ceil(root.width * 1.5), Math.ceil(root.height * 1.5))

            Connections {
                target: root.overview
                // New previews capture on their own; only refresh existing ones.
                function onCaptureGenerationChanged() {
                    if (preview.hasContent)
                        preview.captureFrame();
                }
            }
        }

        // Shown until (or instead of) the capture.
        IconImage {
            anchors.centerIn: parent
            implicitSize: Math.min(48, root.width * 0.5, root.height * 0.5)
            source: Icons.app(AppService.entryForWindow(root.window)?.icon || HyprlandService.appIdOf(root.window))
            visible: !preview.hasContent
        }

        // Title strip for larger cards.
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 26
            color: Qt.alpha(Theme.color.surfaceContainerHighest, 0.9)
            visible: root.height >= 70 && root.width >= 90

            Row {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacing.x2
                anchors.rightMargin: Theme.spacing.x2
                spacing: Theme.spacing.x1

                IconImage {
                    anchors.verticalCenter: parent.verticalCenter
                    implicitSize: 16
                    source: Icons.app(AppService.entryForWindow(root.window)?.icon || HyprlandService.appIdOf(root.window))
                }

                MText {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 16 - parent.spacing
                    role: Typography.labelSmall
                    text: root.window.title
                }
            }
        }
    }

    FocusRing {
        shown: root.selected && root.overview.activeFocus
        radius: Theme.shape.sm
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.PointingHandCursor
        drag.target: root
        drag.threshold: 8

        onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton)
                HyprlandService.closeWindow(root.window);
            else
                root.overview.focusWindow(root.window);
        }
        onReleased: {
            if (!drag.active && root.Drag.target === null)
                return;
            const target = root.Drag.target?.parent;
            if (root.Drag.target && target && target.workspaceId !== root.workspaceCard.workspaceId)
                HyprlandService.moveWindowToWorkspace(root.window, target.workspaceId);
            // Back home; the layout follows Hyprland once the move lands.
            root.x = Qt.binding(() => root.homeX);
            root.y = Qt.binding(() => root.homeY);
        }
    }

    // Close button: on hover and on the keyboard selection (Delete also closes).
    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: Theme.spacing.x1
        width: 24
        height: 24
        radius: 12
        color: closeMouse.containsMouse ? Theme.color.error : Theme.color.surfaceContainerHighest
        visible: (root.hovered || root.selected) && !root.dragActive && root.width >= 56

        MaterialIcon {
            anchors.centerIn: parent
            icon: "close"
            size: 16
            color: closeMouse.containsMouse ? Theme.color.contentError : Theme.color.contentSurface
        }

        MouseArea {
            id: closeMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: HyprlandService.closeWindow(root.window)
        }
    }
}

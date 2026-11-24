import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.core
import qs.components
import qs.services
import qs.integrations.hyprland

// Workspaces of this panel's monitor. Inactive workspaces show their number;
// the focused one stretches into a pill showing its main app's icon (the last
// focused window there), or its number when empty. Scrolling over the strip
// steps through the list. The hovered workspace is exposed for the preview.
Surface {
    id: root

    required property var monitor
    readonly property var model: HyprlandService.workspacesOn(monitor)
    // Workspace under the pointer (null when none), and the horizontal centre
    // of its pill in window coordinates.
    property var hoveredWorkspace: null
    property real hoveredCenter: 0

    implicitWidth: row.implicitWidth + 2 * Theme.spacing.x1
    implicitHeight: Theme.barPill.height
    radius: Theme.shape.pill
    color: Theme.glass(Theme.color.surfaceContainerHigh)
    visible: model.length > 0

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => HyprlandService.cycle(root.model, root.monitor?.activeWorkspace, event.angleDelta.y > 0 ? -1 : 1)
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.spacing.x1

        Repeater {
            model: root.model

            delegate: Rectangle {
                id: pill

                required property var modelData
                readonly property bool current: modelData === root.monitor?.activeWorkspace
                readonly property bool focusedMonitor: root.monitor?.focused ?? false
                readonly property var window: HyprlandService.mainWindowOn(modelData)
                readonly property string iconName: window
                    ? (AppService.entryForWindow(window)?.icon || HyprlandService.appIdOf(window)) : ""
                readonly property bool showIcon: current && iconName !== ""

                width: Math.max(height, content.implicitWidth + 2 * (current ? Theme.spacing.x3 : Theme.spacing.x2))
                height: Theme.barPill.inner
                radius: Theme.shape.pill
                color: modelData.urgent ? Theme.glass(Theme.color.errorContainer)
                     : current ? Theme.glass(focusedMonitor ? Theme.color.primary : Theme.color.secondaryContainer)
                     : "transparent"

                Accessible.role: Accessible.Button
                Accessible.name: "Workspace " + modelData.name + (window ? ", " + window.title : "")

                Behavior on width {
                    NumberAnimation {
                        duration: Motion.workspace
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Motion.emphasizedDecelerate
                    }
                }
                Behavior on color {
                    enabled: !Theme.transitioning
                    ColorAnimation { duration: Motion.card }
                }

                StateLayer {
                    color: label.color
                    hovered: mouse.containsMouse
                    pressed: mouse.pressed
                }

                Row {
                    id: content
                    anchors.centerIn: parent
                    spacing: Theme.spacing.x1 + 2

                    IconImage {
                        anchors.verticalCenter: parent.verticalCenter
                        implicitSize: 18
                        visible: pill.showIcon
                        source: pill.showIcon ? Icons.app(pill.iconName) : ""
                    }

                    MText {
                        id: label
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !pill.showIcon
                        role: Typography.labelLarge
                        text: pill.modelData.name
                        color: pill.modelData.urgent ? Theme.color.contentErrorContainer
                             : pill.current ? (pill.focusedMonitor ? Theme.color.contentPrimary : Theme.color.contentSecondaryContainer)
                             : Theme.color.contentSurfaceVariant
                    }
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: HyprlandService.activate(pill.modelData)
                    onContainsMouseChanged: {
                        if (containsMouse) {
                            root.hoveredCenter = pill.mapToItem(null, pill.width / 2, 0).x;
                            root.hoveredWorkspace = pill.modelData;
                        } else if (root.hoveredWorkspace === pill.modelData) {
                            root.hoveredWorkspace = null;
                        }
                    }
                }
            }
        }
    }
}

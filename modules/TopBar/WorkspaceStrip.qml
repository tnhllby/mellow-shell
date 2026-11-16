import QtQuick
import Quickshell
import qs.core
import qs.components
import qs.integrations.hyprland

// Workspaces of this panel's monitor. The focused workspace stretches into a
// pill; scrolling over the strip steps through the list.
Surface {
    id: root

    required property var monitor
    readonly property var model: HyprlandService.workspacesOn(monitor)

    implicitWidth: row.implicitWidth + 2 * Theme.spacing.x1
    implicitHeight: 36
    radius: Theme.shape.pill
    color: Theme.color.surfaceContainerHigh
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

                width: current ? 44 : 28
                height: 28
                radius: Theme.shape.pill
                color: modelData.urgent ? Theme.color.errorContainer
                     : current ? (focusedMonitor ? Theme.color.primary : Theme.color.secondaryContainer)
                     : "transparent"

                Accessible.role: Accessible.Button
                Accessible.name: "Workspace " + modelData.name

                Behavior on width {
                    NumberAnimation {
                        duration: Motion.workspace
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Motion.emphasizedDecelerate
                    }
                }
                Behavior on color {
                    ColorAnimation { duration: Motion.card }
                }

                StateLayer {
                    color: label.color
                    hovered: mouse.containsMouse
                    pressed: mouse.pressed
                }

                MText {
                    id: label
                    anchors.centerIn: parent
                    role: Typography.labelLarge
                    text: pill.modelData.name
                    color: pill.modelData.urgent ? Theme.color.contentErrorContainer
                         : pill.current ? (pill.focusedMonitor ? Theme.color.contentPrimary : Theme.color.contentSecondaryContainer)
                         : Theme.color.contentSurfaceVariant
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: HyprlandService.activate(pill.modelData)
                }
            }
        }
    }
}

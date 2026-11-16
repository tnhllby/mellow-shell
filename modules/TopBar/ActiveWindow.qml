import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.core
import qs.components
import qs.integrations.hyprland

// Icon and title of the focused window, shown only on the monitor it is on.
Row {
    id: root

    required property var monitor
    property real maximumWidth: 280

    readonly property var window: HyprlandService.activeWindow
    readonly property string appId: HyprlandService.appIdOf(window)
    readonly property var entry: appId ? DesktopEntries.heuristicLookup(appId) : null

    spacing: Theme.spacing.x2

    IconImage {
        anchors.verticalCenter: parent.verticalCenter
        implicitSize: 20
        source: Quickshell.iconPath(root.entry?.icon ?? root.appId, "application-x-executable")
    }

    MText {
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, root.maximumWidth - 20 - root.spacing)
        role: Typography.labelLarge
        color: Theme.color.contentSurfaceVariant
        text: root.window?.title ?? ""
    }
}

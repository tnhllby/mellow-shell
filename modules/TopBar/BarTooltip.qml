import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.core
import qs.components

// Tooltip under the bar for the hovered bar element. Click-through and always
// mapped; opaque, so it needs no blur region.
PanelWindow {
    id: root

    required property var panel
    readonly property string label: panel.hoveredLabel
    // Kept while fading out.
    property string shownLabel: ""
    property bool shown: false

    anchors {
        top: true
        left: true
        right: true
    }
    margins.top: Config.panel.height
    implicitHeight: 48
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    mask: Region {}

    WlrLayershell.namespace: "mellow:tooltip"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    onLabelChanged: {
        if (label === "") {
            delay.stop();
            shown = false;
        } else if (shown) {
            shownLabel = label;
        } else {
            delay.restart();
        }
    }

    Timer {
        id: delay
        interval: 500
        onTriggered: {
            root.shownLabel = root.label;
            root.shown = true;
        }
    }

    Rectangle {
        x: Math.max(Theme.spacing.x3, Math.min(root.width - width - Theme.spacing.x3, root.panel.hoveredLabelCenter - width / 2))
        y: Theme.spacing.x2
        width: text.implicitWidth + 2 * Theme.spacing.x3
        height: 30
        radius: Theme.shape.sm
        color: Theme.color.inverseSurface
        opacity: root.shown ? 1 : 0

        Behavior on opacity {
            MotionNumber {}
        }

        MText {
            id: text
            anchors.centerIn: parent
            role: Typography.labelMedium
            color: Theme.color.inverseContentSurface
            textFormat: Text.PlainText
            text: root.shownLabel
        }
    }
}

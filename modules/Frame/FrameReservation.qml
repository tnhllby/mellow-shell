import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.core

// Invisible strip that reserves the frame's thickness on one screen edge, so
// tiled windows are laid out inside the frame instead of under it.
PanelWindow {
    id: root

    // "left" | "right" | "bottom"
    required property string edge

    visible: Config.frame.enabled
    anchors {
        left: edge !== "right"
        right: edge !== "left"
        top: edge !== "bottom"
        bottom: true
    }
    implicitWidth: Config.frame.thickness
    implicitHeight: Config.frame.thickness
    exclusiveZone: Config.frame.thickness
    color: "transparent"
    mask: Region {}

    WlrLayershell.namespace: "mellow:frame-reserve"
    // Top layer, created after the panel: Hyprland applies exclusive zones in
    // layer and creation order, so the panel keeps its full width.
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
}

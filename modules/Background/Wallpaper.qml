import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.core
import qs.services

// Draws the wallpaper chosen in Wallpaper Studio on the background layer.
// Nothing is drawn until a wallpaper is set, so another wallpaper tool keeps
// working until then.
PanelWindow {
    id: root

    readonly property var entry: WallpaperService.wallpaperFor(screen?.name ?? "")

    visible: Config.wallpaper.draw && entry !== null
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    color: Theme.color.surfaceDim

    WlrLayershell.namespace: "mellow:wallpaper"
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Image {
        anchors.fill: parent
        source: root.entry ? "file://" + root.entry.path : ""
        sourceSize.width: root.width * (root.screen?.devicePixelRatio ?? 1)
        sourceSize.height: root.height * (root.screen?.devicePixelRatio ?? 1)
        fillMode: root.entry?.placement === "fit" ? Image.PreserveAspectFit
            : root.entry?.placement === "center" ? Image.Pad : Image.PreserveAspectCrop
        asynchronous: true
        retainWhileLoading: true
        cache: false
    }
}

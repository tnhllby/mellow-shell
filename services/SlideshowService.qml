pragma Singleton
import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import qs.core

// Changes the wallpaper of all displays (except those with their own) on an
// interval, from the first wallpaper folder. Colours follow only if they come
// from the wallpaper already.
Singleton {
    id: root

    readonly property bool active: Config.wallpaper.slideshowMinutes > 0 && Config.wallpaper.draw && WallpaperService.wallpapers["*"] !== undefined

    function next() {
        if (!active || files.count === 0)
            return;
        const current = WallpaperService.wallpapers["*"];
        let index = -1;
        for (let i = 0; i < files.count; i++)
            if (files.get(i, "filePath") === current.path)
                index = i;
        const path = files.get((index + 1) % files.count, "filePath");
        if (path === current.path)
            return;
        if (ThemeState.source !== "wallpaper") {
            WallpaperService.applyShared(path, null);
            return;
        }
        WallpaperService.schemeFromImage(path, scheme => WallpaperService.applyShared(path, scheme));
    }

    Timer {
        interval: Config.wallpaper.slideshowMinutes * 60000
        repeat: true
        running: root.active
        onTriggered: root.next()
    }

    FolderListModel {
        id: files
        folder: root.active ? "file://" + Config.wallpaper.folders[0]?.replace(/^~/, Quickshell.env("HOME")) : ""
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.avif", "*.bmp"]
        caseSensitive: false
        showDirs: false
    }
}

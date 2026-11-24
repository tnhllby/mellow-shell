pragma Singleton
import QtQuick
import Quickshell

// How settings are presented: pages and rows over ConfigSchema's keys. Every
// key belongs to a page, except theme.mode (only the first-run value; the
// live switch is ThemeState).
Singleton {
    readonly property var pages: [
        { id: "dashboard", title: "Dashboard", icon: "dashboard" },
        { id: "appearance", title: "Appearance", icon: "palette", rows: [
            { key: "profile.avatar", title: "Profile picture", desc: "Image path, then Enter. Empty uses your account's picture" },
            { key: "effects.blur", title: "Blur", desc: "Needs blur to be on in Hyprland" },
            { key: "motion.reduced", title: "Reduced motion", desc: "Changes happen at once" },
            { key: "theming.apps", title: "Colour other apps", desc: "kitty, Dolphin, Gwenview, GTK apps and window borders. Run install.sh --theme once first" }] },
        { id: "wallpaper", title: "Wallpaper", icon: "wallpaper", rows: [
            { key: "wallpaper.draw", title: "Draw the wallpaper", desc: "Off: use another wallpaper tool" },
            { key: "wallpaper.slideshowMinutes", title: "Change automatically", desc: "From the first folder, for displays without their own wallpaper", unit: "min", step: 5, max: 240, zero: "Off" },
            { key: "wallpaper.schemeType", title: "Colour style", desc: "Used the next time colours are generated" },
            { key: "wallpaper.folders", title: "Folders" },
            { key: "wallpaper.presetSeeds", title: "Preset colours", desc: "As #rrggbb" }] },
        { id: "bar", title: "Bar & clock", icon: "toolbar", rows: [
            { key: "panel.apps", title: "Apps button" },
            { key: "panel.overview", title: "Overview button" },
            { key: "panel.tray", title: "System tray" },
            { key: "panel.batteryPercent", title: "Battery percentage" },
            { key: "panel.unreadCount", title: "Number of notifications" },
            { key: "panel.metrics", title: "System metrics", desc: "While the Island shows media" },
            { key: "clock.timeFormat", title: "Time format", desc: "For example HH:mm or hh:mm ap" },
            { key: "clock.dateFormat", title: "Date format", desc: "For example ddd, d MMM" },
            { key: "panel.workspacePreview", title: "Workspace preview", desc: "When resting on a workspace number" },
            { key: "panel.height", title: "Bar height", unit: "px", advanced: true },
            { key: "panel.workspacePreviewDelay", title: "Preview delay", unit: "ms", step: 50, advanced: true },
            { key: "panel.workspacePreviewWidth", title: "Preview width", unit: "px", step: 10, advanced: true }] },
        { id: "frame", title: "Frame", icon: "crop_square", rows: [
            { key: "frame.enabled", title: "Workspace frame" },
            { key: "frame.fullscreenPolicy", title: "With a fullscreen window" },
            { key: "frame.thickness", title: "Thickness", unit: "px", advanced: true }] },
        { id: "island", title: "Island", icon: "music_note", rows: [
            { key: "island.pausedGrace", title: "Keep media after pausing", unit: "s", scale: 1000, step: 10000, max: 600000 },
            { key: "island.compactMaxWidth", title: "Compact width", unit: "px", step: 10, advanced: true },
            { key: "island.expandedWidth", title: "Expanded width", unit: "px", step: 10, advanced: true },
            { key: "island.statsInterval", title: "Statistics refresh", unit: "s", scale: 1000, step: 1000, advanced: true }] },
        { id: "dock", title: "Dock & Launcher", icon: "dock_to_left", rows: [
            { key: "dock.autoHide", title: "Hide the Dock automatically" },
            { key: "dock.pinned", title: "Pinned apps", desc: "Desktop entry names, in order" },
            { key: "launcher.terminal", title: "Terminal", desc: "Command for terminal apps, one word per entry" },
            { key: "launcher.maxResults", title: "Launcher results", advanced: true },
            { key: "dock.hideDelay", title: "Hide delay", unit: "ms", step: 50, advanced: true },
            { key: "dock.triggerWidth", title: "Edge trigger width", unit: "px", advanced: true }] },
        { id: "notifications", title: "Control Center", icon: "notifications", rows: [
            { key: "notifications.popups", title: "Notification pop-ups" },
            { key: "notifications.monitor", title: "Pop-up display", choices: "screens" },
            { key: "controlCenter.brightnessSlider", title: "Brightness slider" },
            { key: "controlCenter.volumeSlider", title: "Volume slider" },
            { key: "controlCenter.tileColumns", title: "Tile columns" },
            { key: "notifications.popupTimeout", title: "Pop-up duration", unit: "s", scale: 1000, step: 1000 },
            { key: "notifications.maxKept", title: "Notifications kept", advanced: true },
            { key: "controlCenter.width", title: "Control Center width", unit: "px", step: 10, advanced: true }] },
        { id: "system", title: "Sound & battery", icon: "volume_up", rows: [
            { key: "osd.enabled", title: "On-screen indicator", desc: "After volume, microphone or brightness changes" },
            { key: "audio.protection", title: "Volume protection", desc: "Caps the volume and undoes sudden jumps made outside MELLOW" },
            { key: "audio.maxVolume", title: "Highest volume", unit: "%", step: 5 },
            { key: "audio.maxStep", title: "Largest jump", unit: "%", step: 5 },
            { key: "battery.low", title: "Low battery warning", unit: "%", zero: "Off" },
            { key: "battery.critical", title: "Critical battery warning", unit: "%", zero: "Off" },
            { key: "battery.fullAlert", title: "Tell when the battery is full" },
            { key: "osd.timeout", title: "Indicator duration", unit: "ms", step: 100, advanced: true }] },
        { id: "overview", title: "Overview", icon: "grid_view", rows: [
            { key: "overview.defaultWorkspaces", title: "Workspaces always shown" },
            { key: "overview.columns", title: "Columns", zero: "Auto" }] }
    ]
}

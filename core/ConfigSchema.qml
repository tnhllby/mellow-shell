pragma Singleton
import QtQuick
import Quickshell

// Every user setting: default value and what is accepted. Config.qml reads
// config.json through this, so a bad value never reaches the shell.
// type: "bool" | "int" (min, max) | "enum" (values) | "string" | "strings"
Singleton {
    readonly property var entries: ({
        // Initial mode; the current choice is persisted by ThemeState.
        "theme.mode": { type: "enum", def: "dark", values: ["dark", "light"] },

        // Qt date/time format strings.
        "clock.timeFormat": { type: "string", def: "HH:mm" },
        "clock.dateFormat": { type: "string", def: "ddd, d MMM" },

        "panel.height": { type: "int", def: 44, min: 36, max: 72 },
        // Hovering a workspace number shows a preview of its windows.
        "panel.workspacePreview": { type: "bool", def: true },
        "panel.workspacePreviewDelay": { type: "int", def: 300, min: 0, max: 2000 },
        "panel.workspacePreviewWidth": { type: "int", def: 320, min: 200, max: 640 },

        // Workspaces 1..n always get a card, even before they exist.
        "overview.defaultWorkspaces": { type: "int", def: 6, min: 1, max: 10 },

        "island.compactMaxWidth": { type: "int", def: 360, min: 200, max: 600 },
        "island.expandedWidth": { type: "int", def: 440, min: 360, max: 640 },
        // Media mode lingers this long after playback pauses (ms).
        "island.pausedGrace": { type: "int", def: 120000, min: 0, max: 3600000 },
        // Ambient system statistics refresh interval (ms).
        "island.statsInterval": { type: "int", def: 3000, min: 1000, max: 60000 },

        // Draw the wallpaper chosen in Wallpaper Studio. Turn off to keep using
        // another wallpaper tool.
        "wallpaper.draw": { type: "bool", def: true },
        "wallpaper.folders": { type: "strings", def: ["~/Pictures/Wallpapers", "~/Pictures"] },
        // matugen scheme type for wallpaper-derived colours.
        "wallpaper.schemeType": { type: "enum", def: "scheme-tonal-spot", values: ["scheme-content", "scheme-expressive", "scheme-fidelity", "scheme-fruit-salad", "scheme-monochrome", "scheme-neutral", "scheme-rainbow", "scheme-tonal-spot", "scheme-vibrant"] },
        // Seeds offered next to the wallpaper's own colours.
        "wallpaper.presetSeeds": { type: "strings", def: ["#5E8C7A", "#4A6FA5", "#8E6CB8", "#C0597A", "#C7774A", "#B59A3A"], pattern: /^#[0-9a-fA-F]{6}$/ },

        // Theme kitty, KDE, GTK and Hyprland from MELLOW's colours. Off by default:
        // it changes those apps' settings. The installer turns it on.
        "theming.apps": { type: "bool", def: false },

        "frame.enabled": { type: "bool", def: true },
        "frame.thickness": { type: "int", def: 4, min: 1, max: 20 },
        // "hide": frame disappears while the monitor's active workspace has a
        // fullscreen window. "show": frame stays.
        "frame.fullscreenPolicy": { type: "enum", def: "hide", values: ["hide", "show"] },

        // Used for desktop entries with Terminal=true.
        "launcher.terminal": { type: "strings", def: ["kitty", "-e"], minLength: 1 },
        "launcher.maxResults": { type: "int", def: 48, min: 5, max: 200 },

        "controlCenter.width": { type: "int", def: 420, min: 380, max: 560 },

        "notifications.popups": { type: "bool", def: true },
        // How long a pop-up stays when the app does not say (ms).
        "notifications.popupTimeout": { type: "int", def: 6000, min: 1000, max: 60000 },
        // Older notifications are dropped beyond this many.
        "notifications.maxKept": { type: "int", def: 50, min: 5, max: 200 },

        "dock.autoHide": { type: "bool", def: true },
        // Width of the invisible activation strip on the left screen edge.
        "dock.triggerWidth": { type: "int", def: 2, min: 1, max: 8 },
        "dock.hideDelay": { type: "int", def: 450, min: 0, max: 3000 },
        // Desktop entry ids; entries that are not installed are skipped.
        "dock.pinned": { type: "strings", def: ["kitty", "foot", "org.gnome.Nautilus", "org.kde.dolphin", "thunar", "firefox", "chromium", "code", "org.gnome.TextEditor"] },

        "motion.reduced": { type: "bool", def: false },

        // "off": opaque surfaces. "subtle": cards are slightly translucent over
        // a compositor blur. "expressive": more translucent cards, and the
        // Overview/Studio backdrops blur what is behind them. Falls back to
        // "off" while Hyprland's blur (decoration:blur:enabled) is disabled.
        "effects.blur": { type: "enum", def: "subtle", values: ["off", "subtle", "expressive"] }
    })

    // What is wrong with `value` for setting `key`, or "" when it is fine.
    function problem(key, value) {
        const e = entries[key];
        if (!e)
            return "unknown setting";
        switch (e.type) {
        case "bool":
            return typeof value === "boolean" ? "" : "expected true or false";
        case "int":
            return Number.isInteger(value) && value >= e.min && value <= e.max ? "" : `expected a whole number from ${e.min} to ${e.max}`;
        case "enum":
            return e.values.includes(value) ? "" : "expected one of: " + e.values.join(", ");
        case "string":
            return typeof value === "string" && value !== "" ? "" : "expected text";
        case "strings":
            return Array.isArray(value) && value.length >= (e.minLength ?? 0) && value.every(v => typeof v === "string" && v !== "" && (!e.pattern || e.pattern.test(v))) ? "" : "expected a list of valid texts";
        }
        return "unknown type";
    }
}

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.core

// User-facing settings: defaults and limits from ConfigSchema, overridden by
// $XDG_CONFIG_HOME/mellow/config.json ({ "panel": { "height": 48 } }), which is
// optional and reloaded when it changes. A wrong value falls back to its default,
// a broken file keeps the last good settings; both are reported in `problems`.
Singleton {
    id: root

    // Valid settings from the file, by "group.name".
    property var overrides: ({})
    // Human-readable problems with the file.
    property var problems: []

    function value(key) {
        return overrides[key] ?? ConfigSchema.entries[key].def;
    }

    // The file as parsed, with settings MELLOW does not know.
    property var raw: ({})
    // The file cannot be read: never overwrite it.
    property bool broken: false

    // Changes a setting and saves it; false when the value is not accepted.
    function set(key, newValue) {
        if (broken || ConfigSchema.problem(key, newValue) !== "")
            return false;
        change(key, newValue);
        return true;
    }

    function reset(key) {
        if (!broken)
            change(key, undefined);
    }

    function change(key, newValue) {
        const [group, name] = key.split(".");
        const nextRaw = JSON.parse(JSON.stringify(raw));
        const next = Object.assign({}, overrides);
        if (newValue === undefined) {
            delete next[key];
            if (isGroup(nextRaw[group])) {
                delete nextRaw[group][name];
                if (Object.keys(nextRaw[group]).length === 0)
                    delete nextRaw[group];
            }
        } else {
            next[key] = newValue;
            if (!isGroup(nextRaw[group]))
                nextRaw[group] = {};
            nextRaw[group][name] = newValue;
        }
        raw = nextRaw;
        overrides = next;
        saveDelay.restart();
    }

    function apply(text) {
        broken = true;
        const found = {};
        const issues = [];
        let data = {};
        if (text.trim() !== "") {
            try {
                data = JSON.parse(text);
            } catch (e) {
                report(["not valid JSON, keeping the previous settings: " + e.message]);
                return;
            }
        }
        if (!isGroup(data)) {
            report(["expected an object with setting groups, keeping the previous settings"]);
            return;
        }
        for (const group in data) {
            if (!isGroup(data[group])) {
                issues.push(`${group}: expected a group of settings`);
                continue;
            }
            for (const name in data[group]) {
                const key = group + "." + name;
                const problem = ConfigSchema.problem(key, data[group][name]);
                if (problem)
                    issues.push(`${key}: ${problem}`);
                else
                    found[key] = data[group][name];
            }
        }
        broken = false;
        raw = data;
        overrides = found;
        report(issues);
    }

    function isGroup(value) {
        return typeof value === "object" && value !== null && !Array.isArray(value);
    }

    function report(issues) {
        problems = issues;
        for (const issue of issues)
            console.warn("config.json: " + issue);
    }

    Timer {
        id: saveDelay
        interval: 300
        onTriggered: makeDir.running = true
    }

    Process {
        id: makeDir
        command: ["mkdir", "-p", Paths.config]
        onExited: file.setText(JSON.stringify(root.raw, null, 2) + "\n")
    }

    FileView {
        id: file
        path: Paths.config + "/config.json"
        // One small read at startup, so the shell never starts with the wrong
        // geometry; later reloads are asynchronous.
        blockLoading: true
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        // Not over changes that are about to be saved.
        onLoaded: {
            if (!saveDelay.running && !makeDir.running)
                root.apply(text());
        }
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                root.apply("");
        }
    }

    readonly property QtObject theme: QtObject {
        readonly property string mode: root.value("theme.mode")
    }

    readonly property QtObject clock: QtObject {
        readonly property string timeFormat: root.value("clock.timeFormat")
        readonly property string dateFormat: root.value("clock.dateFormat")
    }

    readonly property QtObject panel: QtObject {
        readonly property int height: root.value("panel.height")
        readonly property bool workspacePreview: root.value("panel.workspacePreview")
        readonly property int workspacePreviewDelay: root.value("panel.workspacePreviewDelay")
        readonly property int workspacePreviewWidth: root.value("panel.workspacePreviewWidth")
    }

    readonly property QtObject overview: QtObject {
        readonly property int defaultWorkspaces: root.value("overview.defaultWorkspaces")
    }

    readonly property QtObject island: QtObject {
        readonly property int compactMaxWidth: root.value("island.compactMaxWidth")
        readonly property int expandedWidth: root.value("island.expandedWidth")
        readonly property int pausedGrace: root.value("island.pausedGrace")
        readonly property int statsInterval: root.value("island.statsInterval")
    }

    readonly property QtObject wallpaper: QtObject {
        readonly property bool draw: root.value("wallpaper.draw")
        readonly property var folders: root.value("wallpaper.folders")
        readonly property string schemeType: root.value("wallpaper.schemeType")
        readonly property var presetSeeds: root.value("wallpaper.presetSeeds")
    }

    readonly property QtObject theming: QtObject {
        readonly property bool apps: root.value("theming.apps")
    }

    readonly property QtObject frame: QtObject {
        readonly property bool enabled: root.value("frame.enabled")
        readonly property int thickness: root.value("frame.thickness")
        readonly property string fullscreenPolicy: root.value("frame.fullscreenPolicy")
    }

    readonly property QtObject launcher: QtObject {
        readonly property var terminal: root.value("launcher.terminal")
        readonly property int maxResults: root.value("launcher.maxResults")
    }

    readonly property QtObject controlCenter: QtObject {
        readonly property int width: root.value("controlCenter.width")
    }

    readonly property QtObject notifications: QtObject {
        readonly property int maxKept: root.value("notifications.maxKept")
        readonly property bool popups: root.value("notifications.popups")
        readonly property int popupTimeout: root.value("notifications.popupTimeout")
    }

    readonly property QtObject dock: QtObject {
        readonly property bool autoHide: root.value("dock.autoHide")
        readonly property int triggerWidth: root.value("dock.triggerWidth")
        readonly property int hideDelay: root.value("dock.hideDelay")
        readonly property var pinned: root.value("dock.pinned")
    }

    readonly property QtObject motion: QtObject {
        readonly property bool reduced: root.value("motion.reduced")
    }

    readonly property QtObject effects: QtObject {
        readonly property string blur: root.value("effects.blur")
    }
}

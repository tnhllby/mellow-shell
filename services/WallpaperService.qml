pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.core

// Wallpapers per monitor and wallpaper-derived colour schemes.
// State lives in $XDG_STATE_HOME/mellow/wallpaper.json:
//   wallpapers: { "*": {path, placement}, "<monitor>": {path, placement} }
//   previous:   snapshot taken before the last apply (for revert)
// Schemes are generated with matugen (Material Color Utilities) in a separate
// process and cached for the session.
Singleton {
    id: root

    readonly property var wallpapers: store.wallpapers ?? ({})
    readonly property bool canRevert: store.previous !== null && store.previous !== undefined
    property bool matugenAvailable: false
    // Requests wait in the queue until matugen detection has finished.
    property bool matugenChecked: false

    // Scheme cache: key -> scheme object.
    property var cache: ({})
    // Pending generation requests: { key, args, callbacks: [] }.
    property var queue: []
    property var current: null

    readonly property string matugenConfig: Paths.cache + "/matugen.toml"

    function wallpaperFor(monitor) {
        return wallpapers[monitor] ?? wallpapers["*"] ?? null;
    }

    // Applies a wallpaper to one monitor (or "*" for all) and, if given, a scheme.
    function apply(monitor, path, placement, scheme) {
        store.previous = {
            wallpapers: JSON.parse(JSON.stringify(wallpapers)),
            scheme: ThemeState.scheme,
            mode: ThemeState.mode
        };
        const next = monitor === "*" ? {} : JSON.parse(JSON.stringify(wallpapers));
        next[monitor] = { path, placement };
        store.wallpapers = next;
        if (scheme)
            ThemeState.setScheme(scheme);
    }

    function revert() {
        const previous = store.previous;
        if (!previous)
            return;
        store.wallpapers = previous.wallpapers ?? {};
        if (previous.scheme)
            ThemeState.setScheme(previous.scheme);
        else
            ThemeState.resetScheme();
        ThemeState.setMode(previous.mode ?? ThemeState.mode);
        store.previous = null;
    }

    // Scheme from an image's dominant colour. callback(scheme | null, error)
    function schemeFromImage(path, callback) {
        request(Config.wallpaper.schemeType + ":image:" + path, ["image", path], "wallpaper", callback);
    }

    // Scheme from a seed colour ("#rrggbb"). callback(scheme | null, error)
    function schemeFromSeed(hex, callback) {
        if (!/^#[0-9a-fA-F]{6}$/.test(hex)) {
            callback(null, "Invalid colour");
            return;
        }
        request(Config.wallpaper.schemeType + ":seed:" + hex.toLowerCase(), ["color", "hex", hex], "seed", callback);
    }

    function request(key, args, source, callback) {
        if (cache[key]) {
            callback(cache[key], "");
            return;
        }
        if (matugenChecked && !matugenAvailable) {
            callback(null, "matugen is not installed — colours stay unchanged");
            return;
        }
        const pending = queue.find(r => r.key === key) ?? (current?.key === key ? current : null);
        if (pending) {
            pending.callbacks.push(callback);
            return;
        }
        queue = queue.concat([{ key, args, source, callbacks: [callback] }]);
        next();
    }

    function next() {
        if (current || queue.length === 0 || !matugenChecked)
            return;
        if (!matugenAvailable) {
            for (const pending of queue)
                for (const callback of pending.callbacks)
                    callback(null, "matugen is not installed — colours stay unchanged");
            queue = [];
            return;
        }
        current = queue[0];
        queue = queue.slice(1);
        generator.command = ["matugen"].concat(current.args).concat([
            "--dry-run", "-q", "--json", "hex", "-t", Config.wallpaper.schemeType,
            "-c", matugenConfig, "--source-color-index", "0"]);
        generator.running = true;
    }

    // matugen JSON -> { dark: {role: hex}, light: {...}, seed, source }
    function parseScheme(text, source) {
        const colors = JSON.parse(text).colors;
        const scheme = { dark: {}, light: {}, seed: colors.source_color?.default?.color ?? "", source };
        for (const role in colors) {
            const name = role.replace(/(^|_)on_/g, "$1content_").replace(/_([a-z])/g, (m, c) => c.toUpperCase());
            scheme.dark[name] = colors[role].dark.color;
            scheme.light[name] = colors[role].light.color;
        }
        return scheme;
    }

    Process {
        id: generator
        stdout: StdioCollector {
            id: generatorOut
        }
        stderr: StdioCollector {
            id: generatorErr
        }
        onExited: code => {
            const request = root.current;
            root.current = null;
            let scheme = null;
            let error = "";
            if (code === 0) {
                try {
                    scheme = root.parseScheme(generatorOut.text, request.source);
                    const updated = Object.assign({}, root.cache);
                    updated[request.key] = scheme;
                    root.cache = updated;
                } catch (e) {
                    error = "Could not read matugen output";
                }
            } else {
                error = generatorErr.text.trim().split("\n").pop() || `matugen failed (${code})`;
            }
            for (const callback of request.callbacks)
                callback(scheme, error);
            root.next();
        }
    }

    // Detect matugen and give it an empty config so it never runs the user's
    // own templates.
    Process {
        running: true
        command: ["sh", "-c", "command -v matugen"]
        onExited: code => {
            root.matugenAvailable = code === 0;
            root.matugenChecked = true;
            root.next();
        }
    }

    FileView {
        path: root.matugenConfig
        printErrors: false
        Component.onCompleted: setText("[config]\n\n[templates]\n")
    }

    Timer {
        id: writeDelay
        interval: 200
        onTriggered: file.writeAdapter()
    }

    FileView {
        id: file
        path: Paths.state + "/wallpaper.json"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onAdapterUpdated: writeDelay.restart()

        JsonAdapter {
            id: store
            property var wallpapers: ({})
            property var previous: null
        }
    }
}

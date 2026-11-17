pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
import qs.integrations.hyprland

// Installed applications (desktop entries): search, launch and the link
// between running windows and their applications.
// Launch counts are recorded by MELLOW itself ($XDG_STATE_HOME/mellow/apps.json)
// and only nudge the ranking of search results.
Singleton {
    id: root

    // Visible applications, by name.
    readonly property var apps: DesktopEntries.applications.values
        .filter(entry => !entry.noDisplay)
        .sort((a, b) => a.name.localeCompare(b.name))
    readonly property var pinned: {
        DesktopEntries.applications.values;
        return Config.dock.pinned.map(id => DesktopEntries.byId(id)).filter(entry => entry && !entry.noDisplay);
    }
    readonly property var counts: store.counts ?? ({})

    function launch(entry) {
        if (!entry)
            return;
        if (entry.runInTerminal)
            Quickshell.execDetached(Config.launcher.terminal.concat(entry.command));
        else
            entry.execute();
        const next = Object.assign({}, counts);
        next[entry.id] = (next[entry.id] ?? 0) + 1;
        store.counts = next;
    }

    // Ranked search over name, generic name, keywords and comment.
    function search(query) {
        const q = query.trim().toLowerCase();
        if (q === "")
            return [];
        const scored = [];
        for (const entry of apps) {
            const score = match(entry, q);
            if (score > 0)
                scored.push({ entry, score: score + Math.min(10, counts[entry.id] ?? 0) });
        }
        scored.sort((a, b) => b.score - a.score || a.entry.name.localeCompare(b.entry.name));
        return scored.slice(0, Config.launcher.maxResults).map(s => s.entry);
    }

    function match(entry, q) {
        const name = entry.name.toLowerCase();
        if (name === q)
            return 120;
        if (name.startsWith(q))
            return 100;
        if (name.split(/[\s\-_.]+/).some(word => word.startsWith(q)))
            return 85;
        if (name.includes(q))
            return 70;
        const generic = (entry.genericName ?? "").toLowerCase();
        if (generic.includes(q))
            return 55;
        if ((entry.keywords ?? []).some(k => k.toLowerCase().startsWith(q)))
            return 50;
        if (entry.id.toLowerCase().includes(q))
            return 40;
        if ((entry.comment ?? "").toLowerCase().includes(q))
            return 25;
        // Letters in order ("ffx" -> Firefox).
        let i = 0;
        for (const c of name)
            if (c === q[i])
                i++;
        return i === q.length ? 15 : 0;
    }

    // Windows that belong to an application (desktop entry, or a bare app id
    // for windows without one).
    function windowsFor(entry, appId) {
        return HyprlandService.windows.filter(w => entry ? entryForWindow(w)?.id === entry.id
            : HyprlandService.appIdOf(w) === appId);
    }

    // Running applications that are not pinned: [{ entry, appId }], in window order.
    readonly property var runningUnpinned: {
        const seen = new Set(pinned.map(e => e.id));
        const result = [];
        for (const w of HyprlandService.windows) {
            const appId = HyprlandService.appIdOf(w);
            const entry = entryForWindow(w);
            const key = entry?.id ?? appId;
            if (!key || seen.has(key))
                continue;
            seen.add(key);
            result.push({ entry, appId });
        }
        return result;
    }

    // Desktop entry for a window, or null.
    function entryForWindow(window) {
        const appId = HyprlandService.appIdOf(window);
        return appId ? DesktopEntries.heuristicLookup(appId) : null;
    }

    Timer {
        id: writeDelay
        interval: 300
        onTriggered: file.writeAdapter()
    }

    FileView {
        id: file
        path: Paths.state + "/apps.json"
        printErrors: false
        onAdapterUpdated: writeDelay.restart()

        JsonAdapter {
            id: store
            property var counts: ({})
        }
    }
}

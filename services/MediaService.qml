pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import qs.core

// Media sessions (MPRIS) and the current audio output (PipeWire).
// Picks one "active" player: a playing one (the most recently started wins),
// otherwise the last one that played.
Singleton {
    id: root

    readonly property var players: Mpris.players.values
    property var lastPlayer: null

    readonly property var activePlayer: {
        const playing = players.filter(p => p.isPlaying);
        if (playing.length > 0)
            return playing.includes(lastPlayer) ? lastPlayer : playing[0];
        return players.includes(lastPlayer) ? lastPlayer : (players[0] ?? null);
    }
    readonly property bool playing: activePlayer?.isPlaying ?? false

    // Media mode: something is playing, or it was paused only moments ago.
    readonly property bool mediaMode: playing || pauseGrace.running

    // Metadata with fallbacks for players that report little or nothing.
    readonly property string title: activePlayer?.trackTitle || activePlayer?.identity || "Unknown title"
    readonly property string artist: activePlayer?.trackArtist ?? ""
    readonly property string album: activePlayer?.trackAlbum ?? ""
    readonly property string artUrl: activePlayer?.trackArtUrl ?? ""
    readonly property string identity: activePlayer?.identity ?? ""
    readonly property string desktopEntry: activePlayer?.desktopEntry ?? ""

    readonly property bool canSeek: (activePlayer?.canSeek ?? false) && (activePlayer?.positionSupported ?? false) && length > 0
    readonly property real length: activePlayer?.lengthSupported ? activePlayer.length : 0
    readonly property real position: activePlayer?.positionSupported ? activePlayer.position : 0

    readonly property string outputName: Pipewire.defaultAudioSink?.description || Pipewire.defaultAudioSink?.nickname || ""

    function formatTime(seconds) {
        const s = Math.max(0, Math.floor(seconds));
        const h = Math.floor(s / 3600);
        const m = Math.floor(s % 3600 / 60);
        const ss = String(s % 60).padStart(2, "0");
        return h > 0 ? `${h}:${String(m).padStart(2, "0")}:${ss}` : `${m}:${ss}`;
    }

    function togglePlaying() {
        if (activePlayer?.canTogglePlaying)
            activePlayer.togglePlaying();
    }

    function next() {
        if (activePlayer?.canGoNext)
            activePlayer.next();
    }

    function previous() {
        if (activePlayer?.canGoPrevious)
            activePlayer.previous();
    }

    function seekTo(seconds) {
        if (canSeek)
            activePlayer.position = Math.max(0, Math.min(length, seconds));
    }

    function seekBy(seconds) {
        seekTo(position + seconds);
    }

    // Remember which player played last.
    Instantiator {
        model: Mpris.players

        delegate: Connections {
            required property var modelData
            target: modelData

            function onIsPlayingChanged() {
                if (modelData.isPlaying)
                    root.lastPlayer = modelData;
            }
        }
    }

    Connections {
        target: root.activePlayer

        function onIsPlayingChanged() {
            if (!root.activePlayer.isPlaying)
                pauseGrace.restart();
        }
    }

    Timer {
        id: pauseGrace
        interval: Config.island.pausedGrace
    }

    // MPRIS does not push position updates; refresh the bound value once a
    // second while something plays. This only re-reads the player's property.
    Timer {
        interval: 1000
        repeat: true
        running: root.playing && root.activePlayer?.positionSupported === true
        onTriggered: root.activePlayer.positionChanged()
    }

    // Keeps the default sink's properties (description) bound.
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }
}

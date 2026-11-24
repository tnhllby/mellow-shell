pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.core

// Default audio output and input (PipeWire).
Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    readonly property bool sinkAvailable: sink?.audio !== undefined && sink?.audio !== null
    readonly property bool sourceAvailable: source?.audio !== undefined && source?.audio !== null

    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property bool micMuted: source?.audio?.muted ?? false
    readonly property string sinkName: sink?.description || sink?.nickname || ""

    // Volume protection: the last accepted volume, or -1 until it is known
    // (startup, another output).
    property real accepted: -1
    readonly property real limit: Config.audio.maxVolume / 100

    onSinkChanged: {
        accepted = -1;
        settle.restart();
    }
    // Corrected after the change has been delivered: writing the volume inside
    // its own change handler is ignored.
    onVolumeChanged: Qt.callLater(guard)

    function guard() {
        if (accepted < 0 || !sinkAvailable)
            return;
        if (!Config.audio.protection)
            accepted = volume;
        else if (volume - accepted > Config.audio.maxStep / 100 + 0.005)
            sink.audio.volume = accepted;
        else if (volume > limit + 0.005)
            sink.audio.volume = accepted = limit;
        else
            accepted = volume;
    }

    Timer {
        id: settle
        interval: 1000
        running: true
        onTriggered: root.accepted = root.volume
    }

    function setVolume(value) {
        if (sinkAvailable) {
            const next = Math.max(0, Math.min(Config.audio.protection ? Math.min(1, limit) : 1, value));
            // A deliberate change may jump.
            if (accepted >= 0)
                accepted = next;
            sink.audio.volume = next;
            if (value > 0 && sink.audio.muted)
                sink.audio.muted = false;
        }
    }

    function toggleMute() {
        if (sinkAvailable)
            sink.audio.muted = !sink.audio.muted;
    }

    function toggleMicMute() {
        if (sourceAvailable)
            source.audio.muted = !source.audio.muted;
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }
}

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

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

    function setVolume(value) {
        if (sinkAvailable) {
            sink.audio.volume = Math.max(0, Math.min(1, value));
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

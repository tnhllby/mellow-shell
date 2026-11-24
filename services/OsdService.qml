pragma Singleton
import QtQuick
import Quickshell
import qs.core
import qs.integrations.hyprland

// On-screen display: what to show for a moment after the volume, the
// microphone or the brightness changed. Quiet while the Control Center, which
// shows the same sliders, is open.
Singleton {
    id: root

    // "volume" | "microphone" | "brightness"
    property string kind: ""
    property string monitor: ""
    property bool shown: false
    // Display whose brightness is shown.
    property string display: ""
    // Values settle after startup or a device change without a pop-up.
    property bool settled: false

    readonly property string internalDisplay: Quickshell.screens.find(s => BrightnessService.isInternal(s.name))?.name ?? ""

    function show(newKind) {
        if (!settled || !Config.osd.enabled || ShellState.controlCenterMonitor !== "")
            return;
        kind = newKind;
        monitor = HyprlandService.focusedMonitor?.name ?? Quickshell.screens[0]?.name ?? "";
        shown = true;
        hide.restart();
    }

    function showBrightness(name) {
        display = name;
        show("brightness");
    }

    Timer {
        id: settle
        interval: 1500
        running: true
        onTriggered: root.settled = true
    }

    Timer {
        id: hide
        interval: Config.osd.timeout
        onTriggered: root.shown = false
    }

    Connections {
        target: ShellState

        function onControlCenterMonitorChanged() {
            if (ShellState.controlCenterMonitor !== "")
                root.shown = false;
        }
    }

    Connections {
        target: AudioService

        function onSinkChanged() {
            root.settled = false;
            settle.restart();
        }
        function onSourceChanged() {
            root.settled = false;
            settle.restart();
        }
        function onVolumeChanged() {
            root.show("volume");
        }
        function onMutedChanged() {
            root.show("volume");
        }
        function onMicMutedChanged() {
            root.show("microphone");
        }
    }

    Connections {
        target: BrightnessService

        function onCurrentChanged() {
            if (root.internalDisplay)
                root.showBrightness(root.internalDisplay);
        }
    }
}

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.core
import qs.integrations.hyprland
import qs.services

// Keyboard entry points. Every action opens on the focused monitor.
//
// Hyprland global shortcuts (bind them in your Hyprland config):
//   hyprland.conf:  bind = SUPER, C, global, mellow:controlCenter
//   hyprland.lua:   hl.bind("SUPER + C", hl.dsp.global("mellow:controlCenter"))
//
// IPC (scripts, other tools):
//   qs -c mellow ipc call mellow toggleControlCenter
Scope {
    id: root

    function focusedMonitorName() {
        return HyprlandService.focusedMonitor?.name ?? Quickshell.screens[0]?.name ?? "";
    }

    GlobalShortcut {
        appid: "mellow"
        name: "controlCenter"
        description: "Toggle the Control Center"
        onPressed: ShellState.toggleControlCenter(root.focusedMonitorName(), true)
    }

    GlobalShortcut {
        appid: "mellow"
        name: "dock"
        description: "Open the Dock with keyboard focus"
        onPressed: ShellState.toggleDock(root.focusedMonitorName())
    }

    GlobalShortcut {
        appid: "mellow"
        name: "island"
        description: "Expand the Island media player with keyboard focus"
        onPressed: ShellState.toggleIsland(root.focusedMonitorName(), true)
    }

    GlobalShortcut {
        appid: "mellow"
        name: "mediaPlayPause"
        description: "Play or pause the active media player"
        onPressed: MediaService.togglePlaying()
    }

    GlobalShortcut {
        appid: "mellow"
        name: "mediaNext"
        description: "Next track"
        onPressed: MediaService.next()
    }

    GlobalShortcut {
        appid: "mellow"
        name: "mediaPrevious"
        description: "Previous track"
        onPressed: MediaService.previous()
    }

    GlobalShortcut {
        appid: "mellow"
        name: "launcher"
        description: "Toggle the application launcher"
        // Acts on release: a release bind (`bindr = SUPER, SUPER_L`, Meta alone)
        // only sends "released", and Hyprland drops it when another key was
        // pressed while Meta was held. Normal binds send both events.
        onReleased: ShellState.toggleLauncher(root.focusedMonitorName())
    }

    GlobalShortcut {
        appid: "mellow"
        name: "overview"
        description: "Toggle the workspace and window Overview"
        onPressed: ShellState.toggleOverview(root.focusedMonitorName())
    }

    GlobalShortcut {
        appid: "mellow"
        name: "studio"
        description: "Open Wallpaper Studio"
        onPressed: ShellState.openStudio(root.focusedMonitorName())
    }

    GlobalShortcut {
        appid: "mellow"
        name: "settings"
        description: "Open or close the settings window"
        onPressed: ShellState.settingsOpen = !ShellState.settingsOpen
    }

    GlobalShortcut {
        appid: "mellow"
        name: "closeAll"
        description: "Close all MELLOW popups"
        onPressed: ShellState.closeAll()
    }

    IpcHandler {
        target: "mellow"

        function toggleControlCenter(): void {
            ShellState.toggleControlCenter(root.focusedMonitorName(), true);
        }

        function toggleDock(): void {
            ShellState.toggleDock(root.focusedMonitorName());
        }

        function toggleIsland(): void {
            ShellState.toggleIsland(root.focusedMonitorName(), true);
        }

        function mediaPlayPause(): void {
            MediaService.togglePlaying();
        }

        function mediaNext(): void {
            MediaService.next();
        }

        function mediaPrevious(): void {
            MediaService.previous();
        }

        function toggleLauncher(): void {
            ShellState.toggleLauncher(root.focusedMonitorName());
        }

        function toggleOverview(): void {
            ShellState.toggleOverview(root.focusedMonitorName());
        }

        function openStudio(): void {
            ShellState.openStudio(root.focusedMonitorName());
        }

        function toggleSettings(): void {
            ShellState.settingsOpen = !ShellState.settingsOpen;
        }

        function toggleDoNotDisturb(): void {
            NotificationService.toggleDoNotDisturb();
        }

        function toggleKeepAwake(): void {
            KeepAwakeService.toggle();
        }

        // Brightness of the focused monitor, by percentage points.
        function brightnessStep(percent: int): void {
            const name = root.focusedMonitorName();
            if (!BrightnessService.available(name))
                return;
            BrightnessService.setValue(name, BrightnessService.value(name) + percent / 100);
            OsdService.showBrightness(name);
        }

        function toggleTheme(): void {
            ThemeState.toggleMode();
        }

        function closeAll(): void {
            ShellState.closeAll();
        }

        function focusWorkspace(id: int): void {
            HyprlandService.focusWorkspace(id);
        }
    }
}

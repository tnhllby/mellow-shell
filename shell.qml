import QtQuick
import Quickshell
import qs.modules.TopBar
import qs.modules.Dock
import qs.modules.Frame
import qs.modules.Island
import qs.modules.ControlCenter
import qs.modules.Launcher
import qs.modules.Overview
import qs.modules.Background
import qs.modules.Settings
import qs.modules.Notifications
import qs.modules.WallpaperStudio
import qs.modules
import qs.core
import qs.services
import qs.integrations.hyprland

// MELLOW entry point: one set of surfaces per connected screen. Variants
// creates and destroys them as monitors are plugged in or removed.
ShellRoot {
    Shortcuts {}

    // Keeps the service alive from startup.
    readonly property bool appTheming: AppThemeService.enabled

    // Theme lives in core and does not talk to Hyprland; hand it the
    // compositor's blur state here.
    Binding {
        target: Theme
        property: "compositorBlur"
        value: HyprlandService.blurEnabled
    }

    LazyLoader {
        active: ShellState.settingsOpen

        SettingsWindow {}
    }

    Variants {
        model: Quickshell.screens

        Scope {
            id: perScreen
            required property ShellScreen modelData

            Wallpaper {
                screen: perScreen.modelData
            }

            TopBar {
                id: topBar
                screen: perScreen.modelData
            }

            Island {
                screen: perScreen.modelData
            }

            WorkspacePreview {
                screen: perScreen.modelData
                panel: topBar
            }

            WorkspaceFrame {
                screen: perScreen.modelData
            }

            FrameReservation {
                screen: perScreen.modelData
                edge: "left"
            }

            FrameReservation {
                screen: perScreen.modelData
                edge: "right"
            }

            FrameReservation {
                screen: perScreen.modelData
                edge: "bottom"
            }

            Dock {
                screen: perScreen.modelData
            }

            ControlCenter {
                screen: perScreen.modelData
                panel: topBar
            }

            NotificationPopups {
                screen: perScreen.modelData
            }

            Launcher {
                screen: perScreen.modelData
            }

            WallpaperStudio {
                screen: perScreen.modelData
            }

            // Last, so it covers every other surface while open.
            Overview {
                screen: perScreen.modelData
            }
        }
    }
}

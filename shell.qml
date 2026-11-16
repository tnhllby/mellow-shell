import QtQuick
import Quickshell
import qs.modules.TopBar
import qs.modules.Dock
import qs.modules.Frame
import qs.modules.Island
import qs.modules.Background
import qs.modules.WallpaperStudio
import qs.modules

// MELLOW entry point: one set of surfaces per connected screen. Variants
// creates and destroys them as monitors are plugged in or removed.
ShellRoot {
    Shortcuts {}

    Variants {
        model: Quickshell.screens

        Scope {
            id: perScreen
            required property ShellScreen modelData

            Wallpaper {
                screen: perScreen.modelData
            }

            TopBar {
                screen: perScreen.modelData
            }

            Island {
                screen: perScreen.modelData
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

            WallpaperStudio {
                screen: perScreen.modelData
            }
        }
    }
}

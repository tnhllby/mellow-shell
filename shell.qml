import QtQuick
import Quickshell
import qs.modules.TopBar
import qs.modules.Dock
import qs.modules.Frame

// MELLOW entry point: one set of surfaces per connected screen. Variants
// creates and destroys them as monitors are plugged in or removed.
ShellRoot {
    Variants {
        model: Quickshell.screens

        Scope {
            id: perScreen
            required property ShellScreen modelData

            TopBar {
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
        }
    }
}

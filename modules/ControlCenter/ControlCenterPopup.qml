import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.core
import qs.components
import qs.services

// Control Center: Pixel-inspired quick settings that open from the panel.
// Closes on Escape (from the main page), the trigger, or a click outside.
// Only controls backed by an available service are shown.
PopupWindow {
    id: root

    required property var panel
    required property Item anchorItem
    property bool open: false
    // "main" | "wifi" | "bluetooth"
    property string page: "main"
    signal dismissed

    anchor.window: panel
    anchor.item: anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.margins.top: Theme.spacing.x2

    visible: open
    implicitWidth: 400
    implicitHeight: card.height
    color: "transparent"

    onOpenChanged: {
        page = "main";
        if (open) {
            BrightnessService.refresh();
            // Keyboard opens focus the first control (with its ring); pointer
            // opens only focus the popup, so Tab starts the ring.
            Qt.callLater(() => ShellState.controlCenterFromKeyboard ? mainPage.focusFirst() : content.forceActiveFocus());
        }
    }
    onPageChanged: NetworkService.setScanning(open && page === "wifi")

    // Keeps keyboard focus in the popup and dismisses it on outside clicks.
    // The panel is included so its trigger can toggle the popup closed.
    HyprlandFocusGrab {
        active: root.visible
        windows: [root, root.panel]
        onCleared: root.dismissed()
    }

    Surface {
        id: card

        width: parent.width
        height: content.implicitHeight + 2 * Theme.spacing.x4
        radius: Theme.shape.xl
        topRightRadius: Theme.shape.md
        color: Theme.color.surfaceContainer
        border.width: 1
        border.color: Theme.color.outlineVariant

        Behavior on height {
            NumberAnimation {
                duration: Motion.card
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Motion.standard
            }
        }

        FocusScope {
            id: content

            anchors.fill: parent
            anchors.margins: Theme.spacing.x4
            implicitHeight: (root.page === "wifi" ? wifiPage : root.page === "bluetooth" ? btPage : mainPage).implicitHeight
            focus: true

            Keys.onEscapePressed: {
                if (root.page === "main")
                    root.dismissed();
                else
                    root.page = "main";
            }

            MainPage {
                id: mainPage
                width: parent.width
                visible: root.page === "main"
                monitorName: root.panel.screen?.name ?? ""
                onPageRequested: name => root.page = name
            }

            WifiPage {
                id: wifiPage
                width: parent.width
                visible: root.page === "wifi"
                onBack: root.page = "main"
            }

            BluetoothPage {
                id: btPage
                width: parent.width
                visible: root.page === "bluetooth"
                onBack: root.page = "main"
            }
        }
    }
}

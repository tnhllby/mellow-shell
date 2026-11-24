import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.core
import qs.components
import qs.services

// Control Center: full-height panel on the right edge with quick settings,
// media controls and notifications.
// Like the Island it is a layer surface that stays mapped: its input region is
// the card while open and empty otherwise. (An xdg-popup does not work here:
// Hyprland's focus grab treats clicks inside a layer-shell popup as outside
// clicks and dismissed it.) Closes on Escape (from the main page), the
// trigger, or a click outside. Only controls backed by a service are shown.
PanelWindow {
    id: root

    // The panel, kept in the focus grab so its trigger can toggle the card closed.
    required property var panel
    readonly property bool open: ShellState.controlCenterMonitor === screen?.name
    // "main" | "wifi" | "bluetooth"
    property string page: "main"

    function close() {
        if (open)
            ShellState.controlCenterMonitor = "";
    }

    anchors {
        top: true
        right: true
        bottom: true
    }
    // Inside the chrome; the card slides out from under the frame's edge.
    margins.top: Config.panel.height
    margins.right: Config.frame.thickness
    margins.bottom: Config.frame.thickness
    implicitWidth: Config.controlCenter.width + Theme.spacing.x2
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    mask: Region {
        item: root.open ? card : null
    }
    // Only once fully slid in, and gone as soon as closing starts: a region
    // reaching outside the surface makes Hyprland blur all of it.
    BackgroundEffect.blurRegion: CardBlurRegion {
        card: card
        active: Theme.effects.blurOn && root.open && card.x === 0
    }

    WlrLayershell.namespace: "mellow:control-center"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    HyprlandFocusGrab {
        active: root.open
        windows: [root, root.panel]
        onCleared: root.close()
    }

    onOpenChanged: {
        page = "main";
        if (open) {
            BrightnessService.refresh();
            NotificationService.refreshOwner();
            // Keyboard opens focus the first control (with its ring); pointer
            // opens only focus the card, so Tab starts the ring.
            Qt.callLater(() => ShellState.controlCenterFromKeyboard ? mainPage.focusFirst() : content.forceActiveFocus());
        }
    }
    onPageChanged: NetworkService.setScanning(open && page === "wifi")

    Surface {
        id: card

        y: Theme.spacing.x2
        x: root.open ? 0 : root.implicitWidth
        width: Config.controlCenter.width
        height: root.height - 2 * Theme.spacing.x2
        radius: Theme.shape.xl
        // Anchored at the trigger; the organic corner is diagonally opposite.
        topRightRadius: Theme.shape.md
        bottomLeftRadius: Theme.shape.organic
        color: Theme.glass(Theme.color.surfaceContainer)
        border.width: Theme.cardEdgeWidth
        border.color: Theme.cardEdge(color)
        clip: true

        visible: root.open || x < root.implicitWidth

        Behavior on x {
            NumberAnimation {
                duration: root.open ? Motion.module : Motion.exit
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.open ? Motion.emphasizedDecelerate : Motion.emphasizedAccelerate
            }
        }

        FocusScope {
            id: content

            anchors.fill: parent
            anchors.margins: Theme.spacing.x4
            focus: true

            Keys.onEscapePressed: {
                if (root.page === "main")
                    root.close();
                else
                    root.page = "main";
            }

            MainPage {
                id: mainPage
                anchors.fill: parent
                visible: root.page === "main"
                monitorName: root.screen?.name ?? ""
                onPageRequested: name => root.page = name
                onCloseRequested: root.close()
            }

            WifiPage {
                id: wifiPage
                anchors.fill: parent
                visible: root.page === "wifi"
                onBack: root.page = "main"
            }

            BluetoothPage {
                id: btPage
                anchors.fill: parent
                visible: root.page === "bluetooth"
                onBack: root.page = "main"
            }
        }
    }
}

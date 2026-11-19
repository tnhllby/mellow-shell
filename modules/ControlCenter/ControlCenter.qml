import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.core
import qs.components
import qs.services

// Control Center: Pixel-inspired quick settings below the panel's status area.
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
    }
    margins.top: Config.panel.height
    margins.right: Theme.spacing.x3
    implicitWidth: 400
    // Fixed size, so opening or switching pages never resizes the surface.
    implicitHeight: (screen?.height ?? 800) - Config.panel.height - Config.frame.thickness
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    mask: Region {
        item: root.open ? card : null
    }
    BackgroundEffect.blurRegion: Region {
        // Only once fully open (the region ignores scale and opacity), and
        // gone as soon as closing starts.
        item: Theme.effects.blurOn && root.open && card.opacity === 1 && card.scale === 1 ? card : null
        radius: card.radius
        topRightRadius: card.topRightRadius
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
            // Keyboard opens focus the first control (with its ring); pointer
            // opens only focus the card, so Tab starts the ring.
            Qt.callLater(() => ShellState.controlCenterFromKeyboard ? mainPage.focusFirst() : content.forceActiveFocus());
        }
    }
    onPageChanged: NetworkService.setScanning(open && page === "wifi")

    Surface {
        id: card

        y: Theme.spacing.x2
        width: parent.width
        height: Math.min(content.implicitHeight + 2 * Theme.spacing.x4, root.height - y)
        radius: Theme.shape.xl
        topRightRadius: Theme.shape.md
        color: Theme.glass(Theme.color.surfaceContainer)
        clip: true

        visible: opacity > 0
        opacity: root.open ? 1 : 0
        scale: root.open ? 1 : 0.96
        transformOrigin: Item.TopRight

        Behavior on opacity {
            NumberAnimation { duration: Motion.card }
        }
        Behavior on scale {
            NumberAnimation {
                duration: Motion.card
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Motion.emphasizedDecelerate
            }
        }
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
                    root.close();
                else
                    root.page = "main";
            }

            MainPage {
                id: mainPage
                width: parent.width
                visible: root.page === "main"
                monitorName: root.screen?.name ?? ""
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

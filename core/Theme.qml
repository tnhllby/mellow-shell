pragma Singleton
import QtQuick
import Quickshell
import qs.core

// Central provider of semantic design tokens. Components read colours,
// shapes and spacing from here and never hardcode them.
Singleton {
    id: root

    readonly property bool dark: ThemeState.dark
    readonly property ThemeColors color: ThemeColors {
        roles: ThemeState.roles
        fallback: ThemeState.fallbackRoles
    }

    // Set from the shell root: whether the compositor blurs (core does not
    // talk to Hyprland itself).
    property bool compositorBlur: false

    readonly property QtObject effects: QtObject {
        readonly property string blur: root.compositorBlur && ["subtle", "expressive"].includes(Config.effects.blur) ? Config.effects.blur : "off"
        readonly property bool blurOn: blur !== "off"
        // Card opacity over the blur; 1 keeps cards opaque.
        readonly property real cardOpacity: blur === "expressive" ? 0.72 : blur === "subtle" ? 0.86 : 1
        // Bar and frame (one chrome) opacity over the blur.
        readonly property real chromeOpacity: blur === "expressive" ? 0.7 : blur === "subtle" ? 0.85 : 1
        // Full-screen backdrops (Overview, Studio) blur what is behind them.
        readonly property bool backdropBlur: blur === "expressive"
    }

    // A card colour made translucent to match the blur mode.
    function glass(c) {
        return Qt.alpha(c, effects.cardOpacity);
    }

    // The continuous chrome shared by the panel and the workspace frame.
    readonly property color chrome: Qt.alpha(color.surfaceContainer, effects.chromeOpacity)
    // Outside the rounded screen corners: black like the display bezel, in every theme.
    readonly property color screenCorner: "#000000"

    readonly property QtObject shape: QtObject {
        readonly property int xs: 6
        readonly property int sm: 10
        readonly property int md: 16
        readonly property int lg: 22
        readonly property int xl: 30
        readonly property int organic: 38
        readonly property int pill: 999
    }

    // 4 px base unit.
    readonly property QtObject spacing: QtObject {
        readonly property int x1: 4
        readonly property int x2: 8
        readonly property int x3: 12
        readonly property int x4: 16
        readonly property int x5: 20
        readonly property int x6: 24
        readonly property int x8: 32
        readonly property int x10: 40
        readonly property int x12: 48
    }

    // Material 3 state-layer opacities.
    readonly property QtObject state: QtObject {
        readonly property real hover: 0.08
        readonly property real focus: 0.10
        readonly property real pressed: 0.10
    }

    // Bar + frame chrome: rounded outer screen corners and the inner fillets
    // around the workspace.
    readonly property QtObject chromeShape: QtObject {
        readonly property int outerRadius: 22
        readonly property int innerRadius: 11
    }

    readonly property QtObject focusRing: QtObject {
        readonly property int width: 2
        readonly property int offset: 2
    }
}

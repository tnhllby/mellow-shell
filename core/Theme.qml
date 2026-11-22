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

    // Hairline around floating cards: just enough to soften their edge.
    readonly property color cardOutline: Qt.alpha(color.outlineVariant, 0.35)

    // Edge band of blurred cards on the bar and screen edges (Island, Dock): the
    // card's own colour, a little more opaque than the card and wider than the
    // blur inset, so the unblurred ring and the stepped corners of the blur
    // region stay hidden without reading as an outline.
    readonly property int cardEdgeWidth: 2
    function cardEdge(fill) {
        return Qt.alpha(fill, (1 + effects.cardOpacity) / 2);
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
        // Workspace corners, top (fillets) and bottom alike: concentric with the
        // outer corners, so the frame keeps its thickness round the curve.
        readonly property int innerRadius: outerRadius - Config.frame.thickness
    }

    // Pills sitting on the bar (workspaces, status, compact Island).
    readonly property QtObject barPill: QtObject {
        readonly property int height: Config.panel.height - 10
        // Buttons inside a bar pill.
        readonly property int inner: Config.panel.height - 18
    }

    readonly property QtObject focusRing: QtObject {
        readonly property int width: 2
        readonly property int offset: 2
    }
}

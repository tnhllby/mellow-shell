import QtQuick
import Quickshell

// Blur region for a rounded card, inset 1 px from its edge. The card's
// antialiased edge is partly transparent; with the blur under it, the blurred
// backdrop (the wallpaper when Hyprland's xray is on) showed through as a light
// rim. Inset, the edge blends with what is really behind the card.
// `card` must be fully opaque and unscaled while `active` (the region follows
// position and size, not scale or opacity).
Region {
    id: root

    property Item card: null
    property bool active: true

    readonly property int inset: 1
    readonly property bool on: active && card !== null
    // Card position in window coordinates (re-evaluated when it or its parent moves).
    readonly property point origin: {
        card?.x; card?.y; card?.parent?.x; card?.parent?.y;
        return card ? card.mapToItem(null, 0, 0) : Qt.point(0, 0);
    }

    // A corner radius as Qt draws it (unset per-corner radii read as `radius`,
    // and radii are clamped to half the size), minus the inset.
    function corner(r) {
        if (!on)
            return 0;
        return Math.max(0, Math.min(r, card.width / 2, card.height / 2) - inset);
    }

    x: origin.x + inset
    y: origin.y + inset
    width: on ? Math.max(0, card.width - 2 * inset) : 0
    height: on ? Math.max(0, card.height - 2 * inset) : 0
    radius: corner(card?.radius ?? 0)
    topLeftRadius: corner(card?.topLeftRadius ?? 0)
    topRightRadius: corner(card?.topRightRadius ?? 0)
    bottomLeftRadius: corner(card?.bottomLeftRadius ?? 0)
    bottomRightRadius: corner(card?.bottomRightRadius ?? 0)
}

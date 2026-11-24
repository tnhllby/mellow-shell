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
    // Position of the card's parent in the window, when the card is nested.
    property point offset: Qt.point(0, 0)

    readonly property int inset: 1
    readonly property bool on: active && card !== null
    // Card position in window coordinates. Plain x/y, not mapToItem: that
    // includes the card's scale animation and shifted the region.
    readonly property point origin: card ? Qt.point(card.x + offset.x, card.y + offset.y) : Qt.point(0, 0)

    // A corner radius as Qt draws it (unset per-corner radii read as `radius`,
    // and radii are clamped to half the size), minus the inset.
    function corner(r) {
        if (!on)
            return 0;
        return Math.max(0, Math.min(r, (card?.width ?? 0) / 2, (card?.height ?? 0) / 2) - inset);
    }

    x: origin.x + inset
    y: origin.y + inset
    width: on ? Math.max(0, (card?.width ?? 0) - 2 * inset) : 0
    height: on ? Math.max(0, (card?.height ?? 0) - 2 * inset) : 0
    radius: corner(card?.radius ?? 0)
    topLeftRadius: corner(card?.topLeftRadius ?? 0)
    topRightRadius: corner(card?.topRightRadius ?? 0)
    bottomLeftRadius: corner(card?.bottomLeftRadius ?? 0)
    bottomRightRadius: corner(card?.bottomRightRadius ?? 0)
}

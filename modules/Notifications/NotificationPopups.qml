import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.core
import qs.components
import qs.services
import qs.modules.ControlCenter

// Pop-ups for new notifications, below the panel at the right of the monitor
// that was focused. Hovering keeps one open; the rest leave on their own and
// stay in the Control Center. Never takes keyboard focus; the surface stays
// mapped and only the cards receive input.
PanelWindow {
    id: root

    readonly property bool mine: NotificationService.popupMonitor === screen?.name
    readonly property var shown: mine ? NotificationService.popups : []
    // Current cards, for the blur regions.
    property var slots: []
    readonly property int cardWidth: 380

    anchors {
        top: true
        right: true
        bottom: true
    }
    margins.top: Config.panel.height
    margins.right: Config.frame.thickness
    margins.bottom: Config.frame.thickness
    implicitWidth: cardWidth + Theme.spacing.x2
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    mask: Region {
        item: root.shown.length > 0 ? column : null
    }

    component PopupBlur: CardBlurRegion {
        required property int slot
        card: root.slots[slot] ?? null
        // Only settled cards; see CardBlurRegion.
        active: Theme.effects.blurOn && card !== null && card.x === 0 && !card.leaving
        offset: Qt.point(0, column.y)
    }

    BackgroundEffect.blurRegion: Region {
        PopupBlur { slot: 0 }
        PopupBlur { slot: 1 }
        PopupBlur { slot: 2 }
    }

    WlrLayershell.namespace: "mellow:notifications"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
        enabled: root.shown.length > 0
    }

    Column {
        id: column
        y: Theme.spacing.x2
        width: root.cardWidth
        spacing: Theme.spacing.x2

        Repeater {
            model: ScriptModel {
                values: root.shown
            }
            onItemAdded: (index, item) => root.slots = [...root.slots, item]
            onItemRemoved: (index, item) => root.slots = root.slots.filter(i => i !== item)

            NotificationCard {
                id: card

                required property var modelData
                property bool arrived: false
                property bool leaving: false
                // Dismissed by the user, not just timed out.
                property bool dismissed: false

                function leave(dismiss) {
                    dismissed = dismissed || dismiss;
                    leaving = true;
                }

                width: root.cardWidth
                notification: modelData
                now: clock.date
                activeFocusOnTab: false
                color: Theme.glass(Theme.color.surfaceContainerHigh)
                border.width: Theme.cardEdgeWidth
                border.color: Theme.cardEdge(color)

                x: arrived && !leaving ? 0 : root.implicitWidth
                Component.onCompleted: arrived = true
                onXChanged: {
                    if (leaving && x === root.implicitWidth)
                        gone.start();
                }

                onDismissRequested: leave(true)

                Behavior on x {
                    NumberAnimation {
                        duration: Motion.module
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: card.leaving ? Motion.emphasizedAccelerate : Motion.emphasizedDecelerate
                    }
                }

                // Deferred: removing the card from its own handler is unsafe.
                Timer {
                    id: gone
                    interval: 0
                    onTriggered: {
                        const n = card.modelData;
                        NotificationService.hidePopup(n);
                        if (card.dismissed && !n.transient)
                            n.dismiss();
                    }
                }

                HoverHandler {
                    id: hover
                }

                Timer {
                    interval: NotificationService.popupDuration(card.modelData)
                    running: interval > 0 && !hover.hovered && !card.leaving
                    onTriggered: card.leave(false)
                }
            }
        }
    }
}

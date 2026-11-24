import QtQuick
import Quickshell
import qs.core
import qs.components
import qs.services

// Notification center: newest first, with a clear-all button and honest empty
// states (including when another program receives the notifications).
Column {
    id: root

    signal actionInvoked

    spacing: Theme.spacing.x2

    // Keeps keyboard focus in the list when the focused card goes away.
    function dismiss(index, notification) {
        if (cards.itemAt(index)?.activeFocus) {
            const next = cards.itemAt(index + 1) ?? cards.itemAt(index - 1);
            if (next)
                next.forceActiveFocus();
            else
                root.forceActiveFocus();
        }
        notification.dismiss();
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
        enabled: root.visible && ShellState.controlCenterMonitor !== ""
    }

    Item {
        width: parent.width
        height: 40

        MText {
            anchors.verticalCenter: parent.verticalCenter
            role: Typography.titleMedium
            text: "Notifications" + (cards.count > 0 ? "  ·  " + cards.count : "")
        }

        MButton {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            implicitHeight: 32
            variant: "text"
            text: "Clear all"
            visible: cards.count > 0
            onClicked: {
                root.forceActiveFocus();
                NotificationService.clearAll();
            }
        }
    }

    Repeater {
        id: cards
        model: ScriptModel {
            values: NotificationService.list
        }

        NotificationCard {
            required property var modelData
            required property int index
            width: root.width
            notification: modelData
            now: clock.date
            onDismissRequested: root.dismiss(index, modelData)
            onActionInvoked: root.actionInvoked()
        }
    }

    Column {
        width: parent.width
        topPadding: Theme.spacing.x2
        spacing: Theme.spacing.x2
        visible: cards.count === 0

        MaterialIcon {
            anchors.horizontalCenter: parent.horizontalCenter
            icon: NotificationService.active ? "notifications" : "notifications_off"
            size: 28
            color: Theme.color.contentSurfaceVariant
        }

        MText {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            color: Theme.color.contentSurfaceVariant
            text: NotificationService.active ? "No notifications"
                : NotificationService.ownerPid > 0 ? "Another program is receiving notifications. They appear here once it is closed."
                : "Notifications are unavailable."
        }
    }
}

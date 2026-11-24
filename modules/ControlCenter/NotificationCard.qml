import QtQuick
import Quickshell.Services.Notifications
import qs.core
import qs.components
import qs.services

// One notification. Click or Return runs its default action (if it has one);
// the close button or Delete dismisses it; other actions are buttons.
Rectangle {
    id: root

    required property var notification
    property date now
    signal dismissRequested
    signal actionInvoked

    readonly property var defaultAction: NotificationService.defaultAction(notification)
    readonly property bool critical: notification.urgency === NotificationUrgency.Critical

    function activate() {
        if (!defaultAction)
            return;
        defaultAction.invoke();
        actionInvoked();
    }

    implicitHeight: column.implicitHeight + 2 * Theme.spacing.x3
    radius: Theme.shape.lg
    color: Theme.color.surfaceContainerHighest
    activeFocusOnTab: true
    Accessible.role: defaultAction ? Accessible.Button : Accessible.StaticText
    Accessible.name: [notification.appName, notification.summary, notification.body].filter(s => s).join(", ")
    Keys.onReturnPressed: activate()
    Keys.onEnterPressed: activate()
    Keys.onDeletePressed: dismissRequested()

    StateLayer {
        color: Theme.color.contentSurface
        hovered: root.defaultAction !== null && mouse.containsMouse
        pressed: root.defaultAction !== null && mouse.pressed
        focused: root.activeFocus
    }

    FocusRing {
        shown: root.activeFocus
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.defaultAction ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.activate()
    }

    IconBadge {
        id: badge
        x: Theme.spacing.x3
        y: Theme.spacing.x3
        icon: picture.visible ? "" : root.critical ? "priority_high" : "notifications"
        active: root.critical
        color: root.critical ? Theme.color.errorContainer : Theme.color.surfaceContainerHigh
        iconColor: root.critical ? Theme.color.contentErrorContainer : Theme.color.contentSurfaceVariant

        Image {
            id: picture
            anchors.fill: parent
            anchors.margins: Theme.spacing.x2
            source: NotificationService.image(root.notification)
            sourceSize.width: 48
            sourceSize.height: 48
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            visible: status === Image.Ready
        }
    }

    IconButton {
        id: close
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Theme.spacing.x1
        implicitWidth: 32
        implicitHeight: 32
        iconSize: Theme.icon.inline
        icon: "close"
        label: "Dismiss"
        // Delete does the same; keeps Tab moving from card to card.
        activeFocusOnTab: false
        onClicked: root.dismissRequested()
    }

    Column {
        id: column
        anchors.left: badge.right
        anchors.leftMargin: Theme.spacing.x3
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacing.x3
        y: Theme.spacing.x3
        spacing: 2

        MText {
            width: parent.width - close.width
            role: Typography.labelMedium
            color: Theme.color.contentSurfaceVariant
            textFormat: Text.PlainText
            text: [root.critical ? "Urgent" : "", root.notification.appName, NotificationService.age(root.notification, root.now.getTime())].filter(s => s).join("  ·  ")
            visible: text !== ""
        }

        MText {
            width: parent.width - close.width
            role: Typography.labelLarge
            textFormat: Text.PlainText
            text: root.notification.summary
            visible: text !== ""
        }

        MText {
            width: parent.width
            role: Typography.bodyMedium
            color: Theme.color.contentSurfaceVariant
            textFormat: Text.PlainText
            wrapMode: Text.Wrap
            maximumLineCount: 4
            text: root.notification.body
            visible: text !== ""
        }

        Flow {
            width: parent.width
            topPadding: Theme.spacing.x1
            spacing: Theme.spacing.x2
            visible: actions.count > 0

            Repeater {
                id: actions
                model: NotificationService.otherActions(root.notification)

                MButton {
                    required property var modelData
                    implicitHeight: 32
                    variant: "tonal"
                    text: modelData.text
                    onClicked: {
                        modelData.invoke();
                        root.actionInvoked();
                    }
                }
            }
        }
    }
}

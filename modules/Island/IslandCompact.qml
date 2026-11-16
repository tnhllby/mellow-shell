import QtQuick
import Quickshell
import qs.core
import qs.components

// Compact MELLOW Island. In M0 it only has the ambient state (time and date);
// media mode and the expanded player arrive in M2.
Surface {
    id: root

    property real maximumWidth: Infinity

    implicitWidth: Math.min(maximumWidth, content.implicitWidth + 2 * Theme.spacing.x5)
    implicitHeight: 40
    // Asymmetric organic corners give the Island its own silhouette.
    radius: Theme.shape.xl
    topLeftRadius: Theme.shape.organic
    bottomRightRadius: Theme.shape.organic
    color: Theme.color.surfaceContainerHighest
    clip: true

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Row {
        id: content
        anchors.centerIn: parent
        spacing: Theme.spacing.x3

        Rectangle {
            // Ambient marker.
            anchors.verticalCenter: parent.verticalCenter
            width: 8
            height: 8
            radius: Theme.shape.pill
            color: Theme.color.tertiary
        }

        MText {
            anchors.verticalCenter: parent.verticalCenter
            role: Typography.titleMedium
            text: Qt.formatTime(clock.date, Config.clock.timeFormat)
        }

        MText {
            anchors.verticalCenter: parent.verticalCenter
            role: Typography.labelLarge
            color: Theme.color.contentSurfaceVariant
            text: Qt.formatDate(clock.date, Config.clock.dateFormat)
        }
    }
}

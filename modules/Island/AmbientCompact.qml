import QtQuick
import qs.core
import qs.components
import qs.services

// Ambient state: a restrained system summary. Metrics whose source is
// unavailable are left out. A note glyph appears when a paused player can be
// reopened by clicking the Island.
Row {
    id: root

    spacing: Theme.spacing.x4

    component Metric: Row {
        property string icon
        property var value: null
        property string unit: "%"

        visible: value !== null
        spacing: Theme.spacing.x1

        MaterialIcon {
            anchors.verticalCenter: parent.verticalCenter
            icon: parent.icon
            size: 18
            color: Theme.color.tertiary
        }

        MText {
            anchors.verticalCenter: parent.verticalCenter
            role: Typography.labelLarge
            tabular: true
            text: parent.value + parent.unit
        }
    }

    MaterialIcon {
        anchors.verticalCenter: parent.verticalCenter
        icon: "music_note"
        size: 18
        color: Theme.color.primary
        visible: MediaService.activePlayer !== null
        Accessible.name: "Media paused — click to open the player"
    }

    Metric {
        icon: "memory"
        value: SystemStatsService.cpu
        Accessible.name: "CPU load"
    }

    Metric {
        icon: "memory_alt"
        value: SystemStatsService.memory
        Accessible.name: "Memory in use"
    }

    Metric {
        icon: "thermostat"
        value: SystemStatsService.temperature
        unit: "°"
        Accessible.name: "CPU temperature"
    }

    MText {
        anchors.verticalCenter: parent.verticalCenter
        role: Typography.labelLarge
        color: Theme.color.contentSurfaceVariant
        text: "MELLOW"
        visible: SystemStatsService.cpu === null && SystemStatsService.memory === null && SystemStatsService.temperature === null
    }
}

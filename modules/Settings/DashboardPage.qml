import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.core
import qs.components
import qs.services

// Who and what this computer is, its load right now, and problems with
// MELLOW's configuration.
Column {
    id: root

    readonly property var facts: SystemInfoService.facts

    spacing: Theme.spacing.x4
    Component.onCompleted: SystemInfoService.refresh()

    Timer {
        interval: 60000
        repeat: true
        running: true
        onTriggered: SystemInfoService.refresh()
    }

    Surface {
        width: root.width
        height: 136
        radius: Theme.shape.xl
        topLeftRadius: Theme.shape.organic
        bottomRightRadius: Theme.shape.organic
        color: Theme.color.primaryContainer

        ClippingRectangle {
            id: avatar
            x: Theme.spacing.x6
            anchors.verticalCenter: parent.verticalCenter
            width: 88
            height: 88
            radius: Theme.shape.organic
            color: Theme.color.primary

            MText {
                anchors.centerIn: parent
                role: Typography.headlineLarge
                color: Theme.color.contentPrimary
                text: (root.facts.name || SystemInfoService.user).charAt(0).toUpperCase()
                visible: picture.status !== Image.Ready
            }

            Image {
                id: picture
                anchors.fill: parent
                source: root.facts.avatar ? "file://" + root.facts.avatar : ""
                sourceSize.width: 176
                sourceSize.height: 176
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: status === Image.Ready
            }
        }

        Column {
            anchors.left: avatar.right
            anchors.leftMargin: Theme.spacing.x5
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacing.x6
            anchors.verticalCenter: parent.verticalCenter

            MText {
                width: parent.width
                role: Typography.headlineMedium
                color: Theme.color.contentPrimaryContainer
                textFormat: Text.PlainText
                text: root.facts.name || SystemInfoService.user
            }

            MText {
                width: parent.width
                role: Typography.bodyLarge
                color: Theme.color.contentPrimaryContainer
                text: [SystemInfoService.user + (root.facts.host ? "@" + root.facts.host : ""), root.facts.uptime ? "up " + SystemInfoService.duration(Number(root.facts.uptime)) : ""].filter(s => s).join("  ·  ")
            }
        }
    }

    component Meter: Surface {
        property string icon
        property string title
        property string reading
        property real fraction: 0

        height: 112
        radius: Theme.shape.lg
        color: Theme.color.surfaceContainer

        Row {
            x: Theme.spacing.x4
            y: Theme.spacing.x4
            spacing: Theme.spacing.x2

            MaterialIcon {
                icon: parent.parent.icon
                size: Theme.icon.control
                color: Theme.color.primary
            }

            MText {
                anchors.verticalCenter: parent.verticalCenter
                role: Typography.labelLarge
                color: Theme.color.contentSurfaceVariant
                text: parent.parent.title
            }
        }

        MText {
            x: Theme.spacing.x4
            y: 46
            width: parent.width - 2 * x
            role: Typography.titleLarge
            tabular: true
            text: parent.reading
        }

        Rectangle {
            x: Theme.spacing.x4
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.spacing.x4
            width: parent.width - 2 * x
            height: 6
            radius: 3
            color: Theme.color.secondaryContainer

            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, parent.parent.fraction))
                height: parent.height
                radius: parent.radius
                color: Theme.color.primary

                Behavior on width {
                    MotionNumber { duration: Motion.card }
                }
            }
        }
    }

    Grid {
        id: meters

        readonly property var disk: (root.facts.disk ?? "").split(" ").map(Number)
        readonly property real cell: (root.width - Theme.spacing.x3) / 2

        columns: 2
        spacing: Theme.spacing.x3

        Meter {
            width: meters.cell
            icon: "memory"
            title: "Processor"
            reading: SystemStatsService.cpu + "%" + (SystemStatsService.temperature !== null ? "  ·  " + SystemStatsService.temperature + " °C" : "")
            fraction: SystemStatsService.cpu / 100
            visible: SystemStatsService.cpu !== null
        }

        Meter {
            width: meters.cell
            icon: "memory_alt"
            title: "Memory"
            reading: SystemStatsService.memory + "%" + (root.facts.memory ? `  of ${(root.facts.memory / 1048576).toFixed(1)} GiB` : "")
            fraction: SystemStatsService.memory / 100
            visible: SystemStatsService.memory !== null
        }

        Meter {
            width: meters.cell
            icon: "hard_drive"
            title: "Disk"
            reading: `${(meters.disk[0] / 1048576).toFixed(0)} of ${(meters.disk[1] / 1048576).toFixed(0)} GiB`
            fraction: meters.disk[0] / meters.disk[1]
            visible: meters.disk.length === 2 && meters.disk[1] > 0
        }

        Meter {
            width: meters.cell
            icon: PowerService.batteryIcon
            title: "Battery"
            reading: PowerService.percent + "%" + (PowerService.charging ? "  ·  Charging" : PowerService.full ? "  ·  Full" : "")
            fraction: PowerService.percent / 100
            visible: PowerService.hasBattery
        }
    }

    Surface {
        width: root.width
        implicitHeight: list.implicitHeight + 2 * Theme.spacing.x4
        radius: Theme.shape.xl
        color: Theme.color.surfaceContainer

        Column {
            id: list
            x: Theme.spacing.x5
            y: Theme.spacing.x4
            width: parent.width - 2 * x
            spacing: Theme.spacing.x2

            Repeater {
                model: [["System", root.facts.os], ["Kernel", root.facts.kernel], ["Processor", root.facts.cpu]].filter(r => r[1])

                Item {
                    required property var modelData
                    width: list.width
                    height: 28

                    MText {
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.color.contentSurfaceVariant
                        text: parent.modelData[0]
                    }

                    MText {
                        x: 120
                        width: parent.width - x
                        anchors.verticalCenter: parent.verticalCenter
                        textFormat: Text.PlainText
                        text: parent.modelData[1]
                    }
                }
            }
        }
    }

    Surface {
        width: root.width
        implicitHeight: problems.implicitHeight + 2 * Theme.spacing.x4
        radius: Theme.shape.lg
        color: Theme.color.errorContainer
        visible: Config.problems.length > 0

        MText {
            id: problems
            x: Theme.spacing.x5
            y: Theme.spacing.x4
            width: parent.width - 2 * x
            color: Theme.color.contentErrorContainer
            textFormat: Text.PlainText
            wrapMode: Text.Wrap
            text: "config.json\n" + Config.problems.join("\n")
        }
    }
}

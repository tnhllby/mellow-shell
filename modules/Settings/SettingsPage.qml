import QtQuick
import qs.core
import qs.components

// A page of settings from SettingsCatalog: everyday ones, then "Advanced".
Column {
    id: root

    required property var page

    spacing: Theme.spacing.x4

    component Group: Surface {
        id: group

        property string title
        property var rows: []

        width: root.width
        implicitHeight: list.implicitHeight + 2 * Theme.spacing.x3
        radius: Theme.shape.xl
        color: Theme.color.surfaceContainer
        visible: rows.length > 0

        Column {
            id: list
            x: Theme.spacing.x5
            y: Theme.spacing.x3
            width: parent.width - 2 * x

            MText {
                role: Typography.titleMedium
                color: Theme.color.primary
                text: group.title
                visible: text !== ""
            }

            Repeater {
                model: group.rows

                SettingRow {
                    required property var modelData
                    width: list.width
                    row: modelData
                }
            }
        }
    }

    // Theme mode is state, not a config key.
    Surface {
        width: root.width
        implicitHeight: 64
        radius: Theme.shape.xl
        color: Theme.color.surfaceContainer
        visible: root.page.id === "appearance"

        MText {
            x: Theme.spacing.x5
            anchors.verticalCenter: parent.verticalCenter
            role: Typography.bodyLarge
            text: "Dark theme"
        }

        MSwitch {
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacing.x5 + 48
            anchors.verticalCenter: parent.verticalCenter
            checked: ThemeState.dark
            label: "Dark theme"
            onToggled: ThemeState.toggleMode()
        }
    }

    Group {
        rows: root.page.rows.filter(r => !r.advanced)
    }

    Group {
        title: "Advanced"
        rows: root.page.rows.filter(r => r.advanced)
    }
}

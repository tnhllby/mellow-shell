import QtQuick
import Quickshell
import qs.core
import qs.components

// MELLOW's settings: a normal window with the Dashboard and one page per area.
// Changes apply at once and are saved to config.json.
FloatingWindow {
    id: root

    readonly property var page: SettingsCatalog.pages.find(p => p.id === ShellState.settingsPage) ?? SettingsCatalog.pages[0]

    title: "MELLOW Settings"
    implicitWidth: 980
    implicitHeight: 680
    minimumSize: Qt.size(820, 480)
    color: Theme.color.surface
    onClosed: ShellState.settingsOpen = false

    FocusScope {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: ShellState.settingsOpen = false

        Column {
            id: nav
            x: Theme.spacing.x4
            y: Theme.spacing.x6
            width: 208
            spacing: Theme.spacing.x1

            MText {
                x: Theme.spacing.x4
                height: 48
                role: Typography.titleLarge
                text: "Settings"
            }

            Repeater {
                model: SettingsCatalog.pages

                Rectangle {
                    id: item

                    required property var modelData
                    readonly property bool current: modelData.id === root.page.id
                    readonly property color contentColor: current ? Theme.color.contentSecondaryContainer : Theme.color.contentSurfaceVariant

                    width: nav.width
                    height: 44
                    radius: current ? Theme.shape.md : Theme.shape.pill
                    color: current ? Theme.color.secondaryContainer : "transparent"
                    activeFocusOnTab: true
                    Accessible.role: Accessible.PageTab
                    Accessible.name: modelData.title
                    Keys.onReturnPressed: ShellState.settingsPage = modelData.id
                    Keys.onSpacePressed: ShellState.settingsPage = modelData.id

                    Behavior on radius {
                        MotionNumber { duration: Motion.card }
                    }

                    StateLayer {
                        color: item.contentColor
                        hovered: mouse.containsMouse
                        pressed: mouse.pressed
                        focused: item.activeFocus
                    }

                    FocusRing {
                        shown: item.activeFocus
                    }

                    MaterialIcon {
                        x: Theme.spacing.x4
                        anchors.verticalCenter: parent.verticalCenter
                        icon: item.modelData.icon
                        size: Theme.icon.control
                        filled: item.current
                        color: item.contentColor
                    }

                    MText {
                        x: 52
                        anchors.verticalCenter: parent.verticalCenter
                        role: Typography.labelLarge
                        color: item.contentColor
                        text: item.modelData.title
                    }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ShellState.settingsPage = item.modelData.id
                    }
                }
            }
        }

        Flickable {
            id: flick
            anchors.left: nav.right
            anchors.leftMargin: Theme.spacing.x5
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacing.x5
            height: parent.height
            contentHeight: content.implicitHeight + 2 * Theme.spacing.x6
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            Column {
                id: content
                y: Theme.spacing.x6
                width: Math.min(flick.width, 760)
                spacing: Theme.spacing.x4

                MText {
                    height: 48
                    role: Typography.headlineMedium
                    text: root.page.title
                }

                Loader {
                    width: parent.width
                    sourceComponent: root.page.id === "dashboard" ? dashboard : settings
                    onLoaded: flick.contentY = 0
                }

                Component {
                    id: dashboard
                    DashboardPage {}
                }

                Component {
                    id: settings
                    SettingsPage {
                        page: root.page
                    }
                }
            }
        }
    }
}

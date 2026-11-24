import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.core
import qs.components

// System tray: left click activates, middle click runs the second action,
// right click (or left, for menu-only items) opens the app's menu.
Surface {
    id: root

    // The bar's window, parent of the menus.
    required property var window
    property int maxItems: 6
    readonly property var items: SystemTray.items.values.filter(i => i.status !== Status.Passive).slice(0, maxItems)
    property string hoveredLabel: ""
    property real hoveredCenter: 0

    implicitWidth: row.implicitWidth + 2 * Theme.spacing.x2
    implicitHeight: Theme.barPill.height
    radius: Theme.shape.pill
    color: Theme.glass(Theme.color.surfaceContainerHigh)
    visible: items.length > 0

    Row {
        id: row
        anchors.centerIn: parent

        Repeater {
            model: root.items

            Rectangle {
                id: item

                required property var modelData

                width: Theme.barPill.inner
                height: Theme.barPill.inner
                radius: Theme.shape.pill
                color: "transparent"
                Accessible.role: Accessible.Button
                Accessible.name: modelData.tooltipTitle || modelData.title || modelData.id

                function menu() {
                    const at = item.mapToItem(null, 0, item.height);
                    if (modelData.hasMenu)
                        modelData.display(root.window, at.x, Config.panel.height);
                }

                StateLayer {
                    hovered: mouse.containsMouse
                    pressed: mouse.pressed
                }

                IconImage {
                    anchors.centerIn: parent
                    implicitSize: Theme.icon.inline
                    // Named icons missing from the icon theme get a generic one.
                    source: /^image:\/\/icon\/[^?\/]+$/.test(item.modelData.icon)
                        ? Quickshell.iconPath(item.modelData.icon.slice(13), "application-x-executable") : item.modelData.icon
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onContainsMouseChanged: {
                        if (containsMouse) {
                            root.hoveredCenter = item.mapToItem(null, item.width / 2, 0).x;
                            root.hoveredLabel = item.Accessible.name;
                        } else if (root.hoveredLabel === item.Accessible.name) {
                            root.hoveredLabel = "";
                        }
                    }
                    onClicked: event => {
                        if (event.button === Qt.MiddleButton)
                            item.modelData.secondaryActivate();
                        else if (event.button === Qt.RightButton || item.modelData.onlyMenu)
                            item.menu();
                        else
                            item.modelData.activate();
                    }
                }
            }
        }
    }
}

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.core
import qs.components
import qs.services

// Application launcher: a sheet that rises from the bottom edge (Meta).
// Type to search; arrows or Tab move the selection; Enter launches; Escape
// clears the search, then closes. The surface stays mapped (input region and
// keyboard focus only while open), like the Control Center.
PanelWindow {
    id: root

    readonly property bool open: ShellState.launcherMonitor === screen?.name
    property string query: ""
    readonly property var results: query.trim() !== "" ? AppService.search(query)
        : AppService.pinned.concat(AppService.apps.filter(entry => !AppService.pinned.includes(entry)))

    function close() {
        if (open)
            ShellState.launcherMonitor = "";
    }

    function launch(entry) {
        if (!entry)
            return;
        AppService.launch(entry);
        close();
    }

    anchors.bottom: true
    margins.bottom: Config.frame.thickness
    implicitWidth: Math.min(720, (screen?.width ?? 1000) - 2 * Theme.spacing.x8)
    implicitHeight: Math.min(580, (screen?.height ?? 800) - Config.panel.height - 2 * Theme.spacing.x8)
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    mask: Region {
        item: root.open ? sheet : null
    }
    // Only once the sheet has fully slid in, and gone as soon as it closes.
    BackgroundEffect.blurRegion: CardBlurRegion {
        card: sheet
        active: Theme.effects.blurOn && root.open && sheet.y === 0 && sheet.opacity === 1
    }

    WlrLayershell.namespace: "mellow:launcher"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    HyprlandFocusGrab {
        active: root.open
        windows: [root]
        onCleared: root.close()
    }

    onOpenChanged: {
        query = "";
        grid.currentIndex = 0;
        grid.positionViewAtBeginning();
        if (open)
            Qt.callLater(() => search.focusInput());
    }
    onResultsChanged: grid.currentIndex = 0

    Surface {
        id: sheet

        width: parent.width
        height: parent.height - Theme.spacing.x2
        y: root.open ? 0 : parent.height + Theme.spacing.x4
        radius: Theme.shape.xl
        topLeftRadius: Theme.shape.organic
        color: Theme.glass(Theme.color.surfaceContainer)
        opacity: root.open ? 1 : 0
        visible: opacity > 0

        Behavior on y {
            NumberAnimation {
                duration: Motion.card
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.open ? Motion.emphasizedDecelerate : Motion.emphasizedAccelerate
            }
        }
        Behavior on opacity {
            NumberAnimation { duration: Motion.hover }
        }

        FocusScope {
            id: content
            anchors.fill: parent
            anchors.margins: Theme.spacing.x4
            focus: true

            Keys.onEscapePressed: {
                if (root.query !== "")
                    search.text = "";
                else
                    root.close();
            }

            MTextField {
                id: search
                width: parent.width
                height: 52
                radius: Theme.shape.pill
                icon: "search"
                placeholder: "Search apps"
                arrowNavigation: true
                onTextChanged: root.query = text
                onAccepted: root.launch(root.results[grid.currentIndex])
                onNavigate: (dx, dy) => {
                    const next = grid.currentIndex + dx + dy * grid.columns;
                    grid.currentIndex = Math.max(0, Math.min(grid.count - 1, next));
                }
            }

            GridView {
                id: grid

                readonly property int columns: Math.max(3, Math.floor(width / 112))

                anchors.top: search.bottom
                anchors.topMargin: Theme.spacing.x4
                anchors.bottom: parent.bottom
                width: parent.width
                clip: true
                cellWidth: width / columns
                cellHeight: 104
                model: root.results
                boundsBehavior: Flickable.StopAtBounds
                highlightMoveDuration: 0
                keyNavigationEnabled: false

                delegate: Item {
                    id: cell

                    required property DesktopEntry modelData
                    required property int index
                    readonly property bool selected: GridView.isCurrentItem
                    readonly property bool isPinned: root.query === "" && AppService.pinned.includes(modelData)

                    width: grid.cellWidth
                    height: grid.cellHeight
                    Accessible.role: Accessible.Button
                    Accessible.name: modelData.name

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: Theme.spacing.x1
                        radius: cell.selected ? Theme.shape.lg : Theme.shape.md
                        color: cell.selected ? Theme.color.secondaryContainer : "transparent"

                        Behavior on radius {
                            NumberAnimation { duration: Motion.hover }
                        }

                        StateLayer {
                            color: Theme.color.contentSurface
                            hovered: mouse.containsMouse
                            pressed: mouse.pressed
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        width: parent.width - 2 * Theme.spacing.x2
                        spacing: Theme.spacing.x2

                        IconImage {
                            anchors.horizontalCenter: parent.horizontalCenter
                            implicitSize: 48
                            source: Icons.app(cell.modelData.icon)
                        }

                        MText {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            role: Typography.labelMedium
                            color: cell.selected ? Theme.color.contentSecondaryContainer : Theme.color.contentSurface
                            text: cell.modelData.name
                            maximumLineCount: 2
                            wrapMode: Text.Wrap
                        }
                    }

                    MaterialIcon {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: Theme.spacing.x2
                        icon: "keep"
                        size: 14
                        filled: true
                        color: Theme.color.primary
                        visible: cell.isPinned
                    }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.launch(cell.modelData)
                    }
                }

                MText {
                    anchors.centerIn: parent
                    width: parent.width - 2 * Theme.spacing.x8
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    role: Typography.bodyLarge
                    color: Theme.color.contentSurfaceVariant
                    visible: grid.count === 0
                    text: AppService.apps.length === 0 ? "Loading applications…" : `No apps match “${root.query.trim()}”`
                }
            }
        }
    }
}

import QtQuick
import Qt.labs.folderlistmodel
import Quickshell.Widgets
import qs.core
import qs.components

// Wallpaper gallery: folder chips and a scrollable grid of thumbnails.
// Arrow keys move, Return/Space selects.
FocusScope {
    id: root

    property string selected
    property string folder: Paths.expand(Config.wallpaper.folders[0] ?? "~/Pictures")
    signal picked(string path)

    Column {
        anchors.fill: parent
        spacing: Theme.spacing.x3

        SegmentedButton {
            label: "Folder"
            options: Config.wallpaper.folders.map(f => ({ value: Paths.expand(f), label: f.replace(/^~\//, "") }))
            current: root.folder
            onSelected: value => root.folder = value
        }

        GridView {
            id: grid

            readonly property int columns: Math.max(2, Math.floor(width / 176))

            width: parent.width
            height: parent.height - y
            clip: true
            cellWidth: width / columns
            cellHeight: cellWidth * 0.62
            boundsBehavior: Flickable.StopAtBounds
            keyNavigationEnabled: true
            activeFocusOnTab: true
            focus: true

            model: FolderListModel {
                id: files
                folder: "file://" + root.folder
                nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.avif", "*.bmp"]
                caseSensitive: false
                showDirs: false
                sortField: FolderListModel.Time
            }

            delegate: Item {
                id: cell

                required property string filePath
                required property string fileName
                required property int index
                readonly property bool isSelected: filePath === root.selected

                width: grid.cellWidth
                height: grid.cellHeight
                Accessible.role: Accessible.ListItem
                Accessible.name: fileName
                Keys.onReturnPressed: root.picked(filePath)
                Keys.onSpacePressed: root.picked(filePath)

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: Theme.spacing.x1
                    radius: cell.isSelected ? Theme.shape.xl : Theme.shape.md
                    color: Theme.color.surfaceContainerHighest
                    border.width: cell.isSelected ? 3 : 0
                    border.color: Theme.color.primary

                    Behavior on radius {
                        MotionNumber { duration: Motion.card }
                    }

                    ClippingRectangle {
                        anchors.fill: parent
                        anchors.margins: cell.isSelected ? 5 : 0
                        radius: Math.max(0, parent.radius - (cell.isSelected ? 5 : 0))
                        color: "transparent"

                        Image {
                            anchors.fill: parent
                            source: "file://" + cell.filePath
                            sourceSize.width: 320
                            sourceSize.height: 200
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }
                    }

                    StateLayer {
                        radius: parent.radius
                        hovered: cellMouse.containsMouse
                        pressed: cellMouse.pressed
                    }

                    FocusRing {
                        shown: cell.GridView.isCurrentItem && grid.activeFocus
                    }

                    MouseArea {
                        id: cellMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            grid.currentIndex = cell.index;
                            root.picked(cell.filePath);
                        }
                    }
                }
            }

            MText {
                anchors.centerIn: parent
                width: parent.width - 2 * Theme.spacing.x8
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                role: Typography.bodyMedium
                color: Theme.color.contentSurfaceVariant
                text: "No images in " + root.folder + ".\nAdd JPG, PNG or WebP files there."
                visible: files.status === FolderListModel.Ready && files.count === 0
            }
        }
    }
}

import QtQuick
import Quickshell.Widgets
import qs.core
import qs.components

// Live preview of a wallpaper and colour scheme on a miniature MELLOW desktop:
// panel with workspaces, Island and status, the frame, a Control Center card
// and buttons, all drawn with the candidate roles (not the active theme).
ClippingRectangle {
    id: root

    property string source
    property string placement: "fill"
    property var roles: ({})
    property real aspect: 16 / 9

    readonly property ThemeColors c: ThemeColors {
        roles: root.roles
        fallback: ThemeState.fallbackRoles
    }
    readonly property real k: width / 640      // scale of the miniature

    implicitHeight: width / aspect
    radius: Theme.shape.lg
    color: c.surfaceDim

    Image {
        anchors.fill: parent
        source: root.source ? "file://" + root.source : ""
        sourceSize.width: 1280
        fillMode: root.placement === "fit" ? Image.PreserveAspectFit
            : root.placement === "center" ? Image.Pad : Image.PreserveAspectCrop
        asynchronous: true
        retainWhileLoading: true
    }

    // Frame and panel chrome.
    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 22 * root.k
        color: "transparent"
        border.width: 3 * root.k
        border.color: root.c.surfaceContainer
        radius: 10 * root.k
    }

    Rectangle {
        width: parent.width
        height: 22 * root.k
        color: root.c.surfaceContainer

        Row {
            x: 6 * root.k
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3 * root.k

            Repeater {
                model: 3
                Rectangle {
                    required property int index
                    width: (index === 0 ? 18 : 11) * root.k
                    height: 11 * root.k
                    radius: height / 2
                    color: index === 0 ? root.c.primary : root.c.surfaceContainerHighest
                }
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: 120 * root.k
            height: 15 * root.k
            radius: 8 * root.k
            topLeftRadius: 11 * root.k
            bottomRightRadius: 11 * root.k
            color: root.c.surfaceContainerHighest

            Rectangle {
                x: 4 * root.k
                anchors.verticalCenter: parent.verticalCenter
                width: 10 * root.k
                height: 10 * root.k
                radius: 2 * root.k
                color: root.c.secondaryContainer
            }

            Rectangle {
                x: 18 * root.k
                anchors.verticalCenter: parent.verticalCenter
                width: 60 * root.k
                height: 3 * root.k
                radius: height / 2
                color: root.c.contentSurface
            }
        }

        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: 6 * root.k
            anchors.verticalCenter: parent.verticalCenter
            width: 46 * root.k
            height: 13 * root.k
            radius: height / 2
            color: root.c.secondaryContainer
        }
    }

    // Control Center card.
    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: 10 * root.k
        y: 28 * root.k
        width: 170 * root.k
        height: cc.implicitHeight + 16 * root.k
        radius: 14 * root.k
        topRightRadius: 6 * root.k
        color: root.c.surfaceContainer

        Column {
            id: cc
            x: 8 * root.k
            y: 8 * root.k
            width: parent.width - 16 * root.k
            spacing: 5 * root.k

            Text {
                text: "Quick settings"
                color: root.c.contentSurface
                font.family: Typography.family
                font.pixelSize: Math.max(6, 10 * root.k)
            }

            Rectangle {
                width: parent.width
                height: 16 * root.k
                radius: 8 * root.k
                color: root.c.surfaceContainerHighest

                Rectangle {
                    width: parent.width * 0.62
                    height: parent.height
                    radius: parent.radius
                    color: root.c.primary
                }
            }

            Row {
                spacing: 4 * root.k

                Repeater {
                    model: 2
                    Rectangle {
                        required property int index
                        width: (cc.width - 4 * root.k) / 2
                        height: 24 * root.k
                        radius: (index === 0 ? 8 : 12) * root.k
                        color: index === 0 ? root.c.primaryContainer : root.c.surfaceContainerHighest

                        Text {
                            x: 6 * root.k
                            anchors.verticalCenter: parent.verticalCenter
                            text: parent.index === 0 ? "Internet" : "Bluetooth"
                            color: parent.index === 0 ? root.c.contentPrimaryContainer : root.c.contentSurface
                            font.family: Typography.family
                            font.pixelSize: Math.max(5, 8 * root.k)
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 18 * root.k
                radius: 9 * root.k
                topLeftRadius: 13 * root.k
                color: root.c.secondaryContainer

                Text {
                    anchors.centerIn: parent
                    text: "Wallpaper & style"
                    color: root.c.contentSecondaryContainer
                    font.family: Typography.family
                    font.pixelSize: Math.max(5, 8 * root.k)
                }
            }
        }
    }

    // Expanded Island / player card with buttons.
    Rectangle {
        x: 16 * root.k
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16 * root.k
        width: 190 * root.k
        height: 70 * root.k
        radius: 16 * root.k
        topLeftRadius: 22 * root.k
        bottomRightRadius: 22 * root.k
        color: root.c.surfaceContainerHigh

        Rectangle {
            x: 10 * root.k
            anchors.verticalCenter: parent.verticalCenter
            width: 46 * root.k
            height: 46 * root.k
            radius: 10 * root.k
            color: root.c.tertiaryContainer
        }

        Column {
            x: 66 * root.k
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6 * root.k

            Text {
                text: "Now playing"
                color: root.c.contentSurface
                font.family: Typography.family
                font.pixelSize: Math.max(6, 10 * root.k)
            }

            Row {
                spacing: 5 * root.k

                Rectangle {
                    width: 30 * root.k
                    height: 20 * root.k
                    radius: 8 * root.k
                    color: root.c.primary
                }

                Rectangle {
                    width: 58 * root.k
                    height: 20 * root.k
                    radius: 10 * root.k
                    color: root.c.secondaryContainer
                }
            }
        }
    }
}

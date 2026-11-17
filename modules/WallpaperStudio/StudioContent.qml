import QtQuick
import Quickshell
import qs.core
import qs.components
import qs.services

// Wallpaper Studio card: preview and controls on top, gallery below.
FocusScope {
    id: root

    required property string monitorName
    property real aspect: 16 / 9
    signal closeRequested

    // Candidate choices (nothing changes until Apply).
    property string target: "*"
    property string selectedPath: WallpaperService.wallpaperFor(monitorName)?.path ?? ""
    property string placement: WallpaperService.wallpaperFor(monitorName)?.placement ?? "fill"
    // "wallpaper" or a seed colour "#rrggbb".
    property string colorSource: "wallpaper"
    property string previewMode: ThemeState.mode
    property var candidate: null
    property string status: ""
    property int requestId: 0

    readonly property var previewRoles: candidate ? candidate[previewMode]
        : (ThemeState.scheme ? ThemeState.scheme[previewMode] : (previewMode === "dark" ? ColorScheme.dark : ColorScheme.light))
    readonly property var contrast: ColorUtil.check(previewRoles)

    function regenerate() {
        const id = ++requestId;
        const done = (scheme, error) => {
            if (id !== requestId)
                return;
            candidate = scheme;
            status = error;
        };
        status = "Generating colours…";
        if (colorSource === "wallpaper") {
            if (selectedPath)
                WallpaperService.schemeFromImage(selectedPath, done);
            else {
                candidate = null;
                status = "";
            }
        } else {
            WallpaperService.schemeFromSeed(colorSource, done);
        }
    }

    function apply() {
        if (selectedPath)
            WallpaperService.apply(target, selectedPath, placement, candidate);
        else if (candidate)
            ThemeState.setScheme(candidate);
        ThemeState.setMode(previewMode);
    }

    onSelectedPathChanged: regenerate()
    onColorSourceChanged: regenerate()
    Component.onCompleted: {
        regenerate();
        gallery.forceActiveFocus();
    }

    Keys.onEscapePressed: closeRequested()

    ColorQuantizer {
        id: quantizer
        source: root.selectedPath ? "file://" + root.selectedPath : ""
        depth: 3
        rescaleSize: 64
    }

    // Up to four distinct, saturated colours from the wallpaper.
    readonly property var wallpaperSeeds: {
        const colors = quantizer.colors.slice().sort((a, b) => b.hslSaturation - a.hslSaturation);
        const picked = [];
        for (const c of colors) {
            if (c.hslSaturation < 0.15 || picked.some(p => Math.abs(p.hslHue - c.hslHue) < 0.06))
                continue;
            picked.push(c);
            if (picked.length === 4)
                break;
        }
        return picked.map(c => c.toString().slice(0, 7));
    }

    Surface {
        anchors.fill: parent
        radius: Theme.shape.xl
        topLeftRadius: Theme.shape.organic
        color: Theme.color.surfaceContainer

        MouseArea {
            // Swallow clicks so they do not reach the backdrop.
            anchors.fill: parent
        }

        Column {
            anchors.fill: parent
            anchors.margins: Theme.spacing.x6
            spacing: Theme.spacing.x4

            // Header.
            Item {
                width: parent.width
                height: 40

                MText {
                    anchors.verticalCenter: parent.verticalCenter
                    role: Typography.headlineMedium
                    text: "Wallpaper & style"
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacing.x2

                    MButton {
                        text: "Revert"
                        icon: "undo"
                        variant: "tonal"
                        enabled: WallpaperService.canRevert
                        onClicked: WallpaperService.revert()
                    }

                    MButton {
                        text: "Apply"
                        icon: "check"
                        enabled: root.selectedPath !== "" || root.candidate !== null
                        onClicked: root.apply()
                    }

                    IconButton {
                        anchors.verticalCenter: parent.verticalCenter
                        icon: "close"
                        label: "Close"
                        onClicked: root.closeRequested()
                    }
                }
            }

            Row {
                id: top
                width: parent.width
                height: Math.max(preview.height, controls.implicitHeight)
                spacing: Theme.spacing.x6

                ThemePreview {
                    id: preview
                    width: Math.min(parent.width * 0.52, 520)
                    aspect: root.aspect
                    source: root.selectedPath
                    placement: root.placement
                    roles: root.previewRoles
                }

                // Controls.
                Column {
                    id: controls
                    width: parent.width - preview.width - parent.spacing
                    spacing: Theme.spacing.x4

                    Section {
                        title: "Apply to"
                        SegmentedButton {
                            label: "Apply to"
                            options: [{ value: "*", label: "All displays" }].concat(
                                Quickshell.screens.length > 1 ? Quickshell.screens.map(s => ({ value: s.name, label: s.name })) : [])
                            current: root.target
                            onSelected: value => root.target = value
                        }
                    }

                    Section {
                        title: "Placement"
                        SegmentedButton {
                            label: "Placement"
                            options: [{ value: "fill", label: "Fill" }, { value: "fit", label: "Fit" }, { value: "center", label: "Center" }]
                            current: root.placement
                            onSelected: value => root.placement = value
                        }
                    }

                    Section {
                        title: "Colours"
                        Flow {
                            width: parent.width
                            spacing: Theme.spacing.x2

                            SeedChip {
                                label: "From wallpaper"
                                icon: "wallpaper"
                                selected: root.colorSource === "wallpaper"
                                enabled: root.selectedPath !== ""
                                onClicked: root.colorSource = "wallpaper"
                            }

                            Repeater {
                                model: root.wallpaperSeeds.concat(Config.wallpaper.presetSeeds)
                                SeedChip {
                                    required property string modelData
                                    swatch: modelData
                                    label: modelData
                                    selected: root.colorSource.toLowerCase() === modelData.toLowerCase()
                                    onClicked: root.colorSource = modelData
                                }
                            }
                        }
                    }

                    Section {
                        title: "Preview"
                        SegmentedButton {
                            label: "Preview mode"
                            options: [{ value: "dark", label: "Dark" }, { value: "light", label: "Light" }]
                            current: root.previewMode
                            onSelected: value => root.previewMode = value
                        }
                    }

                    // Status: generation, matugen availability and contrast.
                    MText {
                        width: parent.width
                        role: Typography.bodySmall
                        wrapMode: Text.WordWrap
                        color: root.status && root.status !== "Generating colours…" ? Theme.color.error : Theme.color.contentSurfaceVariant
                        text: root.status || (root.contrast.failing.length === 0
                            ? `Text contrast OK — lowest ${root.contrast.lowest.toFixed(1)}:1 (WCAG AA needs 4.5:1)`
                            : "Low contrast: " + root.contrast.failing.join(", "))
                    }

                }
            }

            Gallery {
                id: gallery
                width: parent.width
                height: parent.height - y
                selected: root.selectedPath
                onPicked: path => root.selectedPath = path
            }
        }
    }

    component Section: Column {
        property string title
        width: parent.width
        spacing: Theme.spacing.x2

        MText {
            role: Typography.labelLarge
            color: Theme.color.contentSurfaceVariant
            text: parent.title
        }
    }

    component SeedChip: Rectangle {
        id: chip

        property string label
        property string icon
        property string swatch
        property bool selected: false
        signal clicked

        width: swatch ? 32 : chipRow.implicitWidth + 2 * Theme.spacing.x3
        height: 32
        radius: selected ? Theme.shape.sm : Theme.shape.pill
        color: swatch ? swatch : selected ? Theme.color.secondaryContainer : Theme.color.surfaceContainerHighest
        border.width: selected ? 3 : 0
        border.color: Theme.color.contentSurface
        opacity: enabled ? 1 : 0.38
        activeFocusOnTab: enabled
        Accessible.role: Accessible.RadioButton
        Accessible.name: label
        Accessible.checked: selected
        Keys.onReturnPressed: clicked()
        Keys.onSpacePressed: clicked()

        Behavior on radius {
            NumberAnimation { duration: Motion.hover }
        }

        FocusRing {
            shown: chip.activeFocus
        }

        Row {
            id: chipRow
            anchors.centerIn: parent
            spacing: Theme.spacing.x1
            visible: !chip.swatch

            MaterialIcon {
                anchors.verticalCenter: parent.verticalCenter
                icon: chip.icon
                size: 16
                color: chip.selected ? Theme.color.contentSecondaryContainer : Theme.color.contentSurface
            }

            MText {
                anchors.verticalCenter: parent.verticalCenter
                role: Typography.labelMedium
                color: chip.selected ? Theme.color.contentSecondaryContainer : Theme.color.contentSurface
                text: chip.label
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: chip.enabled
            cursorShape: Qt.PointingHandCursor
            onClicked: chip.clicked()
        }
    }
}

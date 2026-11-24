import QtQuick
import qs.core
import qs.components

// One setting: title, description, a control chosen by its type, and a reset
// button while it differs from the default.
Item {
    id: root

    required property var row
    readonly property string key: row.key
    readonly property var entry: ConfigSchema.entries[key]
    readonly property var value: Config.value(key)
    readonly property bool wide: entry.type === "strings" || (entry.type === "enum" && entry.values.length > 3)

    implicitHeight: Math.max(wide ? head.height + Theme.spacing.x2 + control.height : Math.max(head.height, control.height), 40) + 2 * Theme.spacing.x2

    function label(v) {
        const text = v.replace("scheme-", "").replace(/-/g, " ");
        return text.charAt(0).toUpperCase() + text.slice(1);
    }

    Column {
        id: head
        y: Theme.spacing.x2
        width: root.wide ? root.width - 48 : root.width - 340
        anchors.verticalCenter: root.wide ? undefined : parent.verticalCenter

        MText {
            width: parent.width
            role: Typography.bodyLarge
            text: root.row.title
        }

        MText {
            width: parent.width
            role: Typography.bodySmall
            color: Theme.color.contentSurfaceVariant
            wrapMode: Text.WordWrap
            text: root.row.desc ?? ""
            visible: text !== ""
        }
    }

    IconButton {
        id: reset
        anchors.right: parent.right
        y: root.wide ? 0 : (parent.height - height) / 2
        icon: "undo"
        label: "Reset " + root.row.title
        iconSize: Theme.icon.inline
        visible: Config.overrides[root.key] !== undefined
        onClicked: Config.reset(root.key)
    }

    Loader {
        id: control
        x: root.wide ? 0 : root.width - 48 - width
        y: root.wide ? head.y + head.height + Theme.spacing.x2 : (parent.height - height) / 2
        width: root.wide ? root.width : root.entry.type === "int" || root.entry.type === "string" ? 270 : implicitWidth
        sourceComponent: ({ bool: boolControl, int: intControl, string: stringControl, strings: listControl })[root.entry.type]
            ?? (root.wide ? choiceControl : segmentControl)
    }

    Component {
        id: boolControl

        MSwitch {
            checked: root.value
            label: root.row.title
            onToggled: Config.set(root.key, !root.value)
        }
    }

    Component {
        id: intControl

        ExpressiveSlider {
            readonly property int low: root.entry.min
            readonly property int high: root.row.max ?? root.entry.max
            readonly property int stride: root.row.step ?? 1

            icon: "tune"
            label: root.row.title
            step: Math.max(stride / (high - low), 0.01)
            value: (root.value - low) / (high - low)
            valueText: root.value / (root.row.scale ?? 1) + (root.row.unit ? " " + root.row.unit : "")
            onMoved: v => Config.set(root.key, Math.max(low, Math.min(high, low + Math.round(v * (high - low) / stride) * stride)))
        }
    }

    Component {
        id: segmentControl

        SegmentedButton {
            label: root.row.title
            options: root.entry.values.map(v => ({ value: v, label: root.label(v) }))
            current: root.value
            onSelected: v => Config.set(root.key, v)
        }
    }

    Component {
        id: choiceControl

        Flow {
            spacing: Theme.spacing.x2

            Repeater {
                model: root.entry.values

                MButton {
                    required property string modelData
                    implicitHeight: 36
                    variant: modelData === root.value ? "filled" : "tonal"
                    text: root.label(modelData)
                    onClicked: Config.set(root.key, modelData)
                }
            }
        }
    }

    Component {
        id: stringControl

        MTextField {
            id: field

            text: root.value
            Accessible.name: root.row.title
            onAccepted: {
                if (!Config.set(root.key, text))
                    text = root.value;
            }

            // Typing breaks the binding above.
            Connections {
                target: root

                function onValueChanged() {
                    field.text = root.value;
                }
            }
        }
    }

    Component {
        id: listControl

        Column {
            spacing: Theme.spacing.x1

            Repeater {
                model: root.value

                Rectangle {
                    id: item

                    required property string modelData
                    required property int index

                    width: parent.width
                    height: 40
                    radius: Theme.shape.sm
                    color: Theme.color.surfaceContainerHighest

                    MText {
                        x: Theme.spacing.x3
                        width: parent.width - 56
                        anchors.verticalCenter: parent.verticalCenter
                        textFormat: Text.PlainText
                        text: item.modelData
                    }

                    IconButton {
                        anchors.right: parent.right
                        icon: "close"
                        label: "Remove " + item.modelData
                        iconSize: Theme.icon.inline
                        enabled: root.value.length > (root.entry.minLength ?? 0)
                        onClicked: Config.set(root.key, root.value.filter((v, i) => i !== item.index))
                    }
                }
            }

            MTextField {
                id: add
                width: parent.width
                placeholder: "Add, then press Enter"
                onAccepted: {
                    const next = [...root.value, text.trim()];
                    add.invalid = ConfigSchema.problem(root.key, next) !== "";
                    if (!add.invalid && Config.set(root.key, next))
                        text = "";
                }

                property bool invalid: false
            }

            MText {
                role: Typography.bodySmall
                color: Theme.color.error
                text: "This value is not valid"
                visible: add.invalid
            }
        }
    }
}

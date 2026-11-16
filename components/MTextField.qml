import QtQuick
import qs.core

// Filled Material text field.
Rectangle {
    id: root

    property alias text: input.text
    property alias echoMode: input.echoMode
    property string placeholder
    signal accepted

    function focusInput() {
        input.forceActiveFocus();
    }

    implicitHeight: 44
    radius: Theme.shape.sm
    color: Theme.color.surfaceContainerHighest
    border.width: input.activeFocus ? 2 : 0
    border.color: Theme.color.primary

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: Theme.spacing.x3
        anchors.rightMargin: Theme.spacing.x3
        verticalAlignment: TextInput.AlignVCenter
        color: Theme.color.contentSurface
        selectionColor: Theme.color.primaryContainer
        selectedTextColor: Theme.color.contentPrimaryContainer
        font.family: Typography.family
        font.pixelSize: Typography.bodyLarge.size
        clip: true
        onAccepted: root.accepted()
    }

    MText {
        anchors.fill: input
        role: Typography.bodyLarge
        color: Theme.color.contentSurfaceVariant
        text: root.placeholder
        visible: input.text === ""
    }
}

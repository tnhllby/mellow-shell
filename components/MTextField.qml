import QtQuick
import qs.core

// Filled Material text field.
Rectangle {
    id: root

    property alias text: input.text
    property alias echoMode: input.echoMode
    property string placeholder
    property string icon
    // When true, arrow keys (and Tab) navigate results instead of moving the caret.
    property bool arrowNavigation: false
    signal accepted
    signal navigate(int dx, int dy)

    function focusInput() {
        input.forceActiveFocus();
    }

    implicitHeight: 44
    radius: Theme.shape.sm
    color: Theme.color.surfaceContainerHighest
    border.width: input.activeFocus ? 2 : 0
    border.color: Theme.color.primary

    MaterialIcon {
        id: leading
        x: Theme.spacing.x3
        anchors.verticalCenter: parent.verticalCenter
        icon: root.icon
        size: Theme.icon.control
        color: Theme.color.contentSurfaceVariant
        visible: root.icon !== ""
    }

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: leading.visible ? leading.x + leading.width + Theme.spacing.x3 : Theme.spacing.x3
        anchors.rightMargin: Theme.spacing.x3
        verticalAlignment: TextInput.AlignVCenter
        color: Theme.color.contentSurface
        selectionColor: Theme.color.primaryContainer
        selectedTextColor: Theme.color.contentPrimaryContainer
        font.family: Typography.family
        font.pixelSize: Typography.bodyLarge.size
        clip: true
        onAccepted: root.accepted()

        Keys.priority: Keys.BeforeItem
        Keys.onPressed: event => {
            if (!root.arrowNavigation)
                return;
            const moves = {
                [Qt.Key_Left]: [-1, 0], [Qt.Key_Right]: [1, 0], [Qt.Key_Up]: [0, -1], [Qt.Key_Down]: [0, 1],
                [Qt.Key_Tab]: [1, 0], [Qt.Key_Backtab]: [-1, 0]
            };
            const move = moves[event.key];
            if (move) {
                root.navigate(move[0], move[1]);
                event.accepted = true;
            }
        }
    }

    MText {
        anchors.fill: input
        role: Typography.bodyLarge
        color: Theme.color.contentSurfaceVariant
        text: root.placeholder
        visible: input.text === ""
    }
}

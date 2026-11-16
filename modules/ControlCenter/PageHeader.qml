import QtQuick
import qs.core
import qs.components

// Detail page header: back button, title and an optional switch.
Item {
    id: root

    property string title
    property bool showSwitch: false
    property bool checked: false
    signal back
    signal toggled

    function focusBack() {
        backButton.forceActiveFocus();
    }

    width: parent.width
    height: 40

    IconButton {
        id: backButton
        anchors.verticalCenter: parent.verticalCenter
        icon: "arrow_back"
        label: "Back"
        onClicked: root.back()
    }

    MText {
        anchors.left: backButton.right
        anchors.leftMargin: Theme.spacing.x2
        anchors.verticalCenter: parent.verticalCenter
        role: Typography.titleLarge
        text: root.title
    }

    MSwitch {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        visible: root.showSwitch
        checked: root.checked
        label: root.title
        onToggled: root.toggled()
    }
}

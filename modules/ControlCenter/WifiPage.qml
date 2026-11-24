import QtQuick
import qs.core
import qs.components
import qs.services

// Wi-Fi details: on/off switch and visible networks. Saved and open networks
// connect directly; WPA/WEP personal networks ask for a password inline;
// enterprise networks are listed but need full network settings.
FocusScope {
    id: root

    signal back

    // Network whose password field is open.
    property var passwordFor: null

    onVisibleChanged: {
        passwordFor = null;
        if (visible)
            Qt.callLater(() => header.focusBack());
    }

    function activate(network) {
        if (network.connected) {
            network.disconnect();
        } else if (network.known || NetworkService.isOpen(network)) {
            network.connect();
        } else if (NetworkService.needsPassword(network)) {
            passwordFor = network;
            Qt.callLater(() => password.focusInput());
        }
    }

    function status(network) {
        if (network.stateChanging)
            return network.connected ? "Disconnecting…" : "Connecting…";
        if (network.connected)
            return "Connected";
        if (network.known)
            return "Saved";
        if (!NetworkService.isOpen(network) && !NetworkService.needsPassword(network))
            return "Enterprise — use network settings";
        return "";
    }

    Column {
        id: column
        width: parent.width
        spacing: Theme.spacing.x2

        PageHeader {
            id: header
            title: "Wi-Fi"
            showSwitch: NetworkService.wifiAvailable
            checked: NetworkService.wifiEnabled
            onBack: root.back()
            onToggled: NetworkService.setWifiEnabled(!NetworkService.wifiEnabled)
        }

        MText {
            width: parent.width
            role: Typography.bodyMedium
            color: Theme.color.contentSurfaceVariant
            wrapMode: Text.WordWrap
            text: !NetworkService.wifiAvailable ? "No Wi-Fi adapter available."
                : !NetworkService.wifiEnabled ? "Wi-Fi is off."
                : NetworkService.wifiNetworks.length === 0 ? "Searching for networks…" : ""
            visible: text !== ""
        }

        ListView {
            id: list
            width: parent.width
            height: Math.min(contentHeight, Math.max(120, root.height - y - (passwordForm.visible ? passwordForm.height + column.spacing : 0)))
            clip: true
            spacing: Theme.spacing.x1
            visible: NetworkService.wifiEnabled
            model: NetworkService.wifiNetworks
            boundsBehavior: Flickable.StopAtBounds

            delegate: ListRow {
                required property var modelData
                width: list.width
                icon: NetworkService.signalIcon(modelData)
                title: modelData.name
                subtitle: root.status(modelData)
                trailingIcon: NetworkService.isOpen(modelData) ? "" : "lock"
                highlighted: modelData.connected
                enabled: modelData.connected || modelData.known || NetworkService.isOpen(modelData) || NetworkService.needsPassword(modelData)
                onActivated: root.activate(modelData)
            }
        }

        // Inline password entry for a new protected network.
        Column {
            id: passwordForm
            width: parent.width
            spacing: Theme.spacing.x2
            visible: root.passwordFor !== null

            MText {
                role: Typography.labelLarge
                text: "Password for " + (root.passwordFor?.name ?? "")
            }

            MTextField {
                id: password
                width: parent.width
                echoMode: TextInput.Password
                placeholder: "Password"
                onAccepted: connectButton.clicked()
                Keys.onEscapePressed: root.passwordFor = null
            }

            Row {
                anchors.right: parent.right
                spacing: Theme.spacing.x2

                IconButton {
                    icon: "close"
                    label: "Cancel"
                    onClicked: root.passwordFor = null
                }

                IconButton {
                    id: connectButton
                    icon: "arrow_forward"
                    label: "Connect"
                    variant: "filled"
                    toggled: true
                    enabled: password.text.length > 0
                    onClicked: {
                        root.passwordFor.connectWithPsk(password.text);
                        password.text = "";
                        root.passwordFor = null;
                    }
                }
            }
        }
    }
}

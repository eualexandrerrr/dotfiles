import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kcmutils
import "../lib" as Lib

Lib.DetailPage {
    id: page

    title: qsTr("Wi-Fi")
    switchChecked: page.wifiOn
    emptyText: page.wifiOn ? qsTr("No available networks") : qsTr("Wi-Fi is off")

    footer: Lib.MoreSettingsLink {
        text: qsTr("More Wi-Fi settings")
        onClicked: KCMLauncher.openSystemSettings("kcm_networkmanagement")
    }

    PlasmaNM.Handler { id: handler }
    PlasmaNM.NetworkStatus { id: netStatus }
    PlasmaNM.AvailableDevices { id: availableDevices }
    PlasmaNM.EnabledConnections { id: enabledConnections }

    PlasmaNM.AppletProxyModel {
        id: appletProxyModel
        sourceModel: PlasmaNM.NetworkModel {}
    }

    readonly property bool wifiAvailable: availableDevices.wirelessDeviceAvailable
    readonly property bool wifiOn: wifiAvailable && enabledConnections.wirelessEnabled

    onSwitchToggled: {
        if (wifiAvailable) {
            handler.enableWireless(!wifiOn);
        }
    }

    Component.onCompleted: if (wifiOn) handler.requestScan()

    Timer {
        interval: 10200
        repeat: true
        running: page.wifiOn && page.visible
        onTriggered: handler.requestScan()
    }

    listView.model: appletProxyModel
    listView.spacing: 2

    listView.delegate: Item {
        id: delegate
        width: listView.width
        height: container.height + 2

        readonly property bool predictableWirelessPassword: !Uuid && Type === PlasmaNM.Enums.Wireless &&
            (SecurityType === PlasmaNM.Enums.StaticWep ||
             SecurityType === PlasmaNM.Enums.WpaPsk ||
             SecurityType === PlasmaNM.Enums.Wpa2Psk ||
             SecurityType === PlasmaNM.Enums.SAE)

        property int connectionState: ConnectionState
        property bool expanded: false
        property string phase: "idle"
        property string password: ""
        property bool showPassword: false

        readonly property color subtleBg: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.06)
        readonly property color hoverBg: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
        readonly property color pressBg: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.12)
        readonly property color btnBg: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.05)

        function statusText() {
            if (connectionState === PlasmaNM.Enums.Activated) {
                return SecurityType === PlasmaNM.Enums.NoneSecurity ? qsTr("Connected, open") : qsTr("Connected, secured");
            }
            if (connectionState === PlasmaNM.Enums.Activating || phase === "connecting") {
                return qsTr("Verifying and connecting");
            }
            if (phase === "password") {
                return qsTr("Enter the network security key");
            }
            return "";
        }

        function toggleExpand() {
            if (expanded) {
                expanded = false;
                phase = "idle";
            } else {
                expanded = true;
                phase = (connectionState === PlasmaNM.Enums.Activating) ? "connecting" : "idle";
            }
        }

        function doConnect() {
            if (predictableWirelessPassword) {
                phase = "password";
            } else if (!predictableWirelessPassword && !Uuid) {
                handler.addAndActivateConnection(DevicePath, SpecificPath);
                phase = "connecting";
            } else {
                handler.activateConnection(ConnectionPath, DevicePath, SpecificPath);
                phase = "connecting";
            }
        }

        function doNext() {
            handler.addAndActivateConnection(DevicePath, SpecificPath, password);
            phase = "connecting";
        }

        function doDisconnect() {
            handler.deactivateConnection(ConnectionPath, DevicePath);
            expanded = false;
        }

        onConnectionStateChanged: {
            if (connectionState === PlasmaNM.Enums.Activated) {
                phase = "idle";
            } else if (connectionState === PlasmaNM.Enums.Deactivated && phase === "connecting") {
                phase = "idle";
            }
        }

        Rectangle {
            id: container
            anchors.left: parent.left
            anchors.right: parent.right
            height: contentLayout.implicitHeight
            radius: 4
            color: delegate.expanded ? delegate.subtleBg
                 : (headerMA.containsMouse ? delegate.hoverBg : "transparent")
            Behavior on color { ColorAnimation { duration: Kirigami.Units.shortDuration } }

            ColumnLayout {
                id: contentLayout
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34

                    MouseArea {
                        id: headerMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: delegate.toggleExpand()
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Kirigami.Icon {
                            width: 20
                            height: 20
                            source: model.ConnectionIcon
                            color: Kirigami.Theme.textColor
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            PlasmaComponents3.Label {
                                Layout.fillWidth: true
                                text: model.ItemUniqueName
                                color: Kirigami.Theme.textColor
                                font.pixelSize: 11
                                font.bold: connectionState === PlasmaNM.Enums.Activated
                                elide: Text.ElideRight
                            }

                            PlasmaComponents3.Label {
                                visible: delegate.statusText().length > 0
                                text: delegate.statusText()
                                color: Kirigami.Theme.textColor
                                opacity: 0.5
                                font.pixelSize: 9
                            }
                        }

                        Kirigami.Icon {
                            visible: connectionState === PlasmaNM.Enums.Activated
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            source: "help-about"
                            color: Kirigami.Theme.textColor
                            opacity: infoMA.containsMouse ? 1 : 0.6
                            isMask: true

                            MouseArea {
                                id: infoMA
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: KCMLauncher.openSystemSettings("kcm_networkmanagement")
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: delegate.expanded ? expandedCol.implicitHeight : 0
                    clip: true
                    Behavior on Layout.preferredHeight { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }

                    ColumnLayout {
                        id: expandedCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 0

                        Item { Layout.fillWidth: true; Layout.preferredHeight: 8 }

                        // Idle: Connect button
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            visible: delegate.expanded && delegate.phase === "idle"
                                    && connectionState !== PlasmaNM.Enums.Activated
                                    && connectionState !== PlasmaNM.Enums.Activating

                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 30

                                Rectangle {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 90
                                    height: 30
                                    radius: 4
                                    color: connectBtnMA.containsPress ? delegate.pressBg
                                         : connectBtnMA.containsMouse ? delegate.hoverBg
                                         : delegate.btnBg
                                    Behavior on color { ColorAnimation { duration: 100 } }

                                    PlasmaComponents3.Label {
                                        anchors.centerIn: parent
                                        text: qsTr("Connect")
                                        color: Kirigami.Theme.textColor
                                        font.pixelSize: 11
                                    }

                                    MouseArea {
                                        id: connectBtnMA
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: delegate.doConnect()
                                    }
                                }
                            }
                        }

                        // Password phase
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            visible: delegate.expanded && delegate.phase === "password"

                            PlasmaComponents3.Label {
                                text: qsTr("Enter the network security key")
                                color: Kirigami.Theme.textColor
                                opacity: 0.7
                                font.pixelSize: 10
                            }

                            TextField {
                                id: pwField
                                Layout.fillWidth: true
                                echoMode: delegate.showPassword ? TextInput.Normal : TextInput.Password
                                text: delegate.password
                                onTextEdited: delegate.password = text
                                font.pixelSize: 11
                                placeholderText: qsTr("Password")
                                validator: RegularExpressionValidator {
                                    regularExpression: SecurityType === PlasmaNM.Enums.StaticWep
                                        ? /^(?:.{5}|[0-9a-fA-F]{10}|.{13}|[0-9a-fA-F]{26}){1}$/
                                        : /^(?:.{8,64}){1}$/
                                }
                                onAccepted: if (acceptableInput) delegate.doNext()

                                Item {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 22
                                    height: 22

                                    Kirigami.Icon {
                                        anchors.centerIn: parent
                                        width: 20
                                        height: 20
                                        source: delegate.showPassword ? "view-visible" : "view-hidden"
                                        color: Kirigami.Theme.textColor
                                        isMask: true
                                        opacity: eyeMA.containsMouse ? 1 : 0.6
                                    }

                                    MouseArea {
                                        id: eyeMA
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: delegate.showPassword = !delegate.showPassword
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Item { Layout.fillWidth: true }

                                // Cancel
                                Item {
                                    Layout.preferredWidth: 80
                                    Layout.preferredHeight: 30

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 4
                                        color: cancelBtnMA.containsPress ? delegate.pressBg
                                             : cancelBtnMA.containsMouse ? delegate.hoverBg
                                             : delegate.btnBg
                                        Behavior on color { ColorAnimation { duration: 100 } }

                                        PlasmaComponents3.Label {
                                            anchors.centerIn: parent
                                            text: qsTr("Cancel")
                                            color: Kirigami.Theme.textColor
                                            font.pixelSize: 11
                                        }

                                        MouseArea {
                                            id: cancelBtnMA
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: { delegate.phase = "idle"; delegate.password = ""; }
                                        }
                                    }
                                }

                                // Next (primary)
                                Item {
                                    Layout.preferredWidth: 80
                                    Layout.preferredHeight: 30

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 4
                                        color: nextBtnMA.containsPress ? Qt.darker(Kirigami.Theme.highlightColor, 1.1)
                                             : Kirigami.Theme.highlightColor
                                        opacity: pwField.acceptableInput ? 1 : 0.4
                                        Behavior on color { ColorAnimation { duration: 100 } }

                                        PlasmaComponents3.Label {
                                            anchors.centerIn: parent
                                            text: qsTr("Next")
                                            color: "#FFFFFF"
                                            font.pixelSize: 11
                                        }

                                        MouseArea {
                                            id: nextBtnMA
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: if (pwField.acceptableInput) delegate.doNext()
                                        }
                                    }
                                }
                            }
                        }

                        // Connecting phase
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            visible: delegate.expanded && delegate.phase === "connecting"

                            PlasmaComponents3.Label {
                                text: qsTr("Verifying and connecting")
                                color: Kirigami.Theme.textColor
                                opacity: 0.7
                                font.pixelSize: 10
                            }

                            PlasmaComponents3.ProgressBar {
                                Layout.fillWidth: true
                                indeterminate: true
                            }
                        }

                        // Connected phase
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            visible: delegate.expanded && connectionState === PlasmaNM.Enums.Activated

                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 30

                                Rectangle {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 100
                                    height: 30
                                    radius: 4
                                    color: discBtnMA.containsPress ? delegate.pressBg
                                         : discBtnMA.containsMouse ? delegate.hoverBg
                                         : delegate.btnBg
                                    Behavior on color { ColorAnimation { duration: 100 } }

                                    PlasmaComponents3.Label {
                                        anchors.centerIn: parent
                                        text: qsTr("Disconnect")
                                        color: Kirigami.Theme.textColor
                                        font.pixelSize: 11
                                    }

                                    MouseArea {
                                        id: discBtnMA
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: delegate.doDisconnect()
                                    }
                                }
                            }
                        }

                        Item { Layout.fillWidth: true; Layout.preferredHeight: 8 }
                    }
                }
            }
        }
    }
}

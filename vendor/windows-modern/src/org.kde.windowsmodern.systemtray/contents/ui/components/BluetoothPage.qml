import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.bluezqt as BluezQt
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kcmutils
import "../lib" as Lib

Lib.DetailPage {
    id: page

    title: qsTr("Bluetooth")
    switchChecked: page.btOn
    emptyText: page.btOn ? qsTr("No devices paired") : qsTr("Bluetooth is off")

    footer: Lib.MoreSettingsLink {
        text: qsTr("More Bluetooth settings")
        onClicked: KCMLauncher.openSystemSettings("kcm_bluetooth")
    }

    readonly property QtObject btManager: BluezQt.Manager
    readonly property bool btOn: btManager.bluetoothOperational

    function toggleBluetooth() {
        var enable = !btManager.bluetoothOperational;
        btManager.bluetoothBlocked = !enable;
        for (var i = 0; i < btManager.adapters.length; ++i) {
            btManager.adapters[i].powered = enable;
        }
    }

    onSwitchToggled: page.toggleBluetooth()

    listView.header: PlasmaComponents3.Button {
        width: listView.width
        height: 32
        text: qsTr("Add new device")
        icon.name: "list-add"
        flat: true
        visible: page.btOn

        onClicked: bluetoothExec.exec("bluedevil-wizard")
    }

    Plasma5Support.DataSource {
        id: bluetoothExec
        engine: "executable"
        connectedSources: []
        onNewData: function (sourceName, data) {
            disconnectSource(sourceName);
        }
        function exec(cmd) {
            connectSource(cmd);
        }
    }

    listView.model: btManager.devices
    listView.delegate: Item {
        width: listView.width
        height: 34

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 4
            color: ma.containsMouse ? Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08) : "transparent"

            MouseArea {
                id: ma
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (modelData.connected) {
                        modelData.disconnectFromDevice();
                    } else {
                        modelData.connectToDevice();
                    }
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 8

                Kirigami.Icon {
                    width: 20
                    height: 20
                    source: modelData.icon || "bluetooth"
                    color: Kirigami.Theme.textColor
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    PlasmaComponents3.Label {
                        Layout.fillWidth: true
                        text: modelData.name
                        color: Kirigami.Theme.textColor
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }

                    PlasmaComponents3.Label {
                        text: modelData.connected ? qsTr("Connected") : qsTr("Disconnected")
                        color: Kirigami.Theme.textColor
                        opacity: modelData.connected ? 0.5 : 0.3
                        font.pixelSize: 9
                    }
                }
            }
        }
    }
}

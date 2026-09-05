/*
    DeviceNotifierPage — Win11-styled removable device flyout.

    Uses the plasma5support "soliddevice" dataengine for device list and
    details, and "hotplug" engine for removable device detection.
    Mount/unmount via the soliddevice engine's DeviceAction interface.
*/
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kcmutils
import "../lib" as Lib

Lib.Page {
    id: page

    title: qsTr("Devices")
    contentFillsHeight: false

    footer: Lib.MoreSettingsLink {
        text: qsTr("More device settings")
        onClicked: KCMLauncher.openSystemSettings("kcm_removabledevices")
    }

    // Hotplug engine — lists removable/hotplug device UDIs
    Plasma5Support.DataSource {
        id: hotplugEngine
        engine: "hotplug"
        connectedSources: sources
        interval: 0

        onSourceAdded: connectSource(source)
        onSourceRemoved: disconnectSource(source)
        onNewData: page._refreshDevices()
    }

    // Solid device engine — query device details per UDI
    Plasma5Support.DataSource {
        id: solidEngine
        engine: "soliddevice"
        connectedSources: []
        interval: 0

        onNewData: page._refreshDevices()
    }

    property var deviceList: []

    function _refreshDevices() {
        var udis = hotplugEngine.sources
        var connected = []
        for (var i = 0; i < udis.length; i++) {
            var udi = udis[i]
            var data = solidEngine.data[udi]
            if (!data) continue
            // Only show devices with storage predicate
            if (data["Removable"] === true || data["Hotplug"] === true) {
                connected.push({
                    udi: udi,
                    description: data["Description"] || data["Product"] || qsTr("Removable device"),
                    icon: data["Icon"] || "drive-removable-media",
                    mounted: data["Mounted"] === true,
                    vendor: data["Vendor"] || "",
                    product: data["Product"] || ""
                })
            }
        }
        page.deviceList = connected
    }

    function _mountDevice(udi) {
        solidEngine.connectSource(udi)
        solidEngine.executeCommand(udi, "invokeAction", ["mount"])
    }

    function _unmountDevice(udi) {
        solidEngine.connectSource(udi)
        solidEngine.executeCommand(udi, "invokeAction", ["unmount"])
    }

    Component.onCompleted: {
        // Connect all hotplug sources so we get their data
        var sources = hotplugEngine.sources
        for (var i = 0; i < sources.length; i++) {
            solidEngine.connectSource(sources[i])
        }
        page._refreshDevices()
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 0

        Repeater {
            model: page.deviceList
            Layout.fillWidth: true

            delegate: Item {
                width: page.width
                height: 42

                Rectangle {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    radius: 4
                    color: ma.containsMouse
                        ? Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
                        : "transparent"

                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Kirigami.Icon {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            source: modelData.icon
                            color: Kirigami.Theme.textColor
                            isMask: true
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            PlasmaComponents3.Label {
                                Layout.fillWidth: true
                                text: modelData.description
                                color: Kirigami.Theme.textColor
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }

                            PlasmaComponents3.Label {
                                text: modelData.mounted ? qsTr("Mounted") : qsTr("Not mounted")
                                color: Kirigami.Theme.textColor
                                opacity: 0.4
                                font.pixelSize: 9
                            }
                        }

                        // Mount/Unmount button
                        Item {
                            Layout.preferredWidth: 28
                            Layout.preferredHeight: 28

                            Kirigami.Icon {
                                anchors.centerIn: parent
                                width: 18
                                height: 18
                                source: modelData.mounted ? "media-eject" : "document-open"
                                color: Kirigami.Theme.textColor
                                isMask: true
                                opacity: btnMA.containsMouse ? 1 : 0.6
                            }

                            MouseArea {
                                id: btnMA
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (modelData.mounted)
                                        page._unmountDevice(modelData.uid || modelData.udi)
                                    else
                                        page._mountDevice(modelData.udi)
                                }
                            }
                        }
                    }
                }
            }
        }

        PlasmaComponents3.Label {
            Layout.fillWidth: true
            Layout.topMargin: 10
            text: qsTr("No devices connected")
            color: Kirigami.Theme.textColor
            opacity: 0.5
            font.pixelSize: 11
            visible: page.deviceList.length === 0
            horizontalAlignment: Text.AlignHCenter
        }
    }
}

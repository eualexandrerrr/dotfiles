import QtQuick
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.networkmanagement as PlasmaNM
import "../lib" as Lib

Lib.SplitTile {
    id: tile

    PlasmaNM.Handler {
        id: handler
    }
    PlasmaNM.EnabledConnections {
        id: enabledConnections
    }
    PlasmaNM.AvailableDevices {
        id: availableDevices
    }
    PlasmaNM.ConnectionIcon {
        id: activeConnectionIcon
    }
    PlasmaNM.NetworkStatus {
        id: netStatus
    }

    readonly property bool wifiAvailable: availableDevices.wirelessDeviceAvailable
    readonly property bool wifiOn: wifiAvailable && enabledConnections.wirelessEnabled

    label: qsTr("Wi-Fi")
    iconSource: {
        var base = activeConnectionIcon.connectionIcon;
        if (!wifiOn)
            return base;
        if (base.indexOf("network-wireless") === 0)
            return "network-wireless-100";
        if (base.indexOf("network-mobile") === 0)
            return "network-mobile-100";
        return base;
    }
    active: wifiOn

    onClicked: {
        if (wifiAvailable) {
            handler.enableWireless(!wifiOn);
        }
    }

    tooltipText: wifiOn ? qsTr("Wi-Fi — On") : qsTr("Wi-Fi — Off")

    onRightClicked: networkMenu.popup()

    onMiddleClicked: Qt.openUrlExternally("systemsettings://kcm_networkmanagement")

    PlasmaComponents3.Menu {
        id: networkMenu

        PlasmaComponents3.MenuItem {
            text: qsTr("Open Wi-Fi settings")
            icon.name: "configure"
            onClicked: Qt.openUrlExternally("systemsettings://kcm_networkmanagement")
        }
        PlasmaComponents3.MenuItem {
            text: qsTr("Create hotspot…")
            icon.name: "network-wireless-hotspot"
            onClicked: handler.createHotspot()
        }
        PlasmaComponents3.MenuItem {
            text: qsTr("Connect to hidden network…")
            icon.name: "network-wireless-secure"
            onClicked: handler.addAndActivateConnection("")
        }
        PlasmaComponents3.MenuItem {
            text: qsTr("Known networks…")
            icon.name: "preferences-system-network"
            onClicked: Qt.openUrlExternally("systemsettings://kcm_networkmanagement")
        }
    }
}

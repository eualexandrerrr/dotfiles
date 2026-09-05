import QtQuick
import org.kde.plasma.networkmanagement as PlasmaNM
import "../lib" as Lib

Lib.Tile {
    id: tile

    PlasmaNM.Handler {
        id: handler
    }

    readonly property bool hotspotSupported: handler.hotspotSupported
    property bool hotspotActive: false

    label: qsTr("Hotspot")
    iconSource: "network-wireless-hotspot"
    active: hotspotActive
    visible: hotspotSupported

    onClicked: {
        if (hotspotActive) {
            handler.stopHotspot();
            hotspotActive = false;
        } else {
            handler.createHotspot();
            hotspotActive = true;
        }
    }

    tooltipText: hotspotActive ? qsTr("Hotspot — On") : qsTr("Hotspot — Off")
}

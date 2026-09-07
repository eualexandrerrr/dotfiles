import QtQuick
import org.kde.plasma.networkmanagement as PlasmaNM
import "../lib" as Lib

Lib.Tile {
    id: tile

    PlasmaNM.Handler {
        id: handler
    }

    label: qsTr("Airplane")
    iconSource: "network-flightmode-on-symbolic"
    active: PlasmaNM.Configuration.airplaneModeEnabled

    onClicked: {
        var enable = !PlasmaNM.Configuration.airplaneModeEnabled;
        handler.enableAirplaneMode(enable);
        PlasmaNM.Configuration.airplaneModeEnabled = enable;
    }

    tooltipText: active ? qsTr("Airplane Mode — On") : qsTr("Airplane Mode — Off")
}

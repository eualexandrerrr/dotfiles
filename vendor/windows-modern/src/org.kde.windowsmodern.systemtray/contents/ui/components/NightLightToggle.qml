import QtQuick
import org.kde.plasma.private.brightnesscontrolplugin
import org.kde.plasma.workspace.dbus as DBus
import "../lib" as Lib

Lib.Tile {
    id: tile

    label: qsTr("Night Light")
    iconSource: {
        if (!nightLight.available)
            return "redshift-status-off-symbolic";
        if (!nightLight.running || nightLight.inhibited)
            return "redshift-status-off-symbolic";
        return "redshift-status-on-symbolic";
    }
    active: nightLight.running && !nightLight.inhibited

    onClicked: NightLightInhibitor.toggleInhibition()

    tooltipText: {
        if (!nightLight.available)
            return qsTr("Night Light — Unavailable");
        if (active)
            return qsTr("Night Light — On");
        return qsTr("Night Light — Off");
    }

    DBus.Properties {
        id: nightLight
        busType: DBus.BusType.Session
        service: "org.kde.KWin.NightLight"
        path: "/org/kde/KWin/NightLight"
        iface: "org.kde.KWin.NightLight"

        readonly property bool available: Boolean(properties.available)
        readonly property bool running: Boolean(properties.running)
        readonly property bool enabled: Boolean(properties.enabled)
        readonly property bool inhibited: NightLightInhibitor.inhibited
    }
}

import QtQuick
import org.kde.plasma.workspace.dbus as DBus
import "../lib" as Lib

Lib.Tile {
    id: tile

    property bool touchpadEnabled: true

    label: touchpadEnabled ? qsTr("Touchpad On") : qsTr("Touchpad Off")
    iconSource: "input-touchpad"
    active: !touchpadEnabled

    function _checkState() {
        var reply = DBus.SessionBus.asyncCall({
            service: "org.kde.touchpad",
            path: "/org/kde/touchpad",
            iface: "org.kde.touchpad",
            member: "enabled"
        });
    }

    onClicked: {
        DBus.SessionBus.asyncCall({
            service: "org.kde.touchpad",
            path: "/org/kde/touchpad",
            iface: "org.kde.touchpad",
            member: "setEnabled",
            arguments: [!touchpadEnabled]
        });
        touchpadEnabled = !touchpadEnabled;
    }

    tooltipText: touchpadEnabled ? qsTr("Touchpad — Enabled") : qsTr("Touchpad — Disabled")
}

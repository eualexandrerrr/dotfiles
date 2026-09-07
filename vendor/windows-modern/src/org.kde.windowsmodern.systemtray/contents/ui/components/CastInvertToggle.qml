import QtQuick
import org.kde.plasma.workspace.dbus as DBus
import "../lib" as Lib

Lib.Tile {
    id: tile

    label: qsTr("Invert Colors")
    iconSource: "preferences-desktop-effects"
    active: false

    onClicked: {
        DBus.SessionBus.asyncCall({
            service: "org.kde.KWin",
            path: "/Effects",
            iface: "org.kde.kwin.Effects",
            member: "toggleEffect",
            arguments: ["invert"]
        });
    }

    tooltipText: qsTr("Invert Colors — Toggle")
}

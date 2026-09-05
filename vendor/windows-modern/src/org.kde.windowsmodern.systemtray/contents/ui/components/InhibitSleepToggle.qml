import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support
import "../lib" as Lib

Lib.Tile {
    id: tile

    label: blockSleep ? qsTr("Sleep Blocked") : qsTr("No Sleep")
    iconSource: blockSleep ? "system-suspend-inhibited" : "system-suspend-uninhibited"
    active: blockSleep

    readonly property string blockerName: "WindowsModernQuickSettings"

    property bool blockSleep: false
    property bool initialized: false

    Plasma5Support.DataSource {
        id: inhibitorCheck
        engine: "executable"
        connectedSources: []
        interval: 3000
        onNewData: function (sourceName, data) {
            var output = data["stdout"] || "";
            tile.blockSleep = output.includes(tile.blockerName);
            if (!tile.initialized)
                tile.initialized = true;
        }
        function check(cmd) {
            if (connectedSources.indexOf(cmd) === -1)
                connectSource(cmd);
        }
    }

    Plasma5Support.DataSource {
        id: execOnce
        engine: "executable"
        connectedSources: []
        onNewData: function (sourceName, data) {
            disconnectSource(sourceName);
        }
        function run(cmd) {
            connectSource(cmd);
        }
    }

    Component.onCompleted: inhibitorCheck.check("systemd-inhibit --list --no-legend")

    onClicked: {
        if (tile.blockSleep) {
            execOnce.run("pkill -f " + tile.blockerName);
            tile.blockSleep = false;
        } else {
            execOnce.run("systemd-inhibit --what=idle:sleep --who=\"" + tile.blockerName + "\" --why=\"Inhibited by user\" sleep infinity &");
            tile.blockSleep = true;
        }
    }

    tooltipText: blockSleep ? qsTr("Sleep Inhibited") : qsTr("Sleep Allowed")
}

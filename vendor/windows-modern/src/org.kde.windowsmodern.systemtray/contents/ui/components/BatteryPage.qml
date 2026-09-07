import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.private.battery
import org.kde.plasma.private.batterymonitor
import org.kde.kirigami as Kirigami
import org.kde.kcmutils
import "../lib" as Lib

Lib.Page {
    id: page

    title: qsTr("Battery")

    BatteryControlModel {
        id: batteryControl
    }

    PowerProfilesControl {
        id: powerProfiles
    }

    readonly property string percent: batteryControl.percent + "%"
    readonly property bool isCharging: batteryControl.state === BatteryControlModel.Charging || batteryControl.state === BatteryControlModel.FullyCharged
    readonly property bool isFull: batteryControl.state === BatteryControlModel.FullyCharged

    property string timeLeft: ""
    property string health: "--"
    property bool blockSleep: false

    readonly property string blockerName: "WindowsModernQuickSettings"

    Plasma5Support.DataSource {
        id: healthSrc
        engine: "executable"
        connectedSources: []
        interval: 60000
        onNewData: function (sourceName, data) {
            var output = (data["stdout"] || "").trim();
            var h = parseFloat(output);
            if (!isNaN(h))
                page.health = (h > 100 ? 100 : h).toFixed(0) + "%";
        }
        function get(cmd) {
            connectSource(cmd);
        }
    }

    Plasma5Support.DataSource {
        id: inhibitorCheck
        engine: "executable"
        connectedSources: []
        interval: 3000
        onNewData: function (sourceName, data) {
            var output = data["stdout"] || "";
            page.blockSleep = output.includes(page.blockerName);
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

    Component.onCompleted: {
        page._updateTime();
        healthSrc.get("upower -i $(upower -e | grep battery | head -n 1) | awk '/capacity/ {print $2}' | tr -d ' %' | tr ',' '.'");
        inhibitorCheck.check("systemd-inhibit --list --no-legend");
    }

    function _updateTime() {
        const remaining = batteryControl.remainingMsec;
        if (remaining && remaining > 0) {
            const h = Math.floor(remaining / 3600000);
            const m = Math.floor((remaining % 3600000) / 60000);
            page.timeLeft = h + "h " + m + "m";
        } else {
            page.timeLeft = "";
        }
    }

    function _toggleBlockSleep() {
        if (page.blockSleep) {
            execOnce.run("pkill -f " + page.blockerName);
            page.blockSleep = false;
        } else {
            execOnce.run("systemd-inhibit --what=idle:sleep --who=\"" + page.blockerName + "\" --why=\"Inhibited by user\" sleep infinity &");
            page.blockSleep = true;
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8

        PlasmaComponents3.Label {
            text: page.isFull ? qsTr("Fully charged") : page.isCharging ? qsTr("Charging") : qsTr("Discharging")
            font.pixelSize: 10
            opacity: 0.6
            color: Kirigami.Theme.textColor
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Kirigami.Icon {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                source: page.isCharging ? "battery-100-charging" : "battery-100"
            }

            PlasmaComponents3.Label {
                text: page.percent
                font.pixelSize: 22
                font.weight: Font.DemiBold
                color: Kirigami.Theme.textColor
            }

            Item {
                Layout.fillWidth: true
            }

            PlasmaComponents3.Label {
                visible: page.timeLeft.length > 0 && !page.isFull
                text: page.timeLeft
                font.pixelSize: 10
                opacity: 0.5
                color: Kirigami.Theme.textColor
            }
        }

        PlasmaComponents3.ProgressBar {
            Layout.fillWidth: true
            from: 0
            to: 100
            value: batteryControl.percent
        }

        RowLayout {
            Layout.fillWidth: true
            visible: page.health !== "--"

            PlasmaComponents3.Label {
                text: qsTr("Battery health")
                font.pixelSize: 9
                opacity: 0.5
                color: Kirigami.Theme.textColor
            }

            Item {
                Layout.fillWidth: true
            }

            PlasmaComponents3.Label {
                text: page.health
                font.pixelSize: 9
                font.weight: Font.DemiBold
                color: {
                    var h = parseFloat(page.health);
                    if (isNaN(h))
                        return Kirigami.Theme.textColor;
                    if (h >= 90)
                        return "#4ade80";
                    if (h >= 70)
                        return "#a3e635";
                    if (h >= 50)
                        return "#facc15";
                    return "#f87171";
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: 2
            Layout.bottomMargin: 2
            height: 1
            color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.12)
        }

        Lib.SectionHeader {
            text: qsTr("Power Profiles")
        }

        Repeater {
            model: powerProfiles.profiles

            delegate: Lib.ListRow {
                Layout.fillWidth: true
                text: {
                    switch (modelData) {
                    case "performance":
                        return qsTr("Performance");
                    case "balanced":
                        return qsTr("Balanced");
                    case "power-saver":
                        return qsTr("Power Saver");
                    default:
                        return modelData;
                    }
                }
                iconSource: {
                    switch (modelData) {
                    case "performance":
                        return "emblem-favorite";
                    case "balanced":
                        return "emblem-ok";
                    case "power-saver":
                        return "battery-low";
                    default:
                        return "";
                    }
                }
                selected: powerProfiles.activeProfile === modelData
                onClicked: powerProfiles.setProfile(modelData)
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: 2
            Layout.bottomMargin: 2
            height: 1
            color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.12)
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Kirigami.Icon {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                source: page.blockSleep ? "system-suspend-inhibited" : "system-suspend-uninhibited"
            }

            PlasmaComponents3.Label {
                text: qsTr("Block sleep & screen lock")
                font.pixelSize: 12
                color: Kirigami.Theme.textColor
            }

            Item {
                Layout.fillWidth: true
            }

            PlasmaComponents3.Switch {
                checked: page.blockSleep
                onToggled: page._toggleBlockSleep()
            }
        }
    }

    footer: Lib.MoreSettingsLink {
        text: qsTr("Power settings")
        onClicked: Qt.openUrlExternally("systemsettings://kcm_powerdevilprofilesconfig")
    }
}

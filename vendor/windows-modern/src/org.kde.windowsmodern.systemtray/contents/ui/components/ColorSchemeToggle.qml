import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami
import "../lib" as Lib
import "../js/colorType.js" as ColorType

Lib.Tile {
    id: tile

    property bool darkMode: ColorType.isDark(Kirigami.Theme.backgroundColor)

    label: darkMode ? qsTr("Dark Mode") : qsTr("Light Mode")
    iconSource: darkMode ? "weather-clear-night-symbolic" : "weather-clear-symbolic"
    active: false

    onClicked: {
        var target = darkMode ? Plasmoid.configuration.lightTheme : Plasmoid.configuration.darkTheme;
        darkMode = !darkMode;
        colorschemeExec.exec("plasma-apply-lookandfeel --apply " + target);
    }

    onMiddleClicked: {
        darkMode = !darkMode;
        var target = darkMode ? Plasmoid.configuration.darkTheme : Plasmoid.configuration.lightTheme;
        colorschemeExec.exec("plasma-apply-lookandfeel --apply " + target);
    }

    tooltipText: darkMode ? qsTr("Switch to light mode") : qsTr("Switch to dark mode")

    Plasma5Support.DataSource {
        id: colorschemeExec
        engine: "executable"
        connectedSources: []
        onNewData: function (sourceName, data) {
            disconnectSource(sourceName);
        }
        function exec(cmd) {
            connectSource(cmd);
        }
    }
}

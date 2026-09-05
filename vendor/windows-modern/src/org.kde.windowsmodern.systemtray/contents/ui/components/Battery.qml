import QtQuick
import org.kde.plasma.private.battery
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import "../js/funcs.js" as Funcs

Item {
    id: root

    property alias hasBattery: batteryControl.hasBatteries
    property alias percent: batteryControl.percent
    property alias pluggedIn: batteryControl.pluggedIn

    implicitWidth: row.implicitWidth
    implicitHeight: 16

    BatteryControlModel {
        id: batteryControl
    }

    Row {
        id: row
        anchors.fill: parent
        spacing: 3

        Kirigami.Icon {
            width: 20
            height: 20
            anchors.verticalCenter: parent.verticalCenter
            source: Funcs.batteryIconName(batteryControl.percent, batteryControl.state === BatteryControlModel.Charging)
            color: Kirigami.Theme.textColor
            isMask: true
        }

        PlasmaComponents3.Label {
            visible: root.hasBattery
            text: batteryControl.percent + "%"
            color: Kirigami.Theme.textColor
            opacity: 0.8
            font.pixelSize: 10
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3

Page {
    id: page

    showSwitch: true

    property alias listView: list
    property alias emptyText: emptyLabel.text

    ListView {
        id: list
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 0
        boundsBehavior: Flickable.StopAtBounds
    }

    PlasmaComponents3.Label {
        id: emptyLabel
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: list.count === 0
        color: Kirigami.Theme.textColor
        opacity: 0.5
        font.pixelSize: 11
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}

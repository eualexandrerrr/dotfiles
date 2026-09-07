import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3

RowLayout {
    id: header

    property string title
    property bool showSwitch: false
    property bool switchChecked: false

    signal back
    signal switchToggled

    Layout.fillWidth: true
    Layout.preferredHeight: 32
    Layout.leftMargin: 10
    Layout.rightMargin: 10
    Layout.bottomMargin: 8
    spacing: 6

    Item {
        width: 20
        height: 20
        Layout.alignment: Qt.AlignVCenter

        Kirigami.Icon {
            anchors.centerIn: parent
            width: 20
            height: 20
            source: "go-previous"
            color: Kirigami.Theme.textColor
            isMask: true
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: header.back()
        }
    }

    PlasmaComponents3.Label {
        text: header.title
        color: Kirigami.Theme.textColor
        font.pixelSize: 12
        font.weight: Font.DemiBold
        Layout.fillWidth: true
    }

    PlasmaComponents3.Switch {
        visible: header.showSwitch
        checked: header.switchChecked
        onToggled: header.switchToggled()
        Layout.alignment: Qt.AlignVCenter
    }
}

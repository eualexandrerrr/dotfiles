import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3

Item {
    id: root

    property string text
    property string kcm

    signal clicked

    implicitHeight: 42
    implicitWidth: parent ? parent.width : 200

    PlasmaComponents3.Label {
        anchors.centerIn: parent
        text: root.text
        color: ma.containsMouse ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
        opacity: ma.containsMouse ? 1 : 0.6
        font.pixelSize: 11
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}

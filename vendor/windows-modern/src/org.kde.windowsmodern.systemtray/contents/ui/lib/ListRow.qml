import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3

Item {
    id: row

    property string iconSource
    property string text
    property bool selected: false
    property Component trailing: null

    signal clicked

    Layout.fillWidth: true
    Layout.preferredHeight: 36

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        radius: 4
        color: row.selected
            ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.15)
            : (rowMouse.containsMouse
                ? Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
                : "transparent")

        Behavior on color { ColorAnimation { duration: Kirigami.Units.shortDuration } }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 8

            Kirigami.Icon {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                source: row.iconSource
                color: row.selected ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                isMask: true
                visible: row.iconSource.length > 0
            }

            PlasmaComponents3.Label {
                Layout.fillWidth: true
                text: row.text
                color: Kirigami.Theme.textColor
                font.pixelSize: 11
                font.bold: row.selected
                elide: Text.ElideRight
            }

            Loader {
                Layout.preferredWidth: item ? item.width : 0
                Layout.preferredHeight: item ? item.height : 0
                visible: row.trailing !== null
                sourceComponent: row.trailing
            }
        }

        MouseArea {
            id: rowMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: row.clicked()
        }
    }
}

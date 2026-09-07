import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

Item {
    id: root

    property string iconSource: ""
    property string tooltipText: ""

    property int buttonSize: 20

    signal clicked
    signal rightClicked

    implicitWidth: buttonSize
    implicitHeight: buttonSize

    PlasmaCore.ToolTipArea {
        anchors.fill: parent
        mainText: root.tooltipText
        subText: ""
        textFormat: Text.PlainText
    }

    Kirigami.Icon {
        width: root.buttonSize; height: root.buttonSize
        anchors.centerIn: parent
        source: root.iconSource
        color: Kirigami.Theme.textColor
        isMask: true
        opacity: mouseArea.containsMouse ? 1 : 0.7
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: function (mouse) {
            if (mouse.button === Qt.RightButton) {
                root.rightClicked();
            } else {
                root.clicked();
            }
        }
    }
}

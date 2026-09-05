import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3

Item {
    id: root

    property string iconSource
    property int from: 0
    property int to: 100
    property int value: 0
    property int stepSize: 1
    property int iconSize: Kirigami.Units.iconSizes.smallMedium
    property bool pressed: false
    property bool showArrow: false

    signal moved(int value)
    signal released
    signal arrowClicked
    signal iconClicked
    signal rightClicked
    signal middleClicked

    implicitHeight: 36

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.MiddleButton
        cursorShape: Qt.ArrowCursor
        onClicked: function (mouse) {
            if (mouse.button === Qt.RightButton)
                root.rightClicked();
            else if (mouse.button === Qt.MiddleButton)
                root.middleClicked();
        }
    }

    GridLayout {
        anchors.fill: parent
        columns: 3
        columnSpacing: 12

        Kirigami.Icon {
            Layout.preferredWidth: root.iconSize
            Layout.preferredHeight: root.iconSize
            Layout.alignment: Qt.AlignVCenter
            source: root.iconSource
            isMask: true
            color: Kirigami.Theme.textColor

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.iconClicked()
            }
        }

        PlasmaComponents3.Slider {
            id: slider
            Layout.fillWidth: true
            from: root.from
            to: root.to
            value: root.value
            stepSize: root.stepSize
            onMoved: root.moved(value)
            onPressedChanged: {
                if (!slider.pressed)
                    root.released();
            }

            Binding {
                root.pressed: slider.pressed
            }
        }

        Item {
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            Layout.alignment: Qt.AlignVCenter

            Kirigami.Icon {
                width: Kirigami.Units.iconSizes.small
                height: Kirigami.Units.iconSizes.small
                anchors.centerIn: parent
                visible: root.showArrow
                source: "go-next"
                isMask: true
                color: Kirigami.Theme.textColor
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                enabled: root.showArrow
                onClicked: root.arrowClicked()
            }
        }
    }

    WheelHandler {
        target: slider
        orientation: Qt.Vertical
        acceptedButtons: Qt.NoButton
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: function (wheel) {
            const delta = wheel.angleDelta.y;
            if (delta > 0)
                slider.increase();
            else if (delta < 0)
                slider.decrease();
            slider.moved();
        }
    }
}

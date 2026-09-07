import QtQuick
import QtQuick.Effects

Rectangle {
    id: root
    color: "#0f1013"
    property int stage
    readonly property real u: Math.max(12, height / 60)

    Image {
        anchors.fill: parent
        source: "images/fundo.jpg"
        fillMode: Image.PreserveAspectCrop
        opacity: 0.30
        asynchronous: false
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#b30f1013" }
            GradientStop { position: 1.0; color: "#e60f1013" }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: root.u * 2

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.u * 7
            height: width

            Image {
                id: retrato
                anchors.fill: parent
                source: "images/avatar.png"
                smooth: true
                mipmap: true
                visible: false
            }
            Rectangle {
                id: mascara
                anchors.fill: parent
                radius: width / 2
                visible: false
                layer.enabled: true
            }
            MultiEffect {
                anchors.fill: parent
                source: retrato
                maskEnabled: true
                maskSource: mascara
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.u / 2
            Repeater {
                model: 5
                delegate: Rectangle {
                    width: root.u / 2.2
                    height: width
                    radius: width / 2
                    color: "#ffca28"
                    opacity: 0.25
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        PauseAnimation { duration: index * 130 }
                        NumberAnimation { to: 1.0; duration: 400 }
                        NumberAnimation { to: 0.25; duration: 400 }
                        PauseAnimation { duration: (4 - index) * 130 }
                    }
                }
            }
        }
    }
}

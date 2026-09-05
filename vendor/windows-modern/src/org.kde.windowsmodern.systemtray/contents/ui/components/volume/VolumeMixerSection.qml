import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import "../../lib" as Lib

ColumnLayout {
    id: section

    property var models
    property bool hasApps: models.sinkInputFilterModel.count > 0

    spacing: 0
    visible: hasApps

    Lib.SectionHeader {
        text: qsTr("Volume Mixer")
    }

    Repeater {
        model: models.sinkInputFilterModel

        delegate: Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 36

            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                radius: 4
                color: rowMouse.containsMouse
                    ? Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
                    : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Kirigami.Icon {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        source: model.IconName || "audio-volume-high"
                        color: Kirigami.Theme.textColor
                        isMask: true
                    }

                    PlasmaComponents3.Label {
                        Layout.fillWidth: true
                        text: (model.Client && model.Client.name) || model.Name || qsTr("Unknown application")
                        color: Kirigami.Theme.textColor
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }

                    PlasmaComponents3.Slider {
                        Layout.preferredWidth: 110
                        from: 0
                        to: 65536
                        value: model.Volume
                        stepSize: Math.round(65536 / 100)
                        onMoved: {
                            model.Volume = value
                            model.Muted = value === 0
                        }
                        onPressedChanged: {
                            if (!pressed) {
                                section.models.playFeedback(model.DeviceIndex)
                            }
                        }
                    }
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                }
            }
        }
    }
}

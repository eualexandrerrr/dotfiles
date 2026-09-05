import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import "../../lib" as Lib
import "../../js/funcs.js" as Funcs

ColumnLayout {
    id: section

    property var models
    property bool expanded: false
    readonly property bool hasMultiple: models.sinkFilterModel.count > 1

    spacing: 0

    Lib.SectionHeader {
        text: qsTr("Output Device")
    }

    Lib.ListRow {
        Layout.fillWidth: true
        selected: true
        iconSource: Funcs.volIconName(
            models.sinkAvailable ? models.sink.volume : 0,
            models.sinkAvailable ? models.sink.muted : true
        )
        text: models.sinkAvailable ? models.sink.description : qsTr("No output device")
        trailing: section.hasMultiple ? arrowComponent : null
        onClicked: if (section.hasMultiple) section.expanded = !section.expanded
    }

    Component {
        id: arrowComponent
        Kirigami.Icon {
            width: 16
            height: 16
            source: "arrow-down"
            color: Kirigami.Theme.textColor
            isMask: true
            rotation: section.expanded ? 180 : 0
            Behavior on rotation { NumberAnimation { duration: 120 } }
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: section.expanded ? deviceList.implicitHeight : 0
        clip: true
        visible: section.expanded

        Behavior on Layout.preferredHeight {
            NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
        }

        ColumnLayout {
            id: deviceList
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            Repeater {
                model: models.sinkFilterModel

                delegate: Lib.ListRow {
                    Layout.fillWidth: true
                    selected: model.PulseObject && model.PulseObject.default
                    iconSource: Funcs.volIconName(model.Volume, model.Muted)
                    text: model.Description || model.Name || qsTr("Unknown device")
                    onClicked: {
                        models.setDefaultSink(model.PulseObject)
                        models.playFeedback(model.PulseObject.index)
                        section.expanded = false
                    }
                }
            }
        }
    }
}

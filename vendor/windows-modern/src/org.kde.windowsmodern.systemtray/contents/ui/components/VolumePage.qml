import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kcmutils
import "../lib" as Lib
import "volume" as Volume

Lib.Page {
    id: page

    title: qsTr("Volume")
    contentFillsHeight: false

    footer: Lib.MoreSettingsLink {
        text: qsTr("More volume settings")
        onClicked: KCMLauncher.openSystemSettings("kcm_pulseaudio")
    }

    Volume.VolumeModels {
        id: models
    }

    Volume.OutputDeviceSection {
        Layout.fillWidth: true
        models: models
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.leftMargin: 10
        Layout.rightMargin: 10
        Layout.topMargin: 8
        Layout.bottomMargin: 8
        height: 1
        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
        visible: models.sinkInputFilterModel.count > 0
    }

    Volume.VolumeMixerSection {
        Layout.fillWidth: true
        models: models
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.leftMargin: 10
        Layout.rightMargin: 10
        Layout.topMargin: 8
        Layout.bottomMargin: 8
        height: 1
        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
        visible: models.sourceAvailable
    }

    Volume.InputDeviceSection {
        Layout.fillWidth: true
        models: models
    }

    PlasmaComponents3.Label {
        Layout.fillWidth: true
        Layout.topMargin: 10
        text: qsTr("No applications playing audio")
        color: Kirigami.Theme.textColor
        opacity: 0.5
        font.pixelSize: 11
        visible: models.sinkInputFilterModel.count === 0
        horizontalAlignment: Text.AlignHCenter
    }
}

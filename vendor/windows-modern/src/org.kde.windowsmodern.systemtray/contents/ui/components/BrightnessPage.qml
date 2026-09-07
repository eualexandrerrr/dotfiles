import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.private.brightnesscontrolplugin
import org.kde.kitemmodels as KItemModels
import org.kde.kcmutils
import "../lib" as Lib

Lib.Page {
    id: page

    title: qsTr("Brightness")
    contentFillsHeight: false

    ScreenBrightnessControl {
        id: sbControl
        isSilent: false
    }

    property var displays: []
    property bool _dragging: false

    function refreshDisplays() {
        if (_dragging)
            return;
        const model = sbControl.displays;
        if (!model || model.rowCount() === 0) {
            page.displays = [];
            return;
        }
        const labelRole = model.KItemModels.KRoleNames.role("label");
        const brightnessRole = model.KItemModels.KRoleNames.role("brightness");
        const maxBrightnessRole = model.KItemModels.KRoleNames.role("maxBrightness");
        const displayNameRole = model.KItemModels.KRoleNames.role("displayName");
        let displayList = [];
        for (let i = 0; i < model.rowCount(); i++) {
            const idx = model.index(i, 0);
            displayList.push({
                displayName: model.data(idx, displayNameRole),
                label: model.data(idx, labelRole),
                brightness: model.data(idx, brightnessRole),
                maxBrightness: model.data(idx, maxBrightnessRole)
            });
        }
        page.displays = displayList;
    }

    Connections {
        target: sbControl.displays
        function onDataChanged() {
            page.refreshDisplays();
        }
        function onModelReset() {
            page.refreshDisplays();
        }
        function onRowsInserted() {
            page.refreshDisplays();
        }
        function onRowsRemoved() {
            page.refreshDisplays();
        }
    }

    Component.onCompleted: page.refreshDisplays()

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 0

        Repeater {
            model: page.displays

            delegate: ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                PlasmaComponents3.Label {
                    Layout.leftMargin: 22
                    text: modelData.label || qsTr("Display %1").arg(index + 1)
                    font.pixelSize: 10
                    opacity: 0.5
                    color: Kirigami.Theme.textColor
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    spacing: 12

                    Kirigami.Icon {
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22
                        Layout.alignment: Qt.AlignVCenter
                        source: "brightness-high-symbolic"
                        isMask: true
                        color: Kirigami.Theme.textColor
                    }

                    PlasmaComponents3.Slider {
                        id: slider
                        Layout.fillWidth: true
                        from: modelData.maxBrightness > 100 ? 1 : 0
                        to: modelData.maxBrightness
                        value: modelData.brightness
                        stepSize: Math.max(1, Math.floor(modelData.maxBrightness / 100))

                        onMoved: sbControl.setBrightness(modelData.displayName, value)
                        onPressedChanged: {
                            page._dragging = slider.pressed;
                            if (!slider.pressed)
                                page.refreshDisplays();
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: 8
            Layout.bottomMargin: 8
            height: 1
            color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.12)
        }
    }

    footer: ColumnLayout {
        Lib.MoreSettingsLink {
            text: qsTr("Night color settings")
            onClicked: KCMLauncher.openSystemSettings("kcm_nightcolor")
        }
        Lib.MoreSettingsLink {
            text: qsTr("Display settings")
            onClicked: KCMLauncher.openSystemSettings("kcm_kscreen")
        }
    }
}

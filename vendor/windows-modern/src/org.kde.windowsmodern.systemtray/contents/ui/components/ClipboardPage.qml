/*
    ClipboardPage — Win11-styled clipboard history flyout.

    Uses org.kde.plasma.private.clipboard/HistoryModel (Klipper).
*/
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.private.clipboard as Clipboard
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kcmutils
import "../lib" as Lib
import "../js/funcs.js" as Funcs

Lib.Page {
    id: page

    title: qsTr("Clipboard")
    contentFillsHeight: false

    footer: Lib.MoreSettingsLink {
        text: qsTr("More clipboard settings")
        onClicked: KCMLauncher.openSystemSettings("kcm_keys")
    }

    Clipboard.HistoryModel {
        id: clipboardModel
    }

    readonly property int displayCount: Math.min(clipboardModel.rowCount(), 50)

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 0

        Repeater {
            model: clipboardModel
            Layout.fillWidth: true

            delegate: Item {
                width: page.width
                height: 34
                visible: index < page.displayCount

                Rectangle {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    radius: 4
                    color: ma.containsMouse
                        ? Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
                        : "transparent"

                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (model.UniversalMimeType === "text/plain") {
                                clipboardModel.copyToClipboard(model.Uuid)
                            }
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Kirigami.Icon {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            source: {
                                if (!model.UniversalMimeType || model.UniversalMimeType === "text/plain")
                                    return "edit-paste"
                                if (model.UniversalMimeType.startsWith("image/"))
                                    return "image-x-generic"
                                return "edit-paste"
                            }
                            color: Kirigami.Theme.textColor
                            isMask: true
                        }

                        PlasmaComponents3.Label {
                            Layout.fillWidth: true
                            text: model.DisplayText || qsTr("(empty)")
                            color: Kirigami.Theme.textColor
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }

                        PlasmaComponents3.Label {
                            text: model.NumberOfMarks > 0 ? model.NumberOfMarks : ""
                            color: Kirigami.Theme.textColor
                            opacity: 0.4
                            font.pixelSize: 10
                            visible: model.NumberOfMarks > 0
                        }
                    }
                }
            }
        }

        PlasmaComponents3.Label {
            Layout.fillWidth: true
            Layout.topMargin: 10
            text: qsTr("Clipboard is empty")
            color: Kirigami.Theme.textColor
            opacity: 0.5
            font.pixelSize: 11
            visible: clipboardModel.rowCount() === 0
            horizontalAlignment: Text.AlignHCenter
        }
    }
}

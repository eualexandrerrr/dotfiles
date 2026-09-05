/*
    NotificationsPage — Win11-styled notification history flyout.

    Uses org.kde.notificationmanager/WatchedNotificationsModel.
*/
import QtQuick
import QtQuick.Layouts
import org.kde.notificationmanager as NotificationManager
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kcmutils
import "../lib" as Lib
import "../js/funcs.js" as Funcs

Lib.Page {
    id: page

    title: qsTr("Notifications")
    contentFillsHeight: false

    footer: Lib.MoreSettingsLink {
        text: qsTr("More notification settings")
        onClicked: KCMLauncher.openSystemSettings("kcm_notifications")
    }

    NotificationManager.WatchedNotificationsModel {
        id: notifModel
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 0

        Repeater {
            model: notifModel
            Layout.fillWidth: true

            delegate: Item {
                width: page.width
                height: rowLayout.implicitHeight + 8

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
                    }

                    RowLayout {
                        id: rowLayout
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Kirigami.Icon {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            Layout.alignment: Qt.AlignTop
                            source: model.ApplicationIconName || "preferences-desktop-notification"
                            color: Kirigami.Theme.textColor
                            isMask: true
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            PlasmaComponents3.Label {
                                Layout.fillWidth: true
                                text: model.Summary || model.ApplicationName || qsTr("Notification")
                                color: Kirigami.Theme.textColor
                                font.pixelSize: 11
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            PlasmaComponents3.Label {
                                Layout.fillWidth: true
                                text: model.Body
                                color: Kirigami.Theme.textColor
                                opacity: 0.7
                                font.pixelSize: 10
                                visible: model.Body && model.Body.length > 0
                                elide: Text.ElideRight
                                maximumLineCount: 2
                                wrapMode: Text.Wrap
                            }

                            PlasmaComponents3.Label {
                                text: {
                                    var ts = model.Created
                                    if (!ts) return ""
                                    var diff = (Date.now() - ts.getTime()) / 1000
                                    if (diff < 60) return qsTr("Just now")
                                    if (diff < 3600) return qsTr("%1m ago").arg(Math.floor(diff / 60))
                                    if (diff < 86400) return qsTr("%1h ago").arg(Math.floor(diff / 3600))
                                    return qsTr("%1d ago").arg(Math.floor(diff / 86400))
                                }
                                color: Kirigami.Theme.textColor
                                opacity: 0.4
                                font.pixelSize: 9
                                visible: model.Created
                            }
                        }
                    }
                }
            }
        }

        PlasmaComponents3.Label {
            Layout.fillWidth: true
            Layout.topMargin: 10
            text: qsTr("No notifications")
            color: Kirigami.Theme.textColor
            opacity: 0.5
            font.pixelSize: 11
            visible: notifModel.rowCount === 0
            horizontalAlignment: Text.AlignHCenter
        }
    }
}

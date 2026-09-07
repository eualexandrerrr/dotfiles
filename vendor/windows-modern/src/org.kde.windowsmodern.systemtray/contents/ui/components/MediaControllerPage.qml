/*
    MediaControllerPage — Win11-styled media player flyout.

    Uses org.kde.plasma.private.mpris/Mpris2Model for the player list and
    PlayerContainer for playback controls.
*/
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.private.mpris as Mpris
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kcmutils
import "../lib" as Lib

Lib.Page {
    id: page

    title: qsTr("Media")
    contentFillsHeight: false

    footer: Lib.MoreSettingsLink {
        text: qsTr("More media settings")
        onClicked: KCMLauncher.openSystemSettings("kcm_keys")
    }

    Mpris.Mpris2Model {
        id: mprisModel
    }

    // The active player (first one that's playing, or first available)
    readonly property var activePlayer: {
        for (var i = 0; i < mprisModel.count; i++) {
            var p = mprisModel.get(i)
            if (p && p.playbackStatus === Mpris.PlaybackStatus.Playing)
                return p
        }
        return mprisModel.count > 0 ? mprisModel.get(0) : null
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 12

        // Now playing card
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: cardCol.implicitHeight + 16
            visible: page.activePlayer !== null

            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                radius: 6
                color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.06)

                ColumnLayout {
                    id: cardCol
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    // Album art + track info
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Item {
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 48

                            Rectangle {
                                anchors.fill: parent
                                radius: 4
                                color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.12)
                                visible: !artImg.visible

                                Kirigami.Icon {
                                    anchors.centerIn: parent
                                    width: 24
                                    height: 24
                                    source: "media-optical"
                                    color: Kirigami.Theme.textColor
                                    isMask: true
                                    opacity: 0.5
                                }
                            }

                            Image {
                                id: artImg
                                anchors.fill: parent
                                visible: page.activePlayer && page.activePlayer.artUrl
                                       && page.activePlayer.artUrl.length > 0
                                source: page.activePlayer ? page.activePlayer.artUrl : ""
                                fillMode: Image.PreserveAspectCrop
                                layer.enabled: true
                                layer.effect: Kirigami.ShadowedTexture { radius: 4 }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            PlasmaComponents3.Label {
                                Layout.fillWidth: true
                                text: page.activePlayer ? (page.activePlayer.title || qsTr("Unknown track")) : ""
                                color: Kirigami.Theme.textColor
                                font.pixelSize: 12
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            PlasmaComponents3.Label {
                                Layout.fillWidth: true
                                text: page.activePlayer ? (page.activePlayer.artist || qsTr("Unknown artist")) : ""
                                color: Kirigami.Theme.textColor
                                opacity: 0.6
                                font.pixelSize: 10
                                elide: Text.ElideRight
                            }

                            PlasmaComponents3.Label {
                                Layout.fillWidth: true
                                text: page.activePlayer ? page.activePlayer.instanceName : ""
                                color: Kirigami.Theme.textColor
                                opacity: 0.3
                                font.pixelSize: 9
                                elide: Text.ElideRight
                            }
                        }
                    }

                    // Transport controls
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 16

                        Item { Layout.fillWidth: true }

                        Item {
                            Layout.preferredWidth: 28
                            Layout.preferredHeight: 28

                            Kirigami.Icon {
                                anchors.centerIn: parent
                                width: 22
                                height: 22
                                source: "media-skip-backward"
                                color: Kirigami.Theme.textColor
                                isMask: true
                                opacity: page.activePlayer && page.activePlayer.canGoPrevious ? 1 : 0.3
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                enabled: page.activePlayer && page.activePlayer.canGoPrevious
                                onClicked: page.activePlayer.GoPrevious()
                            }
                        }

                        Item {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36

                            Rectangle {
                                anchors.fill: parent
                                radius: width / 2
                                color: playMA.containsPress
                                    ? Qt.darker(Kirigami.Theme.highlightColor, 1.2)
                                    : Kirigami.Theme.highlightColor
                                opacity: page.activePlayer && (page.activePlayer.canPlay || page.activePlayer.canPause) ? 1 : 0.3

                                Kirigami.Icon {
                                    anchors.centerIn: parent
                                    width: 22
                                    height: 22
                                    source: page.activePlayer && page.activePlayer.playbackStatus === Mpris.PlaybackStatus.Playing
                                        ? "media-playback-pause"
                                        : "media-playback-start"
                                    color: "#FFFFFF"
                                    isMask: true
                                }

                                MouseArea {
                                    id: playMA
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    enabled: page.activePlayer && (page.activePlayer.canPlay || page.activePlayer.canPause)
                                    onClicked: {
                                        if (page.activePlayer.playbackStatus === Mpris.PlaybackStatus.Playing)
                                            page.activePlayer.Pause()
                                        else
                                            page.activePlayer.Play()
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.preferredWidth: 28
                            Layout.preferredHeight: 28

                            Kirigami.Icon {
                                anchors.centerIn: parent
                                width: 22
                                height: 22
                                source: "media-skip-forward"
                                color: Kirigami.Theme.textColor
                                isMask: true
                                opacity: page.activePlayer && page.activePlayer.canGoNext ? 1 : 0.3
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                enabled: page.activePlayer && page.activePlayer.canGoNext
                                onClicked: page.activePlayer.GoNext()
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }
                }
            }
        }

        PlasmaComponents3.Label {
            Layout.fillWidth: true
            Layout.topMargin: 10
            text: qsTr("No media playing")
            color: Kirigami.Theme.textColor
            opacity: 0.5
            font.pixelSize: 11
            visible: page.activePlayer === null
            horizontalAlignment: Text.AlignHCenter
        }
    }
}

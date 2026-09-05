/***************************************************************************
 *   License: GPL-3.0-or-later
 *   Author: Jeysef
 *
 *   Right-hand column of the StartAllBack-style two-column layout.
 *   Vertical list of system locations (Documents, Pictures, Music, This PC,
 *   Settings, Run...) with hover highlighting.  Pattern adapted from
 *   Start.Next.Menu's "places" column (ListModel + ListView, icon + text).
 ***************************************************************************/

import QtQuick

import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import "../code/theme.js" as Theme

Item {
    id: column

    property var executable: null

    readonly property var allLocations: [
        { text: QT_TR_NOOP("Home"),          icon: "user-home",             command: "xdg-open $HOME" },
        { text: QT_TR_NOOP("Documents"),      icon: "folder-documents",     command: "xdg-open $(xdg-user-dir DOCUMENTS)" },
        { text: QT_TR_NOOP("Pictures"),       icon: "folder-pictures",      command: "xdg-open $(xdg-user-dir PICTURES)" },
        { text: QT_TR_NOOP("Music"),          icon: "folder-music",         command: "xdg-open $(xdg-user-dir MUSIC)" },
        { text: QT_TR_NOOP("Downloads"),      icon: "folder-download",      command: "xdg-open $(xdg-user-dir DOWNLOAD)" },
        { text: QT_TR_NOOP("Recent Items"),   icon: "document-open-recent", command: "xdg-open $(xdg-user-dir DOCUMENTS)" },
        { text: QT_TR_NOOP("This PC"),        icon: "computer",             command: "dolphin" },
        { text: QT_TR_NOOP("Update"),         icon: "system-software-update", command: "plasma-discover" },
        { text: QT_TR_NOOP("Terminal"),       icon: "utilities-terminal",   command: "T=$(kreadconfig6 --file kdeglobals --group General --key TerminalApplication); command -v ${T:-konsole} >/dev/null 2>&1 && exec ${T:-konsole} || exec alacritty" },
        { text: QT_TR_NOOP("Run..."),         icon: "system-run",           command: "krunner" }
    ]

    readonly property var allKeys: ["home","documents","pictures","music","downloads","recent","thispc","update","terminal","run"]

    readonly property var visibleLocations: {
        var items = Plasmoid.configuration.rightColumnItems;
        if (!items || items.length === 0) {
            return allLocations;
        }
        var out = [];
        for (var i = 0; i < items.length; i++) {
            var idx = allKeys.indexOf(items[i]);
            if (idx >= 0) {
                out.push(allLocations[idx]);
            }
        }
        return out.length > 0 ? out : allLocations;
    }

    PlasmaComponents3.ScrollView {
        id: scroll
        anchors.fill: parent
        PlasmaComponents3.ScrollBar.horizontal.policy: PlasmaComponents3.ScrollBar.AlwaysOff

        ListView {
            id: list
            anchors.fill: parent
            clip: true
            model: column.visibleLocations
            spacing: Kirigami.Units.smallSpacing / 2
            boundsBehavior: Flickable.StopAtBounds

            delegate: Item {
                id: locDelegate
                width: ListView.view.width
                height: Kirigami.Units.gridUnit * 2

                required property var modelData
                required property int index

                Rectangle {
                    id: locHover
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.smallSpacing / 2
                    radius: Kirigami.Units.smallSpacing
                    color: Kirigami.Theme.hoverColor
                    opacity: locMouse.containsMouse ? Theme.opacityFull : Theme.opacityHidden
                    Behavior on opacity { NumberAnimation { duration: 90 } }
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: Kirigami.Units.largeSpacing
                    anchors.right: parent.right
                    anchors.rightMargin: Kirigami.Units.largeSpacing
                    spacing: Kirigami.Units.largeSpacing

                    Kirigami.Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        width: Kirigami.Units.iconSizes.smallMedium
                        height: width
                        source: locDelegate.modelData.icon
                        animated: false
                    }

                    PlasmaComponents3.Label {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - Kirigami.Units.iconSizes.smallMedium - parent.spacing
                        text: i18n(locDelegate.modelData.text)
                        color: Kirigami.Theme.textColor
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        horizontalAlignment: Text.AlignLeft
                    }
                }

                MouseArea {
                    id: locMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (column.executable && locDelegate.modelData.command) {
                            column.executable.exec(locDelegate.modelData.command);
                        }
                    }
                }
            }
        }
    }
}

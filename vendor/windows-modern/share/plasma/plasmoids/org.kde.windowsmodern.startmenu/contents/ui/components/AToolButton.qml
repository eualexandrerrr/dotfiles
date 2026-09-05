/***************************************************************************
 *   License: GPL-3.0-or-later
 *   Author: Jeysef
 *
 *   Flat/link-style button with icon and text, used for "All apps", "Back".
 *   Styling matches menu.11.next — rounded, subtle border, clean hover.
 ***************************************************************************/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import "../code/theme.js" as Theme

Rectangle {
    id: item

    property int buttonHeight: Math.floor(Kirigami.Units.gridUnit * 2)
    implicitHeight: buttonHeight
    implicitWidth: row.implicitWidth + (Kirigami.Units.mediumSpacing * 2)

    border.width: 1
    border.color: Qt.rgba(Kirigami.Theme.textColor.r,
                           Kirigami.Theme.textColor.g,
                           Kirigami.Theme.textColor.b, Theme.buttonBorderOpacity)

    radius: Kirigami.Units.smallSpacing
    color: {
        var hover = Qt.rgba(Kirigami.Theme.textColor.r,
                            Kirigami.Theme.textColor.g,
                            Kirigami.Theme.textColor.b, Theme.buttonHoverOpacity);
        if (flat) {
            return mouseItem.containsMouse
                   ? Qt.rgba(Kirigami.Theme.textColor.r,
                              Kirigami.Theme.textColor.g,
                              Kirigami.Theme.textColor.b, Theme.buttonFlatHoverOpacity)
                   : Qt.rgba(Kirigami.Theme.textColor.r,
                              Kirigami.Theme.textColor.g,
                              Kirigami.Theme.textColor.b, Theme.buttonFlatBackgroundOpacity);
        }
        return mouseItem.containsMouse ? hover : Kirigami.Theme.backgroundColor;
    }

    Behavior on color { ColorAnimation { duration: 90 } }

    smooth: true
    focus: true

    property alias text: lb.text
    property bool flat: false
    property alias iconName: icon.source
    property bool mirror: false

    signal clicked

    Keys.onSpacePressed: item.clicked()

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        anchors.topMargin: Kirigami.Units.smallSpacing / 2
        anchors.bottomMargin: Kirigami.Units.smallSpacing / 2
        spacing: Kirigami.Units.smallSpacing
        LayoutMirroring.enabled: mirror

        Label {
            id: lb
            color: Kirigami.Theme.textColor
            Layout.leftMargin: Kirigami.Units.smallSpacing
            Layout.fillWidth: true
        }

        Kirigami.Icon {
            id: icon
            implicitHeight: Kirigami.Units.gridUnit
            implicitWidth: implicitHeight
            smooth: true
        }
    }

    MouseArea {
        id: mouseItem
        hoverEnabled: true
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: item.clicked()
    }
}

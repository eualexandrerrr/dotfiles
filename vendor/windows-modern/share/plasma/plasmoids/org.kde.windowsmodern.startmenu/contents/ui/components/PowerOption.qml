/***************************************************************************
 *   License: GPL-3.0-or-later
 *   Author: Jeysef
 *
 *   Single row inside the power-options popup: icon + label, hover
 *   highlight, click to activate.
 ***************************************************************************/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import "../code/theme.js" as Theme

Item {
    id: option

    property string iconSource
    property string label
    property bool optionEnabled: true

    signal activated

    width: parent ? parent.width : Kirigami.Units.gridUnit * 10
    height: Math.floor(Kirigami.Units.gridUnit * 1.6)

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: Kirigami.Units.smallSpacing / 2
        color: option.optionEnabled && hoverArea.containsMouse
               ? Kirigami.Theme.hoverColor
               : "transparent"
        opacity: option.optionEnabled && hoverArea.containsMouse ? Theme.opacityFull : Theme.opacityHidden
        Behavior on opacity { NumberAnimation { duration: 80 } }
    }

    RowLayout {
        id: powerRow
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
            Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
            source: option.iconSource
            opacity: option.optionEnabled ? Theme.opacityFull : Theme.disabledIconOpacity
        }

        PlasmaComponents3.Label {
            text: option.label
            color: option.optionEnabled ? Kirigami.Theme.textColor : Kirigami.Theme.disabledTextColor
            font.pointSize: Kirigami.Theme.defaultFont.pointSize - 1
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: option.optionEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: option.optionEnabled
        onClicked: option.activated()
    }
}

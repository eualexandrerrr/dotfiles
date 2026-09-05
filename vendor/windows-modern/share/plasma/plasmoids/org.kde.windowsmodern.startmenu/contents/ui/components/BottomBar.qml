/***************************************************************************
 *   License: GPL-3.0-or-later
 *   Author: Jeysef
 *
 *   StartAllBack-style compound bottom bar: the search field fills the
 *   remaining space on the left, the "Shut down >" dropdown sits on the
 *   right.  Both share a single row.
 ***************************************************************************/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import "../code/theme.js" as Theme

RowLayout {
    id: bottomBar

    spacing: Kirigami.Units.largeSpacing
    width: parent.width

    property alias searchText: searchFieldInput.text

    // The split button item, exposed so the shell can use it as the
    // visualParent for the power-options popup.
    readonly property Item splitButton: shutdownSplit

    signal searchFocusResults
    signal searchNavUp
    signal searchNavDown
    signal searchActivateFirstResult
    signal searchEscapePressed
    signal tabOut
    signal powerMenuRequested
    signal powerShutdownRequested

    function focusSearch() {
        searchFieldInput.forceActiveFocus();
    }

    Keys.onTabPressed: event => {
        event.accepted = true;
        tabOut();
    }

    // ── Search field (fills) ───────────────────────────────────────────
    PlasmaComponents3.TextField {
        id: searchFieldInput
        Layout.fillWidth: true
        focus: true
        placeholderText: i18n("Search programs and files")
        topPadding: 8
        bottomPadding: 8
        leftPadding: Kirigami.Units.gridUnit + Kirigami.Units.iconSizes.small
        font.pointSize: Kirigami.Theme.defaultFont.pointSize

        background: Rectangle {
            color: Kirigami.Theme.backgroundColor
            radius: Kirigami.Units.smallSpacing * 3
            border.width: 1
            border.color: Qt.rgba(Kirigami.Theme.textColor.r,
                                   Kirigami.Theme.textColor.g,
                                   Kirigami.Theme.textColor.b, Theme.fieldBorderOpacity)
            Behavior on border.color { ColorAnimation { duration: 100 } }
        }

        onTextChanged: bottomBar.searchTextChanged(text)
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                event.accepted = true;
                bottomBar.searchEscapePressed();
                return;
            }
            if (event.key === Qt.Key_Down) {
                event.accepted = true;
                bottomBar.searchNavDown();
                return;
            }
            if (event.key === Qt.Key_Up) {
                event.accepted = true;
                bottomBar.searchNavUp();
                return;
            }
            if (event.key === Qt.Key_Tab) {
                event.accepted = true;
                bottomBar.searchFocusResults();
                return;
            }
        }
        Keys.onReturnPressed: bottomBar.searchActivateFirstResult()

        Kirigami.Icon {
            source: "search"
            anchors.left: searchFieldInput.left
            anchors.verticalCenter: searchFieldInput.verticalCenter
            anchors.leftMargin: Kirigami.Units.smallSpacing * 2
            height: Kirigami.Units.iconSizes.small
            width: height
        }
    }

    // ── Right: Shut down split button ─────────────────────────────────
    // One rounded container; left zone triggers shutdown directly, right
    // chevron zone opens a menu with Lock / Sleep / Restart / Shut down.
    Item {
        id: shutdownSplit
        Layout.alignment: Qt.AlignVCenter
        implicitWidth: splitRow.implicitWidth + Kirigami.Units.largeSpacing * 2
        implicitHeight: Math.floor(Kirigami.Units.gridUnit * 1.6)

        Rectangle {
            id: splitBg
            anchors.fill: parent
            radius: Kirigami.Units.smallSpacing
            color: splitMouse.containsMouse
                   ? Qt.rgba(Kirigami.Theme.textColor.r,
                             Kirigami.Theme.textColor.g,
                             Kirigami.Theme.textColor.b, Theme.buttonFlatHoverOpacity)
                   : Qt.rgba(Kirigami.Theme.textColor.r,
                             Kirigami.Theme.textColor.g,
                             Kirigami.Theme.textColor.b, Theme.buttonFlatBackgroundOpacity)
            border.width: 1
            border.color: Qt.rgba(Kirigami.Theme.textColor.r,
                                   Kirigami.Theme.textColor.g,
                                   Kirigami.Theme.textColor.b, Theme.buttonBorderOpacity)
            Behavior on color { ColorAnimation { duration: 90 } }
        }

        Row {
            id: splitRow
            anchors.centerIn: parent
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                anchors.verticalCenter: parent.verticalCenter
                width: Kirigami.Units.iconSizes.smallMedium
                height: width
                source: "system-shutdown"
            }

            PlasmaComponents3.Label {
                id: shutdownLabel
                anchors.verticalCenter: parent.verticalCenter
                text: i18n("Shut down")
                color: Kirigami.Theme.textColor
                font.pointSize: Kirigami.Theme.defaultFont.pointSize - 1
            }

            // Subtle divider between the two zones.
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: shutdownSplit.height * 0.5
                color: Qt.rgba(Kirigami.Theme.textColor.r,
                               Kirigami.Theme.textColor.g,
                               Kirigami.Theme.textColor.b, Theme.buttonDividerOpacity)
            }

            Kirigami.Icon {
                anchors.verticalCenter: parent.verticalCenter
                width: Kirigami.Units.iconSizes.small
                height: width
                source: "go-next"
                opacity: Theme.buttonChevronOpacity
            }
        }

        // Single MouseArea: hover for the whole button; click position
        // decides whether to shut down (left) or open the menu (right).
        MouseArea {
            id: splitMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: mouse => {
                // Chevron zone = rightmost portion (icon + padding).
                var chevronWidth = Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing * 2;
                if (mouse.x > shutdownSplit.width - chevronWidth) {
                    bottomBar.powerMenuRequested();
                } else {
                    bottomBar.powerShutdownRequested();
                }
            }
        }
    }
}

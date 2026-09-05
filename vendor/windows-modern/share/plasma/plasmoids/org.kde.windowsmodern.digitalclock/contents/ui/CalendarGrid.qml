/*
    SPDX-FileCopyrightText: 2026 Jeysef

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import "Calendar.js" as Calendar

Item {
    id: calendarGrid

    // Square cells: height derived from width, clamped to avoid negative/zero sizes.
    readonly property real cellWidth: Math.max(28, (width - (columns - 1) * spacing) / columns)
    readonly property real cellHeight: cellWidth

    readonly property int columns: 7
    readonly property int rows: 6
    property real spacing: Kirigami.Units.smallSpacing / 2

    Layout.preferredHeight: cellHeight * rows + spacing * (rows - 1)
    Layout.minimumHeight: 240

    function crossfade() {
        grid.opacity = 0;
        fadeIn.restart();
    }

    Grid {
        id: grid
        anchors.fill: parent
        columns: calendarGrid.columns
        rows: calendarGrid.rows
        spacing: calendarGrid.spacing

        Repeater {
            id: gridRepeater

            model: Calendar.generateMonthGrid(
                calendarView.displayedYear,
                calendarView.displayedMonth,
                root.currentTime,
                calendarView.selectedDate,
                calendarView.firstDayOfWeek)

            delegate: CalendarDayDelegate {
                required property var modelData

                width: calendarGrid.cellWidth
                height: calendarGrid.cellHeight

                dayData: modelData
                daysModel: calendarView.calendarBackend.daysModel
            }
        }

    }

    NumberAnimation {
        id: fadeIn
        target: grid
        property: "opacity"
        to: 1
        duration: Kirigami.Units.shortDuration
        easing.type: Easing.InOutQuad
    }

    // Scroll wheel over the grid navigates months.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) {
                calendarView.previousMonth();
            } else {
                calendarView.nextMonth();
            }
            wheel.accepted = true;
        }
    }
}

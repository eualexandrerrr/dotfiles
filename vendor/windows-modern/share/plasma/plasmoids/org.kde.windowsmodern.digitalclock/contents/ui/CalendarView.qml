/*
    SPDX-FileCopyrightText: 2026 Jeysef

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.workspace.calendar as PlasmaCalendar
import org.kde.kirigami as Kirigami

import "Calendar.js" as Calendar

ColumnLayout {
    id: calendarView

    Win11Palette { id: palette }

    // Year/month currently displayed by the calendar (0-based month).
    property int displayedYear: root.currentTime.getFullYear()
    property int displayedMonth: root.currentTime.getMonth()
    property date selectedDate: root.currentTime

    readonly property int firstDayOfWeek: Plasmoid.configuration.firstDayOfWeek > -1
        ? Plasmoid.configuration.firstDayOfWeek
        : Qt.locale().firstDayOfWeek

    readonly property bool showWeekNumbers: Plasmoid.configuration.showWeekNumbers

    readonly property PlasmaCalendar.EventPluginsManager eventPluginsManager: PlasmaCalendar.EventPluginsManager {
        enabledPlugins: Plasmoid.configuration.enabledCalendarPlugins
    }

    readonly property PlasmaCalendar.Calendar calendarBackend: PlasmaCalendar.Calendar {
        days: 7
        weeks: 6
        firstDayOfWeek: calendarView.firstDayOfWeek
        today: root.currentTime
        displayedDate: new Date(calendarView.displayedYear, calendarView.displayedMonth, 1)

        Component.onCompleted: {
            calendarBackend.daysModel.setPluginsManager(calendarView.eventPluginsManager);
        }
    }

    // First date shown in the 6-week grid.
    readonly property date gridStartDate: {
        const firstDayOfMonth = new Date(calendarView.displayedYear, calendarView.displayedMonth, 1);
        const startDayOfWeek = firstDayOfMonth.getDay();
        let daysFromPreviousMonth = startDayOfWeek - calendarView.firstDayOfWeek;
        if (daysFromPreviousMonth < 0) {
            daysFromPreviousMonth += 7;
        }
        return new Date(calendarView.displayedYear, calendarView.displayedMonth, 1 - daysFromPreviousMonth);
    }

    spacing: Kirigami.Units.smallSpacing
    focus: true

    function resetToToday() {
        selectDate(root.currentTime);
    }

    function selectDate(date) {
        displayedYear = date.getFullYear();
        displayedMonth = date.getMonth();
        selectedDate = date;
    }

    function previousMonth() {
        let newMonth = calendarView.displayedMonth - 1;
        let newYear = calendarView.displayedYear;
        if (newMonth < 0) {
            newMonth = 11;
            newYear--;
        }
        calendarView.displayedMonth = newMonth;
        calendarView.displayedYear = newYear;
    }

    function nextMonth() {
        let newMonth = calendarView.displayedMonth + 1;
        let newYear = calendarView.displayedYear;
        if (newMonth > 11) {
            newMonth = 0;
            newYear++;
        }
        calendarView.displayedMonth = newMonth;
        calendarView.displayedYear = newYear;
    }

    onDisplayedMonthChanged: calendarGrid.crossfade()
    onDisplayedYearChanged: calendarGrid.crossfade()

    Keys.onPressed: event => {
        const d = new Date(calendarView.selectedDate);
        switch (event.key) {
        case Qt.Key_Left:
            d.setDate(d.getDate() - 1);
            calendarView.selectDate(d);
            event.accepted = true;
            break;
        case Qt.Key_Right:
            d.setDate(d.getDate() + 1);
            calendarView.selectDate(d);
            event.accepted = true;
            break;
        case Qt.Key_Up:
            d.setDate(d.getDate() - 7);
            calendarView.selectDate(d);
            event.accepted = true;
            break;
        case Qt.Key_Down:
            d.setDate(d.getDate() + 7);
            calendarView.selectDate(d);
            event.accepted = true;
            break;
        case Qt.Key_Home:
            calendarView.resetToToday();
            event.accepted = true;
            break;
        case Qt.Key_PageUp:
            calendarView.previousMonth();
            event.accepted = true;
            break;
        case Qt.Key_PageDown:
            calendarView.nextMonth();
            event.accepted = true;
            break;
        }
    }

    // Month/year navigation header.
    RowLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        PlasmaComponents.Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            textFormat: Text.PlainText
            text: Qt.locale().standaloneMonthName(calendarView.displayedMonth, Locale.LongFormat)
                  + " " + calendarView.displayedYear
            color: palette.text
            font {
                weight: Font.Bold
                pixelSize: Kirigami.Units.gridUnit
            }
        }

        CalendarNavButton {
            up: true
            glyphColor: palette.text
            hoverColor: palette.hover
            pressedColor: palette.pressed
            onClicked: calendarView.previousMonth()
            Accessible.name: i18n("Previous month")
        }

        CalendarNavButton {
            up: false
            glyphColor: palette.text
            hoverColor: palette.hover
            pressedColor: palette.pressed
            onClicked: calendarView.nextMonth()
            Accessible.name: i18n("Next month")
        }
    }

    // Day-of-week header.
    RowLayout {
        Layout.fillWidth: true
        spacing: 0

        PlasmaComponents.Label {
            visible: calendarView.showWeekNumbers
            Layout.preferredWidth: Kirigami.Units.gridUnit * 1.5
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            textFormat: Text.PlainText
            text: i18nc("@label week number column header", "Wk")
            color: palette.textSecondary
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
        }

        Repeater {
            model: 7
            delegate: PlasmaComponents.Label {
                required property int index
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                textFormat: Text.PlainText
                text: Qt.locale().standaloneDayName((calendarView.firstDayOfWeek + index) % 7, Locale.ShortFormat)
                color: palette.textSecondary
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
            }
        }
    }

    // Calendar grid with optional week number column.
    RowLayout {
        Layout.fillWidth: true
        spacing: 0

        ColumnLayout {
            visible: calendarView.showWeekNumbers
            spacing: calendarGrid.spacing
            Layout.preferredWidth: Kirigami.Units.gridUnit * 1.5

            Repeater {
                model: 6
                delegate: PlasmaComponents.Label {
                    required property int index
                    Layout.preferredHeight: calendarGrid.cellHeight
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    textFormat: Text.PlainText
                    text: Calendar.isoWeekNumber(new Date(calendarView.gridStartDate.getTime() + index * 7 * 86400000))
                    color: palette.textSecondary
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                }
            }
        }

        CalendarGrid {
            id: calendarGrid
            Layout.fillWidth: true
            Layout.preferredHeight: calendarGrid.cellHeight * 6 + calendarGrid.spacing * 5
        }
    }
}

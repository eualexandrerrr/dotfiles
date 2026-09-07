/*
    SPDX-FileCopyrightText: 2026 Jeysef

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.clock as PlasmaClock
import org.kde.plasma.private.digitalclock as DigitalClockPrivate
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: timeZoneView

    Win11Palette { id: palette }

    spacing: Kirigami.Units.smallSpacing

    PlasmaComponents.Label {
        Layout.fillWidth: true
        text: i18n("Time Zones")
        color: palette.text
        font {
            weight: Font.Bold
            pixelSize: Kirigami.Units.gridUnit
        }
    }

    ListView {
        id: clocksList
        Layout.fillWidth: true
        Layout.preferredHeight: contentHeight
        interactive: false

        model: root.selectedTimeZonesDeduplicatingExplicitLocalTimeZone()

        delegate: RowLayout {
            id: listItem

            required property string modelData

            readonly property bool isCurrentTimeZone: tzClock.timeZone === root.currentTimeZone
            readonly property string tzLabel: {
                switch (Plasmoid.configuration.displayTimezoneFormat) {
                case 0: // Code
                    return tzClock.timeZoneCode;
                case 1: // City
                    return DigitalClockPrivate.TimeZonesI18n.i18nCity(tzClock.timeZone);
                case 2: // Offset from UTC time
                    return tzClock.timeZoneOffset;
                }
                return "";
            }

            width: ListView.view.width
            height: Kirigami.Units.gridUnit * 2

            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: listItem.tzLabel
                color: listItem.isCurrentTimeZone ? palette.text : palette.textSecondary
                font.weight: listItem.isCurrentTimeZone ? Font.Bold : Font.Normal
                textFormat: Text.PlainText
                elide: Text.ElideRight
            }

            PlasmaComponents.Label {
                text: root.formatTime(tzClock.dateTime, Plasmoid.configuration.showSeconds === 2)
                color: listItem.isCurrentTimeZone ? palette.text : palette.textSecondary
                font.weight: listItem.isCurrentTimeZone ? Font.Bold : Font.Normal
                textFormat: Text.PlainText
            }

            PlasmaComponents.Label {
                visible: !listItem.isCurrentTimeZone
                text: root.formatOffset(tzClock.dateTime)
                color: palette.textSecondary
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                textFormat: Text.PlainText
            }

            PlasmaClock.Clock {
                id: tzClock
                timeZone: listItem.modelData
                trackSeconds: Plasmoid.configuration.showSeconds === 2
            }
        }
    }
}

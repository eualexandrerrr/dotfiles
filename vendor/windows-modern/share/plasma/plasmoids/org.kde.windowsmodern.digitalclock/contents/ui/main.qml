/*
    SPDX-FileCopyrightText: 2026 Jeysef

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.clock as PlasmaClock
import org.kde.plasma.private.digitalclock as DigitalClockPrivate
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    width: Kirigami.Units.gridUnit * 10
    height: Kirigami.Units.gridUnit * 4

    Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground | PlasmaCore.Types.ConfigurableBackground

    toolTipMainText: i18n("Clock")
    toolTipSubText: ""

    readonly property string currentTimeZone: currentClock.timeZone
    readonly property var currentTime: currentClock.dateTime

    // Time format strings, updated by timeFormatCorrection().
    property string timeFormat
    property string timeFormatWithSeconds

    // We need Local to be *always* present, even if not displayed, as it's
    // used for formatting and offset calculations.
    property list<string> allTimeZones

    PlasmaClock.Clock {
        id: currentClock
        timeZone: Plasmoid.configuration.lastSelectedTimezone
    }

    PlasmaClock.Clock {
        id: systemClock
        // No timezone defined: tracks the system timezone.
    }

    function initTimeZones() {
        const timeZones = [];
        if (Plasmoid.configuration.selectedTimeZones.indexOf("Local") === -1) {
            timeZones.push("Local");
        }
        root.allTimeZones = timeZones.concat(Plasmoid.configuration.selectedTimeZones);
    }

    function formatTime(dateTime: date, showSeconds: bool): string {
        let formattedTime;
        if (showSeconds) {
            formattedTime = Qt.locale().toString(dateTime, root.timeFormatWithSeconds);
        } else {
            formattedTime = Qt.locale().toString(dateTime, root.timeFormat);
        }

        // If the date differs from the current clock's date, append the day name.
        if (dateTime.getDay() !== currentClock.dateTime.getDay()) {
            formattedTime += " " + Qt.locale().toString(dateTime, "dddd");
        }

        return formattedTime;
    }

    function formatOffset(dateTime: date): string {
        const offset = Math.round((dateTime - currentClock.dateTime) / (1000 * 60));

        if (offset === 0) {
            return "";
        }

        const hourOffset = Math.abs(Math.floor(offset / 60));
        const minuteOffset = offset % 60;

        if (offset > 0) {
            if (minuteOffset === 0) {
                return i18ncp("@info offset from current time", " • %1 hour later", " • %1 hours later", hourOffset);
            } else {
                return i18nc("@info offset from current time in hours and minutes", " • %1:%2 later", hourOffset, minuteOffset);
            }
        } else {
            if (minuteOffset === 0) {
                return i18ncp("@info offset from current time", " • %1 hour earlier", " • %1 hours earlier", hourOffset);
            } else {
                return i18nc("@info offset from current time in hours and minutes", " • %1:%2 earlier", hourOffset, minuteOffset);
            }
        }
    }

    function selectedTimeZonesDeduplicatingExplicitLocalTimeZone(): /* [string] */ var {
        // Suppress duplicates when the user has added their local city explicitly
        // and is currently back in their normal local time zone.
        const isLiterallyLocalOrResolvesToSomethingOtherThanLocal = timeZone =>
            timeZone === "Local" || timeZone !== systemClock.timeZone;

        return DigitalClockPrivate.TimeZoneUtils.sortedTimeZones(
            Plasmoid.configuration.selectedTimeZones.filter(isLiterallyLocalOrResolvesToSomethingOtherThanLocal));
    }

    // Computes time format strings based on locale and user settings.
    function timeFormatCorrection(timeFormatString = Qt.locale().timeFormat(Locale.ShortFormat)) {
        const regexp = /(hh*)(.+)(mm)/i;
        const match = regexp.exec(timeFormatString);

        if (!match) {
            root.timeFormat = timeFormatString;
            root.timeFormatWithSeconds = timeFormatString;
            return;
        }

        const hours = match[1];
        const delimiter = match[2];
        const minutes = match[3];
        const seconds = "ss";
        const amPm = "AP";
        const uses24hFormatByDefault = timeFormatString.toLowerCase().indexOf("ap") === -1;

        // QLocale does not convert 12h/24h when uppercase H is used, so lowercase h/hh.
        let result = hours.toLowerCase() + delimiter + minutes;
        let resultSec = result + delimiter + seconds;

        // Append AM/PM when user chose 12h or left it as locale default and locale uses 12h.
        if ((Plasmoid.configuration.use24hFormat === Qt.PartiallyChecked && !uses24hFormatByDefault)
                || Plasmoid.configuration.use24hFormat === Qt.Unchecked) {
            result += " " + amPm;
            resultSec += " " + amPm;
        }

        root.timeFormat = result;
        root.timeFormatWithSeconds = resultSec;
    }

    preferredRepresentation: compactRep

    Component {
        id: compactRep
        CompactRepresentation {
            plasmoidItem: root
        }
    }

    Component {
        id: fullRep
        ExpandedRepresentation {}
    }

    compactRepresentation: compactRep

    fullRepresentation: fullRep

    activationTogglesExpanded: true
    hideOnWindowDeactivate: !Plasmoid.configuration.pin

    Connections {
        target: Plasmoid.configuration
        function onSelectedTimeZonesChanged() {
            root.initTimeZones();
        }
        function onUse24hFormatChanged() {
            root.timeFormatCorrection();
        }
        function onShowSecondsChanged() {
            root.timeFormatCorrection();
        }
    }

    Component.onCompleted: {
        Plasmoid.configuration.selectedTimeZones =
            DigitalClockPrivate.TimeZoneUtils.sortedTimeZones(Plasmoid.configuration.selectedTimeZones);

        root.initTimeZones();
        root.timeFormatCorrection();
    }
}

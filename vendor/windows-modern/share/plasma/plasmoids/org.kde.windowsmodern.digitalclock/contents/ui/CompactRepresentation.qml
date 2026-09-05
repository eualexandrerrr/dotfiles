/*
    SPDX-FileCopyrightText: 2026 Jeysef

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.clock as PlasmaClock
import org.kde.plasma.private.digitalclock as DigitalClockPrivate
import org.kde.kirigami as Kirigami

MouseArea {
    id: main
    objectName: "windowsmodern-digitalclock-compactrepresentation"

    activeFocusOnTab: true
    hoverEnabled: true

    Layout.fillWidth: false
    Layout.fillHeight: true

    required property var plasmoidItem

    // Panel cell dimensions.
    readonly property real panelHeight: parent ? parent.height : height
    readonly property real padding: Plasmoid.configuration.compactPadding
    readonly property real maxContentHeight: Math.max(1, panelHeight * (1 - 2 * padding))

    implicitWidth: contentLayout.implicitWidth + Kirigami.Units.largeSpacing
    implicitHeight: panelHeight

    // Font configured by the user or theme defaults.
    readonly property font baseFont: {
        if (Plasmoid.configuration.autoFontAndSize || Plasmoid.configuration.fontFamily.length === 0) {
            return Kirigami.Theme.defaultFont;
        } else {
            return Qt.font({
                family: Plasmoid.configuration.fontFamily,
                pointSize: Plasmoid.configuration.fontSize,
                weight: Plasmoid.configuration.fontWeight,
                styleName: Plasmoid.configuration.fontStyleName,
                italic: Plasmoid.configuration.italicText
            });
        }
    }

    readonly property string timezoneString: {
        const showTimezone = Plasmoid.configuration.showLocalTimezone
            || (Plasmoid.configuration.lastSelectedTimezone !== "Local"
                && !clock.isSystemTimeZone);

        if (!showTimezone) {
            return "";
        }

        switch (Plasmoid.configuration.displayTimezoneFormat) {
        case 0: // Code
            return clock.timeZoneCode;
        case 1: // City
            return DigitalClockPrivate.TimeZonesI18n.i18nCity(clock.timeZone);
        case 2: // Offset from UTC time
            return clock.timeZoneOffset;
        }
        return "";
    }

    readonly property bool showDate: Plasmoid.configuration.showDate
    readonly property bool showTimezone: timezoneString.length > 0

    // Height ratios for stacked labels. Ratios always sum to 1 when visible.
    readonly property real timeHeightRatio: {
        if (showDate && showTimezone) return 0.55;
        if (showDate || showTimezone) return 0.65;
        return 1.0;
    }
    readonly property real dateHeightRatio: {
        if (showDate && showTimezone) return 0.30;
        if (showDate) return 0.35;
        return 0;
    }
    readonly property real tzHeightRatio: showTimezone ? (showDate ? 0.15 : 0.35) : 0

    function pointToPixel(pointSize: int): int {
        const pixelsPerInch = Screen.pixelDensity * 25.4;
        return Math.round(pointSize / 72 * pixelsPerInch);
    }

    function dateFormatter(d: date): string {
        const format = Plasmoid.configuration.dateFormat;
        if (format === "custom") {
            return Qt.locale().toString(d, Plasmoid.configuration.customDateFormat);
        } else if (format === "isoDate") {
            return Qt.formatDate(d, Qt.ISODate);
        } else if (format === "longDate") {
            return Qt.formatDate(d, Qt.locale(), Locale.LongFormat);
        } else {
            return Qt.formatDate(d, Qt.locale(), Locale.ShortFormat);
        }
    }

    Accessible.role: Accessible.Button
    Accessible.name: timeLabel.text + (dateLabel.visible ? ", " + dateLabel.text : "")

    acceptedButtons: Qt.LeftButton

    onClicked: mouse => {
        if (mouse.button === Qt.LeftButton) {
            plasmoidItem.expanded = !plasmoidItem.expanded;
        }
    }

    PlasmaClock.Clock {
        id: clock
        timeZone: Plasmoid.configuration.lastSelectedTimezone
        trackSeconds: Plasmoid.configuration.showSeconds === 2 // Always
    }

    ColumnLayout {
        id: contentLayout
        anchors.centerIn: parent
        width: parent.width
        height: main.maxContentHeight
        spacing: Kirigami.Units.smallSpacing / 2

        PlasmaComponents.Label {
            id: timeLabel

            Layout.fillWidth: true
            Layout.preferredHeight: main.maxContentHeight * main.timeHeightRatio

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            textFormat: Text.PlainText

            text: Qt.locale().toString(clock.dateTime, Plasmoid.configuration.showSeconds === 2 ? root.timeFormatWithSeconds : root.timeFormat)

            font {
                family: main.baseFont.family
                weight: main.baseFont.weight
                italic: main.baseFont.italic
                styleName: main.baseFont.styleName
                pixelSize: {
                    if (Plasmoid.configuration.autoFontAndSize) {
                        return Math.round(main.maxContentHeight * main.timeHeightRatio);
                    } else {
                        return Math.min(main.pointToPixel(Plasmoid.configuration.fontSize),
                                        main.maxContentHeight * main.timeHeightRatio);
                    }
                }
                features: { "tnum": 1 }
            }
        }

        PlasmaComponents.Label {
            id: dateLabel

            visible: main.showDate
            Layout.fillWidth: true
            Layout.preferredHeight: main.maxContentHeight * main.dateHeightRatio

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            textFormat: Text.PlainText

            text: main.dateFormatter(clock.dateTime)

            font {
                family: main.baseFont.family
                weight: main.baseFont.weight
                italic: main.baseFont.italic
                styleName: main.baseFont.styleName
                pixelSize: Math.round(timeLabel.font.pixelSize * 0.65)
                features: { "tnum": 1 }
            }
        }

        PlasmaComponents.Label {
            id: timeZoneLabel

            visible: main.showTimezone
            Layout.fillWidth: true
            Layout.preferredHeight: main.maxContentHeight * main.tzHeightRatio

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            textFormat: Text.PlainText

            text: main.timezoneString

            font {
                family: main.baseFont.family
                weight: main.baseFont.weight
                italic: main.baseFont.italic
                styleName: main.baseFont.styleName
                pixelSize: Math.round(timeLabel.font.pixelSize * 0.55)
                features: { "tnum": 1 }
            }
        }
    }
}

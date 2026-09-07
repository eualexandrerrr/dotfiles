/*
    SPDX-FileCopyrightText: 2013 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2026 Jeysef

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.plasma.private.digitalclock as DigitalClockPrivate
import org.kde.kirigami as Kirigami
import org.kde.config as KConfig
import org.kde.kcmutils as KCMUtils
import org.kde.plasma.workspace.timezoneselector as TimeZone

Kirigami.PageRow {
    id: timeZonesRow

    property string title
    property string cfg_lastSelectedTimezone
    property alias cfg_selectedTimeZones: timeZones.selectedTimeZones

    defaultColumnWidth: timeZonesRow.width
    globalToolBar.style: Kirigami.ApplicationHeaderStyle.Auto

    Component.onCompleted: {
        timeZonesRow.realFooter = applicationWindow().footer
    }

    onVisibleChanged: {
        if (!visible && timeZonesRow.fakeFooter.parent) {
            applicationWindow().footer = timeZonesRow.realFooter
            timeZonesRow.fakeFooter.parent = null
        }
    }

    onCurrentIndexChanged: {
        if (currentIndex == 1) {
            applicationWindow().footer = timeZonesRow.fakeFooter
            timeZonesRow.realFooter.parent = null
        } else {
            applicationWindow().footer = timeZonesRow.realFooter
            timeZonesRow.fakeFooter.parent = null
        }
    }

    property Item realFooter
    property Item fakeFooter: QQC2.DialogButtonBox {
        background: Item {
            Kirigami.Separator {
                id: bottomSeparator
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
            }
        }
        QQC2.Button {
            text: i18n("Cancel")
            onClicked: {
                timeZonesRow.currentIndex = 0
                timeZoneSelector.selectedTimeZone = ""
            }
        }
        QQC2.Button {
            text: i18n("Add Selected Time Zone")
            icon.name: "list-add"
            enabled: timeZoneSelector.selectedTimeZone
            onClicked: {
                timeZones.selectedTimeZones = [...timeZones.selectedTimeZones, timeZoneSelector.selectedTimeZone]
                timeZoneSelector.selectedTimeZone = ""
                timeZonesRow.currentIndex = 0
            }
        }
    }

    initialPage: KCMUtils.ScrollViewKCM {
        title: timeZonesRow.title

        actions: [
            Kirigami.Action {
                text: i18n("Add Time Zone…")
                icon.name: "list-add-symbolic"
                Accessible.name: text
                onTriggered: {
                    if (timeZonesRow.depth == 1) {
                        timeZonesRow.push(timeZonesRow.addTimeZonePage)
                    } else {
                        timeZonesRow.currentIndex = 1
                    }
                }
            }
        ]

        DigitalClockPrivate.TimeZoneModel {
            id: timeZones

            onSelectedTimeZonesChanged: {
                if (selectedTimeZones.length === 0) {
                    // Don't let the user remove all time zones.
                    timeZones.selectLocalTimeZone();
                }
            }
        }

        view: ListView {
            id: configuredTimeZoneList
            clip: true
            focus: true
            activeFocusOnTab: true

            model: DigitalClockPrivate.TimeZoneFilterProxy {
                sourceModel: timeZones
                onlyShowChecked: true
            }
            currentIndex: -1

            delegate: Kirigami.RadioSubtitleDelegate {
                id: timeZoneListItem

                required property int index
                required property var model

                readonly property bool isCurrent: timeZonesRow.cfg_lastSelectedTimezone === model.timeZoneId
                readonly property bool isIdenticalToLocal: !model.isLocalTimeZone && model.city === timeZones.localTimeZoneCity()

                width: ListView.view.width

                font.bold: isCurrent

                Kirigami.Theme.useAlternateBackgroundColor: true

                text: model.city
                subtitle: {
                    if (configuredTimeZoneList.count > 1) {
                        if (isCurrent) {
                            return i18n("Clock is currently using this time zone");
                        } else if (isIdenticalToLocal) {
                            return i18nc("@label This list item shows a time zone city name that is identical to the local time zone's city, and will be hidden in the time zone display in the plasmoid's popup", "Hidden while this is the local time zone's city");
                        }
                    }
                    return "";
                }

                checked: isCurrent

                onToggled: {
                    if (checked) {
                        timeZonesRow.cfg_lastSelectedTimezone = model.timeZoneId;
                    }
                }

                contentItem: RowLayout {
                    spacing: Kirigami.Units.smallSpacing

                    Kirigami.TitleSubtitle {
                        Layout.fillWidth: true

                        opacity: timeZoneListItem.isIdenticalToLocal ? 0.75 : 1.0

                        title: timeZoneListItem.text
                        subtitle: timeZoneListItem.subtitle

                        reserveSpaceForSubtitle: true
                    }

                    QQC2.Button {
                        visible: timeZoneListItem.model.isLocalTimeZone && KConfig.KAuthorized.authorizeControlModule("kcm_clock.desktop")
                        text: i18n("Switch Systemwide Time Zone…")
                        icon.name: "preferences-system-time"
                        font.bold: false
                        onClicked: KCMUtils.KCMLauncher.openSystemSettings("kcm_clock")
                    }

                    QQC2.Button {
                        visible: !timeZoneListItem.model.isLocalTimeZone && configuredTimeZoneList.count > 1
                        icon.name: "edit-delete-remove"
                        font.bold: false
                        onClicked: timeZoneListItem.model.checked = false;
                        QQC2.ToolTip {
                            text: i18n("Remove this time zone")
                        }
                    }
                }
            }

            section {
                property: "isLocalTimeZone"
                delegate: Kirigami.ListSectionHeader {
                    required property string section

                    width: configuredTimeZoneList.width
                    text: section === "true" ? i18n("Systemwide Time Zone") : i18n("Additional Time Zones")
                }
            }

            Kirigami.PlaceholderMessage {
                visible: configuredTimeZoneList.count === 1
                anchors {
                    top: parent.verticalCenter
                    left: parent.left
                    right: parent.right
                    leftMargin: Kirigami.Units.largeSpacing * 6
                    rightMargin: Kirigami.Units.largeSpacing * 6
                }
                text: i18n("Add more time zones to display all of them in the applet's pop-up, or use one of them for the clock itself")
            }
        }

        extraFooterTopPadding: true
    }

    property Item addTimeZonePage: Kirigami.Page {
        padding: 0
        title: i18n("Choose Time Zone")

        Layout.fillHeight: true
        Layout.fillWidth: true

        TimeZone.TimezoneSelector {
            id: timeZoneSelector
            anchors.fill: parent
        }
    }
}

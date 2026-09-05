/*
    SPDX-FileCopyrightText: 2013 Bhushan Shah <bhush94@gmail.com>
    SPDX-FileCopyrightText: 2015 Martin Klapetek <mklapetek@kde.org>
    SPDX-FileCopyrightText: 2026 Jeysef

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick

import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
         name: i18n("Appearance")
         icon: "preferences-desktop-color"
         source: "configAppearance.qml"
    }
    ConfigCategory {
        name: i18n("Calendar")
        icon: "office-calendar"
        source: "configCalendar.qml"
    }
    ConfigCategory {
        name: i18n("Time Zones")
        icon: "preferences-system-time"
        source: "configTimeZones.qml"
    }
}

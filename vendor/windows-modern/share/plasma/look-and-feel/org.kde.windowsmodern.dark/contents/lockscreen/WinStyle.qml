pragma Singleton

/*
 * SPDX-FileCopyrightText: 2026 Jeysef
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick

QtObject {
    readonly property color foregroundColor: "#FFFFFF"
    readonly property color secondaryForegroundColor: "#E0E0E0"
    readonly property color mutedForegroundColor: "#A0A0A0"
    readonly property color accentColor: "#4CC2FF"
    readonly property color dimOverlayColor: "#000000"
    readonly property real dimOverlayOpacity: 0.45
    readonly property color panelBackground: "#40000000"
    readonly property color menuBackground: "#2C2C2C"
    readonly property color menuBorder: "#3F3F3F"
    readonly property color hoverBackground: "#33FFFFFF"

    readonly property string fontFamily: "Segoe UI"

    readonly property int avatarSize: 140
    readonly property int textFieldHeight: 36
    readonly property int textFieldMaxWidth: 380
    readonly property int loginButtonSize: 32
    readonly property int userSwitcherAvatarSize: 32
    readonly property int userSwitcherItemHeight: 32
    readonly property int powerMenuWidth: 150
    readonly property int powerMenuItemHeight: 36

    readonly property int clockTimePixelSize: 96
    readonly property int clockDatePixelSize: 24
    readonly property int usernamePixelSize: 32
    readonly property int bodyPixelSize: 14
    readonly property int userSwitcherNamePixelSize: 20
}

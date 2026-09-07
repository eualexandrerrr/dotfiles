/*
    SPDX-FileCopyrightText: 2026 Jeysef

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import org.kde.kirigami as Kirigami

// Windows 11 color tokens from docs/STYLE.md, resolved against the active
// Kirigami theme so both the dark and light global variants are supported.
QtObject {
    readonly property bool isDark: {
        const bg = Kirigami.Theme.backgroundColor;
        return (bg.r * 0.299 + bg.g * 0.587 + bg.b * 0.114) < 0.5;
    }

    readonly property color background:       isDark ? "#202020" : "#F9F9F9"
    readonly property color surface:          isDark ? "#2C2C2C" : "#FFFFFF"
    readonly property color surfaceBorder:    isDark ? "#3F3F3F" : "#E5E5E5"
    readonly property color text:             isDark ? "#FFFFFF" : "#1E1E1E"
    readonly property color textSecondary:    isDark ? "#9C9C9C" : "#5A5A5A"
    readonly property color textDisabled:     isDark ? "#5A5A5A" : "#A0A0A0"
    readonly property color accent:           isDark ? "#4CC2FF" : "#0067C0"
    readonly property color accentText:       "#FFFFFF"
    readonly property color hover:            isDark ? "#3F3F3F" : "#E9E9E9"
    readonly property color pressed:          isDark ? "#4A4A4A" : "#DADADA"
    readonly property color selected:         isDark ? "#2C2C2C" : "#F3F3F3"
}

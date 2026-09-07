/*
 * SPDX-FileCopyrightText: 2026 Jeysef
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls 2.15 as QQC2

QQC2.ToolButton {
    id: root

    property bool layoutMirrored: false

    width: WinStyle.loginButtonSize
    height: WinStyle.loginButtonSize

    icon.name: root.layoutMirrored ? "go-previous" : "go-next"
    icon.color: root.hovered ? WinStyle.accentColor : WinStyle.mutedForegroundColor

    background: Rectangle {
        color: root.hovered ? WinStyle.hoverBackground : "transparent"
    }

}

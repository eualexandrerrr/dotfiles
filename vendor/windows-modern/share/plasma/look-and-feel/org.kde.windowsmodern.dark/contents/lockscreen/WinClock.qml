/*
 * SPDX-FileCopyrightText: 2026 Jeysef
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami

Column {
    id: root

    property real opacityWhenInactive: 1
    property real opacityWhenActive: 0
    property bool uiVisible: false

    spacing: Kirigami.Units.smallSpacing / 2
    opacity: uiVisible ? opacityWhenActive : opacityWhenInactive

    Behavior on opacity {
        OpacityAnimator {
            duration: Kirigami.Units.veryLongDuration * 2
            easing.type: Easing.InOutQuad
        }
    }

    Text {
        id: timeText
        text: Qt.formatTime(new Date(), "HH:mm")
        font.family: WinStyle.fontFamily
        font.weight: Font.DemiBold
        font.pixelSize: WinStyle.clockTimePixelSize
        color: WinStyle.foregroundColor
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        id: dateText
        text: Qt.formatDate(new Date(), "dddd, MMMM d")
        font.family: WinStyle.fontFamily
        font.pixelSize: WinStyle.clockDatePixelSize
        color: WinStyle.secondaryForegroundColor
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            const now = new Date();
            timeText.text = Qt.formatTime(now, "HH:mm");
            dateText.text = Qt.formatDate(now, "dddd, MMMM d");
        }
    }
}

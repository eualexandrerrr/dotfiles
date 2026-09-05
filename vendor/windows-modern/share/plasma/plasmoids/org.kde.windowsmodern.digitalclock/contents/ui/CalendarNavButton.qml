/*
    SPDX-FileCopyrightText: 2026 Jeysef

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick

import org.kde.kirigami as Kirigami

// Small Windows-11-style chevron button used for month navigation.
MouseArea {
    id: root

    property bool up: true

    property color glyphColor: "#FFFFFF"
    property color hoverColor: "#3F3F3F"
    property color pressedColor: "#4A4A4A"

    width: Kirigami.Units.gridUnit * 1.75
    height: Kirigami.Units.gridUnit * 1.5

    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    Rectangle {
        anchors.fill: parent
        radius: 4
        color: root.containsPress ? root.pressedColor
                                  : (root.containsMouse ? root.hoverColor : "transparent")

        Behavior on color {
            ColorAnimation {
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    Canvas {
        anchors.centerIn: parent
        width: 10
        height: 6

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            ctx.strokeStyle = root.glyphColor;
            ctx.lineWidth = 1.5;
            ctx.lineCap = "round";
            ctx.lineJoin = "round";
            ctx.beginPath();
            if (root.up) {
                ctx.moveTo(0, 5);
                ctx.lineTo(5, 0);
                ctx.lineTo(10, 5);
            } else {
                ctx.moveTo(0, 1);
                ctx.lineTo(5, 6);
                ctx.lineTo(10, 1);
            }
            ctx.stroke();
        }
    }
}

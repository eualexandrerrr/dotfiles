/*
 * SPDX-FileCopyrightText: 2026 Jeysef
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls 2.15 as QQC2

FocusScope {
    id: root

    property alias text: textField.text
    property alias placeholderText: textField.placeholderText
    property alias echoMode: textField.echoMode
    property alias textField: textField
    property bool initialFocus: false
    property bool drawBackground: true
    property int leftPadding: 10
    property int rightPadding: 10

    signal accepted()
    signal escapePressed()
    signal keyPressed(event: var)

    function forceActiveFocusOnTextField(reason) {
        textField.forceActiveFocus(reason);
    }

    // Expose focus to the parent focus chain so this FocusScope is found
    // automatically when the form is shown; active focus is then forwarded
    // to the inner TextField below.
    focus: root.initialFocus

    implicitHeight: WinStyle.textFieldHeight

    Rectangle {
        anchors.fill: parent
        visible: root.drawBackground
        color: "transparent"
        border.color: textField.activeFocus ? WinStyle.accentColor : WinStyle.mutedForegroundColor
        radius: 0
    }

    QQC2.TextField {
        id: textField
        anchors.fill: parent
        leftPadding: root.leftPadding
        rightPadding: root.rightPadding
        verticalAlignment: TextInput.AlignVCenter
        focus: root.initialFocus

        color: WinStyle.foregroundColor
        placeholderTextColor: WinStyle.mutedForegroundColor
        font.family: WinStyle.fontFamily
        font.pixelSize: WinStyle.bodyPixelSize
        background: Item {}

        onAccepted: root.accepted()
        Keys.onEscapePressed: root.escapePressed()
        Keys.onPressed: event => root.keyPressed(event)
    }
}

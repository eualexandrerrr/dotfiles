/*
    SPDX-FileCopyrightText: 2016 David Edmundson <davidedmundson@kde.org>
    SPDX-FileCopyrightText: 2025 Windows Modern Theme

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.kscreenlocker as ScreenLocker

import org.kde.breeze.components

SessionManagementScreen {
    id: sessionManager

    actionItems: [ Item { visible: false } ]

    readonly property alias mainPasswordBox: passwordBox
    property bool lockScreenUiVisible: false
    property alias showPassword: passwordBox.showPassword
    property bool lockedOut: false

    showUserList: true
    property string customErrorMessage: ""
    notificationMessage: "" // Silence default top-aligned banner

    property int visibleBoundary: mapFromItem(loginButton, 0, 0).y
    onHeightChanged: visibleBoundary = mapFromItem(loginButton, 0, 0).y + loginButton.height + Kirigami.Units.smallSpacing

    signal passwordResult(string password)

    onUserSelected: {
        const nextControl = passwordBox;
        nextControl.forceActiveFocus(Qt.TabFocusReason);
    }

    function startLogin() {
        if (sessionManager.lockedOut) {
            return;
        }
        const password = passwordBox.text
        loginButton.forceActiveFocus();
        passwordResult(password);
    }

    Component.onCompleted: {
        if (sessionManager.userList) {
            sessionManager.userList.visible = false;
            sessionManager.userList.opacity = 0;
            sessionManager.userList.height = 0;
        }
    }

    // ── Custom avatar (replaces built-in UserList) ──
    Item {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 140
        Layout.preferredHeight: 140
        Layout.bottomMargin: 16

        Image {
            id: avatarImg
            anchors.fill: parent
            source: {
                if (sessionManager.userListModel && sessionManager.userListModel.count > 0) {
                    const icon = sessionManager.userListModel.get(0).icon;
                    if (icon) return icon;
                }
                return "";
            }
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(140, 140)
            asynchronous: true

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: 140; height: 140
                    radius: 70
                }
            }
        }
    }

    // ── Username ──
    Text {
        Layout.alignment: Qt.AlignHCenter
        Layout.bottomMargin: 4
        text: {
            if (sessionManager.userListModel && sessionManager.userListModel.count > 0) {
                const item = sessionManager.userListModel.get(0);
                if (item.realName) return item.realName;
                if (item.name) return item.name;
            }
            return "";
        }
        font.family: "Segoe UI"
        font.pixelSize: 32
        font.weight: Font.Normal
        color: "#FFFFFF"
        horizontalAlignment: Text.AlignHCenter
    }

    // ── Custom Error Message (Windows 10 style) ──
    Item {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredHeight: 20
        Layout.bottomMargin: 0

        Text {
            anchors.centerIn: parent
            visible: sessionManager.customErrorMessage !== ""
            text: sessionManager.customErrorMessage
            font.family: "Segoe UI"
            font.pixelSize: 14
            font.italic: true
            color: "#A0A0A0"
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // ── MDL2 password field + submit button ──
    Item {
        Layout.fillWidth: true
        implicitHeight: 32

        Rectangle {
            id: passwordBorder
            anchors.fill: parent
            color: passwordBox.focus ? "#40000000" : "#40000000"
            border.color: passwordBox.focus ? "#4CC2FF" : "#A0A0A0"
            radius: 0
        }

        TextField {
            id: passwordBox
            anchors.left: parent.left
            anchors.right: loginButton.left
            anchors.rightMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            height: 32

            property bool showPassword: false
            echoMode: showPassword ? TextInput.Normal : TextInput.Password
            placeholderText: i18ndc("plasma_shell_org.kde.plasma.desktop", "@info:placeholder in text field", "Password")
            placeholderTextColor: "#A0A0A0"
            font.family: "Segoe UI"
            font.pixelSize: 14
            color: "#FFFFFF"
            focus: true
            leftPadding: 8
            verticalAlignment: TextInput.AlignVCenter
            cursorVisible: visible && focus
            activeFocusOnTab: true

            background: Item {}

            onAccepted: {
                if (sessionManager.lockScreenUiVisible && !sessionManager.lockedOut) {
                    sessionManager.startLogin();
                }
            }

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Left && !text) {
                    sessionManager.userList.decrementCurrentIndex();
                    event.accepted = true
                }
                if (event.key === Qt.Key_Right && !text) {
                    sessionManager.userList.incrementCurrentIndex();
                    event.accepted = true
                }
            }

            Connections {
                target: root
                function onClearPassword() {
                    passwordBox.forceActiveFocus()
                    passwordBox.text = "";
                }
                function onNotificationRepeated() {
                    sessionManager.playHighlightAnimation();
                }
            }
        }

        ToolButton {
            id: loginButton
            anchors.right: parent.right
            anchors.rightMargin: 2
            anchors.verticalCenter: parent.verticalCenter
            width: 28
            height: 28

            icon.name: LayoutMirroring.enabled ? "go-previous" : "go-next"
            visible: passwordBox.text.length > 0
            icon.color: hovered ? "#4CC2FF" : "#A0A0A0"

            onClicked: {
                if (!sessionManager.lockedOut) {
                    sessionManager.startLogin();
                }
            }
            Keys.onEnterPressed: {
                if (!sessionManager.lockedOut) {
                    clicked();
                }
            }
            Keys.onReturnPressed: {
                if (!sessionManager.lockedOut) {
                    clicked();
                }
            }

            background: Rectangle {
                color: parent.hovered ? "#33FFFFFF" : "transparent"
            }
        }
    }

    component FailableLabel : PlasmaComponents3.Label {
        id: _failableLabel
        required property int kind
        required property string label

        visible: authenticator.authenticatorTypes & kind
        text: label
        textFormat: Text.PlainText
        horizontalAlignment: Text.AlignHCenter
        Layout.fillWidth: true
        font.family: "Segoe UI"
        font.pixelSize: 12
        color: "#A0A0A0"

        RejectPasswordAnimation {
            id: _rejectAnimation
            target: _failableLabel
            onFinished: _timer.restart()
        }

        Connections {
            target: authenticator
            function onNoninteractiveError(kind, authenticator) {
                if (kind & _failableLabel.kind) {
                    _failableLabel.text = Qt.binding(() => authenticator.errorMessage)
                    _rejectAnimation.start()
                }
            }
        }
        Timer {
            id: _timer
            interval: Kirigami.Units.humanMoment
            onTriggered: {
                _failableLabel.text = Qt.binding(() => _failableLabel.label)
            }
        }
    }

    FailableLabel {
        kind: ScreenLocker.Authenticator.Fingerprint
        label: i18ndc("plasma_shell_org.kde.plasma.desktop", "@info:usagetip", "(or scan your fingerprint on the reader)")
    }
    FailableLabel {
        kind: ScreenLocker.Authenticator.Smartcard
        label: i18ndc("plasma_shell_org.kde.plasma.desktop", "@info:usagetip", "(or scan your smartcard)")
    }
}

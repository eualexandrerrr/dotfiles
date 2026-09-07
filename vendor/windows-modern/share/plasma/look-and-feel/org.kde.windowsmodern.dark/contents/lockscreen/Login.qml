/*
 * SPDX-FileCopyrightText: 2026 Jeysef
 * SPDX-FileCopyrightText: Oliver Beard
 * SPDX-FileCopyrightText: David Edmundson
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2

import org.kde.breeze.components
import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.login as PlasmaLogin

SessionManagementScreen {
    id: root

    property Item mainPasswordBox: passwordField

    property bool showUsernamePrompt: !showUserList
    property bool loginScreenUiVisible: false
    onLoginScreenUiVisibleChanged: {
        if (loginScreenUiVisible) {
            Qt.callLater(focusFirstVisibleFormControl);
        }
    }

    signal loginRequest(string username, string password)

    // Silence the built-in action items layout; we provide our own login UI.
    actionItems: [ Item { visible: false } ]

    // Silence the default top-aligned message; we render errors inline.
    notificationMessage: ""

    // Combined inline error message (Caps Lock + notifications).
    property string customErrorMessage: ""

    // The built-in user list must stay enabled so avatar data and GreeterState
    // sync keep working, but we render our own user switcher and avatar.
    showUserList: true
    userListCurrentIndex: {
        let preselectedUserIndex = PlasmaLogin.UserModel.indexOfData(PlasmaLogin.Settings.preselectedUser, PlasmaLogin.UserModel.NameRole);
        let lastLoggedInUserIndex = PlasmaLogin.UserModel.indexOfData(PlasmaLogin.StateConfig.lastLoggedInUser, PlasmaLogin.UserModel.NameRole);

        if (preselectedUserIndex !== -1) {
            return preselectedUserIndex;
        } else if (lastLoggedInUserIndex !== -1) {
            return lastLoggedInUserIndex;
        } else {
            return 0;
        }
    }

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    Kirigami.Theme.inherit: false

    Component.onCompleted: {
        if (root.userList) {
            root.userList.visible = false;
            root.userList.opacity = 0;
            root.userList.height = 0;
        }
        // FocusScope wrappers prevent the inner TextField from getting active
        // focus automatically from the focus: binding alone. Force it after
        // the initial state is set so typing works immediately.
        Qt.callLater(focusFirstVisibleFormControl);
    }

    onUserSelected: {
        passwordField.text = "";
        focusFirstVisibleFormControl();
    }

    function focusFirstVisibleFormControl() {
        // Focus the WinTextField FocusScope, which forwards active focus to
        // its inner TextField. Directly forcing focus on the inner TextField
        // does not work because FocusScope sits between it and the scene.
        const nextControl = (userNameInput.visible && !userNameInput.text
            ? userNameInput
            : (passwordField.visible
                ? passwordField
                : loginButton));
        nextControl.forceActiveFocus(Qt.TabFocusReason);
    }

    function startLogin() {
        const username = showUsernamePrompt ? userNameInput.text : userList.selectedUser;
        const password = passwordField.text;
        loginButton.forceActiveFocus();
        loginRequest(username, password);
    }

    // ── Avatar ──
    WinAvatar {
        Layout.alignment: Qt.AlignHCenter
        Layout.bottomMargin: 16
        size: WinStyle.avatarSize
        source: {
            if (!root.showUsernamePrompt && userList.currentItem && userList.currentItem.icon) {
                return userList.currentItem.icon;
            }
            return Qt.resolvedUrl("faces/.face.icon");
        }
    }

    // ── Username label ──
    Text {
        Layout.alignment: Qt.AlignHCenter
        Layout.bottomMargin: 4
        text: {
            if (root.showUsernamePrompt) {
                return "User";
            }
            if (userList.currentItem && userList.currentItem.realName) {
                return userList.currentItem.realName;
            }
            return "";
        }
        font.family: WinStyle.fontFamily
        font.pixelSize: WinStyle.usernamePixelSize
        font.weight: Font.Normal
        color: WinStyle.foregroundColor
        horizontalAlignment: Text.AlignHCenter
    }

    // ── Error message ──
    Item {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredHeight: 20
        Layout.bottomMargin: 0

        Text {
            anchors.centerIn: parent
            visible: root.customErrorMessage !== ""
            text: root.customErrorMessage
            font.family: WinStyle.fontFamily
            font.pixelSize: WinStyle.bodyPixelSize
            font.italic: true
            color: WinStyle.mutedForegroundColor
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // ── Username input ──
    WinTextField {
        id: userNameInput
        Layout.fillWidth: true
        Layout.maximumWidth: WinStyle.textFieldMaxWidth
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredHeight: WinStyle.textFieldHeight

        text: ""
        visible: showUsernamePrompt
        initialFocus: showUsernamePrompt
        placeholderText: i18nd("plasma_login", "Username")

        onAccepted: {
            if (root.loginScreenUiVisible) {
                passwordField.forceActiveFocusOnTextField();
            }
        }
    }

    // ── Password field + submit button ──
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: WinStyle.textFieldHeight
        Layout.maximumWidth: WinStyle.textFieldMaxWidth
        Layout.alignment: Qt.AlignHCenter
        visible: root.showUsernamePrompt || (userList.currentItem && userList.currentItem.needsPassword)

        Rectangle {
            anchors.fill: parent
            color: WinStyle.panelBackground
            border.color: passwordField.textField.activeFocus ? WinStyle.accentColor : WinStyle.mutedForegroundColor
            radius: 0
        }

        WinTextField {
            id: passwordField
            anchors.left: parent.left
            anchors.right: loginButton.left
            anchors.rightMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            drawBackground: false
            leftPadding: 10
            rightPadding: 10

            text: ""
            placeholderText: i18nd("plasma_login", "Password")
            echoMode: TextInput.Password
            initialFocus: !showUsernamePrompt

            onAccepted: {
                if (root.loginScreenUiVisible) {
                    root.startLogin();
                }
            }

            onEscapePressed: {
                if (mainStack.currentItem) {
                    mainStack.currentItem.forceActiveFocus();
                }
            }

            onKeyPressed: event => {
                if (event.key === Qt.Key_Left && !text) {
                    userList.decrementCurrentIndex();
                    event.accepted = true;
                }
                if (event.key === Qt.Key_Right && !text) {
                    userList.incrementCurrentIndex();
                    event.accepted = true;
                }
            }

            Connections {
                target: PlasmaLogin.Authenticator
                function onLoginFailed() {
                    passwordField.textField.selectAll();
                    passwordField.forceActiveFocusOnTextField();
                }
            }
        }

        WinLoginButton {
            id: loginButton
            anchors.right: parent.right
            anchors.rightMargin: 2
            anchors.verticalCenter: parent.verticalCenter
            layoutMirrored: root.LayoutMirroring.enabled
            visible: passwordField.text.length > 0 || !root.showUsernamePrompt
            onClicked: root.startLogin()
            Keys.onEnterPressed: clicked()
            Keys.onReturnPressed: clicked()
        }
    }

    // ── No-password login button ──
    QQC2.Button {
        Layout.alignment: Qt.AlignHCenter
        text: i18nd("plasma_login", "Log In")
        visible: !root.showUsernamePrompt && userList.currentItem && !userList.currentItem.needsPassword
        onClicked: root.startLogin()
        flat: true
    }

    // ── Synchronize state with GreeterState ──
    Item {
        id: sync

        readonly property bool isUserList: root.showUserList && !root.showUsernamePrompt

        Component.onCompleted: {
            if (sync.isUserList) {
                root.userList.currentIndex = PlasmaLogin.GreeterState.userListIndex;
                passwordField.text = PlasmaLogin.GreeterState.userListPassword;
            } else {
                userNameInput.text = PlasmaLogin.GreeterState.userPromptUsername;
                passwordField.text = PlasmaLogin.GreeterState.userPromptPassword;
                root.focusFirstVisibleFormControl();
            }
            passwordField.echoMode = PlasmaLogin.GreeterState.showPassword ? TextInput.Normal : TextInput.Password;
        }

        Connections {
            target: root.userList
            function onCurrentIndexChanged() {
                if (!sync.isUserList) {
                    return;
                }
                if (PlasmaLogin.GreeterState.userListIndex != root.userList.currentIndex) {
                    PlasmaLogin.GreeterState.userListIndex = root.userList.currentIndex;
                }
            }
        }

        Connections {
            target: userNameInput.textField
            function onTextChanged() {
                if (!sync.isUserList) {
                    if (PlasmaLogin.GreeterState.userPromptUsername != userNameInput.text) {
                        PlasmaLogin.GreeterState.userPromptUsername = userNameInput.text;
                    }
                }
            }
        }

        Connections {
            target: passwordField.textField
            function onTextChanged() {
                if (sync.isUserList) {
                    if (PlasmaLogin.GreeterState.userListPassword != passwordField.text) {
                        PlasmaLogin.GreeterState.userListPassword = passwordField.text;
                    }
                } else {
                    if (PlasmaLogin.GreeterState.userPromptPassword != passwordField.text) {
                        PlasmaLogin.GreeterState.userPromptPassword = passwordField.text;
                    }
                }
            }
        }

        Connections {
            target: PlasmaLogin.GreeterState
            function onUserListIndexChanged() {
                if (!sync.isUserList) {
                    return;
                }
                if (root.userList.currentIndex != PlasmaLogin.GreeterState.userListIndex) {
                    root.userList.currentIndex = PlasmaLogin.GreeterState.userListIndex;
                }
            }
            function onUserListPasswordChanged() {
                if (!sync.isUserList) {
                    return;
                }
                if (passwordField.text != PlasmaLogin.GreeterState.userListPassword) {
                    passwordField.text = PlasmaLogin.GreeterState.userListPassword;
                }
            }
            function onUserPromptUsernameChanged() {
                if (sync.isUserList) {
                    return;
                }
                if (userNameInput.text != PlasmaLogin.GreeterState.userPromptUsername) {
                    userNameInput.text = PlasmaLogin.GreeterState.userPromptUsername;
                }
            }
            function onUserPromptPasswordChanged() {
                if (sync.isUserList) {
                    return;
                }
                if (passwordField.text != PlasmaLogin.GreeterState.userPromptPassword) {
                    passwordField.text = PlasmaLogin.GreeterState.userPromptPassword;
                }
            }
        }
    }

}

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

import org.kde.kirigami 2.20 as Kirigami
import org.kde.breeze.components as BreezeComponents
import org.kde.plasma.private.keyboardindicator as KeyboardIndicator

import org.kde.plasma.login as PlasmaLogin

Item {
    id: root
    anchors.fill: parent

    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software

    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    Kirigami.Theme.inherit: false

    property string notificationMessage

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    KeyboardIndicator.KeyState {
        id: capsLockState
        key: Qt.Key_CapsLock
    }

    BreezeComponents.RejectPasswordAnimation {
        id: rejectPasswordAnimation
        target: mainStack
    }

    Connections {
        target: greeterEventFilter

        function onKeyPressed(): void {
            // callLater, as otherwise 'enter' key press would arrive after waking
            // and the uiVisible check would pass and a login attempt would be made
            Qt.callLater(() => PlasmaLogin.GreeterState.activateWindow(loginScreenRoot.Window.window));
        }

        function onEscapeKeyPressed(): void {
            PlasmaLogin.GreeterState.timeoutWindow(loginScreenRoot.Window.window);
            PlasmaLogin.GreeterState.clearPasswords();
        }
    }

    // ── Background dimming overlay ──
    // The greeter window is transparent (set in main.cpp). PLM's wallpaper
    // plugin renders behind it and is blurred via BlurScreenBridge when the UI
    // is visible. We only add a Win11-style dark dimming overlay on top.
    Rectangle {
        anchors.fill: parent
        color: WinStyle.dimOverlayColor
        opacity: loginScreenRoot.uiVisible ? WinStyle.dimOverlayOpacity : 0.0
        z: -1

        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.veryLongDuration * 2
                easing.type: Easing.InOutQuad
            }
        }
    }

    MouseArea {
        id: loginScreenRoot
        anchors.fill: parent
        hoverEnabled: true

        property bool uiVisible: PlasmaLogin.GreeterState.activeWindow === Window.window

        cursorShape: uiVisible ? Qt.ArrowCursor : Qt.BlankCursor

        onPressed: PlasmaLogin.GreeterState.activateWindow(Window.window);
        onPositionChanged: PlasmaLogin.GreeterState.activateWindow(Window.window);

        // ── Clock ──
        WinClock {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: parent.height * 0.15
            uiVisible: loginScreenRoot.uiVisible
        }

        // ── Main login stack ──
        QQC2.StackView {
            id: mainStack
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -parent.height * 0.15

            width: Math.min(parent.width * 0.9, 480)
            height: Math.min(parent.height * 0.8, 600)

            focus: true
            hoverEnabled: true

            opacity: loginScreenRoot.uiVisible ? 1 : 0
            Behavior on opacity {
                OpacityAnimator {
                    duration: Kirigami.Units.longDuration
                }
            }

            Connections {
                target: PlasmaLogin.GreeterState

                function onLoginStateChanged() {
                    switch (PlasmaLogin.GreeterState.loginState) {
                        case PlasmaLogin.GreeterState.LoginState.UserList:
                            if (mainStack.depth !== 2) {
                                return; /* already showing user list */
                            }
                            mainStack.pop();
                            return;
                        case PlasmaLogin.GreeterState.LoginState.UserPrompt:
                            if (mainStack.depth !== 1) {
                                return; /* already showing user prompt */
                            }
                            mainStack.push(userPromptComponent);
                            return;
                    }
                }
            }

            initialItem: Login {
                id: userListComponent
                userListModel: PlasmaLogin.UserModel
                loginScreenUiVisible: loginScreenRoot.uiVisible

                customErrorMessage: {
                    const parts = [];
                    if (capsLockState.locked) {
                        parts.push(i18nd("plasma_login", "Caps Lock is on"));
                    }
                    if (root.notificationMessage) {
                        parts.push(root.notificationMessage);
                    }
                    return parts.join(" \u2022 ");
                }

                onLoginRequest: (username, password) => root.handleLoginRequest(username, password, sessionButton.currentSessionType, sessionButton.currentSessionFileName)
            }

            readonly property real zoomFactor: 1.5

            popEnter: Transition {
                ScaleAnimator { from: mainStack.zoomFactor; to: 1; duration: Kirigami.Units.veryLongDuration; easing.type: Easing.OutCubic }
                OpacityAnimator { from: 0; to: 1; duration: Kirigami.Units.veryLongDuration; easing.type: Easing.OutCubic }
            }
            popExit: Transition {
                ScaleAnimator { from: 1; to: 1 / mainStack.zoomFactor; duration: Kirigami.Units.veryLongDuration; easing.type: Easing.OutCubic }
                OpacityAnimator { from: 1; to: 0; duration: Kirigami.Units.veryLongDuration; easing.type: Easing.OutCubic }
            }
            pushEnter: Transition {
                ScaleAnimator { from: 1 / mainStack.zoomFactor; to: 1; duration: Kirigami.Units.veryLongDuration; easing.type: Easing.OutCubic }
                OpacityAnimator { from: 0; to: 1; duration: Kirigami.Units.veryLongDuration; easing.type: Easing.OutCubic }
            }
            pushExit: Transition {
                ScaleAnimator { from: 1; to: mainStack.zoomFactor; duration: Kirigami.Units.veryLongDuration; easing.type: Easing.OutCubic }
                OpacityAnimator { from: 1; to: 0; duration: Kirigami.Units.veryLongDuration; easing.type: Easing.OutCubic }
            }
        }

        Component {
            id: userPromptComponent

            Login {
                showUsernamePrompt: true
                loginScreenUiVisible: loginScreenRoot.uiVisible

                customErrorMessage: {
                    const parts = [];
                    if (capsLockState.locked) {
                        parts.push(i18nd("plasma_login", "Caps Lock is on"));
                    }
                    if (root.notificationMessage) {
                        parts.push(root.notificationMessage);
                    }
                    return parts.join(" \u2022 ");
                }

                userListModel: ListModel {
                    ListElement { realName: ""; icon: "" }
                    Component.onCompleted: {
                        setProperty(0, "realName", i18nd("plasma_login", "Type in Username and Password"));
                        setProperty(0, "icon", Qt.resolvedUrl("faces/.face.icon").toString());
                    }
                }

                onLoginRequest: (username, password) => root.handleLoginRequest(username, password, sessionButton.currentSessionType, sessionButton.currentSessionFileName)
            }
        }

        // ── Bottom-left user switcher ──
        WinUserSwitcher {
            id: userListSwitcher
            anchors {
                left: parent.left
                bottom: footer.top
                leftMargin: Kirigami.Units.largeSpacing * 2
                bottomMargin: Kirigami.Units.largeSpacing
            }
            model: PlasmaLogin.UserModel
            uiVisible: loginScreenRoot.uiVisible
        }

        // ── Footer ──
        RowLayout {
            id: footer
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.largeSpacing
            opacity: loginScreenRoot.uiVisible ? 1 : 0

            Behavior on opacity {
                OpacityAnimator {
                    duration: Kirigami.Units.longDuration
                }
            }

            KeyboardButton { id: keyboardButton }

            SessionButton {
                id: sessionButton
                onSessionChanged: userListComponent.mainPasswordBox.forceActiveFocus();
                Layout.fillHeight: true
            }

            Item { Layout.fillWidth: true }

            WinFooterButton {
                iconName: "network-wireless"
            }

            WinFooterButton {
                iconName: "preferences-desktop-accessibility"
            }

            BreezeComponents.Battery {}

            WinFooterButton {
                id: powerButton
                iconName: "system-shutdown"
                onClicked: powerMenu.open()

                WinPowerMenu {
                    id: powerMenu
                    x: parent.width - width
                    y: -implicitHeight
                }
            }
        }
    }

    function handleLoginRequest(username, password, sessionType, sessionFileName) {
        root.notificationMessage = "";
        PlasmaLogin.GreeterState.handleLoginRequest(username, password, sessionType, sessionFileName);
    }

    Connections {
        target: PlasmaLogin.Authenticator

        function onLoginFailed() {
            notificationMessage = i18nd("plasma_login", "Login Failed");
            footer.enabled = true;
            mainStack.enabled = true;
            rejectPasswordAnimation.start();
        }

        function onLoginSucceeded() {
            mainStack.opacity = 0;
            footer.opacity = 0;
        }
    }

    onNotificationMessageChanged: {
        if (notificationMessage) {
            notificationResetTimer.start();
        }
    }

    Timer {
        id: notificationResetTimer
        interval: 3000
        onTriggered: notificationMessage = ""
    }

}

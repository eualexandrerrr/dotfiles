/*
 * SPDX-FileCopyrightText: 2026 Jeysef
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.login as PlasmaLogin

QQC2.Menu {
    id: root

    width: WinStyle.powerMenuWidth

    background: Rectangle {
        color: WinStyle.menuBackground
        border.color: WinStyle.menuBorder
        border.width: 1
    }

    delegate: QQC2.MenuItem {
        id: menuItem
        width: root.width
        height: WinStyle.powerMenuItemHeight

        contentItem: Row {
            spacing: Kirigami.Units.smallSpacing
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12

            Kirigami.Icon {
                source: menuItem.icon.name
                width: 16
                height: 16
                color: WinStyle.foregroundColor
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: menuItem.text
                color: WinStyle.foregroundColor
                font.family: WinStyle.fontFamily
                font.pixelSize: WinStyle.bodyPixelSize
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        background: Rectangle {
            color: menuItem.highlighted ? WinStyle.hoverBackground : "transparent"
        }
    }

    QQC2.MenuItem {
        text: i18nd("plasma_login", "Sleep")
        icon.name: "system-suspend"
        onTriggered: PlasmaLogin.SessionManagement.suspend()
        visible: PlasmaLogin.SessionManagement.canSuspend
    }

    QQC2.MenuItem {
        text: i18nd("plasma_login", "Shut Down")
        icon.name: "system-shutdown"
        onTriggered: PlasmaLogin.SessionManagement.requestShutdown(PlasmaLogin.SessionManagement.ConfirmationMode.Skip)
        visible: PlasmaLogin.SessionManagement.canShutdown
    }

    QQC2.MenuItem {
        text: i18nd("plasma_login", "Restart")
        icon.name: "system-reboot"
        onTriggered: PlasmaLogin.SessionManagement.requestReboot(PlasmaLogin.SessionManagement.ConfirmationMode.Skip)
        visible: PlasmaLogin.SessionManagement.canReboot
    }
}

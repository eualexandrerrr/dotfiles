/***************************************************************************
 *   License: GPL-3.0-or-later
 *   Author: Jeysef
 *
 *   Power options popup for the "Shut down" split button.  Rendered as
 *   an in-dialog floating panel (NOT a separate PlasmaComponents3.Menu
 *   window) so the parent dialog's hideOnWindowDeactivate does not fire
 *   and close the whole start menu.
 ***************************************************************************/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.private.sessions
import org.kde.kirigami as Kirigami

import "../code/theme.js" as Theme

Item {
    id: root

    property Item visualParent
    readonly property bool opened: popup.visible

    signal closed

    SessionManagement { id: sessionManager }

    function triggerShutdown() {
        if (sessionManager.canShutdown) {
            sessionManager.requestShutdown()
        }
    }

    // ── Invisible click-catcher that closes the popup when clicking ────
    // outside its content.  Covers the entire parent (rootItem FocusScope).
    MouseArea {
        id: clickCatcher
        anchors.fill: parent
        visible: popup.visible
        z: 90
        onClicked: root.close()
    }

    // ── The floating panel ─────────────────────────────────────────────
    Rectangle {
        id: popup
        visible: false
        z: 100

        readonly property real panelWidth: Kirigami.Units.gridUnit * 10
        width: panelWidth
        height: powerColumn.implicitHeight + Kirigami.Units.smallSpacing
        radius: Kirigami.Units.smallSpacing
        color: Kirigami.Theme.backgroundColor
        border.width: 1
        border.color: Qt.rgba(Kirigami.Theme.textColor.r,
                               Kirigami.Theme.textColor.g,
                               Kirigami.Theme.textColor.b, Theme.popupBorderOpacity)

        // Soft shadow effect
        layer.enabled: true

        Column {
            id: powerColumn
            width: popup.panelWidth - Kirigami.Units.smallSpacing
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Kirigami.Units.smallSpacing / 2
            spacing: 0

            PowerOption {
                iconSource: "system-lock-screen"
                label: i18n("Lock")
                optionEnabled: sessionManager.canLock
                onActivated: {
                    sessionManager.lock()
                    root.close()
                }
            }

            PowerOption {
                iconSource: "system-log-out"
                label: i18n("Log out")
                optionEnabled: sessionManager.canLogout
                onActivated: {
                    sessionManager.requestLogout()
                    root.close()
                }
            }

            PowerOption {
                iconSource: "system-suspend"
                label: i18n("Sleep")
                optionEnabled: sessionManager.canSuspend
                onActivated: {
                    sessionManager.suspend()
                    root.close()
                }
            }

            PowerOption {
                iconSource: "system-reboot"
                label: i18n("Restart")
                optionEnabled: sessionManager.canReboot
                onActivated: {
                    sessionManager.requestReboot()
                    root.close()
                }
            }

            // Separator
            Rectangle {
                width: powerColumn.width
                height: 1
                color: Qt.rgba(Kirigami.Theme.textColor.r,
                               Kirigami.Theme.textColor.g,
                               Kirigami.Theme.textColor.b, Theme.separatorOpacity)
            }

            PowerOption {
                iconSource: "system-shutdown"
                label: i18n("Shut down")
                optionEnabled: sessionManager.canShutdown
                onActivated: {
                    sessionManager.requestShutdown()
                    root.close()
                }
            }
        }

        Behavior on opacity { NumberAnimation { duration: 90 } }
    }

    // ── Positioning logic ──────────────────────────────────────────────
    function open() {
        if (!root.visualParent) return

        var popupW = popup.width
        var popupH = popup.height
        var gap = Kirigami.Units.smallSpacing

        // Default: open above the button, right-aligned to its right edge.
        var pos = root.visualParent.mapToItem(root, root.visualParent.width - popupW, -popupH - gap)

        // If the popup would go above the top of the dialog, open below
        // the button instead.
        if (pos.y < gap) {
            pos.y = root.visualParent.mapToItem(root, 0, root.visualParent.height + gap).y
        }

        // Clamp horizontally — keep the popup within the dialog bounds.
        pos.x = Math.max(gap, Math.min(pos.x, root.width - popupW - gap))

        popup.x = pos.x
        popup.y = pos.y
        popup.visible = true
        popup.opacity = 1
    }

    function close() {
        popup.visible = false
        popup.opacity = 0
        root.closed()
    }
}

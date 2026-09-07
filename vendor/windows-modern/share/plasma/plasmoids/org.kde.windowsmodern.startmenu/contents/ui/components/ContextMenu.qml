/***************************************************************************
 *   License: GPL-3.0-or-later
 *   Author: Jeysef
 *
 *   Shared in-dialog context menu popup for list delegates.  A single
 *   instance lives at the rootItem level; delegates call open() with
 *   their action list and position.  Avoids stacking multiple popups.
 ***************************************************************************/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import "../code/theme.js" as Theme

Item {
    id: contextMenu

    signal actionTriggered(string actionId, var argument, var context)
    signal closed

    // Caller-supplied context (e.g. { model, index }) forwarded back with
    // actionTriggered so the shell can dispatch to the right model.
    property var context: ({})

    // ── Click catcher ──────────────────────────────────────────────────
    MouseArea {
        anchors.fill: parent
        visible: popup.visible
        z: 90
        onClicked: contextMenu.close()
    }

    // ── The floating panel ─────────────────────────────────────────────
    Rectangle {
        id: popup
        visible: false
        z: 100
        width: Kirigami.Units.gridUnit * 15
        height: menuColumn.implicitHeight + Kirigami.Units.smallSpacing
        radius: Kirigami.Units.smallSpacing
        color: Kirigami.Theme.backgroundColor
        border.width: 1
        border.color: Qt.rgba(Kirigami.Theme.textColor.r,
                               Kirigami.Theme.textColor.g,
                               Kirigami.Theme.textColor.b, Theme.popupBorderOpacity)

        Column {
            id: menuColumn
            width: popup.width - Kirigami.Units.smallSpacing
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Kirigami.Units.smallSpacing / 2
            spacing: 0

            Repeater {
                model: contextMenu.actions

                delegate: Item {
                    width: menuColumn.width
                    height: modelData.type === "separator" ? 1 : Math.floor(Kirigami.Units.gridUnit * 1.6)

                    Rectangle {
                        anchors.fill: parent
                        visible: modelData.type !== "separator"
                        radius: Kirigami.Units.smallSpacing / 2
                        color: rowHover.containsMouse ? Kirigami.Theme.hoverColor : "transparent"
                        opacity: rowHover.containsMouse ? Theme.opacityFull : Theme.opacityHidden
                        Behavior on opacity { NumberAnimation { duration: 80 } }
                    }

                    Rectangle {
                        anchors.fill: parent
                        visible: modelData.type === "separator"
                        color: Qt.rgba(Kirigami.Theme.textColor.r,
                                       Kirigami.Theme.textColor.g,
                                       Kirigami.Theme.textColor.b, Theme.separatorOpacity)
                    }

                    RowLayout {
                        visible: modelData.type !== "separator"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Kirigami.Units.smallSpacing
                        anchors.rightMargin: Kirigami.Units.smallSpacing
                        spacing: Kirigami.Units.smallSpacing

                        Kirigami.Icon {
                            Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                            Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                            source: modelData.icon || ""
                        }

                        PlasmaComponents3.Label {
                            Layout.fillWidth: true
                            text: modelData.text || ""
                            color: Kirigami.Theme.textColor
                            font.pointSize: Kirigami.Theme.defaultFont.pointSize - 1
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                    }

                    MouseArea {
                        id: rowHover
                        anchors.fill: parent
                        hoverEnabled: true
                        visible: modelData.type !== "separator"
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            // File-level ids are not accessible inside
                            // Repeater delegates in Qt 6, so walk the
                            // parent chain: MouseArea -> delegate Item ->
                            // Column -> popup Rectangle -> contextMenu Item
                            var menu = parent.parent.parent.parent
                            menu.actionTriggered(modelData.actionId, modelData.actionArgument || null, menu.context)
                            menu.close()
                        }
                    }
                }
            }
        }
    }

    property var actions: []

    // Measure the widest action text to size the popup.
    TextMetrics {
        id: widestText
        font.pointSize: Kirigami.Theme.defaultFont.pointSize - 1
        text: {
            var maxText = ""
            for (var i = 0; i < contextMenu.actions.length; i++) {
                var a = contextMenu.actions[i]
                if (a.type === "separator") continue
                var t = a.text || ""
                if (t.length > maxText.length) maxText = t
            }
            return maxText
        }
    }

    readonly property int popupWidth: Math.min(
        Math.max(widestText.width + Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.smallSpacing * 4, Kirigami.Units.gridUnit * 8),
        Kirigami.Units.gridUnit * 20
    )

    function open(actionList, globalX, globalY, context) {
        contextMenu.actions = actionList
        contextMenu.context = context || ({})
        if (actionList.length === 0) return

        var popupW = contextMenu.popupWidth
        var gap = Kirigami.Units.smallSpacing

        // Compute the expected height from the action list itself rather
        // than measuring popup.height after make-visible — the latter is
        // stale on the first open because QML layout hasn't run yet.
        var itemH = Math.floor(Kirigami.Units.gridUnit * 1.6)
        var popupH = Kirigami.Units.smallSpacing // top margin
        for (var i = 0; i < actionList.length; i++) {
            popupH += (actionList[i].type === "separator") ? 1 : itemH
        }
        popupH += Kirigami.Units.smallSpacing // bottom padding

        var px = Math.max(gap, Math.min(globalX, contextMenu.width - popupW - gap))
        var py = globalY + gap
        if (py + popupH > contextMenu.height - gap) {
            py = globalY - popupH - gap
            if (py < gap) py = gap
        }

        popup.x = px
        popup.y = py
        popup.width = popupW
        popup.visible = true
    }

    function close() {
        popup.visible = false
        contextMenu.actions = []
        contextMenu.context = ({})
        contextMenu.closed()
    }
}

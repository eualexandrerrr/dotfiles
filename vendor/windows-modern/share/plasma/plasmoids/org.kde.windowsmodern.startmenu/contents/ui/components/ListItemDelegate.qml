/***************************************************************************
 *   License: GPL-3.0-or-later
 *   Author: Jeysef
 *
 *   Compact vertical-list row delegate for the pinned / all-apps left
 *   column.  Icon + name, hover highlight, keyboard activation.
 *   Right-click uses the shared in-dialog ContextMenu (declared at
 *   rootItem level) via Tools.buildAppActions so the menu is identical
 *   to what search results show.
 *
 *   When dragEnabled is true (PinnedPage), the delegate supports
 *   press-and-drag reordering via view.model.moveRow(from, to).
 ***************************************************************************/

import QtQuick

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import "../code/tools.js" as Tools
import "../code/theme.js" as Theme

Item {
    id: item

    width: ListView.view ? ListView.view.width : parent.width
    height: showDescription ? Kirigami.Units.gridUnit * 2 : Math.floor(Kirigami.Units.gridUnit * 1.5)

    clip: true

    enabled: !model.disabled

    property int itemIndex: model.index
    property int iconSize: Kirigami.Units.iconSizes.smallMedium
    property bool showDescription: false

    // Opt-in drag-to-reorder.  Only the pinned (favorites) list sets this;
    // the all-apps list is alphabetical and not reorderable.
    property bool dragEnabled: false

    Accessible.role: Accessible.MenuItem
    Accessible.name: model.display !== undefined ? model.display : ""

    // ── Drag state ─────────────────────────────────────────────────────
    // These properties are only mutated when dragEnabled is true.  They
    // track an in-progress drag initiated from pressAndHold or
    // press-then-move beyond a threshold.
    property bool _dragging: false
    property real _dragStartY: 0
    property real _dragOffsetY: 0

    // ── Hover background ───────────────────────────────────────────────
    Rectangle {
        id: hoverBackground
        anchors.fill: parent
        radius: Kirigami.Units.smallSpacing
        color: Kirigami.Theme.hoverColor
        opacity: {
            if (item._dragging) return Theme.opacityHidden;
            if (mouseArea.containsMouse) return Theme.opacityFull;
            if (item.ListView.isCurrentItem) return Theme.listItemCurrentOpacity;
            return Theme.opacityHidden;
        }
        Behavior on opacity { NumberAnimation { duration: 90 } }
    }

    // ── Drop indicator line ────────────────────────────────────────────
    // A thin highlight bar marking the insertion point during a sibling's
    // drag.  Position depends on drag direction:
    //   - dragging UP (target < from): insert BEFORE this delegate → top edge
    //   - dragging DOWN (target > from): insert AFTER this delegate → bottom edge
    //   - target == from: no move, hide.
    Rectangle {
        id: dropIndicator
        visible: {
            var view = item.ListView.view
            if (!view || item._dragging) return false
            if (view.dropTargetIndex !== item.itemIndex) return false
            return view.dropTargetIndex !== view.draggingIndex
        }
        anchors.left: parent.left
        anchors.right: parent.right
        height: 2
        radius: 1
        color: Kirigami.Theme.highlightColor
        // Anchor to the top when dragging up, bottom when dragging down.
        anchors.top: {
            var view = item.ListView.view
            return (view && view.dropTargetIndex < view.draggingIndex) ? parent.top : undefined
        }
        anchors.bottom: {
            var view = item.ListView.view
            return (view && view.dropTargetIndex > view.draggingIndex) ? parent.bottom : undefined
        }
    }

    // ── Content row ────────────────────────────────────────────────────
    Item {
        id: contentWrapper
        anchors.fill: parent

        // Lift the content during a drag: follow the cursor vertically,
        // scale up slightly, and raise opacity for a "grabbed" feel.
        transform: [
            Translate { y: item._dragging ? item._dragOffsetY : 0 },
            Scale {
                xScale: item._dragging ? 1.02 : 1.0
                yScale: item._dragging ? 1.02 : 1.0
                origin.x: contentWrapper.width / 2
                origin.y: contentWrapper.height / 2
            }
        ]
        opacity: item._dragging ? Theme.draggingOpacity : Theme.opacityFull

        Behavior on opacity { NumberAnimation { duration: 90 } }

        Row {
            id: row
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: Kirigami.Units.largeSpacing
            anchors.right: parent.right
            anchors.rightMargin: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.largeSpacing

            Kirigami.Icon {
                id: icon
                anchors.verticalCenter: parent.verticalCenter
                width: item.iconSize
                height: width
                animated: false
                source: model.decoration !== undefined ? model.decoration : ""
            }

            Column {
                id: textBlock
                anchors.verticalCenter: parent.verticalCenter
                width: row.width - icon.width - row.spacing
                spacing: Kirigami.Units.smallSpacing / 2

                PlasmaComponents3.Label {
                    id: label
                    width: parent.width
                    horizontalAlignment: Text.AlignLeft
                    maximumLineCount: 1
                    elide: Text.ElideRight
                    color: Kirigami.Theme.textColor
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize
                    text: ("name" in model ? model.name : (model.display !== undefined ? model.display : ""))
                    textFormat: Text.PlainText
                }

                PlasmaComponents3.Label {
                    id: desc
                    visible: item.showDescription && text.length > 0
                    width: parent.width
                    horizontalAlignment: Text.AlignLeft
                    maximumLineCount: 1
                    elide: Text.ElideRight
                    color: Kirigami.Theme.disabledTextColor
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize - 1
                    text: ("description" in model ? (model.description !== undefined ? model.description : "") : "")
                    textFormat: Text.PlainText
                }
            }
        }
    }

    // ── Mouse handling ─────────────────────────────────────────────────
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: item._dragging ? Qt.DragMoveCursor : Qt.PointingHandCursor
        // Keep drag above sibling delegates so the lifted content paints
        // on top while being dragged.
        z: item._dragging ? 20 : 10

        // Drag threshold — distance the cursor must travel from the press
        // point before we treat it as a drag rather than a click.
        readonly property real dragThreshold: Kirigami.Units.gridUnit * 0.4

        property real _pressX: -1
        property real _pressY: -1
        property bool _mightDrag: false

        onPressed: mouse => {
            _pressX = mouse.x;
            _pressY = mouse.y;
            _mightDrag = item.dragEnabled && mouse.button === Qt.LeftButton;
        }

        onPositionChanged: mouse => {
            if (!_mightDrag || item._dragging) {
                if (item._dragging) updateDrag(mouse.y);
                return;
            }

            // Start a drag once the cursor moves past the threshold.
            if (_mightDrag) {
                var dx = mouse.x - _pressX;
                var dy = mouse.y - _pressY;
                if (Math.abs(dy) > mouseArea.dragThreshold || Math.abs(dx) > mouseArea.dragThreshold) {
                    beginDrag(mouse.y);
                }
            }
        }

        onReleased: mouse => {
            if (item._dragging) {
                endDrag();
                _mightDrag = false;
                _pressX = -1;
                _pressY = -1;
                return;
            }
            _mightDrag = false;
            _pressX = -1;
            _pressY = -1;

            // Normal click handling.
            var view = item.ListView.view;
            if (view) view.forceActiveFocus();
            if (mouse.button === Qt.RightButton) {
                openContextMenu(mouse.x, mouse.y);
                return;
            }
            launchApp();
        }

        onClicked: {
            // Suppress the implicit clicked on drag release — handled in onReleased.
            if (item._dragging) {
                // already ended in onReleased
            }
        }

        // ── Drag helpers ──────────────────────────────────────────────
        function beginDrag(localY) {
            var view = item.ListView.view;
            if (!view || !view.model || typeof view.model.moveRow !== "function") return;

            item._dragging = true;
            item._dragStartY = localY;
            item._dragOffsetY = 0;
            view.draggingIndex = item.itemIndex;
        }

        function updateDrag(localY) {
            var view = item.ListView.view;
            if (!view) return;

            // Offset relative to the press point, mapped into view coords.
            var delta = localY - item._dragStartY;
            item._dragOffsetY = delta;

            // Compute the drop target by counting how many siblings have
            // their centre ABOVE the dragged item's current centre.  That
            // count is the target index — it only changes when the dragged
            // item actually crosses a sibling's midpoint, so:
            //   - first item dragged up → 0 above → target 0 → no-op
            //   - last item dragged down → all above → target N-1 → no-op
            //   - slight drag without crossing a centre → no-op
            var myCenter = item.mapToItem(view, 0, item.height / 2).y + delta;
            var target = 0;
            for (var i = 0; i < view.count; i++) {
                if (i === item.itemIndex) continue;
                var other = view.itemAtIndex(i);
                if (!other) continue;
                var otherCenter = other.mapToItem(view, 0, other.height / 2).y;
                if (otherCenter < myCenter) {
                    target++;
                }
            }

            view.dropTargetIndex = target;
        }

        function endDrag() {
            var view = item.ListView.view;
            var from = item.itemIndex;
            var to = view ? view.dropTargetIndex : -1;

            item._dragging = false;
            item._dragOffsetY = 0;

            if (view) {
                view.draggingIndex = -1;
                view.dropTargetIndex = -1;
            }

            // Perform the move.  moveRow(from, to) moves the row at
            // 'from' to position 'to' in the favorites model.  The model
            // emits the appropriate moveRows signals so the ListView
            // repositions delegates without a full reset.
            if (view && view.model && typeof view.model.moveRow === "function"
                    && to >= 0 && to !== from) {
                view.model.moveRow(from, to);
            }
        }
    }

    function launchApp() {
        var view = item.ListView.view
        if (view && view.model && typeof view.model.trigger === "function") {
            view.model.trigger(item.itemIndex, "", null);
            root.closeMenu();
        }
    }

    function openContextMenu(localX, localY) {
        var favModel = (typeof kicker !== "undefined" && kicker.globalFavorites)
                       ? kicker.globalFavorites : null
        var favId = (model.favoriteId !== undefined) ? model.favoriteId : ""
        var url = (model.url !== undefined) ? model.url : ""
        var actionList = (model.actionList !== undefined) ? model.actionList : null
        var acts = Tools.buildAppActions(i18n, favModel, favId, url, actionList)
        if (acts.length === 0) return

        var pos = item.mapToItem(sharedContextMenu, localX, localY)
        var view = item.ListView.view
        sharedContextMenu.open(acts, pos.x, pos.y, {
            model: view ? view.model : null,
            index: item.itemIndex
        })
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            event.accepted = true;
            launchApp();
        }
    }
}

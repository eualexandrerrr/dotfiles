/***************************************************************************
 *   License: GPL-3.0-or-later
 *   Author: Jeysef
 *
 *   StartAllBack-style pinned page: a vertical list of favorite apps using
 *   ListItemDelegate.  The "All apps >" header toggle asks the shell to
 *   swap the left column to the full alphabetical list.
 ***************************************************************************/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import "../components"

ColumnLayout {
    id: pinnedPage

    spacing: Kirigami.Units.largeSpacing

    property alias favoritesList: favoritesListView

    signal showAllAppsRequested
    signal keyNavUpFromList

    function tryActivate(row) {
        if (favoritesListView.count > 0) {
            favoritesListView.currentIndex = Math.min(row, favoritesListView.count - 1);
        }
    }

    function navigateUp() {
        if (favoritesListView.count > 0) {
            favoritesListView.currentIndex = Math.max(0, favoritesListView.currentIndex - 1);
        }
    }

    function navigateDown() {
        if (favoritesListView.count > 0) {
            favoritesListView.currentIndex = Math.min(favoritesListView.count - 1, favoritesListView.currentIndex + 1);
        }
    }

    function activateCurrent() {
        if (favoritesListView.currentIndex >= 0 && favoritesListView.model) {
            favoritesListView.model.trigger(favoritesListView.currentIndex, "", null);
            root.closeMenu();
        }
    }

    // ── Header row: "Pinned" + spacer + "All apps >" ─────────────────────
    RowLayout {
        id: headerRow
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        PlasmaComponents3.Label {
            text: i18n("Pinned")
            color: Kirigami.Theme.textColor
            font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.95
            font.weight: Font.DemiBold
            Layout.alignment: Qt.AlignVCenter
        }

        Item { Layout.fillWidth: true }

        AToolButton {
            buttonHeight: 25
            flat: true
            iconName: "go-next"
            text: i18n("All apps")
            Layout.rightMargin: Kirigami.Units.mediumSpacing
            onClicked: pinnedPage.showAllAppsRequested()
        }
    }

    // ── Pinned favorites vertical list ──────────────────────────────────
    ListView {
        id: favoritesListView
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        interactive: true
        spacing: Kirigami.Units.smallSpacing / 2
        boundsBehavior: Flickable.StopAtBounds
        currentIndex: -1

        // Drag-reorder tracking.  draggingIndex is the index currently
        // being dragged (or -1); dropTargetIndex is where it would land
        // if released (or -1).  Delegates read these to show the drop
        // indicator and lift the dragged row.
        property int draggingIndex: -1
        property int dropTargetIndex: -1

        PlasmaComponents3.ScrollBar.vertical: PlasmaComponents3.ScrollBar {
            policy: PlasmaComponents3.ScrollBar.AsNeeded
        }

        delegate: ListItemDelegate {
            iconSize: Kirigami.Units.iconSizes.smallMedium
            dragEnabled: true
        }

        highlightMoveDuration: 0

        Keys.onUpPressed: event => {
            if (currentIndex <= 0) {
                event.accepted = true;
                pinnedPage.keyNavUpFromList();
            }
        }
    }
}

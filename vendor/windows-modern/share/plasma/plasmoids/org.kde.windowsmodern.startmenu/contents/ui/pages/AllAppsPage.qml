/***************************************************************************
 *   License: GPL-3.0-or-later
 *   Author: Jeysef
 *
 *   StartAllBack-style all-apps page: a vertical alphabetical list using
 *   ListItemDelegate.  Shown in place of the pinned list when "All Programs"
 *   is toggled — the shell swaps the left column content rather than using
 *   a SwipeView page.
 ***************************************************************************/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

import "../components"

ColumnLayout {
    id: allAppsPage

    spacing: Kirigami.Units.largeSpacing

    property alias allAppsList: allAppsListView

    signal backRequested
    signal keyNavUpFromList

    function tryActivate(row) {
        if (allAppsListView.count > 0) {
            allAppsListView.currentIndex = Math.min(row, allAppsListView.count - 1);
        }
    }

    function navigateUp() {
        if (allAppsListView.count > 0) {
            allAppsListView.currentIndex = Math.max(0, allAppsListView.currentIndex - 1);
        }
    }

    function navigateDown() {
        if (allAppsListView.count > 0) {
            allAppsListView.currentIndex = Math.min(allAppsListView.count - 1, allAppsListView.currentIndex + 1);
        }
    }

    function activateCurrent() {
        if (allAppsListView.currentIndex >= 0 && allAppsListView.model) {
            allAppsListView.model.trigger(allAppsListView.currentIndex, "", null);
            root.closeMenu();
        }
    }

    // ── Header row: "All apps" + spacer + "< Back" (right-aligned) ──────
    RowLayout {
        id: headerRow
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        PlasmaComponents3.Label {
            text: i18n("All apps")
            color: Kirigami.Theme.textColor
            font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.95
            font.weight: Font.DemiBold
            Layout.alignment: Qt.AlignVCenter
        }

        Item { Layout.fillWidth: true }

        AToolButton {
            flat: true
            iconName: "go-previous"
            text: i18n("Back")
            buttonHeight: 25
            Layout.rightMargin: Kirigami.Units.mediumSpacing
            onClicked: allAppsPage.backRequested()
        }
    }

    // ── All apps vertical list ───────────────────────────────────────────
    ListView {
        id: allAppsListView
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        interactive: true
        spacing: Kirigami.Units.smallSpacing / 2
        boundsBehavior: Flickable.StopAtBounds
        currentIndex: -1

        PlasmaComponents3.ScrollBar.vertical: PlasmaComponents3.ScrollBar {
            policy: PlasmaComponents3.ScrollBar.AsNeeded
        }

        delegate: ListItemDelegate {
            iconSize: Kirigami.Units.iconSizes.smallMedium
        }

        highlightMoveDuration: 0

        Keys.onUpPressed: event => {
            if (currentIndex <= 0) {
                event.accepted = true;
                allAppsPage.keyNavUpFromList();
            }
        }
    }
}

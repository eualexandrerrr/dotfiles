/***************************************************************************
 *   License: GPL-3.0-or-later
 *   Author: Jeysef
 *
 *   Search results shown in the left column when the search field has text.
 *   Uses Milou.ResultsView (the same component the default Plasma Kickoff
 *   uses) for the model/scrolling/keyboard logic, with a custom delegate
 *   and full-row collapsible category headers.
 ***************************************************************************/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.milou as Milou

import "../components"
import "../code/tools.js" as Tools
import "../code/theme.js" as Theme

Item {
    id: searchPage

    width: parent.width
    height: parent.height

    property alias resultsView: resultsView

    // Emitted by result delegates when the user right-clicks.  The shell
    // (MenuRepresentation) owns the shared ContextMenu instance and opens
    // it — delegates inside Milou.ResultsView can't resolve that id
    // directly due to Qt 6 Repeater delegate scoping.
    signal contextMenuRequested(var actions, real globalX, real globalY, var context)

    // Track collapsed categories as a comma-separated string so QML
    // binding updates fire reliably (var objects don't notify on nested
    // key changes).
    property string collapsedCategories: ""

    function isCollapsed(cat) {
        if (!cat) return false
        var parts = collapsedCategories.split(",")
        return parts.indexOf(cat) >= 0
    }

    function toggleCollapsed(cat) {
        if (!cat) return
        var parts = collapsedCategories ? collapsedCategories.split(",") : []
        var idx = parts.indexOf(cat)
        if (idx >= 0) {
            parts.splice(idx, 1)
        } else {
            parts.push(cat)
        }
        collapsedCategories = parts.join(",")
        resultsView.forceLayout()
    }

    function tryActivate(row, col) {
        if (resultsView.count > 0) {
            resultsView.currentIndex = 0;
        }
    }

    function navigateUp() {
        if (resultsView.count > 0) {
            resultsView.currentIndex = Math.max(0, resultsView.currentIndex - 1);
        }
    }

    function navigateDown() {
        if (resultsView.count > 0) {
            resultsView.currentIndex = Math.min(resultsView.count - 1, resultsView.currentIndex + 1);
        }
    }

    function activateCurrent() {
        if (resultsView.count > 0) {
            resultsView.runCurrentIndex(null);
            root.closeMenu();
        }
    }

    function activateFirstResult() {
        if (resultsView.count > 0) {
            resultsView.currentIndex = 0;
            resultsView.runCurrentIndex(null);
        }
    }

    // ── Filter pills (rounded chips) ────────────────────────────────────
    RowLayout {
        id: filterPillsWrapper
        anchors.top: parent.top
        anchors.topMargin: Kirigami.Units.smallSpacing
        anchors.left: parent.left
        anchors.right: parent.right
        visible: root.searching
        spacing: Kirigami.Units.smallSpacing

        Repeater {
            // Runner ids must match the runners loaded by main.qml's
            // RunnerModel.  "" means "all runners".
            model: [
                { label: i18n("All"),      runner: "" },
                { label: i18n("Apps"),     runner: "krunner_services" },
                { label: i18n("Files"),    runner: "baloosearch" },
                { label: i18n("Settings"), runner: "krunner_systemsettings" },
                { label: i18n("Actions"),  runner: "krunner_powerdevil" }
            ]
            delegate: Rectangle {
                required property var modelData

                readonly property bool active: resultsView.singleRunner === modelData.runner

                Layout.alignment: Qt.AlignVCenter
                radius: Kirigami.Units.smallSpacing
                implicitHeight: Math.floor(Kirigami.Units.gridUnit * 1.4)
                implicitWidth: pillRow.implicitWidth + Kirigami.Units.largeSpacing * 2
                color: active
                       ? Kirigami.Theme.highlightColor
                       : (pillHover.containsMouse
                          ? Qt.rgba(Kirigami.Theme.textColor.r,
                                    Kirigami.Theme.textColor.g,
                                    Kirigami.Theme.textColor.b, Theme.buttonFlatHoverOpacity)
                          : Qt.rgba(Kirigami.Theme.textColor.r,
                                    Kirigami.Theme.textColor.g,
                                    Kirigami.Theme.textColor.b, Theme.buttonFlatBackgroundOpacity))
                border.width: active ? 0 : 1
                border.color: Qt.rgba(Kirigami.Theme.textColor.r,
                                       Kirigami.Theme.textColor.g,
                                       Kirigami.Theme.textColor.b, Theme.buttonBorderOpacity)
                Behavior on color { ColorAnimation { duration: 90 } }

                Row {
                    id: pillRow
                    anchors.centerIn: parent
                    spacing: Kirigami.Units.smallSpacing

                    PlasmaComponents3.Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.label
                        color: active
                               ? Kirigami.Theme.highlightedTextColor
                               : Kirigami.Theme.textColor
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize - 1
                        font.weight: active ? Font.DemiBold : Font.Normal
                    }
                }

                MouseArea {
                    id: pillHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        resultsView.singleRunner = modelData.runner;
                        // Force re-query: reset and re-apply the query
                        var q = bottomBarContent.searchText;
                        resultsView.queryString = "";
                        resultsView.queryString = q;
                    }
                }
            }
        }

        // Force left-justification of the pill cluster.
        Item { Layout.fillWidth: true }
    }

    // ── Search results (Milou ResultsView with custom delegate) ────────
    Milou.ResultsView {
        id: resultsView
        anchors {
            top: filterPillsWrapper.bottom
            topMargin: Kirigami.Units.largeSpacing
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        clip: true
        // queryField is left null — we drive queryString explicitly from
        // the shell's search field.  Setting it to a foreign id that
        // isn't in scope here throws a ReferenceError.
        queryField: null
        // queryString is set explicitly by the shell on text change.
        limit: 50

        onActivated: root.closeMenu()

        PlasmaComponents3.ScrollBar.vertical: PlasmaComponents3.ScrollBar {
            policy: PlasmaComponents3.ScrollBar.AsNeeded
        }

        // Custom section header: full-row, collapsible
        section.delegate: Rectangle {
            width: resultsView.width
            height: headerRow.implicitHeight + Kirigami.Units.smallSpacing
            color: "transparent"

            readonly property string category: section

            RowLayout {
                id: headerRow
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Icon {
                    Layout.preferredWidth: Kirigami.Units.iconSizes.small
                    Layout.preferredHeight: Kirigami.Units.iconSizes.small
                    source: searchPage.isCollapsed(section) ? "arrow-right" : "arrow-down"
                    opacity: Theme.dimmedIconOpacity
                }

                PlasmaComponents3.Label {
                    text: section
                    color: Kirigami.Theme.disabledTextColor
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.85
                    font.weight: Font.DemiBold
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Qt.rgba(Kirigami.Theme.textColor.r,
                                   Kirigami.Theme.textColor.g,
                                   Kirigami.Theme.textColor.b, Theme.headerSeparatorOpacity)
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: searchPage.toggleCollapsed(section)
            }
        }

        // Custom delegate: icon left, text right, no inline category
        delegate: Item {
            id: resultDelegate

            width: resultsView.width
            implicitHeight: visible ? Math.floor(Kirigami.Units.gridUnit * 1.6) : 0

            required property int index
            required property var model

            readonly property bool isCurrent: ListView.isCurrentItem

            // Hover/selection highlight — matches ListItemDelegate style
            Rectangle {
                anchors.fill: parent
                anchors.margins: 0
                radius: Kirigami.Units.smallSpacing
                color: Kirigami.Theme.hoverColor
                opacity: {
                    if (resultMouse.containsMouse) return 1.0
                    if (resultDelegate.isCurrent) return 0.5
                    return 0.0
                }
                Behavior on opacity { NumberAnimation { duration: 90 } }
            }

            RowLayout {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Kirigami.Units.largeSpacing
                anchors.right: parent.right
                anchors.rightMargin: Kirigami.Units.largeSpacing
                spacing: Kirigami.Units.largeSpacing

                Kirigami.Icon {
                    Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                    Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                    source: resultDelegate.model.decoration || ""
                    animated: false
                }

                PlasmaComponents3.Label {
                    id: displayLabel
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    color: Kirigami.Theme.textColor
                    text: resultDelegate.model.display || ""
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize - 1
                    textFormat: Text.PlainText
                    verticalAlignment: Text.AlignVCenter
                }

                PlasmaComponents3.Label {
                    visible: text.length > 0
                    opacity: Theme.dimmedTextOpacity
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    color: Kirigami.Theme.textColor
                    text: resultDelegate.model.subtext || ""
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize - 2
                    verticalAlignment: Text.AlignVCenter
                    Layout.maximumWidth: resultsView.width * 0.35
                }
            }

            MouseArea {
                id: resultMouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => {
                    resultsView.currentIndex = resultDelegate.index
                    if (mouse.button === Qt.RightButton) {
                        openResultContextMenu(mouse.x, mouse.y)
                        return
                    }
                    resultsView.runCurrentIndex()
                }
                onEntered: resultsView.currentIndex = resultDelegate.index
            }

            function openResultContextMenu(localX, localY) {
                var acts = []

                // Runner-provided actions (e.g. "Run in terminal", "Open
                // containing folder"). Milou exposes these via the
                // ActionsRole as a list of {text, iconSource, ...}.
                var runnerActions = resultDelegate.model.actions || []
                for (var i = 0; i < runnerActions.length; i++) {
                    var a = runnerActions[i]
                    acts.push({
                        text: a.text || "",
                        icon: a.iconName || a.iconSource || "",
                        actionId: "_milou_runner_action",
                        actionArgument: { actionIndex: i, matchIndex: resultDelegate.index }
                    })
                }

                var displayName = resultDelegate.model.display || ""

                // Look up the app in the all-apps model so we can offer
                // the same app-specific actions + pin/unpin as the All
                // Apps list — making the context menu identical for the
                // same app regardless of where it's right-clicked.
                var entry = rootItem.lookupAppByDisplayName(displayName)
                var favModel = (typeof kicker !== "undefined" && kicker.globalFavorites)
                               ? kicker.globalFavorites : null

                var ctx = {
                    model: resultsView.model,
                    index: resultDelegate.index,
                    kind: "milou",
                    matchIndex: resultDelegate.index
                }

                if (entry) {
                    // Resolved: route favorite/model actions through the
                    // all-apps model so triggerAction() works correctly.
                    ctx.resolvedModel = sortedAppsModel
                    ctx.resolvedIndex = -1

                    var appActs = Tools.buildAppActions(i18n, favModel,
                                                        entry.favoriteId,
                                                        entry.url,
                                                        entry.actionList)
                    if (appActs.length > 0) {
                        if (acts.length > 0) acts.push({ type: "separator" })
                        acts = acts.concat(appActs)
                    }
                } else {
                    // Not found in all-apps (e.g. a file or calculator
                    // result).  Still offer pin/unpin as a best-effort
                    // using the display name as the favorite id.
                    var favActions = Tools.createFavoriteActions(i18n, favModel, displayName)
                    if (favActions) {
                        if (acts.length > 0) acts.push({ type: "separator" })
                        acts = acts.concat(favActions)
                    }
                }

                // Always offer an "Open" action so the menu is never empty.
                if (acts.length === 0) {
                    acts.push({
                        text: i18n("Open"),
                        icon: "window-new",
                        actionId: "_milou_open",
                        actionArgument: { matchIndex: resultDelegate.index }
                    })
                }

                var pos = resultDelegate.mapToItem(searchPage, localX, localY)
                searchPage.contextMenuRequested(acts, pos.x, pos.y, ctx)
            }

            // Hide items in collapsed categories
            visible: !searchPage.isCollapsed(resultDelegate.ListView.section)
        }

        Keys.onUpPressed: event => {
            if (currentIndex <= 0) {
                event.accepted = true;
                bottomBarContent.focusSearch();
            }
        }
    }
}

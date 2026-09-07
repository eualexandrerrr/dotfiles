/***************************************************************************
 *   License: GPL-3.0-or-later
 *   Author: Jeysef
 *
 *   StartAllBack-style two-column start menu shell:
 *     ┌──────────────────────────────┬─────────────────┐
 *     │  Pinned / All apps (left)    │  User avatar    │
 *     │                              ├─────────────────┤
 *     │  vertical list of apps       │  System         │
 *     │                              │  locations      │
 *     ├──────────────────────────────┴─────────────────┤
 *     │  [Search programs and files...]  [Shut down >] │
 *     └────────────────────────────────────────────────┘
 *
 *   Pages live in pages/, shared components in components/.
 *   Keyboard input is handled by a single top-level handler on rootItem
 *   so any printable character appends to the search field regardless
 *   of which page or child widget currently holds focus.
 ***************************************************************************/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents3

import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kitemmodels 1.0 as KItemModels
import org.kde.coreaddons as KCoreAddons

import "components"
import "pages"
import "code/tools.js" as Tools
import "code/theme.js" as Theme

Item {
    id: main

    onVisibleChanged: {
        root.visible = !root.visible
    }

    Plasmoid.status: root.visible ? PlasmaCore.Types.RequiresAttentionStatus : PlasmaCore.Types.PassiveStatus

    PlasmaCore.Dialog {
        id: root

        objectName: "popupWindow"
        flags: Qt.WindowStaysOnTopHint
        location: PlasmaCore.Types.Floating
        hideOnWindowDeactivate: true

        // Opaque mode forces the solid dialog background variant; otherwise
        // let the desktop theme choose between default/translucent.
        backgroundHints: Plasmoid.configuration.menuTranslucency === Theme.menuTranslucencyOpaque
                         ? PlasmaCore.Dialog.SolidBackground
                         : PlasmaCore.Dialog.StandardBackground

        property bool searching: bottomBarContent.searchText !== ""

        // Left-column state: 0 = pinned, 1 = all apps, 2 = search results
        property int leftColumnState: 0

        onSearchingChanged: {
            if (searching) {
                leftColumnState = 2;
                // Reset scroll position when entering search mode.
                searchPage.resultsView.contentY = 0;
                searchPage.resultsView.currentIndex = 0;
            } else {
                leftColumnState = 0;
            }
        }

        onVisibleChanged: {
            if (visible) {
                reposition();
                reset();
            } else {
                leftColumnState = 0;
                sharedContextMenu.close();
                powerMenu.close();
            }
        }

        onHeightChanged: if (visible) reposition()
        onWidthChanged: if (visible) reposition()

        function reposition() {
            var pos = popupPosition(width, height);
            x = pos.x; y = pos.y;
        }

        function toggle() {
            main.visible = !main.visible
        }

        function reset() {
            bottomBarContent.searchText = "";
            leftColumnState = 0;
            // Reset the search filter pills to "All".
            searchPage.resultsView.singleRunner = "";
            // Defer focus until the dialog has finished laying out.
            Qt.callLater(bottomBarContent.focusSearch);
        }

        function closeMenu() {
            root.visible = false;
        }

        function popupPosition(width, height) {
            var screen = kicker.screenGeometry;
            var appletTopLeft = parent.mapToGlobal(0, 0);
            var horizMidPoint = screen.x + (screen.width / 2);
            var vertMidPoint = screen.y + (screen.height / 2);
            var offset = Kirigami.Units.smallSpacing;

            var menuPos = Plasmoid.configuration.displayPosition;

            if (menuPos === 1) {
                // Center of screen
                return Qt.point(horizMidPoint - width / 2, vertMidPoint - height / 2);
            } else if (menuPos === 2) {
                // Center-bottom (above panel)
                return Qt.point(horizMidPoint - width / 2,
                                screen.y + screen.height - height - kicker.height - offset);
            } else if (menuPos === 3) {
                // Left-bottom (above panel, left-aligned)
                return Qt.point(screen.x + offset,
                                screen.y + screen.height - height - kicker.height - offset);
            } else {
                // menuPos 0 — follow panel: center horizontally over the
                // start button, sit flush against the panel's top edge.
                var centerX = appletTopLeft.x + (kicker.width / 2) - (width / 2);
                centerX = Math.max(screen.x + offset,
                                   Math.min(centerX, screen.x + screen.width - width - offset));
                switch (Plasmoid.location) {
                case PlasmaCore.Types.BottomEdge:
                    return Qt.point(centerX, screen.y + screen.height - height - kicker.height - offset);
                case PlasmaCore.Types.TopEdge:
                    return Qt.point(centerX, screen.y + kicker.height + offset);
                case PlasmaCore.Types.LeftEdge:
                    return Qt.point(appletTopLeft.x + kicker.width + offset,
                                    Math.max(screen.y + offset,
                                             Math.min(appletTopLeft.y + (kicker.height / 2) - (height / 2),
                                                      screen.y + screen.height - height - offset)));
                case PlasmaCore.Types.RightEdge:
                    return Qt.point(appletTopLeft.x - width - offset,
                                    Math.max(screen.y + offset,
                                             Math.min(appletTopLeft.y + (kicker.height / 2) - (height / 2),
                                                      screen.y + screen.height - height - offset)));
                default:
                    return Qt.point(centerX, screen.y + screen.height - height - kicker.height - offset);
                }
            }
        }

        FocusScope {
            id: rootItem

            readonly property int leftColumnWidth: Kirigami.Units.gridUnit * 14
            readonly property int rightColumnWidth: Kirigami.Units.gridUnit * 10
            // Height derived from ~10 list rows + header + padding rather
            // than a fixed grid-unit count.
            readonly property int rowHeight: Kirigami.Units.gridUnit * 2
            readonly property int mainContentHeight: rowHeight * 12 + Kirigami.Units.gridUnit * 2

            width: leftColumnWidth + rightColumnWidth + Kirigami.Units.gridUnit * 3
            height: mainContentHeight + bottomBar.height + Kirigami.Units.gridUnit * 3
            focus: true

            // Note: do NOT auto-redirect to the search field here.
            // onFocusChanged fires when any child calls forceActiveFocus(),
            // and stealing focus back makes it impossible to type from lists.
            // Initial search focus is handled by reset().

            Plasma5Support.DataSource {
                id: executable
                engine: "executable"
                connectedSources: []

                onNewData: function (source, data) {
                    disconnectSource(source);
                }

                function exec(cmd) {
                    connectSource(cmd);
                }
            }

            KCoreAddons.KUser { id: kuser }

            KItemModels.KSortFilterProxyModel {
                id: sortedAppsModel

                sortRoleName: {
                    var m = Plasmoid.configuration.allAppsSortMode;
                    if (m === 4) return "description";
                    if (m === 2 || m === 3) return "url";
                    return "display";
                }
                sortOrder: {
                    var m = Plasmoid.configuration.allAppsSortMode;
                    return (m === 1 || m === 3) ? Qt.DescendingOrder : Qt.AscendingOrder;
                }

                // Map a proxy row through to the source model so delegates
                // can call view.model.trigger(index, ...) uniformly whether
                // the model is the favorites model or this sorted proxy.
                function trigger(row, actionId, argument) {
                    var srcIdx = mapToSource(index(row, 0));
                    if (srcIdx.valid && sourceModel) {
                        return sourceModel.trigger(srcIdx.row, actionId, argument);
                    }
                    return false;
                }

                property var favoritesModel: sourceModel ? sourceModel.favoritesModel : null
            }

            // ── Two-column main content area ──────────────────────────────
            RowLayout {
                id: mainColumns
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: bottomBar.top
                anchors.topMargin: Kirigami.Units.gridUnit
                anchors.bottomMargin: Kirigami.Units.gridUnit
                anchors.leftMargin: Kirigami.Units.gridUnit
                anchors.rightMargin: Kirigami.Units.gridUnit
                spacing: 0

                // ── Left column: pinned / all-apps / search ─────────────────
                ColumnLayout {
                    id: leftColumn
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: rootItem.leftColumnWidth
                    Layout.rightMargin: Kirigami.Units.mediumSpacing
                    spacing: Kirigami.Units.smallSpacing

                    PinnedPage {
                        id: pinnedPage
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: root.leftColumnState === 0
                        onShowAllAppsRequested: {
                            root.leftColumnState = 1;
                        }
                        onKeyNavUpFromList: bottomBarContent.focusSearch()
                    }

                    AllAppsPage {
                        id: allAppsPage
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: root.leftColumnState === 1
                        onBackRequested: {
                            root.leftColumnState = 0;
                        }
                        onKeyNavUpFromList: bottomBarContent.focusSearch()
                    }

                    SearchPage {
                        id: searchPage
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: root.leftColumnState === 2
                        onContextMenuRequested: function(actions, x, y, context) {
                            var pos = searchPage.mapToItem(sharedContextMenu, x, y)
                            sharedContextMenu.open(actions, pos.x, pos.y, context)
                        }
                    }
                }

                // ── Vertical separator ───────────────────────────────────────
                Rectangle {
                    id: columnSeparator
                    Layout.preferredWidth: 1
                    Layout.fillHeight: true
                    color: Kirigami.Theme.textColor
                    opacity: Theme.separatorOpacity
                }

                // ── Right column: avatar + system locations ────────────────
                ColumnLayout {
                    id: rightColumn
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: rootItem.rightColumnWidth
                    Layout.rightMargin: Kirigami.Units.mediumSpacing
                    spacing: Kirigami.Units.smallSpacing
                    visible: Plasmoid.configuration.showRightColumn

                    // ── User avatar (circular) ──────────────────────────────
                    Item {
                        id: avatarArea
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: Kirigami.Units.smallSpacing
                        Layout.bottomMargin: Kirigami.Units.smallSpacing
                        width: Kirigami.Units.iconSizes.medium
                        height: width

                        Image {
                            id: userAvatar
                            anchors.fill: parent
                            source: {
                                var faceUrl = kuser.faceIconUrl.toString()
                                if (faceUrl !== "") return faceUrl
                                return "file:///usr/share/icons/breeze/apps/48/kuser.svg"
                            }
                            cache: false
                            fillMode: Image.PreserveAspectCrop
                            visible: source !== ""
                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Rectangle {
                                    width: avatarArea.width
                                    height: avatarArea.height
                                    radius: avatarArea.width / 2
                                }
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: "transparent"
                            border.width: 1
                            border.color: Qt.rgba(Kirigami.Theme.textColor.r,
                                                   Kirigami.Theme.textColor.g,
                                                   Kirigami.Theme.textColor.b, Theme.buttonBorderOpacity)
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: executable.exec("systemsettings kcm_users")
                        }
                    }

                    PlasmaComponents3.Label {
                        text: i18n("Places")
                        color: Kirigami.Theme.textColor
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.95
                        font.weight: Font.DemiBold
                        Layout.leftMargin: Kirigami.Units.largeSpacing
                    }

                    SystemLocationsColumn {
                        id: systemLocations
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        executable: executable
                    }
                }
            }

            // ── Compound bottom bar: [Search field] + [Shut down >] ────────
            Rectangle {
                id: bottomBar
                width: parent.width
                height: bottomBarContent.implicitHeight + Kirigami.Units.gridUnit
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Kirigami.Units.gridUnit
                anchors.left: parent.left
                anchors.leftMargin: Kirigami.Units.gridUnit
                anchors.right: parent.right
                anchors.rightMargin: Kirigami.Units.gridUnit
                Kirigami.Theme.colorSet: Kirigami.Theme.Header
                Kirigami.Theme.inherit: false
                color: "transparent"

                Rectangle {
                    anchors.top: parent.top
                    width: parent.width
                    height: 1
                    color: Kirigami.Theme.textColor
                    opacity: Theme.separatorOpacity
                }

                BottomBar {
                    id: bottomBarContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    onSearchTextChanged: {
                        // Explicitly push the query to Milou ResultsView.
                        searchPage.resultsView.queryString = bottomBarContent.searchText;
                        // Reset scroll to top on new query — only when
                        // the search page is active to avoid warnings
                        // from setting properties on a non-visible view.
                        if (root.leftColumnState === 2) {
                            searchPage.resultsView.contentY = 0;
                            searchPage.resultsView.currentIndex = 0;
                        }
                    }
                    onSearchFocusResults: rootItem.focusActivePageResults()
                    onSearchNavUp: {
                        if (root.leftColumnState === 0) pinnedPage.navigateUp();
                        else if (root.leftColumnState === 1) allAppsPage.navigateUp();
                        else if (root.leftColumnState === 2) searchPage.navigateUp();
                    }
                    onSearchNavDown: {
                        if (root.leftColumnState === 0) pinnedPage.navigateDown();
                        else if (root.leftColumnState === 1) allAppsPage.navigateDown();
                        else if (root.leftColumnState === 2) searchPage.navigateDown();
                    }
                    onSearchActivateFirstResult: {
                        rootItem.activateCurrentItem();
                    }
                    onSearchEscapePressed: {
                        if (bottomBarContent.searchText !== "") {
                            bottomBarContent.searchText = "";
                        } else {
                            root.closeMenu();
                        }
                    }
                    onTabOut: rootItem.focusActivePageResults()
                    onPowerMenuRequested: {
                        powerMenu.visualParent = bottomBarContent.splitButton;
                        powerMenu.open();
                    }
                    onPowerShutdownRequested: powerMenu.triggerShutdown()
                }
            }

            // ── Power options popup (in-dialog, not a separate window) ────
            ShutdownMenu {
                id: powerMenu
                anchors.fill: parent
                onClosed: {
                    bottomBarContent.focusSearch();
                }
            }

            // ── Shared context menu for list delegates ─────────────────────
            ContextMenu {
                id: sharedContextMenu
                anchors.fill: parent
                onActionTriggered: function(actionId, argument, context) {
                    rootItem.handleContextAction(actionId, argument, context)
                }
            }

            function handleContextAction(actionId, argument, context) {
                // Milou runner actions: invoke the named action on the
                // current match via ResultsView.runAction().
                if (actionId === "_milou_runner_action" && context && context.kind === "milou") {
                    if (argument && typeof argument.actionIndex !== "undefined") {
                        searchPage.resultsView.currentIndex = argument.matchIndex
                        searchPage.resultsView.runAction(argument.actionIndex)
                    }
                    return
                }

                // "Open" fallback for results with no runner actions
                // (e.g. plain app launches from krunner_services).
                if (actionId === "_milou_open" && context && context.kind === "milou") {
                    if (argument) {
                        searchPage.resultsView.currentIndex = argument.matchIndex
                        searchPage.resultsView.runCurrentIndex(null)
                    }
                    return
                }

                var model = context ? (context.resolvedModel || context.model) : null;
                var idx = context ? (context.resolvedIndex !== undefined ? context.resolvedIndex : context.index) : -1;
                var close = (Tools.triggerAction(model, idx, actionId, argument) === true);
                if (close) {
                    root.closeMenu();
                }
            }

            function focusActivePageResults() {
                if (root.leftColumnState === 0) {
                    pinnedPage.tryActivate(0);
                } else if (root.leftColumnState === 1) {
                    allAppsPage.tryActivate(0);
                } else {
                    searchPage.tryActivate(0, 0);
                }
            }

            function activateCurrentItem() {
                if (root.leftColumnState === 0) {
                    pinnedPage.activateCurrent();
                } else if (root.leftColumnState === 1) {
                    allAppsPage.activateCurrent();
                } else if (root.leftColumnState === 2) {
                    searchPage.activateCurrent();
                }
            }

            // Lookup map for search-result context menus.  Built by the
            // hidden appLookupMap ListView below as delegates are
            // instantiated — this is the only reliable way to access model
            // roles by name in QML (QAbstractItemModel doesn't expose
            // roleNames() to the QML side).  Keyed by display name.
            property var _appLookupMap: ({})

            // Rebuild the lookup map when the source model changes.
            // Returns { favoriteId, url, actionList } or null.
            function lookupAppByDisplayName(displayName) {
                if (!displayName) return null;
                return rootItem._appLookupMap[displayName] || null;
            }

            // Lookup map for search-result context menus.  Uses a Repeater
            // (not ListView) because Repeater creates ALL delegates eagerly —
            // ListView only creates delegates in/near the visible viewport,
            // which fails for off-screen helpers.  Each delegate writes its
            // model roles into the map on creation.
            Column {
                x: -9999
                y: -9999
                width: 0
                height: 0
                visible: true

                Repeater {
                    model: sortedAppsModel
                    delegate: Item {
                        Component.onCompleted: {
                            var name = (model.display !== undefined) ? model.display : "";
                            if (name !== "") {
                                rootItem._appLookupMap[name] = {
                                    favoriteId: (model.favoriteId !== undefined) ? model.favoriteId : "",
                                    url: (model.url !== undefined) ? model.url : "",
                                    actionList: (model.actionList !== undefined) ? model.actionList : null
                                };
                            }
                        }
                    }
                }
            }

            // ── Single global keyboard handler ─────────────────────────────
            //
            // Registered once on rootItem. Any printable character typed
            // anywhere in the menu appends to the search field and switches
            // to the search page. Escape/Backspace route to search or close.
            // Navigation keys (Tab, arrows, Enter) are left for children to
            // handle, and only reach here if no child consumed them.
            Keys.onPressed: event => {

                // Ctrl+digit launches a pinned favorite (1..9).
                if (event.modifiers === Qt.ControlModifier) {
                    var digit = event.key - Qt.Key_1;
                    if (digit >= 0 && digit <= 8) {
                        var count = globalFavorites.count;
                        if (digit < count) {
                            event.accepted = true;
                            globalFavorites.trigger(digit, "", null);
                            root.closeMenu();
                        }
                        return;
                    }
                }

                // Ignore pure modifier presses.
                if (event.key === Qt.Key_Shift || event.key === Qt.Key_Control
                        || event.key === Qt.Key_Alt || event.key === Qt.Key_Meta
                        || event.key === Qt.Key_AltGr) {
                    return;
                }

                // Let Tab/Backtab navigate the focus chain normally.
                if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
                    return;
                }

                if (event.key === Qt.Key_Escape) {
                    event.accepted = true;
                    if (root.searching) {
                        reset();
                    } else if (root.leftColumnState === 1) {
                        root.leftColumnState = 0;
                        bottomBarContent.focusSearch();
                    } else {
                        root.closeMenu();
                    }
                    return;
                }

                // Backspace from a list: delete last search char.
                if (event.key === Qt.Key_Backspace) {
                    event.accepted = true;
                    bottomBarContent.searchText = bottomBarContent.searchText.slice(0, -1);
                    return;
                }

                // Arrow / Enter / Page / Home / End are navigation: let the
                // focused child handle them.
                if (event.key === Qt.Key_Up || event.key === Qt.Key_Down
                        || event.key === Qt.Key_Left || event.key === Qt.Key_Right
                        || event.key === Qt.Key_Enter || event.key === Qt.Key_Return
                        || event.key === Qt.Key_PageUp || event.key === Qt.Key_PageDown
                        || event.key === Qt.Key_Home || event.key === Qt.Key_End) {
                    return;
                }

                // Any other printable character: append directly to the
                // searchText property (aliased to the TextField's text).
                // This works regardless of which item has focus — no need
                // to steal focus or guard on activeFocus.  The onTextChanged
                // → onSearchingChanged chain handles the page switch.
                // When the search field itself has focus it handles its own
                // input natively and this handler never fires.
                if (event.text !== "" && event.text !== "\t"
                        && !(event.modifiers & Qt.ControlModifier)) {
                    event.accepted = true;
                    bottomBarContent.searchText = bottomBarContent.searchText + event.text;
                }
            }
        }

        function setModels() {
            pinnedPage.favoritesList.model = globalFavorites;
            sortedAppsModel.sourceModel = findRowModel(rootModel, "KICKER_ALL_MODEL");
            allAppsPage.allAppsList.model = sortedAppsModel;
        }

        // Locate a rootModel child row by its description.  The Kicker
        // models expose "description" as a Q_PROPERTY (not a data role),
        // so we read it off the model returned by modelForRow().
        function findRowModel(parentModel, description) {
            if (!parentModel) return null;
            for (var i = 0; i < parentModel.rowCount(); i++) {
                var m = parentModel.modelForRow(i);
                if (m && m.description === description) {
                    return m;
                }
            }
            return null;
        }

        Component.onCompleted: {
            rootModel.refreshed.connect(setModels);
            reset();
            rootModel.refresh();
        }
    }
}

/***************************************************************************
 *   Ported from com.jeysef.windowsmodernstartmenu
 *   License: GPL-3.0-or-later
 *   Author: Jeysef
 ***************************************************************************/

import QtQuick

import org.kde.plasma.plasmoid

import org.kde.plasma.core as PlasmaCore

import org.kde.plasma.private.kicker 0.1 as Kicker

PlasmoidItem {

    id: kicker

    anchors.fill: parent

    preferredRepresentation: compactRep
    compactRepresentation: compactRep
    fullRepresentation: compactRep

    function action_menuedit() {
        processRunner.runMenuEditor();
    }

    Component {
        id: compactRep
        CompactRepresentation {}
    }

    property QtObject globalFavorites: rootModel.favoritesModel
    property QtObject systemFavorites: rootModel.systemFavoritesModel

    Plasmoid.icon: Plasmoid.configuration.useCustomButtonImage
                   ? Plasmoid.configuration.customButtonImage
                   : Plasmoid.configuration.icon

    onSystemFavoritesChanged: {
        if (systemFavorites) {
            systemFavorites.favorites = Plasmoid.configuration.favoriteSystemActions;
        }
    }

    Kicker.RootModel {
        id: rootModel

        autoPopulate: false

        appNameFormat: 0
        flat: true
        sorted: true
        showAllAppsCategorized: false
        showSeparators: false
        appletInterface: kicker
        showAllApps: true
        showRecentApps: Plasmoid.configuration.showRecentApps
        showRecentDocs: Plasmoid.configuration.showRecentDocs
        showPowerSession: false

        onShowRecentAppsChanged: {
            Plasmoid.configuration.showRecentApps = showRecentApps;
        }

        onShowRecentDocsChanged: {
            Plasmoid.configuration.showRecentDocs = showRecentDocs;
        }

        Component.onCompleted: {
            favoritesModel.initForClient("org.kde.plasma.kicker.favorites.instance-" + Plasmoid.id)

            if (!Plasmoid.configuration.favoritesPortedToKAstats) {
                if (favoritesModel.count < 1) {
                    favoritesModel.portOldFavorites(Plasmoid.configuration.favoriteApps);
                }
                Plasmoid.configuration.favoritesPortedToKAstats = true;
            }
        }
    }

    Connections {
        target: globalFavorites

        function onFavoritesChanged() {
            Plasmoid.configuration.favoriteApps = target.favorites;
        }
    }

    Connections {
        target: systemFavorites

        function onFavoritesChanged() {
            if (Plasmoid.configuration && target)
                Plasmoid.configuration.favoriteSystemActions = target.favorites;
        }
    }

    Connections {
        target: Plasmoid.configuration

        function onFavoriteAppsChanged() {
            globalFavorites.favorites = Plasmoid.configuration.favoriteApps;
        }

        function onFavoriteSystemActionsChanged() {
            systemFavorites.favorites = Plasmoid.configuration.favoriteSystemActions;
        }

        function onHiddenApplicationsChanged() {
            rootModel.refresh();
        }
    }

    Kicker.RunnerModel {
        id: runnerModel

        appletInterface: kicker

        favoritesModel: globalFavorites

        // Always load the full runner set; the SearchPage filter pills
        // narrow results via Milou's singleRunner property instead of
        // rebuilding this model.
        runners: ["krunner_services",
                  "baloosearch",
                  "bookmarks",
                  "krunner_systemsettings",
                  "krunner_sessions",
                  "krunner_powerdevil",
                  "calculator",
                  "unitconverter"]
    }

    Kicker.ProcessRunner {
        id: processRunner
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Edit Applications…")
            icon.name: "kmenuedit"
            visible: Plasmoid.immutability !== PlasmaCore.Types.SystemImmutable
            onTriggered: processRunner.runMenuEditor()
        }
    ]

    Component.onCompleted: {
        if (Plasmoid.hasOwnProperty("activationTogglesExpanded")) {
            Plasmoid.activationTogglesExpanded = true;
        }
    }
}

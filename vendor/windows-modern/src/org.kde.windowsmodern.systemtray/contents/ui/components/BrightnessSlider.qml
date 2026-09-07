import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.brightnesscontrolplugin
import org.kde.kitemmodels as KItemModels
import "../lib" as Lib

Lib.Slider {
    id: root

    property var mainScreen: null
    property rect panelScreenGeometry: Qt.rect(0, 0, 0, 0)
    property int panelScreenIndex: -1

    iconSource: "brightness-high-symbolic"
    iconSize: Kirigami.Units.iconSizes.smallMedium
    showArrow: true

    ScreenBrightnessControl {
        id: sbControl
        isSilent: false
    }

    // The brightness backend exposes only opaque DBus names ("display3",
    // "display4") as displayName, so we cannot match by KScreen connector
    // name. Instead we decide whether the panel sits on an internal or
    // external screen and pick the corresponding display.
    function displayForPanel() {
        const model = sbControl.displays;
        if (!model || model.rowCount() === 0) {
            return null;
        }
        if (model.rowCount() === 1) {
            return model.index(0, 0);
        }

        const isInternalRole = model.KItemModels.KRoleNames.role("isInternal");
        const wantInternal = root.panelOnInternalScreen();

        for (let i = 0; i < model.rowCount(); ++i) {
            const idx = model.index(i, 0);
            if (model.data(idx, isInternalRole) === wantInternal) {
                return idx;
            }
        }

        return model.index(0, 0);
    }

    // True when the panel's screen is the internal (laptop) panel.
    //
    // Qt.application.screens[i].geometry is not exposed to QML in current
    // Qt/Plasma builds (only .name is), so geometry matching is impossible.
    // We resolve the connector name via the containment's screen index, and
    // fall back to the Screen attached property (the popup window's screen,
    // which opens on the panel's screen) and finally to panelScreenGeometry.
    function isInternalConnectorName(name) {
        if (!name) {
            return false;
        }
        return name === "eDP-1" || name === "eDP1" || name === "eDP"
            || name === "LVDS-1" || name === "LVDS1"
            || name === "DSI-1" || name === "DSI1";
    }

    function panelOnInternalScreen() {
        const idx = root.panelScreenIndex;
        const screens = Qt.application.screens;
        if (idx >= 0 && screens && screens.length > idx) {
            const s = screens[idx];
            if (s && s.name) {
                return root.isInternalConnectorName(s.name);
            }
        }
        if (typeof Screen !== "undefined" && Screen.name) {
            return root.isInternalConnectorName(Screen.name);
        }
        return true;
    }

    function refreshDisplays() {
        const model = sbControl.displays;
        const idx = root.displayForPanel();
        if (!model || !idx) {
            root.mainScreen = null;
            return;
        }
        const labelRole = model.KItemModels.KRoleNames.role("label");
        const brightnessRole = model.KItemModels.KRoleNames.role("brightness");
        const maxBrightnessRole = model.KItemModels.KRoleNames.role("maxBrightness");
        const displayNameRole = model.KItemModels.KRoleNames.role("displayName");
        root.mainScreen = {
            displayName: model.data(idx, displayNameRole),
            label: model.data(idx, labelRole),
            brightness: model.data(idx, brightnessRole),
            maxBrightness: model.data(idx, maxBrightnessRole)
        };
    }

    Connections {
        target: sbControl.displays
        function onDataChanged() {
            root.refreshDisplays();
        }
        function onModelReset() {
            root.refreshDisplays();
        }
        function onRowsInserted() {
            root.refreshDisplays();
        }
        function onRowsRemoved() {
            root.refreshDisplays();
        }
    }

    Component.onCompleted: root.refreshDisplays()

    onPanelScreenGeometryChanged: root.refreshDisplays()
    onPanelScreenIndexChanged: root.refreshDisplays()

    visible: sbControl.isBrightnessAvailable && mainScreen !== null
    from: mainScreen ? (mainScreen.maxBrightness > 100 ? 1 : 0) : 0
    to: mainScreen ? mainScreen.maxBrightness : 100
    value: mainScreen ? mainScreen.brightness : 0
    stepSize: mainScreen ? Math.max(1, Math.floor(mainScreen.maxBrightness / 100)) : 1

    onMoved: function (v) {
        if (mainScreen) {
            sbControl.setBrightness(mainScreen.displayName, v);
        }
    }

    onIconClicked: NightLightInhibitor.toggleInhibition()
}

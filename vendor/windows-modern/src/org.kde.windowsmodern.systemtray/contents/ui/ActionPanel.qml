/*
    Action Panel — quick-toggle tiles + sliders shown in the expander popup.

    A Windows 11 / 10 hybrid. The hidden SNI icons grid and footer are
    composed by ExpandedRepresentation around this component.
*/
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid

import "components" as Components

ColumnLayout {
    id: actionPanel

    signal requestPage(string name)

    readonly property real scale: Plasmoid.configuration.scale / 100

    Layout.fillWidth: true
    spacing: 16 * actionPanel.scale

    GridLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 14 * actionPanel.scale
        Layout.rightMargin: 14 * actionPanel.scale
        Layout.topMargin: 6 * actionPanel.scale
        columns: 3
        rowSpacing: 12 * actionPanel.scale
        columnSpacing: 6 * actionPanel.scale

        Components.NetworkToggle {
            Layout.fillWidth: true
            onArrowClicked: actionPanel.requestPage("network")
        }
        Components.BluetoothToggle {
            Layout.fillWidth: true
            onArrowClicked: actionPanel.requestPage("bluetooth")
        }
        Components.AirplaneToggle {
            Layout.fillWidth: true
            visible: Plasmoid.configuration.showAirplane
        }
        Components.BatterySaverToggle {
            Layout.fillWidth: true
            visible: Plasmoid.configuration.showBatterySaver
            onArrowClicked: actionPanel.requestPage("battery")
        }
        Components.NightLightToggle {
            Layout.fillWidth: true
            visible: Plasmoid.configuration.showNightLight
        }
        Components.ColorSchemeToggle {
            Layout.fillWidth: true
            visible: Plasmoid.configuration.showColorScheme
        }
        Components.DndToggle {
            Layout.fillWidth: true
            visible: Plasmoid.configuration.showDnd
        }
        Components.MicMuteToggle {
            Layout.fillWidth: true
            visible: Plasmoid.configuration.showMicMute
        }
        Components.HotspotToggle {
            Layout.fillWidth: true
            visible: Plasmoid.configuration.showHotspot
        }
    }

    GridLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 14 * actionPanel.scale
        Layout.rightMargin: 14 * actionPanel.scale
        Layout.bottomMargin: 14 * actionPanel.scale
        columns: 3
        rowSpacing: 12 * actionPanel.scale
        columnSpacing: 0

        Components.BrightnessSlider {
            Layout.fillWidth: true
            Layout.columnSpan: 3
            visible: Plasmoid.configuration.showBrightness
            showArrow: true
            panelScreenGeometry: Plasmoid.screenGeometry
            panelScreenIndex: Plasmoid.containment.screen
            onArrowClicked: actionPanel.requestPage("brightness")
        }
        Components.VolumeSlider {
            Layout.fillWidth: true
            Layout.columnSpan: 3
            Layout.preferredHeight: 36
            visible: Plasmoid.configuration.showVolume
            onArrowClicked: actionPanel.requestPage("volume")
        }
    }
}

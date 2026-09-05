/*
    SPDX-FileCopyrightText: 2014 Ashish Madeti <ashishmadeti@gmail.com>
    SPDX-FileCopyrightText: 2016 Kai Uwe Broulik <kde@privatebroulik.de>
    SPDX-FileCopyrightText: 2019 Chris Holland <zrenfire@gmail.com>
    SPDX-FileCopyrightText: 2022 ivan (@ratijas) tkachenko <me@ratijas.tk>

    SPDX-License-Identifier: GPL-2.0-or-later

    Simplified fork of org.kde.plasma.win7showdesktop for the Windows
    Modern theme. Removes command/mousewheel/peek-on-hover features;
    keeps the thin sliver rendering and minimize-all behavior.
*/

import QtQuick 2.15
import QtQuick.Layouts 1.3

import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    preferredRepresentation: fullRepresentation
    toolTipSubText: activeController.description

    Plasmoid.icon: "transform-move"
    Plasmoid.title: activeController.title
    Plasmoid.onActivated: activeController.toggle()

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    Layout.minimumWidth: Kirigami.Units.iconSizes.medium
    Layout.minimumHeight: Kirigami.Units.iconSizes.medium

    Layout.maximumWidth: vertical ? Layout.minimumWidth : Math.max(1, Plasmoid.configuration.size)
    Layout.maximumHeight: vertical ? Math.max(1, Plasmoid.configuration.size) : Layout.minimumHeight

    Layout.preferredWidth: Layout.maximumWidth
    Layout.preferredHeight: Layout.maximumHeight

    Plasmoid.constraintHints: Plasmoid.CanFillArea

    readonly property bool inPanel: [PlasmaCore.Types.TopEdge, PlasmaCore.Types.RightEdge, PlasmaCore.Types.BottomEdge, PlasmaCore.Types.LeftEdge]
            .includes(Plasmoid.location)

    readonly property bool horizontal: Plasmoid.location === PlasmaCore.Types.TopEdge || Plasmoid.location === PlasmaCore.Types.BottomEdge
    readonly property bool vertical: Plasmoid.location === PlasmaCore.Types.RightEdge || Plasmoid.location === PlasmaCore.Types.LeftEdge

    readonly property Controller activeController: minimizeAllController

    MinimizeAllController {
        id: minimizeAllController
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        anchors.rightMargin: -panelMargins.panelEdgeMargin

        activeFocusOnTab: true
        hoverEnabled: true

        PanelMargins {
            id: panelMargins
        }

        onClicked: Plasmoid.activated();

        Keys.onPressed: {
            switch (event.key) {
            case Qt.Key_Space:
            case Qt.Key_Enter:
            case Qt.Key_Return:
            case Qt.Key_Select:
                Plasmoid.activated();
                break;
            }
        }

        Accessible.name: Plasmoid.title
        Accessible.description: toolTipSubText
        Accessible.role: Accessible.Button

        Kirigami.Icon {
            anchors.fill: parent
            active: mouseArea.containsMouse || activeController.active
            visible: Plasmoid.containment.corona.editMode
            source: Plasmoid.icon
        }

        DropArea {
            anchors.fill: parent
            onEntered: activateTimer.start()
            onExited: activateTimer.stop()
        }

        Timer {
            id: activateTimer
            interval: 250
            onTriggered: Plasmoid.activated()
        }

        state: {
            if (mouseArea.containsPress) {
                return "pressed";
            } else if (mouseArea.containsMouse || mouseArea.activeFocus) {
                return "hover";
            } else {
                return "normal";
            }
        }

        // Win11 show-desktop: invisible by default. On hover, a short
        // vertical line (50% of panel height, centered) fades in. No
        // background fill, no separator line.
        Rectangle {
            id: hoverLine
            color: Plasmoid.configuration.edgeColor
                  || Qt.rgba(Kirigami.Theme.textColor.r,
                             Kirigami.Theme.textColor.g,
                             Kirigami.Theme.textColor.b, 0.5)
            width: 1
            height: parent.height * 0.5
            anchors.centerIn: parent
            opacity: mouseArea.state === "hover" || mouseArea.state === "pressed" ? 1 : 0
            Behavior on opacity { OpacityAnimator { duration: Kirigami.Units.shortDuration; easing.type: Easing.InOutQuad } }
        }

        PlasmaCore.ToolTipArea {
            id: toolTip
            anchors.fill: parent
            mainText: Plasmoid.title
            subText: toolTipSubText
            textFormat: Text.PlainText
        }
    }
}

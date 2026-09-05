/*
    SPDX-FileCopyrightText: 2019 Chris Holland <zrenfire@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

KSvg.FrameSvgItem {
    id: panelSvg
    visible: false
    imagePath: "widgets/panel-background"
    prefix: [plasmoidLocationString(), ""]

    function plasmoidLocationString(): string {
        switch (Plasmoid.location) {
        case PlasmaCore.Types.LeftEdge:
            return "west"
        case PlasmaCore.Types.TopEdge:
            return "north"
        case PlasmaCore.Types.RightEdge:
            return "east"
        case PlasmaCore.Types.BottomEdge:
            return "south"
        }
        return ""
    }

    readonly property int rowSpacing: Kirigami.Units.smallSpacing
    readonly property int panelEdgeMargin: {
        if (Plasmoid.location === PlasmaCore.Types.LeftEdge) {
            return rowSpacing + panelSvg.fixedMargins.bottom
        } else if (Plasmoid.location === PlasmaCore.Types.RightEdge) {
            return rowSpacing + panelSvg.fixedMargins.bottom
        } else if (Plasmoid.location === PlasmaCore.Types.TopEdge) {
            return rowSpacing + panelSvg.fixedMargins.right
        } else if (Plasmoid.location === PlasmaCore.Types.BottomEdge) {
            return rowSpacing + panelSvg.fixedMargins.right
        } else {
            return 0
        }
    }
}

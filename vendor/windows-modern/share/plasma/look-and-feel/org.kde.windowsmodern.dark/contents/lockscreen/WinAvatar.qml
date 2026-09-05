/*
 * SPDX-FileCopyrightText: 2026 Jeysef
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property int size: WinStyle.avatarSize
    property url source

    implicitWidth: size
    implicitHeight: size

    Image {
        id: image
        anchors.fill: parent
        source: root.source
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(root.size, root.size)
        asynchronous: true
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: maskRect
        }
    }

    Rectangle {
        id: maskRect
        width: root.size
        height: root.size
        radius: root.size / 2
        visible: false
    }

}

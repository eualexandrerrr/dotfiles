/*
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@koyotic.space>
    SPDX-FileCopyrightText: 2026 Jeysef

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid

import "components" as Components
import "lib" as Lib

QQC2.StackView {
    id: mainStack
    focus: true

    Layout.minimumWidth: Kirigami.Units.gridUnit * 12
    Layout.minimumHeight: Kirigami.Units.gridUnit * 12

    readonly property Item activeApplet: systemTrayState.activeApplet

    // Whether the active applet is one we render a themed flyout for.
    readonly property bool themedActive: flyoutRouter.isThemedApplet(activeApplet)

    // Height reserved at the bottom for the themed page's footer link.
    readonly property int themedFooterHeight: (themedActive && footerLoader.item) ? footerLoader.item.implicitHeight : 0

    /* Heading — only relevant for unknown (non-themed) applets */
    property bool appletHasHeading: false
    property bool mergeHeadings: appletHasHeading && activeApplet && activeApplet.fullRepresentationItem && activeApplet.fullRepresentationItem.header && activeApplet.fullRepresentationItem.header.visible
    property int headingHeight: mergeHeadings ? activeApplet.fullRepresentationItem.header.height : 0
    /* Footer — only relevant for unknown applets (themed pages render their own) */
    property bool appletHasFooter: false
    property bool mergeFooters: appletHasFooter && activeApplet && activeApplet.fullRepresentationItem && activeApplet.fullRepresentationItem.footer && activeApplet.fullRepresentationItem.footer.visible
    property int footerHeight: mergeFooters ? activeApplet.fullRepresentationItem.footer.height : 0

    FlyoutRouter {
        id: flyoutRouter
    }

    function _themedContentHeight(): int {
        return mainStack.height - mainStack.themedFooterHeight
    }

    onActiveAppletChanged: {
        mainStack.appletHasHeading = false
        mainStack.appletHasFooter = false

        if (themedActive) {
            const name = flyoutRouter.flyoutNameForApplet(activeApplet)
            const comp = themedPages[name]
            if (comp) {
                (mainStack.empty ? mainStack.push : mainStack.replace)(comp, {
                    "width": Qt.binding(() => mainStack.width),
                    "height": Qt.binding(() => mainStack._themedContentHeight()),
                    "x": 0,
                    "focus": Qt.binding(() => !mainStack.busy),
                    "opacity": 1,
                    "KeyNavigation.up": mainStack.KeyNavigation.up,
                    "KeyNavigation.backtab": mainStack.KeyNavigation.backtab
                }, QQC2.StackView.ReplaceTransition)
            }
            return
        }

        if (activeApplet != null && activeApplet.fullRepresentationItem && !activeApplet.preferredRepresentation) {
            activeApplet.fullRepresentationItem.anchors.left = undefined
            activeApplet.fullRepresentationItem.anchors.top = undefined
            activeApplet.fullRepresentationItem.anchors.right = undefined
            activeApplet.fullRepresentationItem.anchors.bottom = undefined
            activeApplet.fullRepresentationItem.anchors.centerIn = undefined
            activeApplet.fullRepresentationItem.anchors.fill = undefined

            if (activeApplet.fullRepresentationItem instanceof PlasmaComponents3.Page ||
                activeApplet.fullRepresentationItem instanceof PlasmaExtras.Representation) {
                if (activeApplet.fullRepresentationItem.header && activeApplet.fullRepresentationItem.header instanceof PlasmaExtras.PlasmoidHeading) {
                    mainStack.appletHasHeading = true
                    activeApplet.fullRepresentationItem.header.background.visible = false
                }
                if (activeApplet.fullRepresentationItem.footer && activeApplet.fullRepresentationItem.footer instanceof PlasmaExtras.PlasmoidHeading) {
                    mainStack.appletHasFooter = true
                    activeApplet.fullRepresentationItem.footer.background.visible = false
                }
            }

            let unFlipped = systemTrayState.oldVisualIndex < systemTrayState.newVisualIndex
            if (Application.layoutDirection !== Qt.LeftToRight) {
                unFlipped = !unFlipped
            }

            const isTransitionEnabled = systemTrayState.expanded
            ;(mainStack.empty ? mainStack.push : mainStack.replace)(activeApplet.fullRepresentationItem, {
                "width": Qt.binding(() => mainStack.width),
                "height": Qt.binding(() => mainStack.height),
                "x": 0,
                "focus": Qt.binding(() => !mainStack.busy),
                "opacity": 1,
                "KeyNavigation.up": mainStack.KeyNavigation.up,
                "KeyNavigation.backtab": mainStack.KeyNavigation.backtab
            }, isTransitionEnabled ? (unFlipped ? QQC2.StackView.PushTransition : QQC2.StackView.PopTransition) : QQC2.StackView.Immediate)
        } else {
            mainStack.clear()
        }
    }

    onCurrentItemChanged: {
        if (currentItem !== null && root.expanded) {
            currentItem.forceActiveFocus()
        }
    }

    Connections {
        target: Plasmoid
        function onAppletRemoved(applet) {
            if (applet === systemTrayState.activeApplet) {
                mainStack.clear()
            }
        }
    }

    // Footer link for themed pages (e.g. "More Wi-Fi settings"). Lib.Page
    // declares `footer` as a Component but does not render it — we render it
    // here so the link sits at the bottom of the flyout, Win11-style.
    Rectangle {
        id: themedFooter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: mainStack.themedActive && footerLoader.sourceComponent !== null
        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.03)
        implicitHeight: footerLoader.item ? footerLoader.item.implicitHeight + 8 : 0
        height: implicitHeight

        Loader {
            id: footerLoader
            anchors.fill: parent
            sourceComponent: mainStack.themedActive && mainStack.currentItem && mainStack.currentItem.footer !== undefined ? mainStack.currentItem.footer : null
        }
    }

    readonly property var themedPages: ({
        "network":         networkPageComp,
        "bluetooth":       bluetoothPageComp,
        "volume":          volumePageComp,
        "battery":         batteryPageComp,
        "clipboard":       clipboardPageComp,
        "notifications":   notificationsPageComp,
        "devicenotifier":  deviceNotifierPageComp,
        "mediacontroller": mediaControllerPageComp
    })

    Component {
        id: networkPageComp
        Components.NetworkPage {
            onBack: systemTrayState.setActiveApplet(null)
        }
    }
    Component {
        id: bluetoothPageComp
        Components.BluetoothPage {
            onBack: systemTrayState.setActiveApplet(null)
        }
    }
    Component {
        id: volumePageComp
        Components.VolumePage {
            onBack: systemTrayState.setActiveApplet(null)
        }
    }
    Component {
        id: batteryPageComp
        Components.BatteryPage {
            onBack: systemTrayState.setActiveApplet(null)
        }
    }
    Component {
        id: clipboardPageComp
        Components.ClipboardPage {
            onBack: systemTrayState.setActiveApplet(null)
        }
    }
    Component {
        id: notificationsPageComp
        Components.NotificationsPage {
            onBack: systemTrayState.setActiveApplet(null)
        }
    }
    Component {
        id: deviceNotifierPageComp
        Components.DeviceNotifierPage {
            onBack: systemTrayState.setActiveApplet(null)
        }
    }
    Component {
        id: mediaControllerPageComp
        Components.MediaControllerPage {
            onBack: systemTrayState.setActiveApplet(null)
        }
    }
}

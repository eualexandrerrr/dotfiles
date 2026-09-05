/***************************************************************************
 *   License: GPL-3.0-or-later
 *   Author: Jeysef
 *
 *   Start menu configuration UI.
 *   Follows the Start.Next.Menu pattern: FormData.label directly on
 *   controls, not wrapped in Item.
 ***************************************************************************/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.iconthemes as KIconThemes

KCM.SimpleKCM {
    id: configGeneral

    property string cfg_icon: Plasmoid.configuration.icon
    property bool cfg_useCustomButtonImage: Plasmoid.configuration.useCustomButtonImage
    property string cfg_customButtonImage: Plasmoid.configuration.customButtonImage
    property alias cfg_displayPosition: displayPosition.currentIndex
    property alias cfg_showRightColumn: showRightColumn.checked
    property alias cfg_allAppsSortMode: allAppsSortMode.currentIndex
    property alias cfg_menuTranslucency: menuTranslucency.currentIndex

    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        // ── Icon ───────────────────────────────────────────────────────
        Button {
            id: iconButton

            Kirigami.FormData.label: i18n("Icon:")

            implicitWidth: previewFrame.width + Kirigami.Units.smallSpacing * 2
            implicitHeight: previewFrame.height + Kirigami.Units.smallSpacing * 2

            checkable: true
            checked: false

            onPressed: iconMenu.opened ? iconMenu.close() : iconMenu.open()

            Kirigami.Icon {
                id: previewFrame
                anchors.centerIn: parent
                width: Kirigami.Units.iconSizes.large
                height: width
                source: configGeneral.cfg_useCustomButtonImage
                        ? configGeneral.cfg_customButtonImage
                        : configGeneral.cfg_icon
            }

            Menu {
                id: iconMenu
                y: parent.height

                onClosed: iconButton.checked = false

                MenuItem {
                    text: i18nc("@item:inmenu Open icon chooser dialog", "Choose…")
                    icon.name: "document-open-folder"
                    onClicked: iconDialog.open()
                }
                MenuItem {
                    text: i18nc("@item:inmenu Reset icon to default", "Clear Icon")
                    icon.name: "edit-clear"
                    onClicked: {
                        configGeneral.cfg_icon = "start-here"
                        configGeneral.cfg_useCustomButtonImage = false
                    }
                }
            }

            KIconThemes.IconDialog {
                id: iconDialog

                function setCustomButtonImage(image) {
                    configGeneral.cfg_customButtonImage = image
                        || configGeneral.cfg_icon
                        || "start-here"
                    configGeneral.cfg_useCustomButtonImage = true
                }

                onIconNameChanged: setCustomButtonImage(iconName)
            }
        }

        // ── Section separator ──────────────────────────────────────────
        Item {
            Kirigami.FormData.isSection: true
        }

        // ── Display position ───────────────────────────────────────────
        ComboBox {
            Kirigami.FormData.label: i18n("Menu position")
            id: displayPosition
            model: [
                i18n("Default"),
                i18n("Center"),
                i18n("Center bottom"),
                i18n("Left bottom"),
            ]
        }

        // ── Show places column ─────────────────────────────────────────
        CheckBox {
            id: showRightColumn
            Kirigami.FormData.label: i18n("Show places column")
        }

        // ── All apps sort ──────────────────────────────────────────────
        ComboBox {
            Kirigami.FormData.label: i18n("All apps sort")
            id: allAppsSortMode
            model: [
                i18n("Name (A-Z)"),
                i18n("Name (Z-A)"),
                i18n("Newest first"),
                i18n("Oldest first"),
                i18n("Category")
            ]
        }

        // ── Menu translucency ──────────────────────────────────────────
        ComboBox {
            Kirigami.FormData.label: i18n("Menu translucency")
            id: menuTranslucency
            model: [
                i18n("Follow desktop theme"),
                i18n("Translucent"),
                i18n("Opaque")
            ]
        }
    }
}

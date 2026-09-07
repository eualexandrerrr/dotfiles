import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    title: i18n("Lock Screen")

    Kirigami.FormLayout {
        wideMode: true

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Show clock:")
            checked: cfg_alwaysShowClock
            onCheckedChanged: cfg_alwaysShowClock = checked
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Hide clock when prompt is hidden:")
            checked: cfg_hideClockWhenIdle
            onCheckedChanged: cfg_hideClockWhenIdle = checked
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Show media controls:")
            checked: cfg_showMediaControls
            onCheckedChanged: cfg_showMediaControls = checked
        }
    }
}

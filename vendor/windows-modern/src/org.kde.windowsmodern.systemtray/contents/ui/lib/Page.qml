import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

ColumnLayout {
    id: page

    property string title
    property bool showSwitch: false
    property bool switchChecked: false
    property bool contentFillsHeight: true
    property Component footer: null

    signal back
    signal switchToggled

    spacing: 0

    default property alias content: contentLayout.data

    PageHeader {
        title: page.title
        showSwitch: page.showSwitch
        switchChecked: page.switchChecked
        onBack: page.back()
        onSwitchToggled: page.switchToggled()
    }

    ScrollView {
        id: scrollView
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            id: contentLayout
            width: scrollView.availableWidth
            height: page.contentFillsHeight ? Math.max(implicitHeight, scrollView.availableHeight) : implicitHeight
            spacing: 0
        }
    }
}

/*
    FlyoutRouter — maps child applet plugin names to themed flyout pages.

    Known applets get themed Win11 pages instead of their default Plasma
    fullRepresentationItem. Unknown applets fall through to the default
    PlasmoidPopupsContainer behavior with container chrome.
*/
pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: router

    readonly property var mapping: ({
        "org.kde.plasma.networkmanagement":  "network",
        "org.kde.plasma.bluetooth":         "bluetooth",
        "org.kde.plasma.volume":             "volume",
        "org.kde.plasma.battery":            "battery",
        "org.kde.plasma.clipboard":          "clipboard",
        "org.kde.plasma.notifications":      "notifications",
        "org.kde.plasma.devicenotifier":     "devicenotifier",
        "org.kde.plasma.mediacontroller":    "mediacontroller"
    })

    function flyoutNameForApplet(applet) {
        if (!applet || !applet.Plasmoid)
            return ""
        return mapping[applet.Plasmoid.pluginName] || ""
    }

    function isThemedApplet(applet) {
        return flyoutNameForApplet(applet) !== ""
    }
}

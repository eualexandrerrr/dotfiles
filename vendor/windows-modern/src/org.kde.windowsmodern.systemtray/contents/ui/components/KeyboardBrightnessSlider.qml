import QtQuick
import org.kde.plasma.workspace.dbus as DBus
import "../lib" as Lib

Lib.Slider {
    id: root

    property int kbBrightness: 0
    property int kbMax: 1
    property bool available: false

    iconSource: "keyboard-brightness"

    from: 0
    to: kbMax
    value: kbBrightness
    stepSize: Math.max(1, Math.floor(kbMax / 10))

    onMoved: function (v) {
        DBus.SystemBus.asyncCall({
            service: "org.kde.Solid.PowerManagement",
            path: "/org/kde/Solid/PowerManagement",
            iface: "org.kde.Solid.PowerManagement",
            member: "setKeyboardBrightness",
            arguments: [v]
        });
    }

    Component.onCompleted: {
        var reply = DBus.SystemBus.asyncCall({
            service: "org.kde.Solid.PowerManagement",
            path: "/org/kde/Solid/PowerManagement",
            iface: "org.freedesktop.DBus.Properties",
            member: "GetAll",
            arguments: ["org.kde.Solid.PowerManagement"]
        });
        reply.finished.connect(function () {
            if (reply.isError)
                return;
            var props = reply.value;
            if (props && props.keyboardBrightnessMax && props.keyboardBrightnessMax > 0) {
                root.kbMax = props.keyboardBrightnessMax;
                root.kbBrightness = props.keyboardBrightness || 0;
                root.available = true;
            }
        });
    }
}

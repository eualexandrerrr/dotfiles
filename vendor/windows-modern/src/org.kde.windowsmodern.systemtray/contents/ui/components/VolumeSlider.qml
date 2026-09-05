import QtQuick
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.private.volume as Vol
import "../lib" as Lib
import "../js/funcs.js" as Funcs

Lib.Slider {
    id: root

    property var sink: Vol.PreferredDevice.sink
    readonly property bool sinkAvailable: sink && !(sink.name === "auto_null")

    iconSource: Funcs.volIconName(sinkAvailable ? sink.volume : 0, sinkAvailable ? sink.muted : true)
    showArrow: true

    readonly property int maxVol: sinkAvailable && sink.canRaiseVolume ? 98304 : 65536

    visible: sinkAvailable
    from: 0
    to: maxVol
    value: sinkAvailable ? sink.volume : 0
    stepSize: Math.round(maxVol / 100)

    onMoved: function (v) {
        sink.volume = v;
        sink.muted = v === 0;
        if (!pressed && sinkAvailable)
            feedback.play(sink.index);
    }

    onReleased: {
        if (sinkAvailable)
            feedback.play(sink.index);
    }

    Vol.VolumeFeedback {
        id: feedback
    }

    onIconClicked: {
        if (sinkAvailable)
            sink.muted = !sink.muted;
    }

    onRightClicked: volumeMenu.popup()

    onMiddleClicked: {
        if (sinkAvailable)
            sink.muted = !sink.muted;
    }

    PlasmaComponents3.Menu {
        id: volumeMenu

        PlasmaComponents3.MenuItem {
            text: sinkAvailable && sink.muted ? qsTr("Unmute") : qsTr("Mute")
            icon.name: sinkAvailable && sink.muted ? "audio-volume-muted" : "audio-volume-high"
            onClicked: {
                if (sinkAvailable)
                    sink.muted = !sink.muted;
            }
        }
        PlasmaComponents3.MenuItem {
            text: qsTr("Test sound")
            icon.name: "audio-volume-high"
            onClicked: Vol.VolumeFeedback.play()
        }
        PlasmaComponents3.MenuItem {
            text: qsTr("Audio settings")
            icon.name: "configure"
            onClicked: Qt.openUrlExternally("systemsettings://kcm_pulseaudio")
        }
    }
}

import QtQuick
import org.kde.plasma.private.volume as Vol

QtObject {
    id: root

    readonly property var sink: Vol.PreferredDevice.sink
    readonly property bool sinkAvailable: sink && !(sink.name === "auto_null")

    readonly property var sinkFilterModel: Vol.PulseObjectFilterModel {
        sourceModel: Vol.SinkModel {}
        filterOutInactiveDevices: true
    }

    readonly property var sinkInputFilterModel: Vol.PulseObjectFilterModel {
        sourceModel: Vol.SinkInputModel {}
        filters: [
            {
                role: "VirtualStream",
                value: false
            },
            {
                role: "Name",
                value: function (name) {
                    return name.indexOf("speech-dispatcher") !== 0;
                }
            }
        ]
    }

    readonly property var source: Vol.PreferredDevice.source
    readonly property bool sourceAvailable: source && !(source.name === "auto_null")

    readonly property var sourceFilterModel: Vol.PulseObjectFilterModel {
        sourceModel: Vol.SourceModel {}
        filterOutInactiveDevices: true
    }

    readonly property var feedback: Vol.VolumeFeedback {}

    function playFeedback(sinkIndex) {
        feedback.play(sinkIndex);
    }

    function setDefaultSink(pulseObject) {
        pulseObject.default = true;
    }

    function setDefaultSource(pulseObject) {
        pulseObject.default = true;
    }
}

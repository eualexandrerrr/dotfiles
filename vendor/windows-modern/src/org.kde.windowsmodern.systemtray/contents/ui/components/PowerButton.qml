import QtQuick
import org.kde.plasma.private.sessions as Sessions
import org.kde.kirigami as Kirigami

Item {
    id: root
    signal clicked

    Sessions.SessionManagement {
        id: sessionManagement
    }

    Kirigami.Icon {
        width: 20; height: 20
        anchors.centerIn: parent
        source: "system-shutdown"
        color: Kirigami.Theme.textColor
        isMask: true
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            sessionManagement.requestLogoutPrompt();
            root.clicked();
        }
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: maintContainer
    width: 1184
    height: 626
    implicitWidth: 1184
    implicitHeight: 626
    Layout.fillWidth: true
    Layout.fillHeight: true

    Screen_8_DiagnosticsView {
        id: ui
        anchors.fill: parent
    }
}

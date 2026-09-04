import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: auditContainer
    width: 1184
    height: 626
    implicitWidth: 1184
    implicitHeight: 626
    Layout.fillWidth: true
    Layout.fillHeight: true

    Screen_6_AuditView {
        id: ui
        anchors.fill: parent
    }
}

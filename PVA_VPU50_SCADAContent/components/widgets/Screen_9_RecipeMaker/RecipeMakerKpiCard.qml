import QtQuick
import QtQuick.Layouts

Rectangle {
    id: kpiCard
    implicitWidth: 160
    implicitHeight: 52
    radius: 6
    color: "#0a2e50"
    border.color: "#1d5b94"
    border.width: 1

    property string label: ""
    property int value: 0
    property string valueText: ""

    Column {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 12
        spacing: 2
        Text { text: kpiCard.label; color: "#7dd3fc"; font.pixelSize: 8; font.bold: true }
        Text {
            text: kpiCard.valueText !== "" ? kpiCard.valueText : (kpiCard.value + "")
            color: "#ffffff"
            font.pixelSize: 15
            font.bold: true
        }
    }
}

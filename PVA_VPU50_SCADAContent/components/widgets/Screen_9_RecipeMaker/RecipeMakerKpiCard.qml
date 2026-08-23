import QtQuick
import QtQuick.Layouts

Rectangle {
    id: kpiCard
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
        Text { text: kpiCard.label; color: "#94a3b8"; font.pixelSize: 9; font.bold: true }
        Text {
            text: kpiCard.valueText !== "" ? kpiCard.valueText : (kpiCard.value + "")
            color: "#ffffff"
            font.pixelSize: 16
            font.bold: true
        }
    }
}

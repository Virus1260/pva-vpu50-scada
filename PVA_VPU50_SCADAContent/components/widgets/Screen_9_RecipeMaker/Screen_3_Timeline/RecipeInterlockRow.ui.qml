import QtQuick
import QtQuick.Layouts

Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: 64
    radius: 6
    color: "#0a2e50"
    border.color: "#1d5b94"

    property string title: ""
    property string body: ""

    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 4
        Text { text: title; color: "#ffffff"; font.bold: true; font.pixelSize: 12 }
        Text { text: body; color: "#94a3b8"; font.pixelSize: 11; wrapMode: Text.WordWrap; width: parent.width }
    }
}

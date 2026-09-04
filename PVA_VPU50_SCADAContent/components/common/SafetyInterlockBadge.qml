import QtQuick
import QtQuick.Layouts

Rectangle {
    id: badgeRoot
    implicitWidth: 300
    implicitHeight: 26
    Layout.fillWidth: true
    Layout.preferredHeight: 26

    property string interlockText: "Mechanical Seal Flush Flow Switch (FS-102)"
    property bool isSatisfied: true
    property string tagCode: ""

    radius: 4
    color: isSatisfied ? "#064e3b" : "#450a0a"
    border.color: isSatisfied ? "#10b981" : "#ef4444"
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 6

        Text {
            text: badgeRoot.isSatisfied ? "✓" : "⚠"
            color: badgeRoot.isSatisfied ? "#34d399" : "#fca5a5"
            font.bold: true
            font.pixelSize: 11
        }

        Text {
            text: badgeRoot.interlockText
            color: badgeRoot.isSatisfied ? "#a7f3d0" : "#fecaca"
            font.bold: true
            font.pixelSize: 9
            font.family: "Segoe UI"
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        Text {
            text: badgeRoot.tagCode
            color: badgeRoot.isSatisfied ? "#6ee7b7" : "#f87171"
            font.pixelSize: 8
            font.family: "Consolas"
            visible: badgeRoot.tagCode !== ""
        }
    }
}

import QtQuick
import QtQuick.Layouts
import "../../common"

Rectangle {
    id: selectorRoot
    property string label: "Mode"
    property string modeText: ""
    property string iconName: ""
    property real preferredWidth: 66
    property real selectorHeight: 68
    property bool isPressed: mouseArea.pressed

    signal clicked()

    Layout.preferredWidth: preferredWidth
    Layout.minimumWidth: preferredWidth
    Layout.maximumWidth: preferredWidth
    Layout.preferredHeight: selectorHeight
    Layout.minimumHeight: selectorHeight
    Layout.maximumHeight: selectorHeight

    color: isPressed ? "#124373" : (mouseArea.containsMouse ? "#0f3c67" : "#0d345a")
    border.color: mouseArea.containsMouse ? "#3892e6" : "#1e5b94"
    border.width: 1
    radius: 4

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 2
        anchors.rightMargin: 2
        anchors.topMargin: 4
        anchors.bottomMargin: 4
        spacing: 2

        // Top Label (e.g. Mode, Regulation, Temp. Indic.)
        Text {
            text: selectorRoot.label
            color: "#8cb5dc"
            font.pixelSize: 9
            font.bold: true
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        // Center Icon or Mode Text
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScadaIcon {
                anchors.centerIn: parent
                iconName: selectorRoot.iconName
                width: 32
                height: 32
                visible: selectorRoot.iconName !== ""
            }

            Text {
                anchors.centerIn: parent
                text: selectorRoot.modeText
                color: "#ffffff"
                font.bold: true
                font.pixelSize: 11
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                visible: selectorRoot.iconName === ""
            }
        }

        // Bottom Dropdown Indicator Arrow
        Text {
            text: "▼"
            color: "#8cb5dc"
            font.pixelSize: 7
            Layout.alignment: Qt.AlignHCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: selectorRoot.clicked()
    }
}

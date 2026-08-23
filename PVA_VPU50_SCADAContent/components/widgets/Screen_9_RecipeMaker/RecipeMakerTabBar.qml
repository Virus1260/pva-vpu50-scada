import QtQuick
import QtQuick.Layouts

// Authoring workspaces: human flow first, then parameters, BOM, interlocks, governance.
Rectangle {
    id: tabRoot
    implicitWidth: 800
    implicitHeight: 36
    Layout.fillWidth: true
    Layout.preferredHeight: 36
    color: "#06182c"
    border.color: "#184d7e"
    border.width: 1
    radius: 6

    property int currentTab: 0
    readonly property var tabs: ["Tasks", "Parameters", "Bill of Materials", "Interlocks", "Governance"]

    signal tabClicked(int index)

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Repeater {
            model: tabRoot.tabs
            delegate: Rectangle {
                width: tabLabel.implicitWidth + 24
                height: 26
                radius: 4
                color: tabRoot.currentTab === index ? "#154d80" : "transparent"
                border.color: tabRoot.currentTab === index ? "#38bdf8" : "transparent"
                border.width: 1

                Text {
                    id: tabLabel
                    anchors.centerIn: parent
                    text: modelData
                    color: tabRoot.currentTab === index ? "#ffffff" : "#94a3b8"
                    font.bold: tabRoot.currentTab === index
                    font.pixelSize: 11
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        tabRoot.currentTab = index
                        tabRoot.tabClicked(index)
                    }
                }
            }
        }
    }
}

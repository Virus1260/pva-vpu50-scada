import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// One ISA-88 stage (unit procedure): name, sequential lock, reorder/copy/delete.
Rectangle {
    id: stageCard
    implicitWidth: 220
    implicitHeight: 110
    width: 220
    height: 110
    radius: 6
    color: selected ? "#0c345a" : "#0a2e50"
    border.color: selected ? "#00d2ff" : "#1d5b94"
    border.width: selected ? 2 : 1

    property int stageNumber: 1
    property string stageName: ""
    property bool sequentialLock: true
    property bool selected: false

    signal clicked()
    signal nameEdited(string value)
    signal lockToggled()
    signal moveUp()
    signal moveDown()
    signal duplicated()
    signal deleted()

    MouseArea {
        anchors.fill: parent
        onClicked: stageCard.clicked()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "STAGE " + stageCard.stageNumber
                color: "#38bdf8"
                font.bold: true
                font.pixelSize: 10
            }
            Item { Layout.fillWidth: true }
            Repeater {
                model: [
                    { glyph: "↑", key: "up" },
                    { glyph: "↓", key: "down" },
                    { glyph: "⧉", key: "dup" },
                    { glyph: "✕", key: "del" }
                ]
                delegate: Rectangle {
                    width: 20
                    height: 20
                    radius: 3
                    color: modelData.key === "del" ? "#450a0a" : "#0d2847"
                    border.color: modelData.key === "del" ? "#ef4444" : "#1e40af"
                    Text {
                        anchors.centerIn: parent
                        text: modelData.glyph
                        color: modelData.key === "del" ? "#f87171" : "#94a3b8"
                        font.pixelSize: 10
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.key === "up") stageCard.moveUp()
                            else if (modelData.key === "down") stageCard.moveDown()
                            else if (modelData.key === "dup") stageCard.duplicated()
                            else stageCard.deleted()
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            Text { text: "Stage Title"; color: "#7dd3fc"; font.pixelSize: 8; font.bold: true }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 26
                radius: 4
                color: "#08213b"
                border.color: nameInput.activeFocus ? "#00d2ff" : "#1d5b94"

                TextInput {
                    id: nameInput
                    anchors.fill: parent
                    anchors.leftMargin: 6
                    anchors.rightMargin: 6
                    verticalAlignment: TextInput.AlignVCenter
                    text: stageCard.stageName
                    color: "#ffffff"
                    font.pixelSize: 11
                    font.bold: true
                    selectByMouse: true
                    onEditingFinished: stageCard.nameEdited(text)
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Sequential execution lock"
                color: stageCard.sequentialLock ? "#38bdf8" : "#64748b"
                font.pixelSize: 9
            }
            Item { Layout.fillWidth: true }
            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 16
                radius: 8
                color: stageCard.sequentialLock ? "#0284c7" : "#334155"
                Rectangle {
                    width: 12
                    height: 12
                    radius: 6
                    color: "#ffffff"
                    anchors.verticalCenter: parent.verticalCenter
                    x: stageCard.sequentialLock ? parent.width - width - 2 : 2
                    Behavior on x { NumberAnimation { duration: 120 } }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: stageCard.lockToggled()
                }
            }
        }
    }
}

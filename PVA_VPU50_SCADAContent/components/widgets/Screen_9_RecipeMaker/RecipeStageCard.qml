import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// One ISA-88 stage (unit procedure): name, sequential lock, reorder/copy/delete.
Rectangle {
    id: stageCard
    width: parent ? parent.width : 280
    height: 118
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
        anchors.margins: 10
        spacing: 6

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
                    width: 22
                    height: 22
                    radius: 3
                    color: modelData.key === "del" ? "#450a0a" : "#0d2847"
                    border.color: modelData.key === "del" ? "#ef4444" : "#1e40af"
                    Text {
                        anchors.centerIn: parent
                        text: modelData.glyph
                        color: modelData.key === "del" ? "#f87171" : "#94a3b8"
                        font.pixelSize: 11
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
            Text { text: "Name the stage"; color: "#6b8fbb"; font.pixelSize: 9 }
            TextField {
                id: nameField
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                text: stageCard.stageName
                color: "#ffffff"
                font.pixelSize: 12
                background: Rectangle {
                    color: "#08213b"
                    border.color: "#1d5b94"
                    radius: 4
                }
                onEditingFinished: stageCard.nameEdited(text)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Task sequential lock"
                color: "#cbd5e1"
                font.pixelSize: 10
                Layout.fillWidth: true
            }
            Rectangle {
                width: 40
                height: 20
                radius: 10
                color: stageCard.sequentialLock ? "#1d4ed8" : "#1e293b"
                border.color: stageCard.sequentialLock ? "#38bdf8" : "#475569"
                Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    x: stageCard.sequentialLock ? parent.width - 18 : 2
                    y: 2
                    color: "#ffffff"
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

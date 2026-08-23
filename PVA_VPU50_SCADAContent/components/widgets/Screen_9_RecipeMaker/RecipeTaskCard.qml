import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// One operation inside a stage: name, activity types, live P&ID summary, add-activity.
Rectangle {
    id: taskCard
    width: parent ? parent.width : 360
    height: selected ? 168 : 132
    radius: 6
    color: selected ? "#0c345a" : "#0a2e50"
    border.color: selected ? "#00d2ff" : "#1d5b94"
    border.width: selected ? 2 : 1

    property string taskLabel: "Task 1.1"
    property string taskName: ""
    property bool selected: false
    property bool hasTimer: false
    property bool hasManual: false
    property bool hasMedia: false
    property bool hasLoop: false
    property bool hasSchedule: false
    property bool hasHold: false
    property bool hasEquip: false
    property bool hasCheck: false
    property string tagSummary: ""
    property string stopSummary: ""

    signal clicked()
    signal nameEdited(string value)
    signal typeToggled(string typeKey)
    signal addActivity()
    signal duplicated()
    signal deleted()
    signal moveUp()
    signal moveDown()

    MouseArea {
        anchors.fill: parent
        onClicked: taskCard.clicked()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: taskCard.taskLabel
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
                            if (modelData.key === "up") taskCard.moveUp()
                            else if (modelData.key === "down") taskCard.moveDown()
                            else if (modelData.key === "dup") taskCard.duplicated()
                            else taskCard.deleted()
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            Text { text: "Name the task"; color: "#6b8fbb"; font.pixelSize: 9 }
            TextField {
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                text: taskCard.taskName
                color: "#ffffff"
                font.pixelSize: 12
                background: Rectangle {
                    color: "#08213b"
                    border.color: "#1d5b94"
                    radius: 4
                }
                onEditingFinished: taskCard.nameEdited(text)
            }
        }

        RecipeActivityToolbar {
            Layout.fillWidth: true
            hasTimer: taskCard.hasTimer
            hasManual: taskCard.hasManual
            hasMedia: taskCard.hasMedia
            hasLoop: taskCard.hasLoop
            hasSchedule: taskCard.hasSchedule
            hasHold: taskCard.hasHold
            hasEquip: taskCard.hasEquip
            hasCheck: taskCard.hasCheck
            onTypeToggled: function(typeKey) { taskCard.typeToggled(typeKey) }
        }

        RowLayout {
            Layout.fillWidth: true
            visible: taskCard.tagSummary !== "" || taskCard.stopSummary !== ""
            Rectangle {
                visible: taskCard.tagSummary !== ""
                Layout.preferredHeight: 20
                Layout.preferredWidth: tagTxt.implicitWidth + 12
                radius: 3
                color: "#08213b"
                border.color: "#38bdf8"
                Text {
                    id: tagTxt
                    anchors.centerIn: parent
                    text: taskCard.tagSummary
                    color: "#38bdf8"
                    font.pixelSize: 9
                    font.bold: true
                }
            }
            Rectangle {
                visible: taskCard.stopSummary !== ""
                Layout.preferredHeight: 20
                Layout.preferredWidth: stopTxt.implicitWidth + 12
                radius: 3
                color: taskCard.hasHold ? "#78350f" : "#08213b"
                border.color: taskCard.hasHold ? "#f59e0b" : "#1d5b94"
                Text {
                    id: stopTxt
                    anchors.centerIn: parent
                    text: taskCard.stopSummary
                    color: taskCard.hasHold ? "#fde68a" : "#94a3b8"
                    font.pixelSize: 9
                    font.bold: true
                }
            }
            Item { Layout.fillWidth: true }
            Text {
                text: "+ Add activity"
                color: "#38bdf8"
                font.pixelSize: 10
                font.bold: true
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: taskCard.addActivity()
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

// One operation inside a stage: name, activity types, live P&ID summary, add-activity.
// Optimized for touchscreen human finger touch operation (32px action buttons & 36px activity buttons).
Rectangle {
    id: taskCard
    implicitWidth: 380
    implicitHeight: 140
    width: 380
    height: 140
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
        anchors.margins: 8
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                text: taskCard.taskLabel
                color: "#38bdf8"
                font.bold: true
                font.pixelSize: 11
            }
            Item { Layout.fillWidth: true }
            Repeater {
                model: [
                    { icon: "arrow_up", key: "up", tip: "Move Task Up" },
                    { icon: "arrow_down", key: "down", tip: "Move Task Down" },
                    { icon: "duplicate", key: "dup", tip: "Duplicate Task" },
                    { icon: "close_x", key: "del", tip: "Delete Task" }
                ]
                delegate: Rectangle {
                    id: taskActionBtn
                    width: 32
                    height: 32
                    radius: 5
                    color: modelData.key === "del" ? (tskMouse.containsMouse ? "#7f1d1d" : "#450a0a") : (tskMouse.containsMouse ? "#11385f" : "#0d2847")
                    border.color: modelData.key === "del" ? "#ef4444" : (tskMouse.containsMouse ? "#38bdf8" : "#1e40af")
                    border.width: 1

                    scale: tskMouse.pressed ? 0.90 : (tskMouse.containsMouse ? 1.10 : 1.0)
                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }

                    ScadaIcon {
                        anchors.centerIn: parent
                        width: 18
                        height: 18
                        iconName: modelData.icon
                        iconColor: modelData.key === "del" ? "#f87171" : "#94a3b8"
                    }
                    MouseArea {
                        id: tskMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.key === "up") taskCard.moveUp()
                            else if (modelData.key === "down") taskCard.moveDown()
                            else if (modelData.key === "dup") taskCard.duplicated()
                            else taskCard.deleted()
                        }
                        ToolTip.visible: containsMouse
                        ToolTip.text: modelData.tip
                        ToolTip.delay: 250
                    }
                }
            }
        }

        // Editable Task Name
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 26
            radius: 4
            color: "#08213b"
            border.color: tskNameInput.activeFocus ? "#00d2ff" : "#1d5b94"

            TextInput {
                id: tskNameInput
                anchors.fill: parent
                anchors.leftMargin: 6
                anchors.rightMargin: 6
                verticalAlignment: TextInput.AlignVCenter
                text: taskCard.taskName
                color: "#ffffff"
                font.pixelSize: 11
                font.bold: true
                selectByMouse: true
                onEditingFinished: taskCard.nameEdited(text)
            }
        }

        RecipeActivityToolbar {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
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
            spacing: 6

            Rectangle {
                visible: taskCard.tagSummary !== ""
                Layout.preferredHeight: 18
                Layout.preferredWidth: tagTxt.implicitWidth + 10
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
                Layout.preferredHeight: 18
                Layout.preferredWidth: stopTxt.implicitWidth + 10
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
        }
    }
}

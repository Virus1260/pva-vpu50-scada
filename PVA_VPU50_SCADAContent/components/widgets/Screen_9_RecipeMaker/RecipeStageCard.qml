import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

// One ISA-88 stage (unit procedure): name, sequential lock, reorder/copy/delete.
// Touchscreen-friendly touch targets (32px x 32px) for human finger touches.
Rectangle {
    id: stageCard
    implicitWidth: 230
    implicitHeight: 120
    width: 230
    height: 120
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
            spacing: 4

            Text {
                text: "STAGE " + stageCard.stageNumber
                color: "#38bdf8"
                font.bold: true
                font.pixelSize: 11
            }
            Item { Layout.fillWidth: true }
            Repeater {
                model: [
                    { icon: "arrow_up", key: "up", tip: "Move Stage Up" },
                    { icon: "arrow_down", key: "down", tip: "Move Stage Down" },
                    { icon: "duplicate", key: "dup", tip: "Duplicate Stage" },
                    { icon: "close_x", key: "del", tip: "Delete Stage" }
                ]
                delegate: Rectangle {
                    id: stageActionBtn
                    width: 32
                    height: 32
                    radius: 5
                    color: modelData.key === "del" ? (stgMouse.containsMouse ? "#7f1d1d" : "#450a0a") : (stgMouse.containsMouse ? "#11385f" : "#0d2847")
                    border.color: modelData.key === "del" ? "#ef4444" : (stgMouse.containsMouse ? "#38bdf8" : "#1e40af")
                    border.width: 1

                    scale: stgMouse.pressed ? 0.90 : (stgMouse.containsMouse ? 1.10 : 1.0)
                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }

                    ScadaIcon {
                        anchors.centerIn: parent
                        width: 18
                        height: 18
                        iconName: modelData.icon
                        iconColor: modelData.key === "del" ? "#f87171" : "#94a3b8"
                    }
                    MouseArea {
                        id: stgMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.key === "up") stageCard.moveUp()
                            else if (modelData.key === "down") stageCard.moveDown()
                            else if (modelData.key === "dup") stageCard.duplicated()
                            else stageCard.deleted()
                        }
                        ToolTip.visible: containsMouse
                        ToolTip.text: modelData.tip
                        ToolTip.delay: 250
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: "Stage Title"
                color: "#64748b"
                font.pixelSize: 9
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 26
                radius: 4
                color: "#081d33"
                border.color: "#1d4f7c"
                border.width: 1
                TextInput {
                    anchors.fill: parent
                    anchors.leftMargin: 6
                    anchors.rightMargin: 6
                    verticalAlignment: TextInput.AlignVCenter
                    color: "#ffffff"
                    font.pixelSize: 11
                    font.bold: true
                    text: stageCard.stageName
                    selectByMouse: true
                    onEditingFinished: stageCard.nameEdited(text)
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Sequential execution lock"
                color: "#94a3b8"
                font.pixelSize: 9
                Layout.fillWidth: true
            }
            Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 16
                radius: 8
                color: stageCard.sequentialLock ? "#0284c7" : "#334155"
                Rectangle {
                    x: stageCard.sequentialLock ? 18 : 2
                    y: 2
                    width: 12
                    height: 12
                    radius: 6
                    color: "#ffffff"
                    Behavior on x { NumberAnimation { duration: 150 } }
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

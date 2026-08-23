import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Detail editor for the selected task: device, action, setpoint, stop condition, hold text.
Rectangle {
    id: inspectorRoot
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#06182c"
    border.color: "#184d7e"
    border.width: 1
    radius: 6

    property string taskLabel: "Select a task"
    property string taskName: ""
    property int deviceIndex: 0
    property int actionIndex: 0
    property string setpoint: ""
    property int stopIndex: 0
    property string durationSec: "0"
    property bool requireConfirm: false
    property string confirmMessage: ""
    property bool emptySelection: true

    readonly property var deviceOptions: [
        "1M1501 Anchor agitator",
        "1X1001 Homogenizer",
        "1M5001 / 1P5001 Vacuum",
        "1E6001 Jacket heat/cool",
        "1K1001 Charge / CIP valve",
        "1M2001 Discharge pump",
        "1M6001 Recirc pump",
        "MANUAL Operator action"
    ]
    readonly property var actionOptions: ["ON", "OFF", "RAMP"]
    readonly property var stopOptions: [
        "timer",
        "level_below",
        "level_above",
        "temp_above",
        "temp_below",
        "manual",
        "vessel_empty"
    ]

    signal nameEdited(string value)
    signal deviceChanged(int index)
    signal actionChanged(int index)
    signal setpointEdited(string value)
    signal stopChanged(int index)
    signal durationEdited(string value)
    signal confirmToggled()
    signal confirmMessageEdited(string value)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        Text {
            text: "TASK PROPERTIES"
            color: "#38bdf8"
            font.bold: true
            font.pixelSize: 11
        }
        Text {
            text: inspectorRoot.emptySelection ? "Select a task on the left to edit setpoints and stop conditions." : inspectorRoot.taskLabel
            color: "#94a3b8"
            font.pixelSize: 11
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            enabled: !inspectorRoot.emptySelection
            opacity: inspectorRoot.emptySelection ? 0.45 : 1.0

            Text { text: "Task name"; color: "#6b8fbb"; font.pixelSize: 9 }
            TextField {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                text: inspectorRoot.taskName
                color: "#ffffff"
                background: Rectangle { color: "#08213b"; border.color: "#1d5b94"; radius: 4 }
                onEditingFinished: inspectorRoot.nameEdited(text)
            }

            Text { text: "P&ID device"; color: "#6b8fbb"; font.pixelSize: 9 }
            ComboBox {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                model: inspectorRoot.deviceOptions
                currentIndex: inspectorRoot.deviceIndex
                onActivated: inspectorRoot.deviceChanged(index)
            }

            Text { text: "Action"; color: "#6b8fbb"; font.pixelSize: 9 }
            ComboBox {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                model: inspectorRoot.actionOptions
                currentIndex: inspectorRoot.actionIndex
                onActivated: inspectorRoot.actionChanged(index)
            }

            Text { text: "Setpoint (RPM / °C / % / mbar)"; color: "#6b8fbb"; font.pixelSize: 9 }
            TextField {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                text: inspectorRoot.setpoint
                color: "#4ade80"
                font.bold: true
                background: Rectangle { color: "#08213b"; border.color: "#1d5b94"; radius: 4 }
                onEditingFinished: inspectorRoot.setpointEdited(text)
            }

            Text { text: "Stop condition"; color: "#6b8fbb"; font.pixelSize: 9 }
            ComboBox {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                model: inspectorRoot.stopOptions
                currentIndex: inspectorRoot.stopIndex
                onActivated: inspectorRoot.stopChanged(index)
            }

            Text { text: "Duration (sec)"; color: "#6b8fbb"; font.pixelSize: 9 }
            TextField {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                text: inspectorRoot.durationSec
                color: "#ffffff"
                background: Rectangle { color: "#08213b"; border.color: "#1d5b94"; radius: 4 }
                onEditingFinished: inspectorRoot.durationEdited(text)
            }

            RowLayout {
                Layout.fillWidth: true
                Text { text: "21 CFR hold / confirm"; color: "#cbd5e1"; font.pixelSize: 11; Layout.fillWidth: true }
                Rectangle {
                    width: 40
                    height: 20
                    radius: 10
                    color: inspectorRoot.requireConfirm ? "#1d4ed8" : "#1e293b"
                    border.color: inspectorRoot.requireConfirm ? "#38bdf8" : "#475569"
                    Rectangle {
                        width: 16; height: 16; radius: 8; y: 2
                        x: inspectorRoot.requireConfirm ? parent.width - 18 : 2
                        color: "#ffffff"
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: inspectorRoot.confirmToggled()
                    }
                }
            }

            Text { text: "Confirm message"; color: "#6b8fbb"; font.pixelSize: 9; visible: inspectorRoot.requireConfirm }
            TextField {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                visible: inspectorRoot.requireConfirm
                text: inspectorRoot.confirmMessage
                color: "#ffffff"
                background: Rectangle { color: "#08213b"; border.color: "#f59e0b"; radius: 4 }
                onEditingFinished: inspectorRoot.confirmMessageEdited(text)
            }
        }

        Item { Layout.fillHeight: true }
    }
}

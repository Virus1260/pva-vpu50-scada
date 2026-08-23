import QtQuick
import QtQuick.Layouts

// Flattened critical-process-parameter list for the whole master recipe.
Rectangle {
    id: paramRoot
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#06182c"
    border.color: "#184d7e"
    border.width: 1
    radius: 6

    property var taskModel

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        Text { text: "PROCESS PARAMETERS (ALL TASKS)"; color: "#38bdf8"; font.bold: true; font.pixelSize: 11 }
        Text { text: "Setpoints and stop conditions across every stage. Edit a row by selecting the task on the Tasks tab."; color: "#94a3b8"; font.pixelSize: 10; wrapMode: Text.WordWrap; Layout.fillWidth: true }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            color: "#0a243f"
            radius: 4
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                Text { text: "TASK"; color: "#6b8fbb"; font.bold: true; font.pixelSize: 10; Layout.preferredWidth: 70 }
                Text { text: "NAME"; color: "#6b8fbb"; font.bold: true; font.pixelSize: 10; Layout.fillWidth: true }
                Text { text: "P&ID TAG"; color: "#6b8fbb"; font.bold: true; font.pixelSize: 10; Layout.preferredWidth: 160 }
                Text { text: "SETPOINT"; color: "#6b8fbb"; font.bold: true; font.pixelSize: 10; Layout.preferredWidth: 110 }
                Text { text: "STOP"; color: "#6b8fbb"; font.bold: true; font.pixelSize: 10; Layout.preferredWidth: 110 }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 3
            model: paramRoot.taskModel
            delegate: Rectangle {
                width: ListView.view.width
                height: 32
                radius: 4
                color: index % 2 === 0 ? "#092440" : "#071b30"
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    Text { text: model.label; color: "#38bdf8"; font.bold: true; font.pixelSize: 10; Layout.preferredWidth: 70 }
                    Text { text: model.name; color: "#ffffff"; font.pixelSize: 11; Layout.fillWidth: true; elide: Text.ElideRight }
                    Text { text: model.tagSummary; color: "#38bdf8"; font.pixelSize: 10; Layout.preferredWidth: 160; elide: Text.ElideRight }
                    Text { text: model.setpoint; color: "#4ade80"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 110; elide: Text.ElideRight }
                    Text { text: model.stopSummary; color: "#fde68a"; font.pixelSize: 10; Layout.preferredWidth: 110; elide: Text.ElideRight }
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Layouts

// Formulation / specification view: ingredients by SAP-style phase, quantities, UOM.
Rectangle {
    id: bomRoot
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#06182c"
    border.color: "#184d7e"
    border.width: 1
    radius: 6

    property var bomModel

    function phaseColor(phase) {
        if (phase === "A") return "#1e3a8a"
        if (phase === "B") return "#14532d"
        if (phase === "C") return "#7c2d12"
        if (phase === "D") return "#581c87"
        if (phase === "E") return "#854d0e"
        return "#0f766e"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        Text { text: "BILL OF MATERIALS / FORMULATION"; color: "#38bdf8"; font.bold: true; font.pixelSize: 11 }
        Text { text: "Specification items by phase. This is the formula; Tasks describe how the vessel executes it."; color: "#94a3b8"; font.pixelSize: 10; wrapMode: Text.WordWrap; Layout.fillWidth: true }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            color: "#0a243f"
            radius: 4
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                Text { text: "PH"; color: "#6b8fbb"; font.bold: true; font.pixelSize: 10; Layout.preferredWidth: 28 }
                Text { text: "INGREDIENT / SPECIFICATION"; color: "#6b8fbb"; font.bold: true; font.pixelSize: 10; Layout.fillWidth: true }
                Text { text: "QTY"; color: "#6b8fbb"; font.bold: true; font.pixelSize: 10; Layout.preferredWidth: 90 }
                Text { text: "UOM"; color: "#6b8fbb"; font.bold: true; font.pixelSize: 10; Layout.preferredWidth: 50 }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 3
            model: bomRoot.bomModel
            delegate: Rectangle {
                width: ListView.view.width
                height: 30
                radius: 4
                color: index % 2 === 0 ? "#092440" : "#071b30"
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8
                    Rectangle {
                        width: 22; height: 22; radius: 3
                        color: bomRoot.phaseColor(model.phase)
                        Text { anchors.centerIn: parent; text: model.phase; color: "#ffffff"; font.bold: true; font.pixelSize: 10 }
                    }
                    Text { text: model.name; color: "#ffffff"; font.pixelSize: 12; Layout.fillWidth: true; elide: Text.ElideRight }
                    Text { text: model.qty; color: "#4ade80"; font.bold: true; font.pixelSize: 12; Layout.preferredWidth: 90; font.family: "Consolas" }
                    Text { text: model.uom; color: "#94a3b8"; font.pixelSize: 11; Layout.preferredWidth: 50 }
                }
            }
        }
    }
}

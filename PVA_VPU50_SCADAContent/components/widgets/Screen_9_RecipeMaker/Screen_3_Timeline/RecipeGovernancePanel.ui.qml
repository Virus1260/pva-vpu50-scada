import QtQuick
import QtQuick.Layouts

// Author / reviewer / approver record for the master recipe (ISA-88 governance).
Rectangle {
    id: govRoot
    implicitWidth: 800
    implicitHeight: 400
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#06182c"
    border.color: "#184d7e"
    border.width: 1
    radius: 6

    property string recipeStatus: "DRAFT"
    property string authorName: "Process Incharge"
    property string reviewerName: "—"
    property string approverName: "—"
    property string approvalDate: "—"
    property int recipeVersion: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        Text { text: "GOVERNANCE & E-SIGNATURE"; color: "#38bdf8"; font.bold: true; font.pixelSize: 11 }
        Text {
            text: "Master recipe lifecycle: Being Built → In Review → Approved. Execution only reads Approved recipes, and always from a batch snapshot."
            color: "#94a3b8"
            font.pixelSize: 10
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Repeater {
            model: [
                    { role: "AUTHOR (INCHARGE)", name: govRoot.authorName, initials: "IN", hint: "Creates and edits the master recipe" },
                    { role: "REVIEWER", name: govRoot.reviewerName, initials: "RV", hint: "Checks flow, setpoints, and holds" },
                    { role: "APPROVER", name: govRoot.approverName, initials: "AP", hint: "21 CFR Part 11 electronic signature" }
            ]
            delegate: Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 72
                radius: 6
                color: "#0a2e50"
                border.color: "#1d5b94"
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12
                    Rectangle {
                        width: 40; height: 40; radius: 20
                        color: "#154d80"
                        border.color: "#38bdf8"
                        Text {
                            anchors.centerIn: parent
                            text: modelData.initials
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 12
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text { text: modelData.role; color: "#6b8fbb"; font.bold: true; font.pixelSize: 9 }
                        Text { text: modelData.name; color: "#ffffff"; font.bold: true; font.pixelSize: 14 }
                        Text { text: modelData.hint; color: "#94a3b8"; font.pixelSize: 10 }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            radius: 6
            color: "#0a243f"
            border.color: "#1e40af"
            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 3
                Text { text: "CURRENT STATUS"; color: "#38bdf8"; font.bold: true; font.pixelSize: 9 }
                Text { text: "Version " + govRoot.recipeVersion + ".0  ·  " + govRoot.recipeStatus; color: "#ffffff"; font.pixelSize: 13; font.bold: true }
                Text { text: "Signed at: " + govRoot.approvalDate; color: "#94a3b8"; font.pixelSize: 11 }
            }
        }

        Item { Layout.fillHeight: true }
    }
}

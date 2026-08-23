import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Role assignment overlay: Author / Reviewer / Approver (one role per collaborator).
Rectangle {
    id: modalRoot
    anchors.fill: parent
    visible: false
    color: "#cc041428"
    z: 80

    signal cancelled()
    signal sent()

    MouseArea { anchors.fill: parent; onClicked: modalRoot.cancelled() }

    Rectangle {
        width: 640
        height: 420
        radius: 8
        anchors.centerIn: parent
        color: "#0a2e50"
        border.color: "#1d5b94"
        border.width: 1

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            Text { text: "Add Collaborators"; color: "#ffffff"; font.bold: true; font.pixelSize: 18 }

            RowLayout {
                Layout.fillWidth: true
                Text { text: "Collaborators"; color: "#94a3b8"; font.bold: true; font.pixelSize: 11; Layout.fillWidth: true }
                Text { text: "Authors"; color: "#94a3b8"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 80; horizontalAlignment: Text.AlignHCenter }
                Text { text: "Reviewers"; color: "#94a3b8"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 80; horizontalAlignment: Text.AlignHCenter }
                Text { text: "Approvers"; color: "#94a3b8"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 80; horizontalAlignment: Text.AlignHCenter }
            }

            Repeater {
                model: [
                    { name: "Process Incharge", emp: "EMP ID: 1001", initials: "PI", role: 0 },
                    { name: "Shift Supervisor", emp: "EMP ID: 1002", initials: "SS", role: 1 },
                    { name: "QA Manager", emp: "EMP ID: 2001", initials: "QA", role: 2 }
                ]
                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    radius: 4
                    color: "#08213b"
                    border.color: "#1d5b94"
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10
                        Text { text: "✕"; color: "#64748b"; font.pixelSize: 12 }
                        Rectangle {
                            width: 32; height: 32; radius: 16
                            color: "#154d80"
                            Text { anchors.centerIn: parent; text: modelData.initials; color: "#ffffff"; font.bold: true; font.pixelSize: 10 }
                        }
                        Column {
                            Layout.fillWidth: true
                            Text { text: modelData.name; color: "#ffffff"; font.pixelSize: 13; font.bold: true }
                            Text { text: modelData.emp; color: "#94a3b8"; font.pixelSize: 10 }
                        }
                        Rectangle {
                            Layout.preferredWidth: 80
                            height: 16
                            color: "transparent"
                            Rectangle {
                                width: 14; height: 14; radius: 7; anchors.centerIn: parent
                                border.color: "#38bdf8"; color: modelData.role === 0 ? "#1d4ed8" : "transparent"
                            }
                        }
                        Rectangle {
                            Layout.preferredWidth: 80
                            height: 16
                            color: "transparent"
                            Rectangle {
                                width: 14; height: 14; radius: 7; anchors.centerIn: parent
                                border.color: "#38bdf8"; color: modelData.role === 1 ? "#1d4ed8" : "transparent"
                            }
                        }
                        Rectangle {
                            Layout.preferredWidth: 80
                            height: 16
                            color: "transparent"
                            Rectangle {
                                width: 14; height: 14; radius: 7; anchors.centerIn: parent
                                border.color: "#38bdf8"; color: modelData.role === 2 ? "#1d4ed8" : "transparent"
                            }
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                ComboBox {
                    Layout.preferredWidth: 240
                    Layout.preferredHeight: 32
                    model: ["Add Collaborator…", "Operator A", "Operator B"]
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "Cancel"
                    color: "#94a3b8"
                    font.pixelSize: 13
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: modalRoot.cancelled() }
                }
                Rectangle {
                    Layout.preferredWidth: 88
                    Layout.preferredHeight: 34
                    radius: 4
                    color: "#1d4ed8"
                    Text { anchors.centerIn: parent; text: "Send"; color: "#ffffff"; font.bold: true; font.pixelSize: 13 }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: modalRoot.sent() }
                }
            }
        }
    }
}

pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: delConfirmRoot
    implicitWidth: 1024
    implicitHeight: 600
    color: "#bb000000"
    visible: false
    z: 110

    property string targetItemTitle: "Ingredient Name"
    property string targetItemType: "ingredient" // "ingredient" or "recipe"

    signal confirmed
    signal cancelled

    MouseArea {
        anchors.fill: parent
    }

    Rectangle {
        id: box
        anchors.centerIn: parent
        width: 440
        height: 220
        color: "#0b2e52"
        border.color: "#ef4444"
        border.width: 2
        radius: 8

        // Top-Right Corner Close Button
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 12
            anchors.rightMargin: 12
            width: 26
            height: 26
            radius: 4
            z: 10
            color: closeMouse.containsMouse ? "#ef4444" : "#0d365e"
            border.color: closeMouse.containsMouse ? "#f87171" : "#1d5b94"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "✕"
                color: closeMouse.containsMouse ? "#ffffff" : "#94a3b8"
                font.pixelSize: 12
                font.bold: true
                font.family: "Segoe UI"
            }

            MouseArea {
                id: closeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: delConfirmRoot.cancelled()
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: 18
                    color: "#450a0a"
                    border.color: "#ef4444"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "⚠"
                        color: "#ef4444"
                        font.bold: true
                        font.pixelSize: 18
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: "CONFIRM DELETION"
                        color: "#f87171"
                        font.bold: true
                        font.pixelSize: 14
                    }
                    Text {
                        text: "21 CFR Part 11 Electronic Records Safety Prompt"
                        color: "#94a3b8"
                        font.pixelSize: 10
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#1d5b94"
            }

            Text {
                Layout.fillWidth: true
                text: "Are you sure you want to permanently delete <b>" + delConfirmRoot.targetItemTitle + "</b> from the formulation?<br>This action will be recorded in the secure audit trail."
                color: "#e2e8f0"
                font.pixelSize: 12
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Item { Layout.fillWidth: true }

                Rectangle {
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 34
                    radius: 4
                    color: cancelMouse.containsMouse ? "#334155" : "#1e293b"
                    border.color: "#475569"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 11
                    }

                    MouseArea {
                        id: cancelMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: delConfirmRoot.cancelled()
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 34
                    radius: 4
                    color: delMouse.containsMouse ? "#b91c1c" : "#dc2626"
                    border.color: "#f87171"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "DELETE"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: delMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: delConfirmRoot.confirmed()
                    }
                }
            }
        }
    }
}

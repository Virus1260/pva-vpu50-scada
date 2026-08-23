import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: opRowRoot
    Layout.fillWidth: true
    Layout.preferredHeight: 32
    color: "#06182c"
    border.color: "#1e40af"
    border.width: 1
    radius: 3

    property var operationData: ({})
    property int opIndex: 0

    signal removeRequested(int opIndex)
    signal updated(int opIndex, string field, var val)

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 8
        spacing: 10

        // Device Icon & Name
        Text {
            text: opRowRoot.operationData.dev || "Device"
            color: "#38bdf8"
            font.bold: true
            font.pixelSize: 11
            Layout.preferredWidth: 120
            elide: Text.ElideRight
        }

        // Action Badge
        Rectangle {
            Layout.preferredWidth: 44
            Layout.preferredHeight: 20
            radius: 3
            color: opRowRoot.operationData.act === "ON" ? "#14532d" : (opRowRoot.operationData.act === "RAMP" ? "#7c2d12" : "#450a0a")
            border.color: opRowRoot.operationData.act === "ON" ? "#22c55e" : (opRowRoot.operationData.act === "RAMP" ? "#f97316" : "#ef4444")
            border.width: 1
            Text {
                anchors.centerIn: parent
                text: opRowRoot.operationData.act || "ON"
                color: "#ffffff"
                font.bold: true
                font.pixelSize: 10
            }
        }

        // Delay
        Text {
            text: "Delay: " + (opRowRoot.operationData.delay !== undefined ? opRowRoot.operationData.delay + "s" : "0s")
            color: "#94a3b8"
            font.pixelSize: 11
            Layout.preferredWidth: 70
        }

        // Duration
        Text {
            text: "Dur: " + (opRowRoot.operationData.dur !== undefined ? opRowRoot.operationData.dur + "s" : "0s")
            color: "#94a3b8"
            font.pixelSize: 11
            Layout.preferredWidth: 70
        }

        // Setpoint Value
        Text {
            text: "Setpoint: " + (opRowRoot.operationData.val || "—")
            color: "#4ade80"
            font.bold: true
            font.pixelSize: 11
            Layout.preferredWidth: 110
        }

        // Stop Condition
        Text {
            text: "Condition: " + (opRowRoot.operationData.cond || "Timer")
            color: "#fbbf24"
            font.pixelSize: 11
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        // Remove Button
        Rectangle {
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22
            radius: 3
            color: "#450a0a"
            border.color: "#ef4444"
            border.width: 1
            Text {
                anchors.centerIn: parent
                text: "✕"
                color: "#f87171"
                font.bold: true
                font.pixelSize: 10
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: opRowRoot.removeRequested(opRowRoot.opIndex)
            }
        }
    }
}

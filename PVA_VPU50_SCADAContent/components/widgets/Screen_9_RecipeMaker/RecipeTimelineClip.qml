pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: clipRoot
    implicitHeight: 46
    implicitWidth: 160
    radius: 4

    property string stageId: "1.1"
    property string phase: "Phase A"
    property string resourceType: "agitator"
    property string resourceName: "Anchor Agitator"
    property double setValue: 25.0
    property string unit: "RPM"
    property string purpose: "Material Loading"
    property var materials: []
    property bool requireConfirm: false
    property string confirmMessage: ""
    property int durationSec: 180
    property string stopCondition: "timer"
    property bool isSelected: false

    signal configureClicked
    signal deleteClicked

    // Color gradient based on resource type
    color: clipRoot.requireConfirm ? "#78350f" : (clipRoot.resourceType === "agitator" ? "#0369a1" : (clipRoot.resourceType === "homogenizer" ? "#7c3aed" : (clipRoot.resourceType === "vacuum" ? "#0f766e" : (clipRoot.resourceType === "heater" ? "#c2410c" : "#1e3a8a"))))
    border.color: clipRoot.isSelected ? "#ffffff" : (clipRoot.requireConfirm ? "#facc15" : "#38bdf8")
    border.width: clipRoot.isSelected ? 2 : 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 2

        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                text: "★ " + clipRoot.stageId
                color: "#ffffff"
                font.bold: true
                font.pixelSize: 9
            }

            Text {
                Layout.fillWidth: true
                text: clipRoot.resourceName
                color: "#ffffff"
                font.bold: true
                font.pixelSize: 10
                elide: Text.ElideRight
            }

            // Manual Sign-off Indicator Badge
            Rectangle {
                visible: clipRoot.requireConfirm
                Layout.preferredHeight: 14
                Layout.preferredWidth: 36
                radius: 2
                color: "#dc2626"
                Text {
                    anchors.centerIn: parent
                    text: "HOLD"
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 8
                }
            }

            // Remove clip button
            Rectangle {
                Layout.preferredWidth: 14
                Layout.preferredHeight: 14
                radius: 2
                color: delMouse.containsMouse ? "#ef4444" : "#00000000"

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    color: "#cbd5e1"
                    font.pixelSize: 9
                }

                MouseArea {
                    id: delMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: clipRoot.deleteClicked()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            // Setpoint value display
            Text {
                text: "SP: " + clipRoot.setValue + " " + clipRoot.unit
                color: "#facc15"
                font.bold: true
                font.pixelSize: 9
            }

            Item { Layout.fillWidth: true }

            // Duration or Hold
            Text {
                text: clipRoot.requireConfirm ? "Manual Gate" : (Math.round(clipRoot.durationSec / 60) + " min (" + clipRoot.durationSec + "s)")
                color: "#e2e8f0"
                font.pixelSize: 9
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onDoubleClicked: clipRoot.configureClicked()
    }
}

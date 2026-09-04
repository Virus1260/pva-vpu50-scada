/*
This is a UI file (.ui.qml) for the Recipe Top Header & Control Toolbar.
Strictly declarative for Qt Design Studio.
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: toolbarRoot
    width: 1160
    height: 52
    implicitWidth: 1160
    implicitHeight: 52
    Layout.fillWidth: true
    Layout.preferredHeight: 52
    radius: 5
    color: "#0d2b4a"
    border.color: "#184d7e"
    border.width: 1.2

    property string activeTab: "execution" // "execution" or "formulation"
    property bool isExecuting: false
    property string activeRecipeName: "UNIMIX_BATCH_01"

    property alias execTabBtn: executionTabButton
    property alias formTabBtn: formulationTabButton
    property alias toggleAutoBtn: startPauseButton

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 12

        // Tab 1: Execution Engine
        Rectangle {
            id: executionTabButton
            Layout.preferredWidth: 150
            Layout.preferredHeight: 36
            radius: 4
            color: toolbarRoot.activeTab === "execution" ? "#0284c7" : "#0a223a"
            border.color: toolbarRoot.activeTab === "execution" ? "#38bdf8" : "#184d7e"

            Row {
                anchors.centerIn: parent
                spacing: 6
                Image {
                    source: "../../../assets/icons/nav/status_stack.svg"
                    width: 14
                    height: 14
                    sourceSize: Qt.size(14, 14)
                    fillMode: Image.PreserveAspectFit
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text { text: "Batch Execution"; color: "#ffffff"; font.bold: true; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
            }
        }

        // Tab 2: Formulation Studio / Creator
        Rectangle {
            id: formulationTabButton
            Layout.preferredWidth: 150
            Layout.preferredHeight: 36
            radius: 4
            color: toolbarRoot.activeTab === "formulation" ? "#0284c7" : "#0a223a"
            border.color: toolbarRoot.activeTab === "formulation" ? "#38bdf8" : "#184d7e"

            Row {
                anchors.centerIn: parent
                spacing: 6
                Image {
                    source: "../../../assets/icons/nav/recipes_checklist.svg"
                    width: 14
                    height: 14
                    sourceSize: Qt.size(14, 14)
                    fillMode: Image.PreserveAspectFit
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text { text: "Formulation Studio"; color: "#ffffff"; font.bold: true; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
            }
        }

        Item { Layout.fillWidth: true }

        // Start / Pause Batch Execution Button
        Rectangle {
            id: startPauseButton
            Layout.preferredWidth: 160
            Layout.preferredHeight: 36
            radius: 4
            color: toolbarRoot.isExecuting ? "#7f1d1d" : "#065f46"
            border.color: toolbarRoot.isExecuting ? "#ef4444" : "#10b981"
            border.width: 1.2

            Row {
                anchors.centerIn: parent
                spacing: 8
                Rectangle {
                    width: 10
                    height: 10
                    radius: 5
                    color: toolbarRoot.isExecuting ? "#ef4444" : "#22c55e"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: toolbarRoot.isExecuting ? "PAUSE SEQUENCE" : "START AUTO BATCH"
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 11
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}

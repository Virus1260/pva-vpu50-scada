import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../widgets/ScadaKeyboard"

Rectangle {
    id: ackModalRoot
    anchors.fill: parent
    visible: false
    color: "#d0000000"
    z: 100

    property alias alarmTagText: alarmTagLabel.text
    property alias alarmTitleText: alarmTitleLabel.text
    property alias reasonInput: reasonTextInput.text
    property alias confirmBtn: confirmAckBtn
    property alias cancelBtn: cancelAckBtn

    signal ackConfirmed(string reason)
    signal ackCancelled()

    Rectangle {
        anchors.centerIn: parent
        width: 520
        height: 380
        radius: 8
        color: "#081d33"
        border.color: "#ef4444"
        border.width: 2.0

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Image {
                    source: "../../../assets/icons/common/icon_warning.svg"
                    width: 20
                    height: 20
                    sourceSize: Qt.size(20, 20)
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    fillMode: Image.PreserveAspectFit
                }
                Text { text: "21 CFR PART 11 ALARM ACKNOWLEDGEMENT"; color: "#ef4444"; font.bold: true; font.pixelSize: 13; Layout.fillWidth: true }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#1e3a8a" }

            // Alarm Meta Info Box
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 65
                radius: 4
                color: "#051527"
                border.color: "#0d2b4a"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4
                    RowLayout {
                        Text { text: "ALARM TAG:"; color: "#94a3b8"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 90 }
                        Text { id: alarmTagLabel; text: "PIC161001"; color: "#38bdf8"; font.bold: true; font.pixelSize: 11 }
                    }
                    RowLayout {
                        Text { text: "DESCRIPTION:"; color: "#94a3b8"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 90 }
                        Text { id: alarmTitleLabel; text: "Vacuum Seal Differential Pressure Loss"; color: "#ffffff"; font.pixelSize: 11; elide: Text.ElideRight; Layout.fillWidth: true }
                    }
                }
            }

            Text {
                text: "Mandatory Operator Action / Reason for Acknowledgement:"
                color: "#cbd5e1"
                font.bold: true
                font.pixelSize: 11
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#06182c"
                border.color: "#0284c7"
                radius: 4

                TextInput {
                    id: reasonTextInput
                    anchors.fill: parent
                    anchors.margins: 8
                    color: "#ffffff"
                    font.pixelSize: 12
                    text: "Inspected vacuum seals, verified normal skid state, and engaged backup line."
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.IBeamCursor
                    onClicked: {
                        reasonTextInput.forceActiveFocus();
                        textKeyboard.openFor(reasonTextInput, "ACTION / REASON FOR ACKNOWLEDGEMENT");
                    }
                }
            }

            Text {
                text: "Electronic Signature: Action is logged with user credentials, role, timestamp, and HMAC SHA-256 seal."
                color: "#94a3b8"
                font.pixelSize: 10
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            // Action Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    id: cancelAckBtn
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    radius: 4
                    color: "#1e293b"
                    border.color: "#64748b"
                    Text { anchors.centerIn: parent; text: "Cancel"; color: "#cbd5e1"; font.bold: true; font.pixelSize: 12 }
                }

                Rectangle {
                    id: confirmAckBtn
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    radius: 4
                    color: "#059669"
                    border.color: "#34d399"
                    Text { anchors.centerIn: parent; text: "Confirm & Log to Audit"; color: "#ffffff"; font.bold: true; font.pixelSize: 12 }
                }
            }
        }
    }

    ScadaTextKeyboard {
        id: textKeyboard
        anchors.fill: parent
        z: 9999
        visible: false
    }
}

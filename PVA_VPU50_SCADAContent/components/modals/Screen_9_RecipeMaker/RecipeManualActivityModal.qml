pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../../widgets"

Rectangle {
    id: manualModalRoot
    implicitWidth: 1024
    implicitHeight: 600
    color: "#bb000000"
    visible: false
    z: 100

    property string stageId: "2.1"
    property string phaseName: "Phase B"
    property string actionTarget: "Butterfly Valve abc123"
    property string actionRequired: "OPEN" // "OPEN", "CLOSE", "VERIFY"
    property string displayMessage: "Operator to confirm that valve abc123 is OPEN for material loading."
    property bool holdMandatory: true

    signal accepted(var manualConfig)
    signal cancelled

    MouseArea {
        anchors.fill: parent
    }

    function updateAutoMessage() {
        if (actionRequired === "OPEN") {
            displayMessage = "Operator to confirm that " + actionTarget + " is OPEN for material loading / phase transfer.";
        } else if (actionRequired === "CLOSE") {
            displayMessage = "Operator to confirm that " + actionTarget + " is CLOSED and secured before vacuum pull.";
        } else {
            displayMessage = "Operator visual inspection: Verify " + actionTarget + " clarity and homogeneity.";
        }
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: 580
        height: 480
        color: "#0b2e52"
        border.color: "#f59e0b"
        border.width: 2
        radius: 8

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Top Header Bar
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: 4
                    color: "#78350f"
                    border.color: "#f59e0b"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "✋"
                        font.pixelSize: 16
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: "MANUAL ACTIVITY / OPERATOR INTERVENTION BLOCK"
                        color: "#fbbf24"
                        font.bold: true
                        font.pixelSize: 13
                    }
                    Text {
                        text: "21 CFR Part 11 Physical Verification & Sequence Interlock Gate"
                        color: "#94a3b8"
                        font.pixelSize: 10
                    }
                }

                // Read-Only Stage Badge
                Rectangle {
                    Layout.preferredHeight: 26
                    Layout.preferredWidth: stageTxt.implicitWidth + 12
                    radius: 4
                    color: "#081d33"
                    border.color: "#f59e0b"
                    border.width: 1

                    Text {
                        id: stageTxt
                        anchors.centerIn: parent
                        text: "Stage " + manualModalRoot.stageId
                        color: "#fbbf24"
                        font.bold: true
                        font.pixelSize: 11
                    }
                }

                // Read-Only Phase Badge
                Rectangle {
                    Layout.preferredHeight: 26
                    Layout.preferredWidth: phaseTxt.implicitWidth + 12
                    radius: 4
                    color: "#164e85"
                    border.color: "#60a5fa"
                    border.width: 1

                    Text {
                        id: phaseTxt
                        anchors.centerIn: parent
                        text: manualModalRoot.phaseName
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 11
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 26
                    Layout.preferredHeight: 26
                    radius: 4
                    color: closeMouse.containsMouse ? "#ef4444" : "#0d365e"
                    border.color: "#1d5b94"
                    border.width: 1

                    ScadaIcon {
                        anchors.centerIn: parent
                        Layout.preferredWidth: 12
                        Layout.preferredHeight: 12
                        iconName: "close_x"
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: manualModalRoot.cancelled()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#1d5b94"
            }

            // Form Inputs Grid
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 12
                rowSpacing: 10

                // Field 1: Action Target (Dropdown List of Physical Manual Assets)
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                    spacing: 4
                    Text {
                        text: "ACTION TARGET (PHYSICAL MACHINE ASSET) *"
                        color: "#fbbf24"
                        font.pixelSize: 11
                        font.bold: true
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Repeater {
                            model: [
                                "Butterfly Valve abc123",
                                "Charging Hatch Clamp",
                                "Sight Glass Window",
                                "Sampling Valve V204",
                                "Powder Funnel V301"
                            ]
                            delegate: Rectangle {
                                id: targetBtn
                                required property string modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: 34
                                radius: 4
                                color: manualModalRoot.actionTarget === targetBtn.modelData ? "#78350f" : "#081d33"
                                border.color: manualModalRoot.actionTarget === targetBtn.modelData ? "#fbbf24" : "#1d5b94"
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: targetBtn.modelData
                                    color: manualModalRoot.actionTarget === targetBtn.modelData ? "#ffffff" : "#94a3b8"
                                    font.pixelSize: 9
                                    font.bold: manualModalRoot.actionTarget === targetBtn.modelData
                                    elide: Text.ElideRight
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        manualModalRoot.actionTarget = targetBtn.modelData;
                                        manualModalRoot.updateAutoMessage();
                                    }
                                }
                            }
                        }
                    }
                }

                // Field 2: Action Required (Mutually Exclusive [ ] OPEN or [ ] CLOSE or [ ] VERIFY)
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                    spacing: 4
                    Text {
                        text: "ACTION REQUIRED (MUTUALLY EXCLUSIVE) *"
                        color: "#cbd5e1"
                        font.pixelSize: 11
                        font.bold: true
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        // [ ] OPEN
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            radius: 4
                            color: manualModalRoot.actionRequired === "OPEN" ? "#065f46" : "#081d33"
                            border.color: manualModalRoot.actionRequired === "OPEN" ? "#34d399" : "#1d5b94"
                            border.width: 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Text {
                                    text: manualModalRoot.actionRequired === "OPEN" ? "☑" : "☐"
                                    color: "#34d399"
                                    font.bold: true
                                    font.pixelSize: 14
                                }
                                Text {
                                    text: "OPEN VALVE / HATCH"
                                    color: "#ffffff"
                                    font.bold: true
                                    font.pixelSize: 11
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    manualModalRoot.actionRequired = "OPEN";
                                    manualModalRoot.updateAutoMessage();
                                }
                            }
                        }

                        // [ ] CLOSE
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            radius: 4
                            color: manualModalRoot.actionRequired === "CLOSE" ? "#831843" : "#081d33"
                            border.color: manualModalRoot.actionRequired === "CLOSE" ? "#f472b6" : "#1d5b94"
                            border.width: 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Text {
                                    text: manualModalRoot.actionRequired === "CLOSE" ? "☑" : "☐"
                                    color: "#f472b6"
                                    font.bold: true
                                    font.pixelSize: 14
                                }
                                Text {
                                    text: "CLOSE & SEAL VALVE"
                                    color: "#ffffff"
                                    font.bold: true
                                    font.pixelSize: 11
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    manualModalRoot.actionRequired = "CLOSE";
                                    manualModalRoot.updateAutoMessage();
                                }
                            }
                        }

                        // [ ] VERIFY
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            radius: 4
                            color: manualModalRoot.actionRequired === "VERIFY" ? "#0369a1" : "#081d33"
                            border.color: manualModalRoot.actionRequired === "VERIFY" ? "#38bdf8" : "#1d5b94"
                            border.width: 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Text {
                                    text: manualModalRoot.actionRequired === "VERIFY" ? "☑" : "☐"
                                    color: "#38bdf8"
                                    font.bold: true
                                    font.pixelSize: 14
                                }
                                Text {
                                    text: "VISUAL VERIFY"
                                    color: "#ffffff"
                                    font.bold: true
                                    font.pixelSize: 11
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    manualModalRoot.actionRequired = "VERIFY";
                                    manualModalRoot.updateAutoMessage();
                                }
                            }
                        }
                    }
                }

                // Field 3: Display Message (Auto-Generated but Editable Text)
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                    spacing: 4
                    Text {
                        text: "HMI DISPLAY MESSAGE (PROMPT DISPLAYED TO LIVE OPERATOR) *"
                        color: "#fbbf24"
                        font.pixelSize: 11
                        font.bold: true
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 52
                        color: "#081d33"
                        border.color: msgInput.activeFocus ? "#fbbf24" : "#1d5b94"
                        border.width: 1
                        radius: 4

                        TextInput {
                            id: msgInput
                            anchors.fill: parent
                            anchors.margins: 8
                            text: manualModalRoot.displayMessage
                            color: "#ffffff"
                            font.pixelSize: 12
                            font.bold: true
                            selectByMouse: true
                            onTextChanged: manualModalRoot.displayMessage = text
                        }
                    }
                }
            }

            // Explanatory Simulation Note
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                radius: 4
                color: "#1e1b4b"
                border.color: "#818cf8"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 8
                    Text {
                        text: "ℹ SIMULATION BEHAVIOR: Timeline playhead will pause here on the P&ID preview player until the operator clicks 'Confirm'."
                        color: "#c7d2fe"
                        font.pixelSize: 10
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // Bottom Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Item { Layout.fillWidth: true }

                Rectangle {
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 36
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
                        onClicked: manualModalRoot.cancelled()
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 170
                    Layout.preferredHeight: 36
                    radius: 4
                    color: "#d97706"
                    border.color: "#fcd34d"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "Save Manual Interlock"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 12
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var config = {
                                stageId: manualModalRoot.stageId,
                                phase: manualModalRoot.phaseName,
                                resourceType: "manualActivity",
                                resourceName: "Manual: " + manualModalRoot.actionTarget,
                                actionTarget: manualModalRoot.actionTarget,
                                actionRequired: manualModalRoot.actionRequired,
                                confirmMessage: manualModalRoot.displayMessage,
                                requireConfirm: true,
                                durationSec: 0,
                                stopCondition: "manual"
                            };
                            manualModalRoot.accepted(config);
                        }
                    }
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Layouts

Item {
    id: manualActionModalRoot
    anchors.fill: parent
    visible: false
    z: 110

    property string stepNumberStr: "STEP 03"
    property string stepTitle: "CHARGING PHASE B (WAX PHASE) VIA VACUUM SUCTION"
    property string instructions: "1. Open Manual Ball Valve [MV-101] below Wax Prep Vessel.\n2. Modulate Vacuum Valve using buttons below to suck 11.5 kg wax.\n3. Once empty, close valve [MV-101] and tap 'Confirm Complete'."
    property string linkedPhase: "Phase B (Wax Phase)"
    property real currentVacuum: -0.62
    property real currentTemp: 82.4
    property real targetVacuum: -0.60
    property string operatorId: "OP-104"
    property string operatorPin: ""
    property bool requirePin: true
    property int pulseCount: 0
    property string statusMsg: ""

    signal actionCompleted(string opId, string stepNum, real finalVac, real finalTemp)
    signal actionCancelled

    // Dark backdrop overlay
    Rectangle {
        anchors.fill: parent
        color: "#cc040d1a"

        MouseArea {
            anchors.fill: parent
            // Block clicks to underlying controls
        }
    }

    // Modal Card Container
    Rectangle {
        width: Math.min(parent.width - 40, 660)
        height: Math.min(parent.height - 40, 540)
        anchors.centerIn: parent
        color: "#0b2545"
        border.color: "#f59e0b"
        border.width: 2
        radius: 8
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            // Header Banner
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                color: "#78350f"
                border.color: "#f59e0b"
                border.width: 1
                radius: 6

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    Text {
                        text: "⚠"
                        color: "#fef08a"
                        font.pixelSize: 22
                        font.bold: true
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "MANUAL INTERVENTION REQUIRED: " + manualActionModalRoot.stepNumberStr
                            color: "#fef08a"
                            font.bold: true
                            font.pixelSize: 13
                            font.family: "Segoe UI"
                        }

                        Text {
                            text: manualActionModalRoot.stepTitle
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 11
                            font.family: "Segoe UI"
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        radius: 15
                        color: "#451a03"
                        border.color: "#f59e0b"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: "#ffffff"
                            font.pixelSize: 13
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                manualActionModalRoot.visible = false;
                                manualActionModalRoot.actionCancelled();
                            }
                        }
                    }
                }
            }

            // Operator Instruction Box
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 90
                color: "#071b33"
                border.color: "#1e3a8a"
                border.width: 1
                radius: 6

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4

                    Text {
                        text: "SOP Standard Operating Guidance:"
                        color: "#38bdf8"
                        font.bold: true
                        font.pixelSize: 11
                        font.family: "Segoe UI"
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: manualActionModalRoot.instructions
                        color: "#e2e8f0"
                        font.pixelSize: 11
                        font.family: "Segoe UI"
                        wrapMode: Text.Wrap
                        lineHeight: 1.2
                    }
                }
            }

            // Live Telemetry Readout
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                color: "#081d33"
                border.color: "#334155"
                border.width: 1
                radius: 6

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 20

                    // Vacuum Gauge Box
                    RowLayout {
                        spacing: 8
                        Text {
                            text: "Vessel Vacuum:"
                            color: "#94a3b8"
                            font.pixelSize: 12
                            font.family: "Segoe UI"
                        }
                        Text {
                            text: manualActionModalRoot.currentVacuum.toFixed(2) + " bar"
                            color: manualActionModalRoot.currentVacuum <= -0.55 ? "#4ade80" : "#facc15"
                            font.bold: true
                            font.pixelSize: 16
                            font.family: "Consolas"
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.fillHeight: true
                        Layout.topMargin: 10
                        Layout.bottomMargin: 10
                        color: "#1e3a8a"
                    }

                    // Temperature Gauge Box
                    RowLayout {
                        spacing: 8
                        Text {
                            text: "Vessel Temp:"
                            color: "#94a3b8"
                            font.pixelSize: 12
                            font.family: "Segoe UI"
                        }
                        Text {
                            text: manualActionModalRoot.currentTemp.toFixed(1) + " °C"
                            color: "#38bdf8"
                            font.bold: true
                            font.pixelSize: 16
                            font.family: "Consolas"
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Interlock Status Pill
                    Rectangle {
                        Layout.preferredHeight: 26
                        Layout.preferredWidth: 150
                        radius: 4
                        color: "#064e3b"
                        border.color: "#10b981"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "✓ Interlocks Clear"
                            color: "#a7f3d0"
                            font.bold: true
                            font.pixelSize: 10
                            font.family: "Segoe UI"
                        }
                    }
                }
            }

            // Manual Touch Controls (Vacuum Pulse & Vent)
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                spacing: 14

                // SUCK VACUUM PULSE
                Rectangle {
                    id: pulseBtn
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 6
                    color: pulseMouse.pressed ? "#0284c7" : (pulseMouse.containsMouse ? "#0369a1" : "#0c4a6e")
                    border.color: "#38bdf8"
                    border.width: 1

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "SUCK VACUUM PULSE"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 13
                            font.family: "Segoe UI"
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "(Hold to pulse valve V-VAC-01)"
                            color: "#bae6fd"
                            font.pixelSize: 10
                            font.family: "Segoe UI"
                        }
                    }

                    MouseArea {
                        id: pulseMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPressed: {
                            manualActionModalRoot.pulseCount += 1;
                            if (manualActionModalRoot.currentVacuum > -0.75) {
                                manualActionModalRoot.currentVacuum -= 0.04;
                            }
                            manualActionModalRoot.statusMsg = "Vacuum pulse triggered (#" + manualActionModalRoot.pulseCount + ")";
                        }
                    }
                }

                // VENT / RELEASE
                Rectangle {
                    id: ventBtn
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 6
                    color: ventMouse.pressed ? "#475569" : (ventMouse.containsMouse ? "#334155" : "#1e293b")
                    border.color: "#64748b"
                    border.width: 1

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "VENT / RELEASE"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 13
                            font.family: "Segoe UI"
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "(Tap to vent 0.05 bar)"
                            color: "#cbd5e1"
                            font.pixelSize: 10
                            font.family: "Segoe UI"
                        }
                    }

                    MouseArea {
                        id: ventMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (manualActionModalRoot.currentVacuum < -0.10) {
                                manualActionModalRoot.currentVacuum += 0.05;
                            }
                            manualActionModalRoot.statusMsg = "Vacuum vented by 0.05 bar";
                        }
                    }
                }
            }

            // 21 CFR Part 11 Electronic Signature Box
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 88
                color: "#081d33"
                border.color: "#1e3a8a"
                border.width: 1
                radius: 6

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 6

                    Text {
                        text: "FDA 21 CFR Part 11 Electronic Signature Verification:"
                        color: "#94a3b8"
                        font.bold: true
                        font.pixelSize: 11
                        font.family: "Segoe UI"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        // Operator ID
                        ColumnLayout {
                            spacing: 2
                            Text { text: "Operator ID:"; color: "#64748b"; font.pixelSize: 10 }
                            Rectangle {
                                Layout.preferredWidth: 140
                                Layout.preferredHeight: 32
                                color: "#061325"
                                border.color: "#1d5b94"
                                border.width: 1
                                radius: 4

                                TextInput {
                                    id: opIdInput
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    text: manualActionModalRoot.operatorId
                                    color: "#ffffff"
                                    font.bold: true
                                    font.pixelSize: 12
                                    font.family: "Consolas"
                                    onTextChanged: manualActionModalRoot.operatorId = text
                                }
                            }
                        }

                        // PIN Input
                        ColumnLayout {
                            spacing: 2
                            Text { text: "Security PIN:"; color: "#64748b"; font.pixelSize: 10 }
                            Rectangle {
                                Layout.preferredWidth: 120
                                Layout.preferredHeight: 32
                                color: "#061325"
                                border.color: "#1d5b94"
                                border.width: 1
                                radius: 4

                                TextInput {
                                    id: pinInput
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    text: manualActionModalRoot.operatorPin
                                    color: "#ffffff"
                                    echoMode: TextInput.Password
                                    font.bold: true
                                    font.pixelSize: 14
                                    font.family: "Consolas"
                                    onTextChanged: manualActionModalRoot.operatorPin = text
                                }
                            }
                        }

                        // Status Note / Feedback
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text { text: "Audit Note:"; color: "#64748b"; font.pixelSize: 10 }
                            Text {
                                text: manualActionModalRoot.statusMsg || "Ready for verification"
                                color: "#38bdf8"
                                font.pixelSize: 11
                                font.family: "Segoe UI"
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }

            // Bottom Action Bar: Confirm & Close
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                spacing: 12

                // Cancel Button
                Rectangle {
                    Layout.preferredWidth: 120
                    Layout.fillHeight: true
                    radius: 4
                    color: "#1e293b"
                    border.color: "#475569"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: "#94a3b8"
                        font.bold: true
                        font.pixelSize: 12
                        font.family: "Segoe UI"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            manualActionModalRoot.visible = false;
                            manualActionModalRoot.actionCancelled();
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // CONFIRM STEP COMPLETED Button
                Rectangle {
                    id: confirmBtn
                    Layout.preferredWidth: 260
                    Layout.fillHeight: true
                    radius: 4
                    color: confirmMouse.containsMouse ? "#059669" : "#10b981"
                    border.color: "#34d399"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: "✓"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 16
                        }

                        Text {
                            text: "CONFIRM STEP COMPLETED"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 12
                            font.family: "Segoe UI"
                        }
                    }

                    MouseArea {
                        id: confirmMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (manualActionModalRoot.requirePin && manualActionModalRoot.operatorPin.length < 2) {
                                manualActionModalRoot.statusMsg = "PIN required for 21 CFR Part 11 signoff!";
                                return;
                            }
                            manualActionModalRoot.actionCompleted(
                                manualActionModalRoot.operatorId,
                                manualActionModalRoot.stepNumberStr,
                                manualActionModalRoot.currentVacuum,
                                manualActionModalRoot.currentTemp
                            );
                            manualActionModalRoot.visible = false;
                        }
                    }
                }
            }
        }
    }
}

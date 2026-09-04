/*
This is a UI file (.ui.qml) for the ISA-88 Automated Batch Recipe Execution Engine.
Strictly declarative for Qt Design Studio.
Compliant with GAMP 5 and FDA 21 CFR Part 11.
Supports live concurrent sub-operation progress bars, equipment status, and BOM phase tracking.
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: executorRoot
    width: 1160
    height: 550
    implicitWidth: 1160
    implicitHeight: 550
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#06182c"
    border.color: "#184d7e"
    border.width: 1.2
    radius: 6
    clip: true

    property int currentStepIndex: 0
    property int stepTimeRemaining: 180
    property int batchTimerSec: 0
    property bool isExecuting: false
    property string activeRecipeName: "Industrial Shampoo Formulation"
    property string activeProductName: "Botanical Conditioning Shampoo (100 kg)"
    property string activeBatchId: "B1"

    property real currentTemp: 34.4
    property real targetTemp: 45.0
    property real currentVac: -450.0
    property real targetVac: -450.0
    property real currentAgitatorRpm: 25.0
    property real targetAgitatorRpm: 25.0
    property real currentHomoRpm: 0.0
    property real targetHomoRpm: 3600.0

    // Equipment Active States
    property bool agitatorActive: isExecuting
    property bool homogActive: isExecuting && currentStepIndex === 2
    property bool vacuumActive: isExecuting && (currentStepIndex === 1 || currentStepIndex === 2)
    property bool heaterActive: isExecuting && (currentStepIndex === 0 || currentStepIndex === 2)
    property bool coolerActive: isExecuting && currentStepIndex === 3
    property bool fillActive: isExecuting && currentStepIndex === 0
    property bool drainActive: false

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // =====================================================================
        // 1. ACTIVE PHASE HERO BANNER & REAL-TIME COUNTDOWN
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 84
            radius: 6
            color: "#0d2b4a"
            border.color: executorRoot.isExecuting ? "#00d2ff" : "#1e40af"
            border.width: 1.5

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 14

                // Step Number Circle Badge
                Rectangle {
                    width: 52
                    height: 52
                    radius: 26
                    color: executorRoot.isExecuting ? "#0284c7" : "#1e293b"
                    border.color: executorRoot.isExecuting ? "#38bdf8" : "#64748b"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: (executorRoot.currentStepIndex + 1) + ""
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 20
                    }
                }

                // Phase Identity & ISA-88 Context
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    RowLayout {
                        spacing: 8
                        Rectangle {
                            width: 95
                            height: 18
                            radius: 9
                            color: executorRoot.isExecuting ? "#064e3b" : "#334155"
                            Text {
                                anchors.centerIn: parent
                                text: executorRoot.isExecuting ? "PHASE RUNNING" : "PHASE STANDBY"
                                color: executorRoot.isExecuting ? "#6ee7b7" : "#cbd5e1"
                                font.bold: true
                                font.pixelSize: 9
                            }
                        }

                        Text {
                            text: "ISA-88 BATCH SEQUENCE – PHASE " + (executorRoot.currentStepIndex + 1) + " OF 5"
                            color: "#38bdf8"
                            font.bold: true
                            font.pixelSize: 10
                        }
                    }

                    Text {
                        text: executorRoot.currentStepIndex === 0 ? "Phase A: Initial Water Charge & Pre-Heat (45.0°C)" :
                              (executorRoot.currentStepIndex === 1 ? "Phase B: SLES 28% & CAPB Surfactant Induction" :
                              (executorRoot.currentStepIndex === 2 ? "Phase C: High-Shear Emulsification & Homogenizer Ramping" :
                              (executorRoot.currentStepIndex === 3 ? "Phase D: Controlled Cooling (45.0°C) & Active Dosing" : "Phase E: Viscosity Adjustment (Salt Trim) & Deaeration")))
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 14
                    }

                    Text {
                        text: "Recipe: " + executorRoot.activeRecipeName + " | Product: " + executorRoot.activeProductName + " | Batch: " + executorRoot.activeBatchId
                        color: "#94a3b8"
                        font.pixelSize: 10
                    }
                }

                // Live Step Countdown Timer Box
                Rectangle {
                    Layout.preferredWidth: 130
                    Layout.preferredHeight: 60
                    radius: 5
                    color: "#071b30"
                    border.color: "#00d2ff"
                    border.width: 1.2

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 1
                        Text { text: "STEP REMAINING"; color: "#00d2ff"; font.bold: true; font.pixelSize: 9; horizontalAlignment: Text.AlignHCenter }
                        Text {
                            text: (Math.floor(executorRoot.stepTimeRemaining / 60)) + ":" + (executorRoot.stepTimeRemaining % 60 < 10 ? "0" : "") + (executorRoot.stepTimeRemaining % 60)
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 20
                            font.family: "Monospace"
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                // Live Batch Elapsed Timer Box
                Rectangle {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 60
                    radius: 5
                    color: "#071b30"
                    border.color: "#f59e0b"
                    border.width: 1.2

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 1
                        Text { text: "BATCH ELAPSED"; color: "#f59e0b"; font.bold: true; font.pixelSize: 9; horizontalAlignment: Text.AlignHCenter }
                        Text {
                            text: (Math.floor(executorRoot.batchTimerSec / 60)) + ":" + (executorRoot.batchTimerSec % 60 < 10 ? "0" : "") + (executorRoot.batchTimerSec % 60)
                            color: "#fde68a"
                            font.bold: true
                            font.pixelSize: 20
                            font.family: "Monospace"
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }

        // =====================================================================
        // 2. ACTIVE SUB-OPERATIONS PARALLEL RUNNERS BREAKDOWN
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 90
            radius: 5
            color: "#071c33"
            border.color: "#184d7e"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "ACTIVE CONCURRENT SUB-OPERATIONS (ISA-88)"; color: "#38bdf8"; font.bold: true; font.pixelSize: 10 }
                    Item { Layout.fillWidth: true }
                    Text { text: "Simultaneous Multi-Device Coordinated Execution"; color: "#94a3b8"; font.pixelSize: 9 }
                }

                // Op 1: Agitator Anchor Stirring
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle { width: 8; height: 8; radius: 4; color: "#22c55e" }
                    Text { text: "Agitator Drive"; color: "#ffffff"; font.bold: true; font.pixelSize: 10; Layout.preferredWidth: 100 }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 8
                        radius: 4
                        color: "#0a243f"
                        border.color: "#1e40af"
                        Rectangle {
                            width: parent.width * (executorRoot.isExecuting ? 0.72 : 0.0)
                            height: parent.height
                            radius: 4
                            color: "#22c55e"
                        }
                    }

                    Text { text: "25.0 RPM | 72%"; color: "#86efac"; font.bold: true; font.pixelSize: 10; font.family: "Monospace"; Layout.preferredWidth: 90; horizontalAlignment: Text.AlignRight }
                }

                // Op 2: Thermal Jacket Control
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle { width: 8; height: 8; radius: 4; color: "#f97316" }
                    Text { text: "Thermal Jacket"; color: "#ffffff"; font.bold: true; font.pixelSize: 10; Layout.preferredWidth: 100 }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 8
                        radius: 4
                        color: "#0a243f"
                        border.color: "#1e40af"
                        Rectangle {
                            width: parent.width * (executorRoot.isExecuting ? 0.58 : 0.0)
                            height: parent.height
                            radius: 4
                            color: "#f97316"
                        }
                    }

                    Text { text: "SP: 45.0°C | 58%"; color: "#fdba74"; font.bold: true; font.pixelSize: 10; font.family: "Monospace"; Layout.preferredWidth: 90; horizontalAlignment: Text.AlignRight }
                }

                // Op 3: Vacuum / Homogenizer
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle { width: 8; height: 8; radius: 4; color: "#8b5cf6" }
                    Text { text: "Vacuum Pump"; color: "#ffffff"; font.bold: true; font.pixelSize: 10; Layout.preferredWidth: 100 }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 8
                        radius: 4
                        color: "#0a243f"
                        border.color: "#1e40af"
                        Rectangle {
                            width: parent.width * (executorRoot.isExecuting ? 0.45 : 0.0)
                            height: parent.height
                            radius: 4
                            color: "#8b5cf6"
                        }
                    }

                    Text { text: "-450 mbar | 45%"; color: "#c4b5fd"; font.bold: true; font.pixelSize: 10; font.family: "Monospace"; Layout.preferredWidth: 90; horizontalAlignment: Text.AlignRight }
                }
            }
        }

        // =====================================================================
        // 3. FOUR PROCESS TELEMETRY CARDS (Actuals vs Setpoints)
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            spacing: 8

            // CARD A: PRODUCT TEMPERATURE
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 5
                color: "#0a243f"
                border.color: "#184d7e"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 2

                    Text { text: "PRODUCT TEMP (1B1001)"; color: "#f87171"; font.bold: true; font.pixelSize: 9 }
                    RowLayout {
                        Layout.fillWidth: true
                        ColumnLayout {
                            Text { text: "Actual"; color: "#94a3b8"; font.pixelSize: 9 }
                            Text { text: executorRoot.currentTemp.toFixed(1) + " °C"; color: "#f87171"; font.bold: true; font.pixelSize: 14 }
                        }
                        Item { Layout.fillWidth: true }
                        ColumnLayout {
                            Text { text: "Target SP"; color: "#94a3b8"; font.pixelSize: 9; horizontalAlignment: Text.AlignRight }
                            Text { text: executorRoot.targetTemp.toFixed(1) + " °C"; color: "#ffffff"; font.bold: true; font.pixelSize: 14; horizontalAlignment: Text.AlignRight }
                        }
                    }
                }
            }

            // CARD B: AGITATOR SPEED
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 5
                color: "#0a243f"
                border.color: "#184d7e"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 2

                    Text { text: "AGITATOR SPEED (1M1001)"; color: "#4ade80"; font.bold: true; font.pixelSize: 9 }
                    RowLayout {
                        Layout.fillWidth: true
                        ColumnLayout {
                            Text { text: "Actual"; color: "#94a3b8"; font.pixelSize: 9 }
                            Text { text: executorRoot.currentAgitatorRpm.toFixed(0) + " rpm"; color: "#4ade80"; font.bold: true; font.pixelSize: 14 }
                        }
                        Item { Layout.fillWidth: true }
                        ColumnLayout {
                            Text { text: "Target SP"; color: "#94a3b8"; font.pixelSize: 9; horizontalAlignment: Text.AlignRight }
                            Text { text: executorRoot.targetAgitatorRpm.toFixed(0) + " rpm"; color: "#ffffff"; font.bold: true; font.pixelSize: 14; horizontalAlignment: Text.AlignRight }
                        }
                    }
                }
            }

            // CARD C: HOMOGENIZER SPEED
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 5
                color: "#0a243f"
                border.color: "#184d7e"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 2

                    Text { text: "HOMOGENIZER (1M1002)"; color: "#38bdf8"; font.bold: true; font.pixelSize: 9 }
                    RowLayout {
                        Layout.fillWidth: true
                        ColumnLayout {
                            Text { text: "Actual"; color: "#94a3b8"; font.pixelSize: 9 }
                            Text { text: executorRoot.currentHomoRpm.toFixed(0) + " rpm"; color: "#38bdf8"; font.bold: true; font.pixelSize: 14 }
                        }
                        Item { Layout.fillWidth: true }
                        ColumnLayout {
                            Text { text: "Target SP"; color: "#94a3b8"; font.pixelSize: 9; horizontalAlignment: Text.AlignRight }
                            Text { text: executorRoot.targetHomoRpm.toFixed(0) + " rpm"; color: "#ffffff"; font.bold: true; font.pixelSize: 14; horizontalAlignment: Text.AlignRight }
                        }
                    }
                }
            }

            // CARD D: CHAMBER VACUUM
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 5
                color: "#0a243f"
                border.color: "#184d7e"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 2

                    Text { text: "CHAMBER VACUUM (1P1001)"; color: "#c084fc"; font.bold: true; font.pixelSize: 9 }
                    RowLayout {
                        Layout.fillWidth: true
                        ColumnLayout {
                            Text { text: "Actual"; color: "#94a3b8"; font.pixelSize: 9 }
                            Text { text: executorRoot.currentVac.toFixed(0) + " mbar"; color: "#c084fc"; font.bold: true; font.pixelSize: 14 }
                        }
                        Item { Layout.fillWidth: true }
                        ColumnLayout {
                            Text { text: "Target SP"; color: "#94a3b8"; font.pixelSize: 9; horizontalAlignment: Text.AlignRight }
                            Text { text: executorRoot.targetVac.toFixed(0) + " mbar"; color: "#ffffff"; font.bold: true; font.pixelSize: 14; horizontalAlignment: Text.AlignRight }
                        }
                    }
                }
            }
        }

        // =====================================================================
        // 4. FIVE-STAGE ISA-88 BATCH PROCESS STEPPER TABLE
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 5
            color: "#071c33"
            border.color: "#184d7e"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 6

                Text {
                    text: "ISA-88 BATCH CONTROL SEQUENCE MATRIX"
                    color: "#94a3b8"
                    font.bold: true
                    font.pixelSize: 11
                }

                // Five Step Visual Rows
                Repeater {
                    model: [
                        { step: 1, name: "Phase A: Initial Water Charge & Pre-Heat", desc: "DI water filling to 55% level and jacket pre-heating to 45.0°C.", temp: "45.0 °C", vac: "-200 mbar", agit: "25 rpm", homo: "0 rpm", dur: "03:00", reqSign: false },
                        { step: 2, name: "Phase B: SLES 28% & CAPB Induction", desc: "Slow surfactant vacuum induction under low-shear mixing.", temp: "45.0 °C", vac: "-300 mbar", agit: "20 rpm", homo: "0 rpm", dur: "05:00", reqSign: true },
                        { step: 3, name: "Phase C: High-Shear Emulsification & Homogenization", desc: "Rotor-stator micro-dispersion high-shear ramping to 3600 RPM at 70°C.", temp: "70.0 °C", vac: "-450 mbar", agit: "60 rpm", homo: "3600 rpm", dur: "08:00", reqSign: false },
                        { step: 4, name: "Phase D: Controlled Cooling & Preservative Dosing", desc: "Jacket chilled water cooling to 45.0°C and active scent charging.", temp: "45.0 °C", vac: "0 mbar", agit: "30 rpm", homo: "0 rpm", dur: "05:00", reqSign: true },
                        { step: 5, name: "Phase E: Viscosity Adjustment (Salt Trim)", desc: "Electrolyte viscosity trim, vacuum deaeration, and QC sampling.", temp: "35.0 °C", vac: "-300 mbar", agit: "40 rpm", homo: "0 rpm", dur: "04:00", reqSign: true }
                    ]

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        radius: 4
                        color: index === executorRoot.currentStepIndex ? "#0e3a66" :
                               (index < executorRoot.currentStepIndex ? "#06231a" : "#081d33")
                        border.color: index === executorRoot.currentStepIndex ? "#00d2ff" :
                                      (index < executorRoot.currentStepIndex ? "#22c55e" : "#184d7e")
                        border.width: index === executorRoot.currentStepIndex ? 1.5 : 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            // Status Indicator
                            Rectangle {
                                width: 24
                                height: 24
                                radius: 12
                                color: index < executorRoot.currentStepIndex ? "#16a34a" :
                                       (index === executorRoot.currentStepIndex ? (executorRoot.isExecuting ? "#0284c7" : "#f59e0b") : "#1e293b")
                                Text {
                                    anchors.centerIn: parent
                                    text: index < executorRoot.currentStepIndex ? "✓" : (index + 1) + ""
                                    color: "#ffffff"
                                    font.bold: true
                                    font.pixelSize: 11
                                }
                            }

                            // Step Name & Description
                            ColumnLayout {
                                Layout.preferredWidth: 280
                                spacing: 1
                                Text {
                                    text: modelData.name
                                    color: index <= executorRoot.currentStepIndex ? "#ffffff" : "#64748b"
                                    font.bold: true
                                    font.pixelSize: 11
                                }
                                Text {
                                    text: modelData.desc
                                    color: index <= executorRoot.currentStepIndex ? "#94a3b8" : "#475569"
                                    font.pixelSize: 9
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            // Setpoint Targets
                            Text { text: "Temp: " + modelData.temp; color: "#cbd5e1"; font.pixelSize: 10; Layout.preferredWidth: 90 }
                            Text { text: "Vac: " + modelData.vac; color: "#cbd5e1"; font.pixelSize: 10; Layout.preferredWidth: 95 }
                            Text { text: "Agit: " + modelData.agit; color: "#cbd5e1"; font.pixelSize: 10; Layout.preferredWidth: 80 }
                            Text { text: "Homo: " + modelData.homo; color: "#cbd5e1"; font.pixelSize: 10; Layout.preferredWidth: 95 }
                            Text { text: "Dur: " + modelData.dur; color: "#f5d033"; font.bold: true; font.pixelSize: 10; Layout.preferredWidth: 70 }

                            Item { Layout.fillWidth: true }

                            // Phase Status Capsule
                            Rectangle {
                                Layout.preferredWidth: 95
                                Layout.preferredHeight: 22
                                radius: 4
                                color: index < executorRoot.currentStepIndex ? "#064e3b" :
                                       (index === executorRoot.currentStepIndex ? (executorRoot.isExecuting ? "#0369a1" : "#78350f") : "#1e293b")
                                border.color: index < executorRoot.currentStepIndex ? "#22c55e" :
                                              (index === executorRoot.currentStepIndex ? (executorRoot.isExecuting ? "#38bdf8" : "#f59e0b") : "#475569")
                                Text {
                                    anchors.centerIn: parent
                                    text: index < executorRoot.currentStepIndex ? "COMPLETED" :
                                           (index === executorRoot.currentStepIndex ? (executorRoot.isExecuting ? "RUNNING" : "HOLD / SIGN") : "PENDING")
                                    color: index < executorRoot.currentStepIndex ? "#86efac" :
                                           (index === executorRoot.currentStepIndex ? (executorRoot.isExecuting ? "#bae6fd" : "#fde68a") : "#94a3b8")
                                    font.bold: true
                                    font.pixelSize: 9
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

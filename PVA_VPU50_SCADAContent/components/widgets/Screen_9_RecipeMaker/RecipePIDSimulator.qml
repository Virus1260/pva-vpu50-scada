pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: simulatorRoot
    implicitWidth: 600
    implicitHeight: 340
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#051324"
    border.color: isFullscreen ? "#38bdf8" : "#1d5b94"
    border.width: isFullscreen ? 2 : 1
    radius: 6
    clip: true

    // Real-Time Simulation Telemetry Properties
    property string activePhase: "Phase A"
    property string activeStage: "1.1"
    property string activeDescription: "Aqueous Phase Initial Heating & Agitation"
    property double agitatorRpm: 25.0
    property double homoRpm: 0.0
    property double vacuumMbar: 0.0
    property double vesselTemp: 25.0
    property double targetTemp: 85.0
    property double liquidLevelPct: 45.0 // 0.0 to 100.0%
    property string fluidColor: "#38bdf8" // Changes as formulation emulsifies
    property bool isHeating: true
    property bool isCooling: false
    property bool valveChargeOpen: true
    property bool valveDrainOpen: false
    property bool isFullscreen: false

    // Manual Sequence Interlock / Hold State
    property bool isManualHoldActive: false
    property string manualHoldMessage: "Operator to confirm that valve abc123 is OPEN for material loading."
    property string manualTargetAsset: "Butterfly Valve abc123"

    signal manualConfirmed
    signal toggleFullscreenRequested

    // Rotation animation for Agitator Blades
    NumberAnimation {
        id: agitatorRotAnim
        target: agitatorBladeGroup
        property: "rotation"
        from: 0
        to: 360
        duration: simulatorRoot.agitatorRpm > 0 ? Math.max(200, (60000 / simulatorRoot.agitatorRpm)) : 1000000
        loops: Animation.Infinite
        running: simulatorRoot.agitatorRpm > 0
    }

    // Rotation animation for Homogenizer Rotor
    NumberAnimation {
        id: homoRotAnim
        target: homoRotor
        property: "rotation"
        from: 0
        to: 360
        duration: simulatorRoot.homoRpm > 0 ? Math.max(80, (60000 / simulatorRoot.homoRpm)) : 1000000
        loops: Animation.Infinite
        running: simulatorRoot.homoRpm > 0
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 4

        // 1. Simulation Top Bar (Player Header + Telemetry + Fullscreen Toggle)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            radius: 4
            color: "#0b2e52"
            border.color: "#1d5b94"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 8

                Rectangle {
                    Layout.preferredWidth: 8
                    Layout.preferredHeight: 8
                    radius: 4
                    color: simulatorRoot.isManualHoldActive ? "#eab308" : "#22c55e"
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: simulatorRoot.isManualHoldActive
                        NumberAnimation { from: 1.0; to: 0.2; duration: 500 }
                        NumberAnimation { from: 0.2; to: 1.0; duration: 500 }
                    }
                }

                Text {
                    text: "P&ID SIMULATION PLAYER (VPU-50 SKID)"
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 11
                }

                // Current Phase Badge
                Rectangle {
                    Layout.preferredHeight: 20
                    Layout.preferredWidth: phaseTxt.implicitWidth + 10
                    radius: 3
                    color: "#164e85"
                    border.color: "#38bdf8"
                    border.width: 1
                    Text {
                        id: phaseTxt
                        anchors.centerIn: parent
                        text: simulatorRoot.activePhase + " (Stage " + simulatorRoot.activeStage + ")"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 9
                    }
                }

                Item { Layout.fillWidth: true }

                // Live Value Chips
                RowLayout {
                    spacing: 8

                    Text {
                        text: "🌪 Agitator: <b>" + Math.round(simulatorRoot.agitatorRpm) + " RPM</b>"
                        color: simulatorRoot.agitatorRpm > 0 ? "#38bdf8" : "#64748b"
                        font.pixelSize: 10
                        textFormat: Text.RichText
                    }

                    Text {
                        text: "⚙ Homo: <b>" + Math.round(simulatorRoot.homoRpm) + " RPM</b>"
                        color: simulatorRoot.homoRpm > 0 ? "#c084fc" : "#64748b"
                        font.pixelSize: 10
                        textFormat: Text.RichText
                    }

                    Text {
                        text: "💨 Vac: <b>" + Math.round(simulatorRoot.vacuumMbar) + " mbar</b>"
                        color: simulatorRoot.vacuumMbar < -50 ? "#2dd4bf" : "#64748b"
                        font.pixelSize: 10
                        textFormat: Text.RichText
                    }

                    Text {
                        text: "🌡 Temp: <b>" + simulatorRoot.vesselTemp.toFixed(1) + " °C</b>"
                        color: simulatorRoot.isHeating ? "#fb923c" : (simulatorRoot.isCooling ? "#60a5fa" : "#94a3b8")
                        font.pixelSize: 10
                        textFormat: Text.RichText
                    }
                }

                // Fullscreen Button
                Rectangle {
                    Layout.preferredWidth: 84
                    Layout.preferredHeight: 22
                    radius: 3
                    color: fsMouse.containsMouse ? "#0284c7" : "#081d33"
                    border.color: "#38bdf8"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Text {
                            text: simulatorRoot.isFullscreen ? "⛶ Minimize" : "⛶ Fullscreen"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 9
                        }
                    }

                    MouseArea {
                        id: fsMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: simulatorRoot.toggleFullscreenRequested()
                    }
                }
            }
        }

        // 2. Animated P&ID Canvas Area
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#030c17"
            border.color: "#163f68"
            border.width: 1
            radius: 4
            clip: true

            Item {
                anchors.fill: parent

                // Background Schematic Grid Lines
                Canvas {
                    anchors.fill: parent
                    opacity: 0.15
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.strokeStyle = "#38bdf8";
                        ctx.lineWidth = 0.5;
                        for (var x = 0; x < width; x += 30) {
                            ctx.beginPath();
                            ctx.moveTo(x, 0);
                            ctx.lineTo(x, height);
                            ctx.stroke();
                        }
                        for (var y = 0; y < height; y += 30) {
                            ctx.beginPath();
                            ctx.moveTo(0, y);
                            ctx.lineTo(width, y);
                            ctx.stroke();
                        }
                    }
                }

                // =============================================================
                // PIPING & INSTRUMENTATION LINES
                // =============================================================

                // Top Vacuum Suction Line (Top Right)
                Rectangle {
                    x: parent.width * 0.5 + 40
                    y: 35
                    width: parent.width * 0.35
                    height: 4
                    color: simulatorRoot.vacuumMbar < -50 ? "#2dd4bf" : "#334155"
                }

                // Vacuum Gauge Widget (Top Right)
                Rectangle {
                    x: parent.width * 0.85
                    y: 18
                    width: 38
                    height: 38
                    radius: 19
                    color: "#0b2e52"
                    border.color: simulatorRoot.vacuumMbar < -50 ? "#2dd4bf" : "#475569"
                    border.width: 2

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 0
                        Text { text: "VAC"; color: "#94a3b8"; font.pixelSize: 7; Layout.alignment: Qt.AlignHCenter }
                        Text { text: Math.round(simulatorRoot.vacuumMbar) + ""; color: "#ffffff"; font.bold: true; font.pixelSize: 8; Layout.alignment: Qt.AlignHCenter }
                    }
                }

                // Top Water & Raw Material Charging Line (Top Left)
                Rectangle {
                    x: parent.width * 0.15
                    y: 40
                    width: parent.width * 0.35 - 40
                    height: 4
                    color: simulatorRoot.valveChargeOpen ? "#38bdf8" : "#334155"
                }

                // Top Charging Valve V101 / 1K1001 Icon
                Rectangle {
                    x: parent.width * 0.25
                    y: 28
                    width: 28
                    height: 28
                    radius: 4
                    color: simulatorRoot.valveChargeOpen ? "#065f46" : "#1e293b"
                    border.color: simulatorRoot.valveChargeOpen ? "#34d399" : "#64748b"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: simulatorRoot.valveChargeOpen ? "V101\nOPEN" : "V101\nCLSD"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 6
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                // =============================================================
                // MAIN VPU-50 VESSEL & JACKET
                // =============================================================
                Rectangle {
                    id: vesselOuter
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 15
                    width: Math.min(parent.width * 0.42, 220)
                    height: Math.min(parent.height * 0.72, 210)
                    radius: 24
                    color: "#081d33"

                    // Heating / Cooling Thermal Jacket Border
                    border.color: simulatorRoot.isHeating ? "#ea580c" : (simulatorRoot.isCooling ? "#38bdf8" : "#1d5b94")
                    border.width: 6

                    // Thermographic Infrared Heat Glow
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 4
                        radius: 20
                        color: simulatorRoot.isHeating ? "#451a03" : (simulatorRoot.isCooling ? "#082f49" : "#00000000")
                        opacity: 0.6
                    }

                    // Liquid Contents Area (Dynamic Fill Level)
                    Rectangle {
                        id: liquidFill
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 6
                        height: (parent.height - 12) * (simulatorRoot.liquidLevelPct / 100.0)
                        radius: 18
                        color: simulatorRoot.fluidColor
                        opacity: 0.75

                        // Subtle fluid surface wave line
                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 3
                            color: "#ffffff"
                            opacity: 0.6
                        }
                    }

                    // =========================================================
                    // AGITATOR ANCHOR SHAFT & BLADES
                    // =========================================================
                    // Agitator Motor Housing on Top of Vessel
                    Rectangle {
                        anchors.bottom: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 32
                        height: 22
                        radius: 3
                        color: simulatorRoot.agitatorRpm > 0 ? "#0284c7" : "#1e293b"
                        border.color: "#38bdf8"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "1M1501"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 7
                        }
                    }

                    // Center Shaft
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.margins: 20
                        width: 4
                        color: "#94a3b8"
                    }

                    // Rotating Anchor Blades
                    Item {
                        id: agitatorBladeGroup
                        anchors.centerIn: parent
                        width: vesselOuter.width - 30
                        height: 50

                        // Left Wing
                        Rectangle {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width * 0.42
                            height: 12
                            radius: 4
                            color: "#e2e8f0"
                            border.color: "#38bdf8"
                            border.width: 1
                        }

                        // Right Wing
                        Rectangle {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width * 0.42
                            height: 12
                            radius: 4
                            color: "#e2e8f0"
                            border.color: "#38bdf8"
                            border.width: 1
                        }
                    }

                    // =========================================================
                    // BOTTOM HIGH-SHEAR HOMOGENIZER (1X1001)
                    // =========================================================
                    Rectangle {
                        anchors.top: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 44
                        height: 24
                        radius: 4
                        color: simulatorRoot.homoRpm > 0 ? "#7c3aed" : "#1e293b"
                        border.color: simulatorRoot.homoRpm > 0 ? "#c084fc" : "#475569"
                        border.width: 1

                        Item {
                            id: homoRotor
                            anchors.centerIn: parent
                            width: 16
                            height: 16

                            Text {
                                anchors.centerIn: parent
                                text: "⚙"
                                color: "#ffffff"
                                font.pixelSize: 14
                            }
                        }
                    }
                }

                // Vessel Tag Label
                Rectangle {
                    anchors.top: vesselOuter.top
                    anchors.topMargin: 8
                    anchors.horizontalCenter: vesselOuter.horizontalCenter
                    width: 70
                    height: 18
                    radius: 3
                    color: "#bb081d33"
                    border.color: "#38bdf8"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "VPU-50 (50L)"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 9
                    }
                }
            }

            // =================================================================
            // 3. MOCK 21 CFR PART 11 OPERATOR CONFIRMATION PROMPT
            // (Pops up directly over simulator when playhead hits manual block)
            // =================================================================
            Rectangle {
                anchors.centerIn: parent
                width: Math.min(parent.width * 0.85, 480)
                height: 180
                radius: 8
                color: "#0b2e52"
                border.color: "#fbbf24"
                border.width: 2
                visible: simulatorRoot.isManualHoldActive
                z: 20

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            Layout.preferredWidth: 28
                            Layout.preferredHeight: 28
                            radius: 14
                            color: "#78350f"
                            border.color: "#fbbf24"
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: "✋"
                                font.pixelSize: 14
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                text: "21 CFR PART 11 OPERATOR HOLD POINT"
                                color: "#fbbf24"
                                font.bold: true
                                font.pixelSize: 12
                            }
                            Text {
                                text: "Plant floor sequence interlock active: Physical action required"
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
                        text: simulatorRoot.manualHoldMessage
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 11
                        wrapMode: Text.WordWrap
                    }

                    Item { Layout.fillHeight: true }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            text: "Target: <b>" + simulatorRoot.manualTargetAsset + "</b>"
                            color: "#38bdf8"
                            font.pixelSize: 10
                            textFormat: Text.RichText
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            Layout.preferredWidth: 160
                            Layout.preferredHeight: 32
                            radius: 4
                            color: confMouse.containsMouse ? "#d97706" : "#b45309"
                            border.color: "#fcd34d"
                            border.width: 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 4
                                Text { text: "✓ Confirm & Resume"; color: "#ffffff"; font.bold: true; font.pixelSize: 11 }
                            }

                            MouseArea {
                                id: confMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: simulatorRoot.manualConfirmed()
                            }
                        }
                    }
                }
            }
        }
    }
}

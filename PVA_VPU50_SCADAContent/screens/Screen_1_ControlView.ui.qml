/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML.
*/

import QtQuick
import QtQuick.Layouts
import "../components/widgets"
import "../components/widgets/Screen_1_Control"

Rectangle {
    id: controlRoot
    width: 1184
    height: 626
    implicitWidth: 1184
    implicitHeight: 626
    color: "#08213b"
    clip: true

    // Property Aliases for Row 1 (Agitator / Mixing 1)
    property alias row1ModeSelector: r1ModeSelector
    property alias row1PowerCard: r1PowerCurrent
    property alias row1SpeedControl: r1Speed
    property alias row1MinusBtn: r1Speed.minusButton
    property alias row1PlusBtn: r1Speed.plusButton
    property alias row1Media: r1Media
    property alias row1Runtime: r1Runtime

    // Property Aliases for Row 2 (Homogenizer / Mixing 2)
    property alias row2ModeSelector: r2ModeSelector
    property alias row2PowerCard: r2PowerCurrent
    property alias row2SpeedControl: r2Speed
    property alias row2MinusBtn: r2Speed.minusButton
    property alias row2PlusBtn: r2Speed.plusButton
    property alias row2Media: r2Media
    property alias row2Runtime: r2Runtime

    // Property Aliases for Row 3 (Circulation)
    property alias row3ModeSelector: r3ModeSelector
    property alias row3Media: r3Media
    property alias row3Runtime: r3Runtime

    // Property Aliases for Row 4 (Vacuum)
    property alias row4ModeSelector: r4ModeSelector
    property alias row4PressureCard: r4Pressure
    property alias row4StartCard: r4Start
    property alias row4EndCard: r4End
    property alias row4Media: r4Media
    property alias row4Runtime: r4Runtime

    // Property Aliases for Row 5 (Suction Liquids)
    property alias row5ModeSelector: r5ModeSelector
    property alias row5AngleOpenCard: r5AngleOpen
    property alias row5AngleCloseCard: r5AngleClose
    property alias row5TimeOpenCard: r5TimeOpen
    property alias row5TimeCloseCard: r5TimeClose
    property alias row5Media: r5Media
    property alias row5Runtime: r5Runtime

    // Property Aliases for Row 6 (Heating / Temperature)
    property alias row6ModeSelector: r6ModeSelector
    property alias row6RegSelector: r6RegSelector
    property alias row6TempSrcSelector: r6TempSrcSelector
    property alias row6GradientCard: r6Gradient
    property alias row6DeltaTCard: r6DeltaT
    property alias row6TempCard: r6Temp
    property alias row6DevCard: r6Dev
    property alias row6Media: r6Media
    property alias row6Runtime: r6Runtime

    // --- Run-Mode Decoupling & Automatic Recipe Lockout Properties ---
    property bool isLocked: false
    property string lockoutBatchId: ""
    property string lockoutRecipeName: ""
    property int lockoutStep: 0
    property int lockoutTotalSteps: 0

    // Top Industrial Safety Lockout Banner
    Rectangle {
        id: lockoutBanner
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 38
        z: 999
        visible: controlRoot.isLocked
        color: "#991b1b"
        border.color: "#ef4444"
        border.width: 1
        radius: 4

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 10

            Text {
                text: "🔒"
                font.pixelSize: 16
            }

            Text {
                text: "AUTOMATIC RECIPE EXECUTION ACTIVE • MANUAL OVERRIDES INHIBITED"
                color: "#ffffff"
                font.bold: true
                font.pixelSize: 12
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "transparent"
            }

            Text {
                text: "BATCH: " + (controlRoot.lockoutBatchId || "ACTIVE") + " • " + (controlRoot.lockoutRecipeName || "FORMULATION") + " (STEP " + controlRoot.lockoutStep + "/" + controlRoot.lockoutTotalSteps + ")"
                color: "#fef08a"
                font.bold: true
                font.pixelSize: 12
            }
        }
    }

    // Main 6 Process Rows Container
    ColumnLayout {
        anchors.top: controlRoot.isLocked ? lockoutBanner.bottom : parent.top
        anchors.topMargin: controlRoot.isLocked ? 4 : 0
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 4
        enabled: !controlRoot.isLocked
        opacity: controlRoot.isLocked ? 0.45 : 1.0

        // =========================================================================
        // ROW 1: AGITATOR (Mixing 1)
        // =========================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 86
            Layout.minimumHeight: 80
            Layout.maximumHeight: 92
            color: "#0f3862"
            border.color: "#184d7e"
            border.width: 1
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                anchors.topMargin: 8
                anchors.bottomMargin: 8
                spacing: 8

                // ZONE 1: Left Equipment Block (Locked 282px)
                RowLayout {
                    Layout.preferredWidth: 282
                    Layout.minimumWidth: 282
                    Layout.maximumWidth: 282
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 6

                    Rectangle {
                        Layout.preferredWidth: 66
                        Layout.minimumWidth: 66
                        Layout.maximumWidth: 66
                        Layout.preferredHeight: 68
                        Layout.minimumHeight: 68
                        Layout.maximumHeight: 68
                        color: r1Media.isPlaying ? "#78dc20" : "#0c345a"
                        border.color: r1Media.isPlaying ? "#ffffff" : "#1d5b94"
                        border.width: 1
                        radius: 4
                        ScadaIcon {
                            anchors.centerIn: parent
                            iconName: "stirrer_agitator"
                            width: 44
                            height: 44
                        }
                    }

                    ScadaModeSelector {
                        id: r1ModeSelector
                        label: "Mode"
                        iconName: "agitator_cw"
                        preferredWidth: 66
                        selectorHeight: 68
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }

                // Left Centering Spacer
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                // ZONE 2: Middle Parameter Grid (Col 1: 25%, Col 2..4: 75%, Centered)
                RowLayout {
                    Layout.preferredWidth: 700
                    Layout.minimumWidth: 480
                    Layout.maximumWidth: 780
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 8

                    ScadaPowerCurrentCard {
                        id: r1PowerCurrent
                        cardHeight: 68
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        Layout.alignment: Qt.AlignVCenter
                    }

                    ScadaSpeedControl {
                        id: r1Speed
                        minVal: 25.0
                        maxVal: 120.0
                        currentVal: 0.0
                        targetVal: 25.0
                        unit: "rpm"
                        decimals: 1
                        controlHeight: 68
                        isLocked: r1Media.isPlaying
                        parameterTitle: "Agitator Speed"
                        parameterTag: "1M1501"
                        Layout.fillWidth: true
                        Layout.preferredWidth: 3
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                // Right Centering Spacer
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                // ZONE 3: Right Media Controls & Runtime (Locked 216px)
                RowLayout {
                    Layout.preferredWidth: 216
                    Layout.minimumWidth: 216
                    Layout.maximumWidth: 216
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 6

                    ScadaMediaControls {
                        id: r1Media
                        Layout.alignment: Qt.AlignVCenter
                    }
                    ScadaRuntimeWidget {
                        id: r1Runtime
                        preferredWidth: 66
                        widgetHeight: 68
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }
        }

        // =========================================================================
        // ROW 2: HOMOGENIZER (Mixing 2)
        // =========================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 86
            Layout.minimumHeight: 80
            Layout.maximumHeight: 92
            color: "#0f3862"
            border.color: "#184d7e"
            border.width: 1
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                anchors.topMargin: 8
                anchors.bottomMargin: 8
                spacing: 8

                // ZONE 1: Left Equipment Block (Locked 282px)
                RowLayout {
                    Layout.preferredWidth: 282
                    Layout.minimumWidth: 282
                    Layout.maximumWidth: 282
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 6

                    Rectangle {
                        Layout.preferredWidth: 66
                        Layout.minimumWidth: 66
                        Layout.maximumWidth: 66
                        Layout.preferredHeight: 68
                        Layout.minimumHeight: 68
                        Layout.maximumHeight: 68
                        color: r2Media.isPlaying ? "#78dc20" : "#0c345a"
                        border.color: r2Media.isPlaying ? "#ffffff" : "#1d5b94"
                        border.width: 1
                        radius: 4
                        ScadaIcon {
                            anchors.centerIn: parent
                            iconName: "homogenizer"
                            width: 44
                            height: 44
                        }
                    }

                    ScadaModeSelector {
                        id: r2ModeSelector
                        label: "Mode"
                        iconName: "homo_permanent"
                        preferredWidth: 66
                        selectorHeight: 68
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }

                // Left Centering Spacer
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                // ZONE 2: Middle Parameter Grid (Col 1: 25%, Col 2..4: 75%, Centered)
                RowLayout {
                    Layout.preferredWidth: 700
                    Layout.minimumWidth: 480
                    Layout.maximumWidth: 780
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 8

                    ScadaPowerCurrentCard {
                        id: r2PowerCurrent
                        cardHeight: 68
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        Layout.alignment: Qt.AlignVCenter
                    }

                    ScadaSpeedControl {
                        id: r2Speed
                        minVal: 600
                        maxVal: 4800
                        currentVal: 0
                        targetVal: 600
                        unit: "rpm"
                        decimals: 0
                        controlHeight: 68
                        isLocked: r2Media.isPlaying
                        parameterTitle: "Homogenizer Speed"
                        parameterTag: "1M2003"
                        Layout.fillWidth: true
                        Layout.preferredWidth: 3
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                // Right Centering Spacer
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                // ZONE 3: Right Media Controls & Runtime (Locked 216px)
                RowLayout {
                    Layout.preferredWidth: 216
                    Layout.minimumWidth: 216
                    Layout.maximumWidth: 216
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 6

                    ScadaMediaControls {
                        id: r2Media
                        Layout.alignment: Qt.AlignVCenter
                    }
                    ScadaRuntimeWidget {
                        id: r2Runtime
                        preferredWidth: 66
                        widgetHeight: 68
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }
        }

        // =========================================================================
        // ROW 3: CIRCULATION (EXT)
        // =========================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 86
            Layout.minimumHeight: 80
            Layout.maximumHeight: 92
            color: "#0f3862"
            border.color: "#184d7e"
            border.width: 1
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                anchors.topMargin: 8
                anchors.bottomMargin: 8
                spacing: 8

                // ZONE 1: Left Equipment Block (Locked 282px)
                RowLayout {
                    Layout.preferredWidth: 282
                    Layout.minimumWidth: 282
                    Layout.maximumWidth: 282
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 6

                    Rectangle {
                        Layout.preferredWidth: 66
                        Layout.minimumWidth: 66
                        Layout.maximumWidth: 66
                        Layout.preferredHeight: 68
                        Layout.minimumHeight: 68
                        Layout.maximumHeight: 68
                        color: r3Media.isPlaying ? "#78dc20" : "#0c345a"
                        border.color: r3Media.isPlaying ? "#ffffff" : "#1d5b94"
                        border.width: 1
                        radius: 4
                        ScadaIcon {
                            anchors.centerIn: parent
                            iconName: "external_circulation"
                            width: 44
                            height: 44
                        }
                    }

                    ScadaModeSelector {
                        id: r3ModeSelector
                        label: "Mode"
                        iconName: "ext_discharge_circulation"
                        preferredWidth: 66
                        selectorHeight: 68
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }

                // ZONE 2: Middle Empty Area
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                // ZONE 3: Right Media Controls & Runtime (Locked 216px)
                RowLayout {
                    Layout.preferredWidth: 216
                    Layout.minimumWidth: 216
                    Layout.maximumWidth: 216
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 6

                    ScadaMediaControls {
                        id: r3Media
                        Layout.alignment: Qt.AlignVCenter
                    }
                    ScadaRuntimeWidget {
                        id: r3Runtime
                        preferredWidth: 66
                        widgetHeight: 68
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }
        }

        // =========================================================================
        // ROW 4: VACUUM SYSTEM
        // =========================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 86
            Layout.minimumHeight: 80
            Layout.maximumHeight: 92
            color: "#0f3862"
            border.color: "#184d7e"
            border.width: 1
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                anchors.topMargin: 8
                anchors.bottomMargin: 8
                spacing: 8

                // ZONE 1: Left Equipment Block (Locked 282px)
                RowLayout {
                    Layout.preferredWidth: 282
                    Layout.minimumWidth: 282
                    Layout.maximumWidth: 282
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 6

                    Rectangle {
                        Layout.preferredWidth: 66
                        Layout.minimumWidth: 66
                        Layout.maximumWidth: 66
                        Layout.preferredHeight: 68
                        Layout.minimumHeight: 68
                        Layout.maximumHeight: 68
                        color: r4Media.isPlaying ? "#78dc20" : "#0c345a"
                        border.color: r4Media.isPlaying ? "#ffffff" : "#1d5b94"
                        border.width: 1
                        radius: 4
                        ScadaIcon {
                            anchors.centerIn: parent
                            iconName: "vacuum_gauge"
                            width: 44
                            height: 44
                        }
                    }

                    ScadaModeSelector {
                        id: r4ModeSelector
                        label: "Mode"
                        iconName: "vacuum_gauge"
                        preferredWidth: 66
                        selectorHeight: 68
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }

                // Left Centering Spacer
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                // ZONE 2: Middle Parameter Grid (Pressure, Start, End, 4th Column Spacer)
                RowLayout {
                    Layout.preferredWidth: 700
                    Layout.minimumWidth: 480
                    Layout.maximumWidth: 780
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 8

                    ScadaCard {
                        id: r4Pressure
                        title: "Pressure"
                        primaryValue: "-209.8"
                        unit: "mbar"
                        cardHeight: 68
                        showProgressBar: true
                        progressValue: 0.46
                        progressColor: "#00d2ff"
                        Layout.fillWidth: true
                        Layout.preferredWidth: 168
                        Layout.minimumWidth: 120
                        Layout.maximumWidth: 185
                        Layout.alignment: Qt.AlignVCenter
                    }

                    ScadaCard {
                        id: r4Start
                        title: "Start pressure"
                        primaryValue: "-400.0"
                        unit: "mbar"
                        cardHeight: 68
                        Layout.fillWidth: true
                        Layout.preferredWidth: 168
                        Layout.minimumWidth: 120
                        Layout.maximumWidth: 185
                        Layout.alignment: Qt.AlignVCenter
                    }

                    ScadaCard {
                        id: r4End
                        title: "End pressure"
                        primaryValue: "-450.0"
                        unit: "mbar"
                        cardHeight: 68
                        Layout.fillWidth: true
                        Layout.preferredWidth: 168
                        Layout.minimumWidth: 120
                        Layout.maximumWidth: 185
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 168
                        Layout.minimumWidth: 120
                        Layout.maximumWidth: 185
                        Layout.fillHeight: true
                    }
                }

                // Right Centering Spacer
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                // ZONE 3: Right Media Controls & Runtime (Locked 216px)
                RowLayout {
                    Layout.preferredWidth: 216
                    Layout.minimumWidth: 216
                    Layout.maximumWidth: 216
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 6

                    ScadaMediaControls {
                        id: r4Media
                        Layout.alignment: Qt.AlignVCenter
                    }
                    ScadaRuntimeWidget {
                        id: r4Runtime
                        preferredWidth: 66
                        widgetHeight: 68
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }
        }

        // =========================================================================
        // ROW 5: SUCTION LIQUIDS
        // =========================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 86
            Layout.minimumHeight: 80
            Layout.maximumHeight: 92
            color: "#0f3862"
            border.color: "#184d7e"
            border.width: 1
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                anchors.topMargin: 8
                anchors.bottomMargin: 8
                spacing: 8

                // ZONE 1: Left Equipment Block (Locked 282px)
                RowLayout {
                    Layout.preferredWidth: 282
                    Layout.minimumWidth: 282
                    Layout.maximumWidth: 282
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 6

                    Rectangle {
                        Layout.preferredWidth: 66
                        Layout.minimumWidth: 66
                        Layout.maximumWidth: 66
                        Layout.preferredHeight: 68
                        Layout.minimumHeight: 68
                        Layout.maximumHeight: 68
                        color: r5Media.isPlaying ? "#78dc20" : "#0c345a"
                        border.color: r5Media.isPlaying ? "#ffffff" : "#1d5b94"
                        border.width: 1
                        radius: 4
                        ScadaIcon {
                            anchors.centerIn: parent
                            iconName: "suction"
                            width: 44
                            height: 44
                        }
                    }

                    ScadaModeSelector {
                        id: r5ModeSelector
                        label: "Mode"
                        iconName: "suction_liquids"
                        preferredWidth: 66
                        selectorHeight: 68
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }

                // Left Centering Spacer
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                // ZONE 2: Middle Parameter Grid (Angle open, Angle closed, Time open, Time closed)
                RowLayout {
                    Layout.preferredWidth: 700
                    Layout.minimumWidth: 480
                    Layout.maximumWidth: 780
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 8

                    ScadaCard {
                        id: r5AngleOpen
                        title: "Angle open"
                        primaryValue: "0.0"
                        secondaryValue: "100.0%"
                        unit: ""
                        cardHeight: 68
                        Layout.fillWidth: true
                        Layout.preferredWidth: 168
                        Layout.minimumWidth: 120
                        Layout.maximumWidth: 185
                        Layout.alignment: Qt.AlignVCenter
                    }

                    ScadaCard {
                        id: r5AngleClose
                        title: "Angle closed"
                        primaryValue: "0.0"
                        secondaryValue: "100.0%"
                        unit: ""
                        cardHeight: 68
                        Layout.fillWidth: true
                        Layout.preferredWidth: 168
                        Layout.minimumWidth: 120
                        Layout.maximumWidth: 185
                        Layout.alignment: Qt.AlignVCenter
                    }

                    ScadaCard {
                        id: r5TimeOpen
                        title: "Time open"
                        primaryValue: "0"
                        secondaryValue: "0.0 s"
                        unit: ""
                        cardHeight: 68
                        Layout.fillWidth: true
                        Layout.preferredWidth: 168
                        Layout.minimumWidth: 120
                        Layout.maximumWidth: 185
                        Layout.alignment: Qt.AlignVCenter
                    }

                    ScadaCard {
                        id: r5TimeClose
                        title: "Time closed"
                        primaryValue: "0"
                        secondaryValue: "0.0 s"
                        unit: ""
                        cardHeight: 68
                        Layout.fillWidth: true
                        Layout.preferredWidth: 168
                        Layout.minimumWidth: 120
                        Layout.maximumWidth: 185
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                // Right Centering Spacer
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                // ZONE 3: Right Media Controls & Runtime (Locked 216px)
                RowLayout {
                    Layout.preferredWidth: 216
                    Layout.minimumWidth: 216
                    Layout.maximumWidth: 216
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 6

                    ScadaMediaControls {
                        id: r5Media
                        Layout.alignment: Qt.AlignVCenter
                    }
                    ScadaRuntimeWidget {
                        id: r5Runtime
                        preferredWidth: 66
                        widgetHeight: 68
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }
        }

        // =========================================================================
        // ROW 6: HEATING & TEMPERATURE CONTROL
        // =========================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 86
            Layout.minimumHeight: 80
            Layout.maximumHeight: 92
            color: "#0f3862"
            border.color: "#184d7e"
            border.width: 1
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                anchors.topMargin: 8
                anchors.bottomMargin: 8
                spacing: 8

                // ZONE 1: Left Equipment Block (Locked 282px)
                RowLayout {
                    Layout.preferredWidth: 282
                    Layout.minimumWidth: 282
                    Layout.maximumWidth: 282
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 6

                    Rectangle {
                        Layout.preferredWidth: 66
                        Layout.minimumWidth: 66
                        Layout.maximumWidth: 66
                        Layout.preferredHeight: 68
                        Layout.minimumHeight: 68
                        Layout.maximumHeight: 68
                        color: r6Media.isPlaying ? "#78dc20" : "#0c345a"
                        border.color: r6Media.isPlaying ? "#ffffff" : "#1d5b94"
                        border.width: 1
                        radius: 4
                        ScadaIcon {
                            anchors.centerIn: parent
                            iconName: "heating_jacket"
                            width: 44
                            height: 44
                        }
                    }

                    ScadaModeSelector {
                        id: r6ModeSelector
                        label: "Mode"
                        iconName: "heat_mode_heating"
                        preferredWidth: 66
                        selectorHeight: 68
                    }

                    ScadaModeSelector {
                        id: r6RegSelector
                        label: "Regulation"
                        iconName: "heat_reg_product"
                        preferredWidth: 66
                        selectorHeight: 68
                    }

                    ScadaModeSelector {
                        id: r6TempSrcSelector
                        label: "Temp. Indic."
                        iconName: "heat_src_baffle"
                        preferredWidth: 66
                        selectorHeight: 68
                    }
                }

                // Left Centering Spacer
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                // ZONE 2: Middle Parameter Grid (Gradient, Delta T, Temperature, Deviation)
                RowLayout {
                    Layout.preferredWidth: 700
                    Layout.minimumWidth: 480
                    Layout.maximumWidth: 780
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 8

                    ScadaCard {
                        id: r6Gradient
                        title: "Gradient"
                        primaryValue: "12.1"
                        unit: "°C/h"
                        cardHeight: 68
                        showProgressBar: true
                        progressValue: 0.35
                        progressColor: "#00d2ff"
                        Layout.fillWidth: true
                        Layout.preferredWidth: 168
                        Layout.minimumWidth: 120
                        Layout.maximumWidth: 185
                        Layout.alignment: Qt.AlignVCenter
                    }

                    ScadaCard {
                        id: r6DeltaT
                        title: "Delta T Jacket"
                        primaryValue: "23.2"
                        secondaryValue: "0.0 °C"
                        unit: ""
                        cardHeight: 68
                        Layout.fillWidth: true
                        Layout.preferredWidth: 168
                        Layout.minimumWidth: 120
                        Layout.maximumWidth: 185
                        Layout.alignment: Qt.AlignVCenter
                    }

                    ScadaCard {
                        id: r6Temp
                        title: "Temperature"
                        primaryValue: "40.1"
                        secondaryValue: "89.0 °C"
                        unit: ""
                        cardHeight: 68
                        Layout.fillWidth: true
                        Layout.preferredWidth: 168
                        Layout.minimumWidth: 120
                        Layout.maximumWidth: 185
                        Layout.alignment: Qt.AlignVCenter
                    }

                    ScadaCard {
                        id: r6Dev
                        title: "Deviation"
                        primaryValue: "48.9"
                        secondaryValue: "1.0 °C"
                        unit: ""
                        cardHeight: 68
                        Layout.fillWidth: true
                        Layout.preferredWidth: 168
                        Layout.minimumWidth: 120
                        Layout.maximumWidth: 185
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                // Right Centering Spacer
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                // ZONE 3: Right Media Controls & Runtime (Locked 216px)
                RowLayout {
                    Layout.preferredWidth: 216
                    Layout.minimumWidth: 216
                    Layout.maximumWidth: 216
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 6

                    ScadaMediaControls {
                        id: r6Media
                        Layout.alignment: Qt.AlignVCenter
                    }
                    ScadaRuntimeWidget {
                        id: r6Runtime
                        preferredWidth: 66
                        widgetHeight: 68
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }
        }

        // Bottom spacer to prevent vertical stretching
        Item {
            Layout.fillHeight: true
        }
    }
}

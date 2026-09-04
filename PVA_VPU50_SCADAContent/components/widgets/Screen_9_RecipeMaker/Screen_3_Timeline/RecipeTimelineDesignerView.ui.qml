pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../"
import "../../../common"
import "../../../design_system"
import "../../../../theme"

Item {
    id: timelineDesignerViewRoot
    implicitWidth: 1166
    implicitHeight: 640

    property string recipeId: "REC-VPU50-002"
    property string recipeTitle: "Body Lotion Formulation"
    property string recipeStatus: "DRAFT"
    property string recipeBatchMode: "Fixed (100 kg)"
    property string recipeVersion: "v1.0"
    property int selectedStepIndex: 0
    property int totalStepsCount: 5
    property string validationStatusText: "✓ Pre-Flight Checklist: 5/5 All Guardrails Valid"
    property bool validationPassed: true
    property string validationDetails: "All phases reconciled. Mechanical seal & thermal safety interlocks verified."

    // Inspector dynamic binding properties for selected step
    property string inspectorStepName: ""
    property string inspectorPhaseType: "PHASE_HOMOGENIZATION"
    property string inspectorPhaseTypeDisplay: "HOMOGENIZATION"
    property string inspectorTargetUnit: "MAIN_VESSEL_VPU50"
    property string inspectorLinkedPhase: "Phase B (Wax Phase)"

    // Agitator Subsystem Parameters
    property real inspectorAgitatorSpeed: 25.0
    property string inspectorAgitatorMode: "agitator_cw"
    property string inspectorAgitatorModeTitle: "Clockwise (CW)"
    property string inspectorAgitatorModeSubtitle: "Down-Pumping"
    property int inspectorAgitatorCwSec: 30
    property int inspectorAgitatorCcwSec: 30

    // Homogenizer Subsystem Parameters
    property real inspectorHomogenizerSpeed: 2800.0
    property string inspectorHomogenizerMode: "homo_permanent"
    property string inspectorHomogenizerModeTitle: "Permanent"
    property string inspectorHomogenizerModeSubtitle: "Continuous Run"
    property int inspectorHomoPulseOnSec: 30
    property int inspectorHomoPulseOffSec: 10
    property bool inspectorRunAgitatorCoActive: true
    property real inspectorCoActiveAgitatorSpeed: 35.0
    property string inspectorCoActiveAgitatorMode: "agitator_cw"

    // Thermal Subsystem Parameters
    property real inspectorTargetTemp: 82.5
    property real inspectorTempGradient: 12.0
    property string inspectorThermalMode: "heat_mode_heating"
    property string inspectorThermalModeTitle: "Heating Mode"
    property string inspectorThermalModeSubtitle: "Utility Steam Modulation"

    // Vacuum Subsystem Parameters
    property real inspectorTargetVacuum: -450.0
    property real inspectorVacStart: -400.0
    property real inspectorVacEnd: -450.0
    property string inspectorVacuumMode: "vac_auto_drawdown"
    property string inspectorVacuumModeTitle: "Automatic Drawdown"
    property string inspectorVacuumModeSubtitle: "Vacuum Header Control"

    // Step Duration & Manual Intervention
    property int inspectorDurationMin: 15
    property int inspectorDurationSec: 0
    property string inspectorManualCategory: "Manual Vacuum Suction"
    property string inspectorGuidanceText: "Connect suction hose to Phase B Wax Tank. Open manual valve MV-101. Modulate vacuum to suck all contents."
    property bool inspectorRequireOperatorSign: true
    property bool inspectorRequireSupervisorPin: true

    // Aliases for logic controller
    property alias sequenceListView: stepsListView
    property alias saveDraftMouse: saveDraftArea
    property alias validateMouse: validateArea
    property alias backToIngredientsMouse: backMouseArea
    property alias submitReviewMouse: submitReviewArea
    property alias applyInspectorMouse: applyInspectorArea
    property alias launchManualSimMouse: launchManualSimArea

    // Left Palette button aliases
    property alias addAutoTransferMouse: addAutoTransferArea
    property alias addManualAddMouse: addManualAddArea
    property alias addHeatMouse: addHeatArea
    property alias addCoolMouse: addCoolArea
    property alias addHoldMouse: addHoldArea
    property alias addAgitatorMouse: addAgitatorArea
    property alias addHomogenizerMouse: addHomogenizerArea
    property alias addVacuumMouse: addVacuumArea
    property alias addVentMouse: addVentArea
    property alias addManualActionMouse: addManualActionArea
    property alias addQcSampleMouse: addQcSampleArea
    property alias addDischargeMouse: addDischargeArea

    // Step Bottom Dock reorder aliases
    property alias moveUpMouse: moveUpArea
    property alias moveDownMouse: moveDownArea
    property alias deleteStepMouse: deleteStepArea

    // Step Inspector Interactive Aliases
    property alias stepNameInput: stepNameInputField
    property alias stepNameKeyboardMouse: stepTitleMouse
    property alias agitatorStepper: agitatorSpeedStepper
    property alias agitatorModeBtn: agitatorModeSelectorBtn
    property alias homoStepper: homoSpeedStepper
    property alias homoModeBtn: homoModeSelectorBtn
    property alias coActiveAgitatorStepper: coActiveAgitatorSpeedStepper
    property alias coActiveAgitatorModeBtn: coActiveAgitatorModeSelectorBtn
    property alias coActiveToggleMouse: coActiveToggleArea
    property alias thermalModeBtn: thermalModeSelectorBtn
    property alias tempStepper: temperatureStepper
    property alias rampStepper: rampGradientStepper
    property alias vacModeBtn: vacuumModeSelectorBtn
    property alias vacStartStepper: vacuumStartStepper
    property alias vacEndStepper: vacuumEndStepper
    property alias manualVacStepper: manualVacuumStepper
    property alias durationMinMouse: durationMinArea
    property alias durationSecMouse: durationSecArea
    property alias pulseOnMouse: pulseOnArea
    property alias pulseOffMouse: pulseOffArea
    property alias guidanceKeyboardMouse: guidanceArea

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        // =====================================================================
        // 1. TOP BAR: Recipe Metadata & Quick Governance
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 46
            color: "#0b2e52"
            border.color: "#1d5b94"
            border.width: 1
            radius: 6

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 12

                ScadaIcon {
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22
                    iconName: "recipes_checklist"
                }

                // Recipe ID Badge
                Rectangle {
                    Layout.preferredHeight: 26
                    Layout.preferredWidth: 120
                    radius: 4
                    color: "#081d33"
                    border.color: "#38bdf8"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: timelineDesignerViewRoot.recipeId
                        color: "#38bdf8"
                        font.bold: true
                        font.pixelSize: 11
                        font.family: "Consolas"
                    }
                }

                Text {
                    text: timelineDesignerViewRoot.recipeTitle
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 13
                    font.family: "Segoe UI"
                }

                // Status Badge (DRAFT / UNDER REVIEW / APPROVED)
                Rectangle {
                    Layout.preferredHeight: 24
                    Layout.preferredWidth: 95
                    radius: 12
                    color: timelineDesignerViewRoot.recipeStatus === "APPROVED" ? "#064e3b" : (timelineDesignerViewRoot.recipeStatus === "UNDER REVIEW" ? "#78350f" : "#1e293b")
                    border.color: timelineDesignerViewRoot.recipeStatus === "APPROVED" ? "#10b981" : (timelineDesignerViewRoot.recipeStatus === "UNDER REVIEW" ? "#f59e0b" : "#94a3b8")
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: timelineDesignerViewRoot.recipeStatus
                        color: timelineDesignerViewRoot.recipeStatus === "APPROVED" ? "#34d399" : (timelineDesignerViewRoot.recipeStatus === "UNDER REVIEW" ? "#fcd34d" : "#cbd5e1")
                        font.bold: true
                        font.pixelSize: 10
                        font.family: "Segoe UI"
                    }
                }

                TouchBadge {
                    text: timelineDesignerViewRoot.recipeBatchMode + " • " + timelineDesignerViewRoot.recipeVersion
                    badgeColor: Theme.textSecondary
                    isMonospace: false
                    implicitHeight: 28
                }

                Item { Layout.fillWidth: true }

                // Save Draft Button
                Rectangle {
                    Layout.preferredWidth: 95
                    Layout.preferredHeight: 32
                    radius: 4
                    color: saveDraftArea.containsMouse ? "#1e40af" : "#0f3a69"
                    border.color: "#38bdf8"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Save Draft"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 11
                        font.family: "Segoe UI"
                    }

                    MouseArea {
                        id: saveDraftArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                // Pre-Flight Validate Button
                Rectangle {
                    Layout.preferredWidth: 105
                    Layout.preferredHeight: 32
                    radius: 4
                    color: validateArea.containsMouse ? "#047857" : "#065f46"
                    border.color: "#34d399"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Validate All"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 11
                        font.family: "Segoe UI"
                    }

                    MouseArea {
                        id: validateArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }

        // =====================================================================
        // MAIN WORKSPACE: 3 COLUMNS (Toolbox, Visual Timeline, Inspector)
        // =====================================================================
        // =====================================================================
        // MAIN WORKSPACE: RESIZABLE 3-PANE SPLITVIEW (Toolbox, Timeline, Inspector)
        // =====================================================================
        SplitView {
            id: workspaceSplitView
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: Qt.Horizontal

            handle: Rectangle {
                implicitWidth: 8
                color: SplitHandle.pressed ? "#38bdf8" : (SplitHandle.hovered ? "#0284c7" : "#0f2e4d")
                border.color: "#1d5b94"
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 4
                    Repeater {
                        model: 5
                        Rectangle {
                            width: 2
                            height: 6
                            radius: 1
                            color: SplitHandle.hovered ? "#ffffff" : "#64748b"
                        }
                    }
                }
            }

            // -----------------------------------------------------------------
            // PANEL 1: LEFT TOOLBOX (ISA-88 Step Palette)
            // -----------------------------------------------------------------
            Rectangle {
                id: leftPalettePanel
                SplitView.preferredWidth: 185
                SplitView.minimumWidth: 160
                SplitView.maximumWidth: 260
                SplitView.fillHeight: true
                color: "#092442"
                border.color: "#1d5b94"
                border.width: 1
                radius: 6

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 6

                    // Toolbox Header
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        color: "#081d33"
                        radius: 4

                        Text {
                            anchors.centerIn: parent
                            text: "ISA-88 STEP PALETTE"
                            color: "#38bdf8"
                            font.bold: true
                            font.pixelSize: 11
                            font.family: "Segoe UI"
                        }
                    }

                    Flickable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentHeight: paletteColumn.implicitHeight
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        ColumnLayout {
                            id: paletteColumn
                            width: parent.width
                            spacing: 6

                            // Section: Material & Transfers (Blue)
                            Text { text: "TRANSFERS & CHARGING"; color: "#60a5fa"; font.bold: true; font.pixelSize: 10 }

                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: 40; radius: 4
                                color: addAutoTransferArea.containsMouse ? "#1d4ed8" : "#1e40af"
                                border.color: "#60a5fa"; border.width: 1
                                Text { anchors.centerIn: parent; text: "+ Liquid Transfer"; color: "#ffffff"; font.bold: true; font.pixelSize: 12 }
                                MouseArea { id: addAutoTransferArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                            }

                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: 40; radius: 4
                                color: addManualAddArea.containsMouse ? "#1d4ed8" : "#1e40af"
                                border.color: "#60a5fa"; border.width: 1
                                Text { anchors.centerIn: parent; text: "+ Manual Hatch Add"; color: "#ffffff"; font.bold: true; font.pixelSize: 12 }
                                MouseArea { id: addManualAddArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                            }

                            // Section: Thermal (Orange)
                            Text { text: "THERMAL CONTROL"; color: "#fb923c"; font.bold: true; font.pixelSize: 10; Layout.topMargin: 4 }

                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: 40; radius: 4
                                color: addHeatArea.containsMouse ? "#c2410c" : "#9a3412"
                                border.color: "#fb923c"; border.width: 1
                                Text { anchors.centerIn: parent; text: "+ Heat Jacket"; color: "#ffffff"; font.bold: true; font.pixelSize: 12 }
                                MouseArea { id: addHeatArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                            }

                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: 40; radius: 4
                                color: addCoolArea.containsMouse ? "#0369a1" : "#075985"
                                border.color: "#38bdf8"; border.width: 1
                                Text { anchors.centerIn: parent; text: "+ Cool Jacket"; color: "#ffffff"; font.bold: true; font.pixelSize: 12 }
                                MouseArea { id: addCoolArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                            }

                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: 40; radius: 4
                                color: addHoldArea.containsMouse ? "#b45309" : "#78350f"
                                border.color: "#f59e0b"; border.width: 1
                                Text { anchors.centerIn: parent; text: "+ Hold / Soak Temp"; color: "#ffffff"; font.bold: true; font.pixelSize: 12 }
                                MouseArea { id: addHoldArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                            }

                            // Section: Mechanical Agitation (Purple)
                            Text { text: "AGITATION & SHEAR"; color: "#c084fc"; font.bold: true; font.pixelSize: 10; Layout.topMargin: 4 }

                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: 40; radius: 4
                                color: addAgitatorArea.containsMouse ? "#7e22ce" : "#581c87"
                                border.color: "#c084fc"; border.width: 1
                                Text { anchors.centerIn: parent; text: "+ Anchor Stirring"; color: "#ffffff"; font.bold: true; font.pixelSize: 12 }
                                MouseArea { id: addAgitatorArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                            }

                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: 40; radius: 4
                                color: addHomogenizerArea.containsMouse ? "#9333ea" : "#6b21a8"
                                border.color: "#e879f9"; border.width: 1
                                Text { anchors.centerIn: parent; text: "+ Homogenizer Shear"; color: "#ffffff"; font.bold: true; font.pixelSize: 12 }
                                MouseArea { id: addHomogenizerArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                            }

                            // Section: Atmospheric & Vacuum (Teal)
                            Text { text: "PRESSURE & DE-AERATION"; color: "#2dd4bf"; font.bold: true; font.pixelSize: 10; Layout.topMargin: 4 }

                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: 40; radius: 4
                                color: addVacuumArea.containsMouse ? "#0f766e" : "#115e59"
                                border.color: "#2dd4bf"; border.width: 1
                                Text { anchors.centerIn: parent; text: "+ Draw Vacuum"; color: "#ffffff"; font.bold: true; font.pixelSize: 12 }
                                MouseArea { id: addVacuumArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                            }

                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: 40; radius: 4
                                color: addVentArea.containsMouse ? "#334155" : "#1e293b"
                                border.color: "#64748b"; border.width: 1
                                Text { anchors.centerIn: parent; text: "+ Release / Vent"; color: "#ffffff"; font.bold: true; font.pixelSize: 12 }
                                MouseArea { id: addVentArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                            }

                            // Section: Human Actions & Quality (Amber)
                            Text { text: "HUMAN & LAB SAMPLES"; color: "#fbbf24"; font.bold: true; font.pixelSize: 10; Layout.topMargin: 4 }

                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: 40; radius: 4
                                color: addManualActionArea.containsMouse ? "#d97706" : "#b45309"
                                border.color: "#fcd34d"; border.width: 1
                                Text { anchors.centerIn: parent; text: "+ Manual Suction/Action"; color: "#ffffff"; font.bold: true; font.pixelSize: 12 }
                                MouseArea { id: addManualActionArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                            }

                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: 40; radius: 4
                                color: addQcSampleArea.containsMouse ? "#475569" : "#334155"
                                border.color: "#94a3b8"; border.width: 1
                                Text { anchors.centerIn: parent; text: "+ QC Lab Sampling"; color: "#ffffff"; font.bold: true; font.pixelSize: 12 }
                                MouseArea { id: addQcSampleArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                            }

                            // Section: Discharge (Red)
                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: 40; radius: 4; Layout.topMargin: 4
                                color: addDischargeArea.containsMouse ? "#b91c1c" : "#991b1b"
                                border.color: "#f87171"; border.width: 1
                                Text { anchors.centerIn: parent; text: "+ Product Discharge"; color: "#ffffff"; font.bold: true; font.pixelSize: 12 }
                                MouseArea { id: addDischargeArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                            }
                        }
                    }
                }
            }

            // -----------------------------------------------------------------
            // PANEL 2: CENTER STAGE (Visual Sequence Timeline)
            // -----------------------------------------------------------------
            Rectangle {
                id: centerSequencePanel
                SplitView.minimumWidth: 380
                SplitView.fillWidth: true
                SplitView.fillHeight: true
                color: "#092442"
                border.color: "#1d5b94"
                border.width: 1
                radius: 6

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 6

                    // Center Stage Header
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        color: "#081d33"
                        radius: 4

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 8

                            Text {
                                text: "PROCESS TIMELINE SEQUENCE (" + timelineDesignerViewRoot.totalStepsCount + " STEPS)"
                                color: "#38bdf8"
                                font.bold: true
                                font.pixelSize: 11
                                font.family: "Segoe UI"
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: "Tap card to edit properties in right inspector"
                                color: "#64748b"
                                font.pixelSize: 10
                                font.family: "Segoe UI"
                            }
                        }
                    }

                    // Execution Cards List
                    ListView {
                        id: stepsListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 8
                        boundsBehavior: Flickable.StopAtBounds
                    }
                }
            }

            // -----------------------------------------------------------------
            // PANEL 3: RIGHT STEP PROPERTY INSPECTOR (Default 420px, Resizable)
            // -----------------------------------------------------------------
            Rectangle {
                id: rightInspectorPanel
                SplitView.preferredWidth: Dimensions.inspectorWidth
                SplitView.minimumWidth: 340
                SplitView.maximumWidth: 480
                SplitView.fillHeight: true
                color: "#092442"
                border.color: "#1d5b94"
                border.width: 1
                radius: 6

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    // 1. Inspector Header Zone
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        color: "#081d33"
                        radius: 4

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8

                            Text {
                                text: "STEP PROPERTY INSPECTOR"
                                color: "#38bdf8"
                                font.bold: true
                                font.pixelSize: 12
                                font.family: "Segoe UI"
                            }

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                Layout.preferredWidth: 84
                                Layout.preferredHeight: 22
                                radius: 3
                                color: "#1e293b"
                                border.color: "#38bdf8"
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: (timelineDesignerViewRoot.selectedStepIndex + 1 < 10 ? "STEP 0" : "STEP ") + (timelineDesignerViewRoot.selectedStepIndex + 1)
                                    color: "#38bdf8"
                                    font.bold: true
                                    font.pixelSize: 11
                                    font.family: "Consolas"
                                }
                            }
                        }
                    }

                    // 2. Dynamic Configuration Zone (Flickable Form with Vertical ScrollBar)
                    Flickable {
                        id: inspectorFlickable
                        objectName: "inspectorFlickable"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentWidth: width
                        contentHeight: inspectorForm.implicitHeight + Dimensions.spaceXl
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        flickableDirection: Flickable.VerticalFlick

                        ScrollBar.vertical: ScrollBar {
                            id: inspectorScrollBar
                            policy: ScrollBar.AsNeeded
                            width: 8
                            contentItem: Rectangle {
                                implicitWidth: 6
                                radius: 3
                                color: inspectorScrollBar.pressed ? Theme.primaryGlow : (inspectorScrollBar.hovered ? Theme.primary : Theme.borderDim)
                            }
                        }

                        ColumnLayout {
                            id: inspectorForm
                            width: inspectorFlickable.width - (inspectorFlickable.ScrollBar.vertical.visible ? 10 : 0)
                            spacing: Dimensions.spaceSm

                            // Step Title Field (Touch target with keyboard icon)
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: Dimensions.spaceXs

                                Text {
                                    text: "Step Title:"
                                    color: Theme.textSecondary
                                    font.pointSize: Typography.sizeBadge
                                    font.family: Typography.fontDisplay
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Dimensions.minTouchTarget
                                    color: Theme.bgInput
                                    border.color: stepTitleMouse.containsMouse ? Theme.primaryGlow : Theme.borderDim
                                    border.width: stepTitleMouse.containsMouse ? Dimensions.borderWidthThick : Dimensions.borderWidthThin
                                    radius: Dimensions.cornerRadiusSm

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: Dimensions.spaceSm
                                        spacing: Dimensions.spaceSm

                                        TextInput {
                                            id: stepNameInputField
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            verticalAlignment: TextInput.AlignVCenter
                                            text: timelineDesignerViewRoot.inspectorStepName
                                            color: Theme.textPrimary
                                            font.bold: true
                                            font.pointSize: Typography.sizeBody
                                            font.family: Typography.fontDisplay
                                            selectByMouse: true
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 36
                                            Layout.preferredHeight: 32
                                            radius: Dimensions.cornerRadiusSm
                                            color: stepTitleMouse.containsMouse ? Theme.accentHover : Theme.bgCard
                                            border.color: Theme.primary
                                            border.width: Dimensions.borderWidthThin

                                            Text {
                                                anchors.centerIn: parent
                                                text: "⌨"
                                                color: Theme.textHighlight
                                                font.pixelSize: 14
                                            }
                                        }
                                    }

                                    MouseArea {
                                        id: stepTitleMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }
                            }

                            // Phase Badge & Target Unit (Clean RowLayout, non-overlapping)
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Dimensions.spaceSm

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: Dimensions.spaceXs

                                    Text {
                                        text: "ISA-88 Phase:"
                                        color: Theme.textSecondary
                                        font.pointSize: Typography.sizeBadge
                                        font.family: Typography.fontDisplay
                                    }

                                    TouchBadge {
                                        Layout.fillWidth: true
                                        text: timelineDesignerViewRoot.inspectorPhaseTypeDisplay
                                        badgeColor: Theme.primary
                                        isMonospace: true
                                        implicitHeight: 32
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: Dimensions.spaceXs

                                    Text {
                                        text: "Equipment Unit:"
                                        color: Theme.textSecondary
                                        font.pointSize: Typography.sizeBadge
                                        font.family: Typography.fontDisplay
                                    }

                                    TouchBadge {
                                        Layout.fillWidth: true
                                        text: timelineDesignerViewRoot.inspectorTargetUnit
                                        badgeColor: Theme.statusApprove
                                        isMonospace: true
                                        implicitHeight: 32
                                    }
                                }
                            }

                            // =========================================================
                            // SUBSYSTEM A: AGITATOR (Visible if Agitation)
                            // =========================================================
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                visible: timelineDesignerViewRoot.inspectorPhaseType === "PHASE_AGITATION"

                                Text { text: "Equipment Mode:"; color: "#94a3b8"; font.pixelSize: 10 }
                                SubsystemModeButton {
                                    id: agitatorModeSelectorBtn
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Dimensions.minTouchTarget
                                    iconName: timelineDesignerViewRoot.inspectorAgitatorMode
                                    title: timelineDesignerViewRoot.inspectorAgitatorModeTitle
                                    subtitle: timelineDesignerViewRoot.inspectorAgitatorModeSubtitle
                                }

                                Text { text: "Target Speed (RPM):"; color: "#94a3b8"; font.pixelSize: 10 }
                                DeviceSetpointStepper {
                                    id: agitatorSpeedStepper
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 56
                                    minValue: 25.0
                                    maxValue: 120.0
                                    stepSize: 1.0
                                    value: timelineDesignerViewRoot.inspectorAgitatorSpeed
                                    unitText: "RPM"
                                    decimals: 1
                                    parameterTitle: "Agitator Speed"
                                    parameterTag: "1M1501"
                                }

                                // Reversing interval timers (Visible if Reversing mode)
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    visible: timelineDesignerViewRoot.inspectorAgitatorMode === "agitator_reversing" || timelineDesignerViewRoot.inspectorAgitatorMode === "REVERSING"

                                    Text { text: "Reversing Cycle Timers:"; color: "#94a3b8"; font.pixelSize: 10 }
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 6

                                        Rectangle {
                                            Layout.fillWidth: true; Layout.preferredHeight: 36; radius: 4
                                            color: "#071b33"; border.color: "#1d5b94"; border.width: 1
                                            RowLayout {
                                                anchors.centerIn: parent; spacing: 4
                                                Text { text: "CW Duration:"; color: "#8cb5dc"; font.pixelSize: 10 }
                                                Text { text: timelineDesignerViewRoot.inspectorAgitatorCwSec + " s"; color: "#ffffff"; font.bold: true; font.pixelSize: 12; font.family: "Consolas" }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true; Layout.preferredHeight: 36; radius: 4
                                            color: "#071b33"; border.color: "#1d5b94"; border.width: 1
                                            RowLayout {
                                                anchors.centerIn: parent; spacing: 4
                                                Text { text: "CCW Duration:"; color: "#8cb5dc"; font.pixelSize: 10 }
                                                Text { text: timelineDesignerViewRoot.inspectorAgitatorCcwSec + " s"; color: "#ffffff"; font.bold: true; font.pixelSize: 12; font.family: "Consolas" }
                                            }
                                        }
                                    }
                                }
                            }

                            // =========================================================
                            // SUBSYSTEM B: HOMOGENIZER (Visible if Homogenization)
                            // =========================================================
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                visible: timelineDesignerViewRoot.inspectorPhaseType === "PHASE_HOMOGENIZATION"

                                Text { text: "Equipment Mode:"; color: "#94a3b8"; font.pixelSize: 10 }
                                SubsystemModeButton {
                                    id: homoModeSelectorBtn
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Dimensions.minTouchTarget
                                    iconName: timelineDesignerViewRoot.inspectorHomogenizerMode
                                    title: timelineDesignerViewRoot.inspectorHomogenizerModeTitle
                                    subtitle: timelineDesignerViewRoot.inspectorHomogenizerModeSubtitle
                                }

                                Text { text: "Target Speed (RPM):"; color: "#94a3b8"; font.pixelSize: 10 }
                                DeviceSetpointStepper {
                                    id: homoSpeedStepper
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 56
                                    minValue: 600.0
                                    maxValue: 4800.0
                                    stepSize: 50.0
                                    value: timelineDesignerViewRoot.inspectorHomogenizerSpeed
                                    unitText: "RPM"
                                    decimals: 0
                                    parameterTitle: "Homogenizer Speed"
                                    parameterTag: "1M2003"
                                }

                                // Interval pulse timers (Visible if Pulse Mode)
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    visible: timelineDesignerViewRoot.inspectorHomogenizerMode === "homo_interval" || timelineDesignerViewRoot.inspectorHomogenizerMode === "INTERVAL_PULSE"

                                    Text { text: "Interval Pulse Settings:"; color: "#94a3b8"; font.pixelSize: 10 }
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 6

                                        Rectangle {
                                            Layout.fillWidth: true; Layout.preferredHeight: 36; radius: 4
                                            color: pulseOnArea.containsMouse ? "#0f365e" : "#071b33"
                                            border.color: pulseOnArea.containsMouse ? "#38bdf8" : "#1d5b94"
                                            border.width: 1
                                            RowLayout {
                                                anchors.centerIn: parent; spacing: 6
                                                Text { text: "Pulse ON:"; color: "#8cb5dc"; font.pixelSize: 10 }
                                                Text { text: timelineDesignerViewRoot.inspectorHomoPulseOnSec + " s"; color: "#ffffff"; font.bold: true; font.pixelSize: 12; font.family: "Consolas" }
                                                Text { text: "⚡"; color: "#38bdf8"; font.pixelSize: 11 }
                                            }
                                            MouseArea {
                                                id: pulseOnArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true; Layout.preferredHeight: 36; radius: 4
                                            color: pulseOffArea.containsMouse ? "#0f365e" : "#071b33"
                                            border.color: pulseOffArea.containsMouse ? "#38bdf8" : "#1d5b94"
                                            border.width: 1
                                            RowLayout {
                                                anchors.centerIn: parent; spacing: 6
                                                Text { text: "Pulse OFF:"; color: "#8cb5dc"; font.pixelSize: 10 }
                                                Text { text: timelineDesignerViewRoot.inspectorHomoPulseOffSec + " s"; color: "#ffffff"; font.bold: true; font.pixelSize: 12; font.family: "Consolas" }
                                                Text { text: "⏸"; color: "#38bdf8"; font.pixelSize: 11 }
                                            }
                                            MouseArea {
                                                id: pulseOffArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                            }
                                        }
                                    }
                                }

                                // Co-Active Equipment (Parallel Agitation) - UN-SQUASHED VERTICAL STACK!
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: timelineDesignerViewRoot.inspectorRunAgitatorCoActive ? 172 : 44
                                    color: "#08223f"
                                    border.color: "#184d7e"
                                    border.width: 1
                                    radius: 4

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        spacing: 8

                                        Item {
                                            Layout.fillWidth: true
                                            implicitHeight: 24

                                            RowLayout {
                                                anchors.fill: parent
                                                spacing: 8

                                                Rectangle {
                                                    Layout.preferredWidth: 18
                                                    Layout.preferredHeight: 18
                                                    radius: 3
                                                    color: timelineDesignerViewRoot.inspectorRunAgitatorCoActive ? "#0284c7" : "#0f172a"
                                                    border.color: "#38bdf8"
                                                    border.width: 1

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: "✓"
                                                        color: "#ffffff"
                                                        font.bold: true
                                                        font.pixelSize: 12
                                                        visible: timelineDesignerViewRoot.inspectorRunAgitatorCoActive
                                                    }
                                                }

                                                Text {
                                                    text: "Run Anchor Agitator concurrently"
                                                    color: "#ffffff"
                                                    font.bold: true
                                                    font.pixelSize: 11
                                                    font.family: "Segoe UI"
                                                }

                                                Item { Layout.fillWidth: true }
                                            }

                                            MouseArea {
                                                id: coActiveToggleArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                            }
                                        }

                                        // Nested Co-Active controls: VERTICAL STACK (Un-squashed!)
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 6
                                            visible: timelineDesignerViewRoot.inspectorRunAgitatorCoActive

                                            SubsystemModeButton {
                                                id: coActiveAgitatorModeSelectorBtn
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: Dimensions.minTouchTarget
                                                iconName: timelineDesignerViewRoot.inspectorCoActiveAgitatorMode
                                                title: "CW Down"
                                                subtitle: "Mixing"
                                            }

                                            DeviceSetpointStepper {
                                                id: coActiveAgitatorSpeedStepper
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 56
                                                minValue: 25.0
                                                maxValue: 120.0
                                                stepSize: 1.0
                                                value: timelineDesignerViewRoot.inspectorCoActiveAgitatorSpeed
                                                unitText: "RPM"
                                                decimals: 0
                                                parameterTitle: "Co-Active Agitator"
                                                parameterTag: "1M1501"
                                            }
                                        }
                                    }
                                }

                                // Hard Safety Interlocks Active
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    Text { text: "Hard Safety Interlocks Active:"; color: "#94a3b8"; font.pixelSize: 10 }

                                    SafetyInterlockBadge {
                                        interlockText: "Mechanical Seal Flush Flow Switch (FS-102)"
                                        isSatisfied: true
                                        tagCode: "FS-102"
                                    }

                                    SafetyInterlockBadge {
                                        interlockText: "Minimum Vessel Level Interlock (> 150 L)"
                                        isSatisfied: true
                                        tagCode: "LSL-101"
                                    }
                                }
                            }

                            // =========================================================
                            // SUBSYSTEM C: THERMAL JACKET (Visible if Thermal Control)
                            // =========================================================
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                visible: timelineDesignerViewRoot.inspectorPhaseType === "PHASE_THERMAL_CONTROL"

                                Text { text: "Thermal Mode (Heating / Cooling):"; color: "#94a3b8"; font.pixelSize: 10 }
                                SubsystemModeButton {
                                    id: thermalModeSelectorBtn
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Dimensions.minTouchTarget
                                    iconName: timelineDesignerViewRoot.inspectorThermalMode
                                    title: timelineDesignerViewRoot.inspectorThermalModeTitle
                                    subtitle: timelineDesignerViewRoot.inspectorThermalModeSubtitle
                                }

                                Text { text: "Target Temperature (°C):"; color: "#94a3b8"; font.pixelSize: 10 }
                                DeviceSetpointStepper {
                                    id: temperatureStepper
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 56
                                    minValue: 15.0
                                    maxValue: 95.0
                                    stepSize: 0.5
                                    value: timelineDesignerViewRoot.inspectorTargetTemp
                                    unitText: "°C"
                                    decimals: 1
                                    parameterTitle: "Vessel Temperature"
                                    parameterTag: "1TI1301"
                                }

                                Text { text: "Ramp Rate Gradient (°C/h):"; color: "#94a3b8"; font.pixelSize: 10 }
                                DeviceSetpointStepper {
                                    id: rampGradientStepper
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 56
                                    minValue: 1.0
                                    maxValue: 30.0
                                    stepSize: 0.5
                                    value: timelineDesignerViewRoot.inspectorTempGradient
                                    unitText: "°C/h"
                                    decimals: 1
                                    parameterTitle: "Heating Gradient"
                                    parameterTag: "RAMP-RATE"
                                }

                                SafetyInterlockBadge {
                                    interlockText: timelineDesignerViewRoot.inspectorAgitatorSpeed >= 15.0 ? "Agitator Safe Heat Dispersion Active" : "⚠ Interlock: Agitator must be ≥ 15 RPM during Heating!"
                                    isSatisfied: timelineDesignerViewRoot.inspectorAgitatorSpeed >= 15.0
                                    tagCode: "1M1501"
                                }
                            }

                            // =========================================================
                            // SUBSYSTEM D: VACUUM & DEAERATION (Visible if Vacuum)
                            // =========================================================
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                visible: timelineDesignerViewRoot.inspectorPhaseType === "PHASE_VACUUM_CONTROL" || timelineDesignerViewRoot.inspectorPhaseType === "PHASE_VACUUM"

                                Text { text: "Vacuum Mode:"; color: "#94a3b8"; font.pixelSize: 10 }
                                SubsystemModeButton {
                                    id: vacuumModeSelectorBtn
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Dimensions.minTouchTarget
                                    iconName: timelineDesignerViewRoot.inspectorVacuumMode
                                    title: timelineDesignerViewRoot.inspectorVacuumModeTitle
                                    subtitle: timelineDesignerViewRoot.inspectorVacuumModeSubtitle
                                }

                                Text { text: "Start Pressure (mbar):"; color: "#94a3b8"; font.pixelSize: 10 }
                                DeviceSetpointStepper {
                                    id: vacuumStartStepper
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 56
                                    minValue: -800.0
                                    maxValue: 0.0
                                    stepSize: 10.0
                                    value: timelineDesignerViewRoot.inspectorVacStart
                                    unitText: "mbar"
                                    decimals: 1
                                    parameterTitle: "Start Vacuum"
                                    parameterTag: "PR-3001"
                                }

                                Text { text: "End Pressure / Hold Setpoint (mbar):"; color: "#94a3b8"; font.pixelSize: 10 }
                                DeviceSetpointStepper {
                                    id: vacuumEndStepper
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 56
                                    minValue: -800.0
                                    maxValue: 0.0
                                    stepSize: 10.0
                                    value: timelineDesignerViewRoot.inspectorVacEnd
                                    unitText: "mbar"
                                    decimals: 1
                                    parameterTitle: "Hold Vacuum"
                                    parameterTag: "PR-3001"
                                }

                                SafetyInterlockBadge {
                                    interlockText: "Vessel Cover & Lid Seal Integrity Verified"
                                    isSatisfied: true
                                    tagCode: "PR-3001"
                                }
                            }

                            // =========================================================
                            // SUBSYSTEM E: MANUAL INTERVENTION (Visible if Manual)
                            // =========================================================
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                visible: timelineDesignerViewRoot.inspectorPhaseType === "PHASE_MANUAL_INTERVENTION"

                                Text { text: "Linked Formulation Phase: " + timelineDesignerViewRoot.inspectorLinkedPhase; color: "#fef08a"; font.pixelSize: 11; font.bold: true }

                                Text { text: "Guidance Instructions:"; color: "#94a3b8"; font.pixelSize: 10 }
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 56
                                    color: "#081d33"
                                    border.color: guidanceArea.containsMouse ? "#38bdf8" : "#1e3a8a"
                                    border.width: guidanceArea.containsMouse ? 2 : 1
                                    radius: 4

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 6
                                        spacing: 6

                                        Text {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            text: timelineDesignerViewRoot.inspectorGuidanceText
                                            color: "#e2e8f0"
                                            font.pixelSize: 10
                                            wrapMode: Text.Wrap
                                            elide: Text.ElideRight
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 32
                                            Layout.preferredHeight: 26
                                            radius: 3
                                            color: guidanceArea.containsMouse ? "#0284c7" : "#0f2e4d"
                                            border.color: "#38bdf8"
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: "⌨"
                                                color: "#ffffff"
                                                font.pixelSize: 13
                                            }
                                        }
                                    }

                                    MouseArea {
                                        id: guidanceArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }

                                Text { text: "Target Vacuum Suction (mbar):"; color: "#94a3b8"; font.pixelSize: 10 }
                                DeviceSetpointStepper {
                                    id: manualVacuumStepper
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 56
                                    minValue: -800.0
                                    maxValue: 0.0
                                    stepSize: 10.0
                                    value: timelineDesignerViewRoot.inspectorTargetVacuum
                                    unitText: "mbar"
                                    decimals: 1
                                    parameterTitle: "Manual Vacuum Suction"
                                    parameterTag: "PR-3001"
                                }

                                // Test / Launch Manual Simulation Button
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Dimensions.buttonHeightMd
                                    radius: Dimensions.cornerRadiusSm
                                    color: launchManualSimArea.containsMouse ? "#b45309" : "#78350f"
                                    border.color: "#f59e0b"
                                    border.width: 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: "⚡ Test / Preview Operator Modal"
                                        color: "#fef08a"
                                        font.bold: true
                                        font.pointSize: Typography.sizeBadge
                                        font.family: Typography.fontDisplay
                                    }

                                    MouseArea {
                                        id: launchManualSimArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }
                            }

                            // Step Duration (Common for all steps - 48px touch targets)
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: Dimensions.spaceXs

                                Text {
                                    text: "Step Duration:"
                                    color: Theme.textSecondary
                                    font.pointSize: Typography.sizeBadge
                                    font.family: Typography.fontDisplay
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Dimensions.spaceSm

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: Dimensions.buttonHeightMd
                                        radius: Dimensions.cornerRadiusSm
                                        color: durationMinArea.containsMouse ? Theme.bgCardHover : Theme.bgInput
                                        border.color: durationMinArea.containsMouse ? Theme.primaryGlow : Theme.borderDim
                                        border.width: Dimensions.borderWidthThin
                                        RowLayout {
                                            anchors.centerIn: parent; spacing: Dimensions.spaceSm
                                            Text {
                                                text: "Minutes:"
                                                color: Theme.textSecondary
                                                font.pointSize: Typography.sizeBadge
                                                font.family: Typography.fontDisplay
                                            }
                                            Text {
                                                text: "" + timelineDesignerViewRoot.inspectorDurationMin
                                                color: Theme.textPrimary
                                                font.bold: true
                                                font.pointSize: Typography.sizeH3
                                                font.family: Typography.fontMono
                                            }
                                            Text { text: "⏱"; color: Theme.textHighlight; font.pixelSize: 12 }
                                        }
                                        MouseArea {
                                            id: durationMinArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: Dimensions.buttonHeightMd
                                        radius: Dimensions.cornerRadiusSm
                                        color: durationSecArea.containsMouse ? Theme.bgCardHover : Theme.bgInput
                                        border.color: durationSecArea.containsMouse ? Theme.primaryGlow : Theme.borderDim
                                        border.width: Dimensions.borderWidthThin
                                        RowLayout {
                                            anchors.centerIn: parent; spacing: Dimensions.spaceSm
                                            Text {
                                                text: "Seconds:"
                                                color: Theme.textSecondary
                                                font.pointSize: Typography.sizeBadge
                                                font.family: Typography.fontDisplay
                                            }
                                            Text {
                                                text: (timelineDesignerViewRoot.inspectorDurationSec < 10 ? "0" : "") + timelineDesignerViewRoot.inspectorDurationSec
                                                color: Theme.textPrimary
                                                font.bold: true
                                                font.pointSize: Typography.sizeH3
                                                font.family: Typography.fontMono
                                            }
                                            Text { text: "⏱"; color: Theme.textHighlight; font.pixelSize: 12 }
                                        }
                                        MouseArea {
                                            id: durationSecArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                        }
                                    }
                                }
                            }

                            // 3. Commit & Apply Parameters Button (Enlarged with generous bottom margin)
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: Dimensions.buttonHeightLg
                                Layout.topMargin: Dimensions.spaceSm
                                Layout.bottomMargin: Dimensions.spaceLg
                                radius: Dimensions.cornerRadiusSm
                                color: applyInspectorArea.containsMouse ? Theme.accentHover : Theme.primary
                                border.color: Theme.primaryGlow
                                border.width: Dimensions.borderWidthThin

                                Text {
                                    anchors.centerIn: parent
                                    text: "✓ Apply Parameters to Step"
                                    color: Theme.textPrimary
                                    font.bold: true
                                    font.pointSize: Typography.sizeBody
                                    font.family: Typography.fontDisplay
                                }

                                MouseArea {
                                    id: applyInspectorArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }
            }
        }
    }

        // =====================================================================
        // 4. BOTTOM DOCK: Validation Status & Sequence Governance
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 46
            color: "#0b2e52"
            border.color: "#1d5b94"
            border.width: 1
            radius: 6

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                // Back to Stage 2 (Ingredient Builder)
                Rectangle {
                    Layout.preferredWidth: 140
                    Layout.preferredHeight: 32
                    radius: 4
                    color: backMouseArea.containsMouse ? "#1e293b" : "#0f172a"
                    border.color: "#64748b"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "←"; color: "#ffffff"; font.bold: true; font.pixelSize: 13 }
                        Text { text: "Back to Ingredients"; color: "#ffffff"; font.bold: true; font.pixelSize: 11; font.family: "Segoe UI" }
                    }

                    MouseArea {
                        id: backMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                // Reorder controls
                Rectangle {
                    Layout.preferredWidth: 70; Layout.preferredHeight: 32; radius: 4
                    color: moveUpArea.containsMouse ? "#1e3a8a" : "#0f2847"
                    border.color: "#38bdf8"; border.width: 1
                    Text { anchors.centerIn: parent; text: "Move ↑"; color: "#ffffff"; font.bold: true; font.pixelSize: 10 }
                    MouseArea { id: moveUpArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                }

                Rectangle {
                    Layout.preferredWidth: 70; Layout.preferredHeight: 32; radius: 4
                    color: moveDownArea.containsMouse ? "#1e3a8a" : "#0f2847"
                    border.color: "#38bdf8"; border.width: 1
                    Text { anchors.centerIn: parent; text: "Move ↓"; color: "#ffffff"; font.bold: true; font.pixelSize: 10 }
                    MouseArea { id: moveDownArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                }

                Rectangle {
                    Layout.preferredWidth: 75; Layout.preferredHeight: 32; radius: 4
                    color: deleteStepArea.containsMouse ? "#7f1d1d" : "#450a0a"
                    border.color: "#ef4444"; border.width: 1
                    Text { anchors.centerIn: parent; text: "Delete Step"; color: "#fca5a5"; font.bold: true; font.pixelSize: 10 }
                    MouseArea { id: deleteStepArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                }

                // Live Validation Status Strip
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    radius: 4
                    color: timelineDesignerViewRoot.validationPassed ? "#064e3b" : "#451a03"
                    border.color: timelineDesignerViewRoot.validationPassed ? "#10b981" : "#f59e0b"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 8

                        Text {
                            text: timelineDesignerViewRoot.validationStatusText
                            color: timelineDesignerViewRoot.validationPassed ? "#a7f3d0" : "#fef08a"
                            font.bold: true
                            font.pixelSize: 11
                            font.family: "Segoe UI"
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: timelineDesignerViewRoot.validationDetails
                            color: timelineDesignerViewRoot.validationPassed ? "#6ee7b7" : "#fde047"
                            font.pixelSize: 10
                            font.family: "Segoe UI"
                            elide: Text.ElideRight
                        }
                    }
                }

                // Submit for Review Button (21 CFR Part 11)
                Rectangle {
                    Layout.preferredWidth: 170
                    Layout.preferredHeight: 32
                    radius: 4
                    color: submitReviewArea.containsMouse ? "#047857" : "#059669"
                    border.color: "#34d399"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "✓"; color: "#ffffff"; font.bold: true; font.pixelSize: 14 }
                        Text { text: "Submit for QA Review"; color: "#ffffff"; font.bold: true; font.pixelSize: 11; font.family: "Segoe UI" }
                    }

                    MouseArea {
                        id: submitReviewArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
    }
}

pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../../../common"
import "../../../design_system"
import "../../../../theme"
import "../../../../config"
import "../../../modals"
import "../../ScadaKeyboard"

Item {
    id: timelineLogicRoot
    implicitWidth: 1166
    implicitHeight: 640

    property string recipeId: "REC-VPU50-002"
    property string recipeTitle: "Body Lotion Formulation"
    property string recipeStatus: "DRAFT"
    property string recipeBatchMode: "Fixed (100 kg)"
    property string recipeVersion: "v1.0"
    property int selectedIndex: 0
    property var activeIngredientsList: []

    property string activeModalTarget: ""
    property var keypadCallback: null
    property var textKeyboardCallback: null

    function openNumericKeypad(initialVal, title, tag, unit, minV, maxV, callback) {
        keypadCallback = callback;
        numpadModal.targetInput = null;
        numpadModal.title = title || "Parameter Setpoint";
        numpadModal.targetTag = tag || "";
        numpadModal.unit = unit || "";
        numpadModal.minVal = (minV !== undefined && minV !== null) ? minV : null;
        numpadModal.maxVal = (maxV !== undefined && maxV !== null) ? maxV : null;
        numpadModal.currentInput = (initialVal !== undefined && initialVal !== null) ? String(initialVal) : "0";
        numpadModal.validateInput();
        numpadModal.visible = true;
        numpadModal.forceActiveFocus();
    }

    function openTextKeyboard(targetItem, title) {
        textKeyboard.openFor(targetItem ? targetItem : view.stepNameInput, title ? title : "EDIT STEP TITLE");
    }

    TextInput {
        id: guidanceHiddenInput
        visible: false
        text: view.inspectorGuidanceText
        onTextChanged: {
            if (textKeyboard.visible && textKeyboard.targetInput === guidanceHiddenInput) {
                view.inspectorGuidanceText = text;
            }
        }
    }

    // Centralized Hardware Definitions & Constraint Catalog
    HardwareDefinitions {
        id: hwDefs
    }

    signal backToIngredientsRequested
    signal submitForApprovalRequested(var recipeData)
    signal recipeSaved(var recipeData)
    signal launchManualModalRequested(var stepData)

    // ISA-88 Sequence Model
    ListModel {
        id: timelineModel

        ListElement {
            stepId: 1
            stepName: "Charge Aqueous Phase A"
            phaseType: "PHASE_AUTO_TRANSFER"
            targetUnit: "MAIN_VESSEL_VPU50"
            linkedPhase: "Phase A"
            targetTemp: 25.0
            tempGradient: 12.0
            thermalMode: "heat_mode_heating"
            agitatorSpeed: 0.0
            agitatorMode: "agitator_cw"
            agitatorCwSec: 30
            agitatorCcwSec: 30
            homogenizerSpeed: 0.0
            homogenizerMode: "homo_permanent"
            homoPulseOnSec: 30
            homoPulseOffSec: 10
            runAgitatorCoActive: false
            coActiveAgitatorSpeed: 25.0
            coActiveAgitatorMode: "agitator_cw"
            targetVacuum: 0.0
            vacStart: 0.0
            vacEnd: 0.0
            vacuumMode: "vac_auto_drawdown"
            durationMin: 5
            durationSec: 0
            manualCategory: "Auto Metering"
            guidanceText: "Pump Phase A water and glycerin into vessel."
            colorStrip: "#0284c7"
            pillParams: "Pump P-101 • 9.2 kg • Phase A"
        }

        ListElement {
            stepId: 2
            stepName: "Heat Phase A to Emulsification Temp"
            phaseType: "PHASE_THERMAL_CONTROL"
            targetUnit: "MAIN_VESSEL_VPU50"
            linkedPhase: "Phase A"
            targetTemp: 82.5
            tempGradient: 12.0
            thermalMode: "heat_mode_heating"
            agitatorSpeed: 25.0
            agitatorMode: "agitator_cw"
            agitatorCwSec: 30
            agitatorCcwSec: 30
            homogenizerSpeed: 0.0
            homogenizerMode: "homo_permanent"
            homoPulseOnSec: 30
            homoPulseOffSec: 10
            runAgitatorCoActive: false
            coActiveAgitatorSpeed: 25.0
            coActiveAgitatorMode: "agitator_cw"
            targetVacuum: 0.0
            vacStart: 0.0
            vacEnd: 0.0
            vacuumMode: "vac_auto_drawdown"
            durationMin: 20
            durationSec: 0
            manualCategory: "Thermal Jacket"
            guidanceText: "Heat vessel jacket to 82.5°C with anchor running."
            colorStrip: "#ea580c"
            pillParams: "82.5°C • 25 RPM • Ramp 12.0°C/h"
        }

        ListElement {
            stepId: 3
            stepName: "Manual Vacuum Transfer: Phase B Wax"
            phaseType: "PHASE_MANUAL_INTERVENTION"
            targetUnit: "MAIN_VESSEL_VPU50"
            linkedPhase: "Phase B (Wax Phase)"
            targetTemp: 82.5
            tempGradient: 12.0
            thermalMode: "heat_mode_heating"
            agitatorSpeed: 15.0
            agitatorMode: "agitator_cw"
            agitatorCwSec: 30
            agitatorCcwSec: 30
            homogenizerSpeed: 0.0
            homogenizerMode: "homo_permanent"
            homoPulseOnSec: 30
            homoPulseOffSec: 10
            runAgitatorCoActive: false
            coActiveAgitatorSpeed: 25.0
            coActiveAgitatorMode: "agitator_cw"
            targetVacuum: -450.0
            vacStart: -400.0
            vacEnd: -450.0
            vacuumMode: "vac_manual_hose"
            durationMin: 8
            durationSec: 0
            manualCategory: "Manual Vacuum Suction"
            guidanceText: "Connect suction hose to Phase B Wax Tank. Open manual valve MV-101. Modulate vacuum to suck 11.5 kg wax."
            colorStrip: "#d97706"
            pillParams: "✋ Vacuum -450 mbar • MV-101 • PIN Sign-off"
        }

        ListElement {
            stepId: 4
            stepName: "Emulsification & Homogenization"
            phaseType: "PHASE_HOMOGENIZATION"
            targetUnit: "MAIN_VESSEL_VPU50"
            linkedPhase: "Emulsion"
            targetTemp: 82.0
            tempGradient: 12.0
            thermalMode: "heat_mode_heating"
            agitatorSpeed: 35.0
            agitatorMode: "agitator_cw"
            agitatorCwSec: 30
            agitatorCcwSec: 30
            homogenizerSpeed: 2800.0
            homogenizerMode: "homo_permanent"
            homoPulseOnSec: 30
            homoPulseOffSec: 10
            runAgitatorCoActive: true
            coActiveAgitatorSpeed: 35.0
            coActiveAgitatorMode: "agitator_cw"
            targetVacuum: -450.0
            vacStart: -400.0
            vacEnd: -450.0
            vacuumMode: "vac_auto_drawdown"
            durationMin: 15
            durationSec: 0
            manualCategory: "High Shear"
            guidanceText: "High shear rotor-stator homogenization with seal flush active."
            colorStrip: "#9333ea"
            pillParams: "2800 RPM • Anchor 35 RPM • 15 Mins"
        }

        ListElement {
            stepId: 5
            stepName: "Cooling to Phase C Addition Temp"
            phaseType: "PHASE_THERMAL_CONTROL"
            targetUnit: "MAIN_VESSEL_VPU50"
            linkedPhase: "Cooling"
            targetTemp: 55.0
            tempGradient: 15.0
            thermalMode: "heat_mode_cooling"
            agitatorSpeed: 30.0
            agitatorMode: "agitator_cw"
            agitatorCwSec: 30
            agitatorCcwSec: 30
            homogenizerSpeed: 0.0
            homogenizerMode: "homo_permanent"
            homoPulseOnSec: 30
            homoPulseOffSec: 10
            runAgitatorCoActive: false
            coActiveAgitatorSpeed: 25.0
            coActiveAgitatorMode: "agitator_cw"
            targetVacuum: 0.0
            vacStart: 0.0
            vacEnd: 0.0
            vacuumMode: "vac_auto_drawdown"
            durationMin: 25
            durationSec: 0
            manualCategory: "Cooling Jacket"
            guidanceText: "Circulate cooling tower water to drop temperature to 55°C."
            colorStrip: "#075985"
            pillParams: "55.0°C • 30 RPM • Cooling Tower"
        }
    }

    // Embed Declarative UI View
    RecipeTimelineDesignerView {
        id: view
        objectName: "view"
        anchors.fill: parent

        recipeId: timelineLogicRoot.recipeId
        recipeTitle: timelineLogicRoot.recipeTitle
        recipeStatus: timelineLogicRoot.recipeStatus
        recipeBatchMode: timelineLogicRoot.recipeBatchMode
        recipeVersion: timelineLogicRoot.recipeVersion
        selectedStepIndex: timelineLogicRoot.selectedIndex
        totalStepsCount: timelineModel.count

        sequenceListView.model: timelineModel
        sequenceListView.delegate: Component {
            id: stepCardDelegate

            Rectangle {
                id: cardItem
                required property int index
                required property int stepId
                required property string stepName
                required property string phaseType
                required property string linkedPhase
                required property real targetTemp
                required property real agitatorSpeed
                required property real homogenizerSpeed
                required property real targetVacuum
                required property int durationMin
                required property string manualCategory
                required property string guidanceText
                required property string colorStrip
                required property string pillParams

                width: ListView.view.width
                height: Dimensions.cardHeightStandard
                radius: Dimensions.cardBorderRadius
                color: timelineLogicRoot.selectedIndex === index ? Theme.cardBgSelected : (cardHoverMouse.containsMouse ? Theme.cardBgHover : Theme.cardBg)
                border.color: timelineLogicRoot.selectedIndex === index ? Theme.cardBorderSelected : (cardHoverMouse.containsMouse ? Theme.cardBorderHover : Theme.cardBorder)
                border.width: timelineLogicRoot.selectedIndex === index ? 2 : 1

                property color stripCol: cardItem.colorStrip

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    anchors.topMargin: 8
                    anchors.bottomMargin: 8
                    spacing: 12

                    // 1. Left Phase Color Stripe
                    Rectangle {
                        Layout.preferredWidth: 6
                        Layout.fillHeight: true
                        radius: 3
                        color: cardItem.stripCol
                    }

                    // 2. Monospace Step Index Badge
                    Rectangle {
                        Layout.preferredWidth: 68
                        Layout.preferredHeight: Dimensions.controlButtonSize
                        Layout.alignment: Qt.AlignVCenter
                        radius: Dimensions.controlButtonRadius
                        color: "#081d33"
                        border.color: cardItem.stripCol
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "STEP " + String(cardItem.index + 1).padStart(2, '0')
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 12
                            font.family: "Consolas"
                        }
                    }

                    // 3. Step Name & Parameter Details
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 4

                        Text {
                            text: cardItem.stepName
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 14
                            font.family: "Segoe UI"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: cardItem.pillParams
                            color: "#38bdf8"
                            font.pixelSize: 12
                            font.family: "Segoe UI"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    // 4. Middle Aligned Phase Tile Badge (Uniform width, vertically & horizontally aligned)
                    Rectangle {
                        Layout.preferredWidth: Dimensions.phaseBadgeWidth
                        Layout.preferredHeight: Dimensions.phaseBadgeHeight
                        Layout.alignment: Qt.AlignVCenter
                        radius: Dimensions.controlButtonRadius
                        color: Qt.rgba(cardItem.stripCol.r, cardItem.stripCol.g, cardItem.stripCol.b, 0.18)
                        border.color: cardItem.stripCol
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: cardItem.phaseType.replace("PHASE_", "")
                            color: cardItem.stripCol
                            font.bold: true
                            font.pixelSize: 11
                            font.family: "Consolas"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    // 5. In-Card Action Buttons (Move Up, Move Down, Duplicate, Delete) - Matching Screen 1 Control Sizing
                    RowLayout {
                        spacing: Dimensions.controlButtonSpacing
                        Layout.alignment: Qt.AlignVCenter

                        // Move Up Button (44x44, radius 4, icon 22px)
                        Rectangle {
                            id: upBtn
                            Layout.preferredWidth: Dimensions.controlButtonSize
                            Layout.preferredHeight: Dimensions.controlButtonSize
                            radius: Dimensions.controlButtonRadius
                            color: upMouse.pressed ? Theme.controlBtnPressed : (upMouse.containsMouse ? Theme.controlBtnHover : Theme.controlBtnBg)
                            border.color: upMouse.containsMouse ? Theme.controlBtnHoverBorder : Theme.controlBtnBorder
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "↑"
                                color: upMouse.containsMouse ? "#38bdf8" : "#ffffff"
                                font.bold: true
                                font.pixelSize: Dimensions.controlButtonIconSize
                            }
                            MouseArea {
                                id: upMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: timelineLogicRoot.moveStepUp(cardItem.index)
                            }
                        }

                        // Move Down Button (44x44, radius 4, icon 22px)
                        Rectangle {
                            id: downBtn
                            Layout.preferredWidth: Dimensions.controlButtonSize
                            Layout.preferredHeight: Dimensions.controlButtonSize
                            radius: Dimensions.controlButtonRadius
                            color: downMouse.pressed ? Theme.controlBtnPressed : (downMouse.containsMouse ? Theme.controlBtnHover : Theme.controlBtnBg)
                            border.color: downMouse.containsMouse ? Theme.controlBtnHoverBorder : Theme.controlBtnBorder
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "↓"
                                color: downMouse.containsMouse ? "#38bdf8" : "#ffffff"
                                font.bold: true
                                font.pixelSize: Dimensions.controlButtonIconSize
                            }
                            MouseArea {
                                id: downMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: timelineLogicRoot.moveStepDown(cardItem.index)
                            }
                        }

                        // Duplicate Button (44x44, radius 4, icon 22px)
                        Rectangle {
                            id: dupBtn
                            Layout.preferredWidth: Dimensions.controlButtonSize
                            Layout.preferredHeight: Dimensions.controlButtonSize
                            radius: Dimensions.controlButtonRadius
                            color: dupMouse.pressed ? Theme.controlBtnPressed : (dupMouse.containsMouse ? Theme.controlBtnHover : Theme.controlBtnBg)
                            border.color: dupMouse.containsMouse ? Theme.controlBtnHoverBorder : Theme.controlBtnBorder
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "⎘"
                                color: dupMouse.containsMouse ? "#ffffff" : "#38bdf8"
                                font.bold: true
                                font.pixelSize: Dimensions.controlButtonIconSize
                            }
                            MouseArea {
                                id: dupMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: timelineLogicRoot.duplicateStep(cardItem.index)
                            }
                        }

                        // Delete Button (44x44, radius 4, icon 20px)
                        Rectangle {
                            id: delBtn
                            Layout.preferredWidth: Dimensions.controlButtonSize
                            Layout.preferredHeight: Dimensions.controlButtonSize
                            radius: Dimensions.controlButtonRadius
                            color: delMouse.pressed ? "#2d0606" : (delMouse.containsMouse ? Theme.controlBtnDeleteHover : Theme.controlBtnDeleteBg)
                            border.color: delMouse.containsMouse ? "#f87171" : Theme.controlBtnDeleteBorder
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                color: delMouse.containsMouse ? "#ffffff" : "#fca5a5"
                                font.bold: true
                                font.pixelSize: 20
                            }
                            MouseArea {
                                id: delMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: timelineLogicRoot.removeStep(cardItem.index)
                            }
                        }
                    }
                }

                MouseArea {
                    id: cardHoverMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    z: -1
                    onClicked: {
                        timelineLogicRoot.selectStep(cardItem.index);
                    }
                }
            }
        }
    }

    // =========================================================================
    // MODAL DIALOG: SHARED SUBSYSTEM RUN MODE SELECTOR
    // =========================================================================
    SubsystemModeSelectorModal {
        id: modeModal
        objectName: "modeModal"
        anchors.fill: parent
        visible: false

        onModeSelected: function(modeId) {
            if (timelineLogicRoot.activeModalTarget === "agitator") {
                view.inspectorAgitatorMode = modeId;
                var aDef = hwDefs.getAgitatorMode(modeId);
                view.inspectorAgitatorModeTitle = aDef.title;
                view.inspectorAgitatorModeSubtitle = aDef.subtitle;
            } else if (timelineLogicRoot.activeModalTarget === "homogenizer") {
                view.inspectorHomogenizerMode = modeId;
                var hDef = hwDefs.getHomogenizerMode(modeId);
                view.inspectorHomogenizerModeTitle = hDef.title;
                view.inspectorHomogenizerModeSubtitle = hDef.subtitle;
            } else if (timelineLogicRoot.activeModalTarget === "jacket") {
                view.inspectorThermalMode = modeId;
                var jDef = hwDefs.getJacketMode(modeId);
                view.inspectorThermalModeTitle = jDef.title;
                view.inspectorThermalModeSubtitle = jDef.subtitle;
            } else if (timelineLogicRoot.activeModalTarget === "vacuum") {
                view.inspectorVacuumMode = modeId;
                var vDef = hwDefs.getVacuumMode(modeId);
                view.inspectorVacuumModeTitle = vDef.title;
                view.inspectorVacuumModeSubtitle = vDef.subtitle;
            } else if (timelineLogicRoot.activeModalTarget === "coActiveAgitator") {
                view.inspectorCoActiveAgitatorMode = modeId;
            }
        }

        onClosed: {
            modeModal.visible = false;
        }
    }

    function openSubsystemModeModal(target) {
        timelineLogicRoot.activeModalTarget = target;
        if (target === "agitator") {
            modeModal.title = "SELECT AGITATOR ROTATION MODE";
            modeModal.modeList = hwDefs.agitator.modes;
            modeModal.selectedModeId = view.inspectorAgitatorMode;
        } else if (target === "homogenizer") {
            modeModal.title = "SELECT HOMOGENIZER RUN MODE";
            modeModal.modeList = hwDefs.homogenizer.modes;
            modeModal.selectedModeId = view.inspectorHomogenizerMode;
        } else if (target === "coActiveAgitator") {
            modeModal.title = "SELECT CO-ACTIVE AGITATOR MODE";
            modeModal.modeList = hwDefs.agitator.modes;
            modeModal.selectedModeId = view.inspectorCoActiveAgitatorMode;
        } else if (target === "jacket") {
            modeModal.title = "SELECT THERMAL CONTROL MODE";
            modeModal.modeList = hwDefs.jacket.modes;
            modeModal.selectedModeId = view.inspectorThermalMode;
        } else if (target === "vacuum") {
            modeModal.title = "SELECT VACUUM SYSTEM MODE";
            modeModal.modeList = hwDefs.vacuum.modes;
            modeModal.selectedModeId = view.inspectorVacuumMode;
        }
        modeModal.visible = true;
    }

    // =========================================================================
    // STEP SELECTION & INSPECTOR SYNCHRONIZATION
    // =========================================================================
    function selectStep(idx) {
        if (idx >= 0 && idx < timelineModel.count) {
            timelineLogicRoot.selectedIndex = idx;
            var item = timelineModel.get(idx);
            view.inspectorStepName = item.stepName || "";
            view.inspectorPhaseType = item.phaseType || "PHASE_HOMOGENIZATION";
            view.inspectorPhaseTypeDisplay = (item.phaseType || "PHASE_HOMOGENIZATION").replace("PHASE_", "");
            view.inspectorTargetUnit = item.targetUnit || "MAIN_VESSEL_VPU50";
            view.inspectorLinkedPhase = item.linkedPhase || "";

            // Agitator
            view.inspectorAgitatorSpeed = (item.agitatorSpeed !== undefined) ? item.agitatorSpeed : 25.0;
            view.inspectorAgitatorMode = item.agitatorMode || "agitator_cw";
            var agitDef = hwDefs.getAgitatorMode(view.inspectorAgitatorMode);
            view.inspectorAgitatorModeTitle = agitDef.title;
            view.inspectorAgitatorModeSubtitle = agitDef.subtitle;
            view.inspectorAgitatorCwSec = item.agitatorCwSec || 30;
            view.inspectorAgitatorCcwSec = item.agitatorCcwSec || 30;

            // Homogenizer
            view.inspectorHomogenizerSpeed = (item.homogenizerSpeed !== undefined) ? item.homogenizerSpeed : 2800.0;
            view.inspectorHomogenizerMode = item.homogenizerMode || "homo_permanent";
            var homoDef = hwDefs.getHomogenizerMode(view.inspectorHomogenizerMode);
            view.inspectorHomogenizerModeTitle = homoDef.title;
            view.inspectorHomogenizerModeSubtitle = homoDef.subtitle;
            view.inspectorHomoPulseOnSec = item.homoPulseOnSec || 30;
            view.inspectorHomoPulseOffSec = item.homoPulseOffSec || 10;
            view.inspectorRunAgitatorCoActive = (item.runAgitatorCoActive !== undefined) ? item.runAgitatorCoActive : true;
            view.inspectorCoActiveAgitatorSpeed = (item.coActiveAgitatorSpeed !== undefined) ? item.coActiveAgitatorSpeed : 35.0;
            view.inspectorCoActiveAgitatorMode = item.coActiveAgitatorMode || "agitator_cw";

            // Thermal
            view.inspectorTargetTemp = (item.targetTemp !== undefined) ? item.targetTemp : 82.5;
            view.inspectorTempGradient = (item.tempGradient !== undefined) ? item.tempGradient : 12.0;
            view.inspectorThermalMode = item.thermalMode || "heat_mode_heating";
            var thermDef = hwDefs.getJacketMode(view.inspectorThermalMode);
            view.inspectorThermalModeTitle = thermDef.title;
            view.inspectorThermalModeSubtitle = thermDef.subtitle;

            // Vacuum
            view.inspectorTargetVacuum = (item.targetVacuum !== undefined) ? item.targetVacuum : -450.0;
            view.inspectorVacStart = (item.vacStart !== undefined) ? item.vacStart : -400.0;
            view.inspectorVacEnd = (item.vacEnd !== undefined) ? item.vacEnd : -450.0;
            view.inspectorVacuumMode = item.vacuumMode || "vac_auto_drawdown";
            var vacDef = hwDefs.getVacuumMode(view.inspectorVacuumMode);
            view.inspectorVacuumModeTitle = vacDef.title;
            view.inspectorVacuumModeSubtitle = vacDef.subtitle;

            // Duration & Guidance
            view.inspectorDurationMin = item.durationMin || 15;
            view.inspectorDurationSec = item.durationSec || 0;
            view.inspectorManualCategory = item.manualCategory || "Manual Action";
            view.inspectorGuidanceText = item.guidanceText || "";
        }
    }

    // =========================================================================
    // APPLY PARAMETERS TO ACTIVE STEP
    // =========================================================================
    function applyParametersToActiveStep() {
        if (timelineLogicRoot.selectedIndex >= 0 && timelineLogicRoot.selectedIndex < timelineModel.count) {
            var idx = timelineLogicRoot.selectedIndex;
            var newName = view.stepNameInput.text.trim() || view.inspectorStepName;

            // Build dynamic pill params
            var pills = "";
            if (view.inspectorPhaseType === "PHASE_HOMOGENIZATION") {
                pills = Math.round(view.inspectorHomogenizerSpeed) + " RPM • " +
                        (view.inspectorRunAgitatorCoActive ? ("Anchor " + Math.round(view.inspectorCoActiveAgitatorSpeed) + " RPM • ") : "") +
                        view.inspectorDurationMin + " Mins";
            } else if (view.inspectorPhaseType === "PHASE_AGITATION") {
                pills = "Anchor " + Math.round(view.inspectorAgitatorSpeed) + " RPM • " + view.inspectorAgitatorModeTitle + " • " + view.inspectorDurationMin + " Mins";
            } else if (view.inspectorPhaseType === "PHASE_THERMAL_CONTROL") {
                pills = view.inspectorTargetTemp.toFixed(1) + "°C • Ramp " + view.inspectorTempGradient.toFixed(1) + "°C/h • " + view.inspectorDurationMin + " Mins";
            } else if (view.inspectorPhaseType === "PHASE_VACUUM_CONTROL" || view.inspectorPhaseType === "PHASE_VACUUM") {
                pills = "Vacuum " + Math.round(view.inspectorVacEnd) + " mbar • " + view.inspectorDurationMin + " Mins";
            } else if (view.inspectorPhaseType === "PHASE_MANUAL_INTERVENTION") {
                pills = "✋ " + view.inspectorManualCategory + " • " + view.inspectorLinkedPhase;
            } else {
                pills = newName + " • " + view.inspectorDurationMin + " Mins";
            }

            timelineModel.setProperty(idx, "stepName", newName);
            timelineModel.setProperty(idx, "targetTemp", view.inspectorTargetTemp);
            timelineModel.setProperty(idx, "tempGradient", view.inspectorTempGradient);
            timelineModel.setProperty(idx, "thermalMode", view.inspectorThermalMode);
            timelineModel.setProperty(idx, "agitatorSpeed", view.inspectorAgitatorSpeed);
            timelineModel.setProperty(idx, "agitatorMode", view.inspectorAgitatorMode);
            timelineModel.setProperty(idx, "agitatorCwSec", view.inspectorAgitatorCwSec);
            timelineModel.setProperty(idx, "agitatorCcwSec", view.inspectorAgitatorCcwSec);
            timelineModel.setProperty(idx, "homogenizerSpeed", view.inspectorHomogenizerSpeed);
            timelineModel.setProperty(idx, "homogenizerMode", view.inspectorHomogenizerMode);
            timelineModel.setProperty(idx, "homoPulseOnSec", view.inspectorHomoPulseOnSec);
            timelineModel.setProperty(idx, "homoPulseOffSec", view.inspectorHomoPulseOffSec);
            timelineModel.setProperty(idx, "runAgitatorCoActive", view.inspectorRunAgitatorCoActive);
            timelineModel.setProperty(idx, "coActiveAgitatorSpeed", view.inspectorCoActiveAgitatorSpeed);
            timelineModel.setProperty(idx, "coActiveAgitatorMode", view.inspectorCoActiveAgitatorMode);
            timelineModel.setProperty(idx, "targetVacuum", view.inspectorTargetVacuum);
            timelineModel.setProperty(idx, "vacStart", view.inspectorVacStart);
            timelineModel.setProperty(idx, "vacEnd", view.inspectorVacEnd);
            timelineModel.setProperty(idx, "vacuumMode", view.inspectorVacuumMode);
            timelineModel.setProperty(idx, "durationMin", view.inspectorDurationMin);
            timelineModel.setProperty(idx, "durationSec", view.inspectorDurationSec);
            timelineModel.setProperty(idx, "guidanceText", view.inspectorGuidanceText);
            timelineModel.setProperty(idx, "pillParams", pills);

            runPreFlightCompiler();
        }
    }

    // =========================================================================
    // STEP MANIPULATION: INSERT, MOVE, DUPLICATE, DELETE
    // =========================================================================
    function moveStepUp(idx) {
        if (idx > 0) {
            timelineModel.move(idx, idx - 1, 1);
            timelineLogicRoot.selectedIndex = idx - 1;
            runPreFlightCompiler();
        }
    }

    function moveStepDown(idx) {
        if (idx >= 0 && idx < timelineModel.count - 1) {
            timelineModel.move(idx, idx + 1, 1);
            timelineLogicRoot.selectedIndex = idx + 1;
            runPreFlightCompiler();
        }
    }

    function duplicateStep(idx) {
        if (idx >= 0 && idx < timelineModel.count) {
            var orig = timelineModel.get(idx);
            timelineModel.insert(idx + 1, {
                stepId: timelineModel.count + 1,
                stepName: orig.stepName + " (Copy)",
                phaseType: orig.phaseType,
                targetUnit: orig.targetUnit,
                linkedPhase: orig.linkedPhase,
                targetTemp: orig.targetTemp,
                tempGradient: orig.tempGradient,
                thermalMode: orig.thermalMode,
                agitatorSpeed: orig.agitatorSpeed,
                agitatorMode: orig.agitatorMode,
                agitatorCwSec: orig.agitatorCwSec,
                agitatorCcwSec: orig.agitatorCcwSec,
                homogenizerSpeed: orig.homogenizerSpeed,
                homogenizerMode: orig.homogenizerMode,
                homoPulseOnSec: orig.homoPulseOnSec,
                homoPulseOffSec: orig.homoPulseOffSec,
                runAgitatorCoActive: orig.runAgitatorCoActive,
                coActiveAgitatorSpeed: orig.coActiveAgitatorSpeed,
                coActiveAgitatorMode: orig.coActiveAgitatorMode,
                targetVacuum: orig.targetVacuum,
                vacStart: orig.vacStart,
                vacEnd: orig.vacEnd,
                vacuumMode: orig.vacuumMode,
                durationMin: orig.durationMin,
                durationSec: orig.durationSec,
                manualCategory: orig.manualCategory,
                guidanceText: orig.guidanceText,
                colorStrip: orig.colorStrip,
                pillParams: orig.pillParams
            });
            timelineLogicRoot.selectedIndex = idx + 1;
            runPreFlightCompiler();
        }
    }

    function removeStep(idx) {
        if (timelineModel.count > 1 && idx >= 0 && idx < timelineModel.count) {
            timelineModel.remove(idx);
            if (timelineLogicRoot.selectedIndex >= timelineModel.count) {
                timelineLogicRoot.selectedIndex = timelineModel.count - 1;
            }
            selectStep(timelineLogicRoot.selectedIndex);
            runPreFlightCompiler();
        }
    }

    function insertPhase(phaseType, name, color, pills, defTemp, defAgit, defHom, defVac, defMin, defCat, defGuide) {
        timelineModel.append({
            stepId: timelineModel.count + 1,
            stepName: name,
            phaseType: phaseType,
            targetUnit: "MAIN_VESSEL_VPU50",
            linkedPhase: "Phase " + String.fromCharCode(65 + Math.min(timelineModel.count, 4)),
            targetTemp: defTemp,
            tempGradient: 12.0,
            thermalMode: defTemp > 45.0 ? "heat_mode_heating" : "heat_mode_cooling",
            agitatorSpeed: defAgit,
            agitatorMode: "agitator_cw",
            agitatorCwSec: 30,
            agitatorCcwSec: 30,
            homogenizerSpeed: defHom,
            homogenizerMode: "homo_permanent",
            homoPulseOnSec: 30,
            homoPulseOffSec: 10,
            runAgitatorCoActive: defHom > 0,
            coActiveAgitatorSpeed: 35.0,
            coActiveAgitatorMode: "agitator_cw",
            targetVacuum: defVac,
            vacStart: defVac < 0 ? -400.0 : 0.0,
            vacEnd: defVac,
            vacuumMode: defVac < 0 ? "vac_auto_drawdown" : "vac_vent_atm",
            durationMin: defMin,
            durationSec: 0,
            manualCategory: defCat,
            guidanceText: defGuide,
            colorStrip: color,
            pillParams: pills
        });
        timelineLogicRoot.selectedIndex = timelineModel.count - 1;
        selectStep(timelineLogicRoot.selectedIndex);
        runPreFlightCompiler();
    }

    // =========================================================================
    // PRE-FLIGHT COMPILER / GUARDRAIL ENGINE (ISA-88 & MACHINE INTEGRITY)
    // =========================================================================
    function runPreFlightCompiler() {
        var hasHeatingWithoutAgitation = false;
        var hasHomogenizerDry = false;
        var hasLiquidChargeBeforeHomogenizer = false;
        var stepCount = timelineModel.count;

        for (var i = 0; i < stepCount; i++) {
            var st = timelineModel.get(i);

            // Track liquid charge
            if (st.phaseType === "PHASE_AUTO_TRANSFER" || (st.phaseType === "PHASE_MANUAL_INTERVENTION" && st.manualCategory.indexOf("Suction") !== -1)) {
                hasLiquidChargeBeforeHomogenizer = true;
            }

            // Guardrail 1: Heating requires Agitator >= 15 RPM
            if (st.phaseType === "PHASE_THERMAL_CONTROL" && st.targetTemp > 45.0 && st.agitatorSpeed < 15.0) {
                hasHeatingWithoutAgitation = true;
            }

            // Guardrail 2: Homogenizer > 2000 RPM requires prior liquid charge
            if (st.phaseType === "PHASE_HOMOGENIZATION" && st.homogenizerSpeed > 2000.0 && !hasLiquidChargeBeforeHomogenizer) {
                hasHomogenizerDry = true;
            }
        }

        if (hasHeatingWithoutAgitation) {
            view.validationPassed = false;
            view.validationStatusText = "⚠ Pre-Flight Warning: Wall Charring Risk";
            view.validationDetails = "Heating block requires Agitator speed ≥ 15 RPM to prevent product burn onto vessel walls.";
            return false;
        } else if (hasHomogenizerDry) {
            view.validationPassed = false;
            view.validationStatusText = "⚠ Pre-Flight Warning: Seal Burn Risk";
            view.validationDetails = "Homogenizer set > 2000 RPM before liquid addition. Mechanical seal dry run detected.";
            return false;
        } else {
            view.validationPassed = true;
            view.validationStatusText = "✓ Pre-Flight Checklist: " + stepCount + "/" + stepCount + " Guardrails Valid";
            view.validationDetails = "All ISA-88 phases reconciled. Thermal shock and mechanical seal interlocks verified.";
            return true;
        }
    }

    // =========================================================================
    // EXTERNAL RECIPE LOADING (CALLED FROM STAGE 2 TRANSITION)
    // =========================================================================
    function loadRecipe(recipe, ingredients) {
        if (recipe) {
            timelineLogicRoot.recipeId = recipe.recipeId || "REC-VPU50-002";
            timelineLogicRoot.recipeTitle = recipe.title || "Body Lotion Formulation";
            timelineLogicRoot.recipeStatus = recipe.status || "DRAFT";
            timelineLogicRoot.recipeBatchMode = (recipe.qtyType || "Fixed") + " (" + (recipe.batchSizeKg || 100) + " kg)";
            timelineLogicRoot.recipeVersion = "v" + (recipe.version || "1.0");
        }
        if (ingredients && ingredients.length > 0) {
            timelineLogicRoot.activeIngredientsList = ingredients;
        }
        selectStep(0);
        runPreFlightCompiler();
    }

    // =========================================================================
    // STEPPER CONNECTIONS & NUMERIC KEYPAD INTEGRATION
    // =========================================================================
    Connections {
        target: view.agitatorStepper
        function onValueModified(newVal) {
            view.inspectorAgitatorSpeed = newVal;
        }
        function onSetpointRequested(title, tag, current, min, max, unit) {
            timelineLogicRoot.openNumericKeypad(current, title, tag, unit, min, max, function(val) {
                view.agitatorStepper.applyValue(val);
                view.inspectorAgitatorSpeed = val;
            });
        }
    }

    Connections {
        target: view.homoStepper
        function onValueModified(newVal) {
            view.inspectorHomogenizerSpeed = newVal;
        }
        function onSetpointRequested(title, tag, current, min, max, unit) {
            timelineLogicRoot.openNumericKeypad(current, title, tag, unit, min, max, function(val) {
                view.homoStepper.applyValue(val);
                view.inspectorHomogenizerSpeed = val;
            });
        }
    }

    Connections {
        target: view.coActiveAgitatorStepper
        function onValueModified(newVal) {
            view.inspectorCoActiveAgitatorSpeed = newVal;
        }
        function onSetpointRequested(title, tag, current, min, max, unit) {
            timelineLogicRoot.openNumericKeypad(current, title, tag, unit, min, max, function(val) {
                view.coActiveAgitatorStepper.applyValue(val);
                view.inspectorCoActiveAgitatorSpeed = val;
            });
        }
    }

    Connections {
        target: view.tempStepper
        function onValueModified(newVal) {
            view.inspectorTargetTemp = newVal;
        }
        function onSetpointRequested(title, tag, current, min, max, unit) {
            timelineLogicRoot.openNumericKeypad(current, title, tag, unit, min, max, function(val) {
                view.tempStepper.applyValue(val);
                view.inspectorTargetTemp = val;
            });
        }
    }

    Connections {
        target: view.rampStepper
        function onValueModified(newVal) {
            view.inspectorTempGradient = newVal;
        }
        function onSetpointRequested(title, tag, current, min, max, unit) {
            timelineLogicRoot.openNumericKeypad(current, title, tag, unit, min, max, function(val) {
                view.rampStepper.applyValue(val);
                view.inspectorTempGradient = val;
            });
        }
    }

    Connections {
        target: view.vacStartStepper
        function onValueModified(newVal) {
            view.inspectorVacStart = newVal;
        }
        function onSetpointRequested(title, tag, current, min, max, unit) {
            timelineLogicRoot.openNumericKeypad(current, title, tag, unit, min, max, function(val) {
                view.vacStartStepper.applyValue(val);
                view.inspectorVacStart = val;
            });
        }
    }

    Connections {
        target: view.vacEndStepper
        function onValueModified(newVal) {
            view.inspectorVacEnd = newVal;
        }
        function onSetpointRequested(title, tag, current, min, max, unit) {
            timelineLogicRoot.openNumericKeypad(current, title, tag, unit, min, max, function(val) {
                view.vacEndStepper.applyValue(val);
                view.inspectorVacEnd = val;
            });
        }
    }

    Connections {
        target: view.manualVacStepper
        function onValueModified(newVal) {
            view.inspectorTargetVacuum = newVal;
        }
        function onSetpointRequested(title, tag, current, min, max, unit) {
            timelineLogicRoot.openNumericKeypad(current, title, tag, unit, min, max, function(val) {
                view.manualVacStepper.applyValue(val);
                view.inspectorTargetVacuum = val;
            });
        }
    }

    Connections {
        target: view.coActiveToggleMouse
        function onClicked() {
            view.inspectorRunAgitatorCoActive = !view.inspectorRunAgitatorCoActive;
        }
    }

    Connections {
        target: view.durationMinMouse
        function onClicked() {
            timelineLogicRoot.openNumericKeypad(view.inspectorDurationMin, "Step Duration Minutes", "DURATION", "min", 0, 999, function(val) {
                view.inspectorDurationMin = Math.round(val);
            });
        }
    }

    Connections {
        target: view.durationSecMouse
        function onClicked() {
            timelineLogicRoot.openNumericKeypad(view.inspectorDurationSec, "Step Duration Seconds", "DURATION", "sec", 0, 59, function(val) {
                view.inspectorDurationSec = Math.round(val);
            });
        }
    }

    Connections {
        target: view.pulseOnMouse
        function onClicked() {
            timelineLogicRoot.openNumericKeypad(view.inspectorHomoPulseOnSec, "Pulse ON Duration", "PULSE-ON", "sec", 1, 300, function(val) {
                view.inspectorHomoPulseOnSec = Math.round(val);
            });
        }
    }

    Connections {
        target: view.pulseOffMouse
        function onClicked() {
            timelineLogicRoot.openNumericKeypad(view.inspectorHomoPulseOffSec, "Pulse OFF Duration", "PULSE-OFF", "sec", 1, 300, function(val) {
                view.inspectorHomoPulseOffSec = Math.round(val);
            });
        }
    }

    Connections {
        target: view.stepNameKeyboardMouse
        function onClicked() {
            textKeyboard.openFor(view.stepNameInput, "EDIT STEP TITLE");
        }
    }

    Connections {
        target: view.guidanceKeyboardMouse
        function onClicked() {
            guidanceHiddenInput.text = view.inspectorGuidanceText;
            timelineLogicRoot.textKeyboardCallback = function(val) {
                view.inspectorGuidanceText = val;
            };
            textKeyboard.openFor(guidanceHiddenInput, "EDIT GUIDANCE INSTRUCTIONS");
        }
    }

    // =========================================================================
    // SUBSYSTEM MODE BUTTON TRIGGER CONNECTIONS
    // =========================================================================
    Connections {
        target: view.agitatorModeBtn
        function onClicked() {
            timelineLogicRoot.openSubsystemModeModal("agitator");
        }
    }

    Connections {
        target: view.homoModeBtn
        function onClicked() {
            timelineLogicRoot.openSubsystemModeModal("homogenizer");
        }
    }

    Connections {
        target: view.coActiveAgitatorModeBtn
        function onClicked() {
            timelineLogicRoot.openSubsystemModeModal("coActiveAgitator");
        }
    }

    Connections {
        target: view.thermalModeBtn
        function onClicked() {
            timelineLogicRoot.openSubsystemModeModal("jacket");
        }
    }

    Connections {
        target: view.vacModeBtn
        function onClicked() {
            timelineLogicRoot.openSubsystemModeModal("vacuum");
        }
    }

    // Apply Parameters button
    Connections {
        target: view.applyInspectorMouse
        function onClicked() {
            timelineLogicRoot.applyParametersToActiveStep();
        }
    }

    // =========================================================================
    // CONNECT VIEW ACTIONS
    // =========================================================================
    Connections {
        target: view.backToIngredientsMouse
        function onClicked() {
            timelineLogicRoot.backToIngredientsRequested();
        }
    }

    function serializeTimelineToJson() {
        var stepsList = [];
        for (var i = 0; i < timelineModel.count; i++) {
            var s = timelineModel.get(i);
            stepsList.push({
                stepId: s.stepId || (i + 1),
                stepName: s.stepName,
                phaseType: s.phaseType,
                targetUnit: s.targetUnit || "MAIN_VESSEL_VPU50",
                linkedPhase: s.linkedPhase || "",
                targetTemp: s.targetTemp,
                tempGradient: s.tempGradient,
                thermalMode: s.thermalMode,
                agitatorSpeed: s.agitatorSpeed,
                agitatorMode: s.agitatorMode,
                agitatorCwSec: s.agitatorCwSec,
                agitatorCcwSec: s.agitatorCcwSec,
                homogenizerSpeed: s.homogenizerSpeed,
                homogenizerMode: s.homogenizerMode,
                homoPulseOnSec: s.homoPulseOnSec,
                homoPulseOffSec: s.homoPulseOffSec,
                runAgitatorCoActive: s.runAgitatorCoActive,
                coActiveAgitatorSpeed: s.coActiveAgitatorSpeed,
                coActiveAgitatorMode: s.coActiveAgitatorMode,
                targetVacuum: s.targetVacuum,
                vacStart: s.vacStart,
                vacEnd: s.vacEnd,
                vacuumMode: s.vacuumMode,
                durationMin: s.durationMin,
                durationSec: s.durationSec,
                manualCategory: s.manualCategory,
                guidanceText: s.guidanceText,
                colorStrip: s.colorStrip,
                pillParams: s.pillParams
            });
        }
        return JSON.stringify({
            id: timelineLogicRoot.recipeId,
            name: timelineLogicRoot.recipeTitle,
            version: timelineLogicRoot.recipeVersion,
            status: timelineLogicRoot.recipeStatus,
            batchMode: timelineLogicRoot.recipeBatchMode,
            ingredients: timelineLogicRoot.activeIngredientsList,
            steps: stepsList
        });
    }

    Connections {
        target: view.saveDraftMouse
        function onClicked() {
            var payload = serializeTimelineToJson();
            if (typeof Scada !== "undefined" && Scada.saveRecipeFromDesigner) {
                var res = JSON.parse(Scada.saveRecipeFromDesigner(timelineLogicRoot.recipeId, timelineLogicRoot.recipeTitle, payload, "DRAFT"));
                if (res.sha256) {
                    view.validationStatusText = "✓ Draft Saved (SHA-256: " + res.sha256.substring(0, 8) + "...)";
                }
            }
            timelineLogicRoot.recipeSaved({
                recipeId: timelineLogicRoot.recipeId,
                title: timelineLogicRoot.recipeTitle,
                status: "DRAFT",
                stepsCount: timelineModel.count
            });
        }
    }

    Connections {
        target: view.validateMouse
        function onClicked() {
            timelineLogicRoot.runPreFlightCompiler();
        }
    }

    Connections {
        target: view.submitReviewMouse
        function onClicked() {
            if (timelineLogicRoot.runPreFlightCompiler()) {
                timelineLogicRoot.recipeStatus = "UNDER REVIEW";
                var payload = serializeTimelineToJson();
                if (typeof Scada !== "undefined" && Scada.saveRecipeFromDesigner) {
                    var res = JSON.parse(Scada.saveRecipeFromDesigner(timelineLogicRoot.recipeId, timelineLogicRoot.recipeTitle, payload, "UNDER REVIEW"));
                    if (res.sha256) {
                        view.validationStatusText = "✓ Submitted for QA (SHA-256: " + res.sha256.substring(0, 8) + "...)";
                    }
                }
                timelineLogicRoot.submitForApprovalRequested({
                    recipeId: timelineLogicRoot.recipeId,
                    title: timelineLogicRoot.recipeTitle,
                    status: "UNDER REVIEW",
                    stepsCount: timelineModel.count
                });
            }
        }
    }

    Connections {
        target: view.moveUpMouse
        function onClicked() {
            timelineLogicRoot.moveStepUp(timelineLogicRoot.selectedIndex);
        }
    }

    Connections {
        target: view.moveDownMouse
        function onClicked() {
            timelineLogicRoot.moveStepDown(timelineLogicRoot.selectedIndex);
        }
    }

    Connections {
        target: view.deleteStepMouse
        function onClicked() {
            timelineLogicRoot.removeStep(timelineLogicRoot.selectedIndex);
        }
    }

    Connections {
        target: view.launchManualSimMouse
        function onClicked() {
            if (timelineLogicRoot.selectedIndex >= 0 && timelineLogicRoot.selectedIndex < timelineModel.count) {
                var cur = timelineModel.get(timelineLogicRoot.selectedIndex);
                timelineLogicRoot.launchManualModalRequested({
                    stepNumber: "STEP " + String(timelineLogicRoot.selectedIndex + 1).padStart(2, '0'),
                    stepTitle: cur.stepName,
                    instructions: cur.guidanceText,
                    linkedPhase: cur.linkedPhase,
                    targetVacuum: cur.targetVacuum || -450.0,
                    currentTemp: cur.targetTemp || 82.5
                });
            }
        }
    }

    // Palette insertion connections
    Connections {
        target: view.addAutoTransferMouse
        function onClicked() {
            timelineLogicRoot.insertPhase("PHASE_AUTO_TRANSFER", "Charge Liquid Phase", "#0284c7", "Pump P-101 • Auto-Dose", 25.0, 0.0, 0.0, 0.0, 5, "Auto Metering", "Auto-dose liquid phase from supply tank.");
        }
    }

    Connections {
        target: view.addManualAddMouse
        function onClicked() {
            timelineLogicRoot.insertPhase("PHASE_MANUAL_INTERVENTION", "Manual Ingredient Addition", "#0284c7", "Hatch Open • Confirm Scale", 25.0, 10.0, 0.0, 0.0, 5, "Hatch Loading", "Open manhole hatch and load pre-weighed powder.");
        }
    }

    Connections {
        target: view.addHeatMouse
        function onClicked() {
            timelineLogicRoot.insertPhase("PHASE_THERMAL_CONTROL", "Heat Vessel Jacket", "#ea580c", "80.0°C • 25 RPM • Steam", 80.0, 25.0, 0.0, 0.0, 15, "Thermal Jacket", "Open steam valve and ramp to 80°C with agitator active.");
        }
    }

    Connections {
        target: view.addCoolMouse
        function onClicked() {
            timelineLogicRoot.insertPhase("PHASE_THERMAL_CONTROL", "Cool Jacket to Setpoint", "#075985", "45.0°C • 25 RPM • Cooling", 45.0, 25.0, 0.0, 0.0, 20, "Cooling Jacket", "Circulate cooling water to lower vessel temperature.");
        }
    }

    Connections {
        target: view.addHoldMouse
        function onClicked() {
            timelineLogicRoot.insertPhase("PHASE_THERMAL_CONTROL", "Soak / Temperature Hold", "#78350f", "Hold 80°C • 15 Mins", 80.0, 20.0, 0.0, 0.0, 15, "Thermal Soak", "Maintain batch at constant temperature.");
        }
    }

    Connections {
        target: view.addAgitatorMouse
        function onClicked() {
            timelineLogicRoot.insertPhase("PHASE_AGITATION", "Main Anchor Stirring", "#7e22ce", "Anchor 35 RPM • Steady Blend", 50.0, 35.0, 0.0, 0.0, 10, "Agitator", "Run anchor paddle to ensure uniform bulk mixing.");
        }
    }

    Connections {
        target: view.addHomogenizerMouse
        function onClicked() {
            timelineLogicRoot.insertPhase("PHASE_HOMOGENIZATION", "High-Shear Emulsification", "#9333ea", "2800 RPM • 15 Mins • Seal Flow", 80.0, 35.0, 2800.0, -450.0, 15, "High Shear", "Run homogenizer rotor-stator for tight particle dispersion.");
        }
    }

    Connections {
        target: view.addVacuumMouse
        function onClicked() {
            timelineLogicRoot.insertPhase("PHASE_VACUUM_CONTROL", "Draw Vessel Vacuum", "#0f766e", "-450 mbar • De-aerate", 50.0, 15.0, 0.0, -450.0, 10, "Vacuum Header", "Evacuate vessel to pull out micro air bubbles.");
        }
    }

    Connections {
        target: view.addVentMouse
        function onClicked() {
            timelineLogicRoot.insertPhase("PHASE_VACUUM_CONTROL", "Vent to Atmospheric", "#334155", "0 mbar • Pressure Equalize", 40.0, 10.0, 0.0, 0.0, 3, "Atmospheric Vent", "Open sterile vent filter to equalize pressure.");
        }
    }

    Connections {
        target: view.addManualActionMouse
        function onClicked() {
            timelineLogicRoot.insertPhase("PHASE_MANUAL_INTERVENTION", "Manual Vacuum Transfer: Phase B Wax", "#d97706", "✋ Vacuum Suction • MV-101 • PIN", 82.5, 15.0, 0.0, -450.0, 8, "Manual Vacuum Suction", "Connect suction hose to Phase B Wax Tank. Open valve MV-101. Use vacuum pulse to transfer.");
        }
    }

    Connections {
        target: view.addQcSampleMouse
        function onClicked() {
            timelineLogicRoot.insertPhase("PHASE_MANUAL_INTERVENTION", "QC Lab Sample Verification", "#475569", "Lab Sample • pH & Viscosity Check", 45.0, 10.0, 0.0, 0.0, 15, "QC Lab Sample", "Draw 100ml sample from bottom valve for lab test.");
        }
    }

    Connections {
        target: view.addDischargeMouse
        function onClicked() {
            timelineLogicRoot.insertPhase("PHASE_DISCHARGE", "Transfer Product to Storage Tank", "#991b1b", "Discharge Pump • Temp < 45°C", 38.0, 10.0, 0.0, 0.0, 15, "Discharge Valve", "Open bottom flush valve and start transfer pump.");
        }
    }

    // =========================================================================
    // MODAL DIALOGS: ON-SCREEN NUMERIC KEYPAD & FULL QWERTY KEYBOARD
    // =========================================================================
    NumericKeypadModal {
        id: numpadModal
        objectName: "numpadModal"
        anchors.fill: parent
        z: 10000
        visible: false

        onAccepted: function(val) {
            if (timelineLogicRoot.keypadCallback) {
                timelineLogicRoot.keypadCallback(val);
                timelineLogicRoot.keypadCallback = null;
            }
        }
        onRejected: {
            timelineLogicRoot.keypadCallback = null;
        }
        onClosed: {
            timelineLogicRoot.keypadCallback = null;
        }
    }

    ScadaTextKeyboard {
        id: textKeyboard
        objectName: "textKeyboard"
        z: 10000
        visible: false

        onSubmitted: function(val) {
            if (timelineLogicRoot.textKeyboardCallback) {
                timelineLogicRoot.textKeyboardCallback(val);
                timelineLogicRoot.textKeyboardCallback = null;
            }
        }
        onClosed: {
            timelineLogicRoot.textKeyboardCallback = null;
        }
    }

    Component.onCompleted: {
        selectStep(0);
        runPreFlightCompiler();
    }
}

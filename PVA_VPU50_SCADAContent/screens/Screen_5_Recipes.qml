import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../config"

Item {
    id: recipesContainer
    Layout.fillWidth: true
    Layout.fillHeight: true

    ScadaConfig { id: scadaConfig }
    ScadaStateMiddleware { id: stateMiddleware }

    readonly property var stepSequence: [
        { name: "Phase A: Initial Water Charge", desc: "Fill vessel to 55% with DI water at ambient temperature", dur: 180, reqHold: false, devs: "Fill Valve (SP: 55%)" },
        { name: "Phase A: Pre-Heating & Gentle Agitation", desc: "Heat aqueous phase to 45.0°C under slow anchor stirring", dur: 240, reqHold: false, devs: "Agitator (25 RPM) | Heater (SP: 45°C)" },
        { name: "Phase A: Dissolve EDTA & Citric Acid", desc: "Manual addition of chelating and pH adjusting agents", dur: 120, reqHold: true, devs: "Agitator (45 RPM) | 21 CFR Sign-off" },
        { name: "Phase B: SLES 28% & CAPB Induction", desc: "Slowly charge primary surfactant through bottom suction port", dur: 300, reqHold: true, devs: "Agitator (20 RPM) | Vacuum (-300 mbar)" },
        { name: "Phase C: High-Shear Emulsification", desc: "High shear homogenization with speed ramping and full vacuum", dur: 480, reqHold: false, devs: "Agitator (60 RPM) | Homo (600->3600 RPM) | Vacuum (-450 mbar)" }
    ]

    Screen_5_RecipesView {
        id: ui
        anchors.fill: parent
        activeRecipeName: stateMiddleware.activeRecipeName
        activeProductName: stateMiddleware.activeProductName
    }

    Timer {
        id: executionTicker
        interval: 1000
        running: ui.isExecuting && !ui.manualOverlay.visible
        repeat: true
        onTriggered: {
            stateMiddleware.batchTimerSec += 1;
            
            if (ui.stepTimeRemaining > 0) {
                ui.stepTimeRemaining -= 1;
            } else {
                if (ui.currentStepIndex < 4) {
                    ui.currentStepIndex += 1;
                    var nextStep = stepSequence[ui.currentStepIndex];
                    if (nextStep && nextStep.reqHold) {
                        ui.manualOverlay.visible = true;
                        stateMiddleware.isManualWaiting = true;
                        stateMiddleware.confirmActive = true;
                        stateMiddleware.confirmMessage = "21 CFR Part 11 Sign-off required for " + nextStep.name;
                    } else {
                        ui.stepTimeRemaining = nextStep ? nextStep.dur : 180;
                    }
                } else {
                    ui.isExecuting = false;
                    stateMiddleware.isRecipeRunning = false;
                    stateMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "operator", "Batch Execution COMPLETED: " + stateMiddleware.activeRecipeName, "BATCH_CONTROL");
                }
            }

            var curStep = stepSequence[ui.currentStepIndex];
            stateMiddleware.updateRecipeExecution(
                ui.isExecuting,
                false,
                ui.activeRecipeName,
                ui.currentStepIndex,
                curStep ? curStep.name : "Step " + (ui.currentStepIndex + 1),
                curStep ? curStep.desc : "",
                5,
                ui.stepTimeRemaining,
                stateMiddleware.batchTimerSec,
                ui.manualOverlay.visible,
                ui.manualOverlay.visible,
                curStep ? curStep.desc : "",
                curStep ? curStep.devs : "Agitator | Homogenizer"
            );
        }
    }

    MouseArea {
        parent: ui.execTabBtn
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: ui.activeTab = "execution"
    }

    MouseArea {
        parent: ui.formTabBtn
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: ui.activeTab = "formulation"
    }

    MouseArea {
        parent: ui.toggleAutoBtn
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            ui.isExecuting = !ui.isExecuting;
            stateMiddleware.isRecipeRunning = ui.isExecuting;
            if (ui.isExecuting && ui.stepTimeRemaining <= 0) {
                ui.stepTimeRemaining = 180;
            }
            stateMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "operator", (ui.isExecuting ? "START Batch Execution: " : "PAUSE Batch Execution: ") + ui.activeRecipeName, "BATCH_CONTROL");
        }
    }

    MouseArea {
        parent: ui.manualConfirmBtn
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            ui.manualOverlay.visible = false;
            stateMiddleware.isManualWaiting = false;
            stateMiddleware.confirmActive = false;
            stateMiddleware.auditLogEmitted(new Date().toLocaleTimeString(), "operator", "21 CFR Part 11 Hold Point SIGNED & CONFIRMED for Phase " + (ui.currentStepIndex + 1), "ELECTRONIC_SIGNATURE");
            if (ui.currentStepIndex < 4) {
                ui.currentStepIndex += 1;
                var nextStep = stepSequence[ui.currentStepIndex];
                ui.stepTimeRemaining = nextStep ? nextStep.dur : 180;
            }
        }
    }
}

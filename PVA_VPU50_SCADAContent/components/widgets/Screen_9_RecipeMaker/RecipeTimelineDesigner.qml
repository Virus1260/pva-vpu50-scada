pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: timelineDesignerLogicRoot
    implicitWidth: 1166
    implicitHeight: 600

    property string recipeId: "REC-VPU50-002"
    property string recipeTitle: "Body Lotion Formulation"
    property var ingredientsList: []

    signal backToIngredientsRequested
    signal openConfigModalRequested(var config)
    signal openManualModalRequested(var config)
    signal recipeSaved(var recipePayload)
    signal recipeSubmittedForReview(var recipePayload)
    signal nodeRedExportGenerated(string jsonText)

    // In-memory data store for operations on each track and phase
    property var agitatorOps: ({
        "Phase A": { stageId: "1.1", setValue: 25.0, unit: "RPM", purpose: "Material Loading", requireConfirm: false, confirmMessage: "", durationSec: 480, stopCondition: "temp_above", materials: ["WATER (9.2 KG)", "GLYCERINE"] },
        "Phase B": { stageId: "2.1", setValue: 35.0, unit: "RPM", purpose: "Emulsification", requireConfirm: false, confirmMessage: "", durationSec: 720, stopCondition: "timer", materials: ["LIGHT LIQUID PARAFFIN", "STEARIC ACID"] },
        "Phase C": { stageId: "3.1", setValue: 45.0, unit: "RPM", purpose: "Material Loading", requireConfirm: false, confirmMessage: "", durationSec: 600, stopCondition: "timer", materials: ["SLES 70%"] },
        "Phase D": { stageId: "4.1", setValue: 20.0, unit: "RPM", purpose: "Gel Neutralization", requireConfirm: false, confirmMessage: "", durationSec: 480, stopCondition: "timer", materials: ["TRIETHANOLAMINE"] },
        "Phase E": { stageId: "5.1", setValue: 15.0, unit: "RPM", purpose: "Cooling & Actives", requireConfirm: false, confirmMessage: "", durationSec: 420, stopCondition: "timer", materials: ["DMDM HYDANTOIN"] }
    })

    property var homoOps: ({
        "Phase B": { stageId: "2.2", setValue: 2400.0, unit: "RPM", purpose: "High-Shear Emulsification", requireConfirm: false, confirmMessage: "", durationSec: 360, stopCondition: "timer", materials: [] },
        "Phase C": { stageId: "3.2", setValue: 3000.0, unit: "RPM", purpose: "Micro-Droplet Dispersion", requireConfirm: false, confirmMessage: "", durationSec: 420, stopCondition: "timer", materials: [] }
    })

    property var vacuumOps: ({
        "Phase B": { stageId: "2.3", setValue: -350.0, unit: "mbar", purpose: "De-aeration", requireConfirm: false, confirmMessage: "", durationSec: 600, stopCondition: "timer", materials: [] },
        "Phase C": { stageId: "3.3", setValue: -450.0, unit: "mbar", purpose: "Vacuum Suction & De-aeration", requireConfirm: false, confirmMessage: "", durationSec: 600, stopCondition: "timer", materials: ["SLES 70%"] }
    })

    property var thermalOps: ({
        "Phase A": { stageId: "1.2", setValue: 85.0, unit: "°C", purpose: "Aqueous Phase Heating", requireConfirm: false, confirmMessage: "", durationSec: 480, stopCondition: "temp_above", materials: [] },
        "Phase B": { stageId: "2.4", setValue: 85.0, unit: "°C", purpose: "Emulsion Temperature Soak", requireConfirm: false, confirmMessage: "", durationSec: 720, stopCondition: "timer", materials: [] },
        "Phase D": { stageId: "4.2", setValue: 50.0, unit: "°C", purpose: "Controlled Cooling", requireConfirm: false, confirmMessage: "", durationSec: 480, stopCondition: "temp_below", materials: [] },
        "Phase E": { stageId: "5.2", setValue: 40.0, unit: "°C", purpose: "Final Product Cooling", requireConfirm: false, confirmMessage: "", durationSec: 420, stopCondition: "temp_below", materials: [] }
    })

    property var valveOps: ({
        "Phase A": { stageId: "1.3", setValue: 100.0, unit: "% Open", purpose: "Water Charge", requireConfirm: false, confirmMessage: "", durationSec: 180, stopCondition: "level_above", materials: ["WATER (9.2 KG)"] }
    })

    property var manualOps: ({
        "Phase B": { stageId: "2.5", actionTarget: "Butterfly Valve abc123", actionRequired: "OPEN", confirmMessage: "Operator to confirm that valve abc123 is OPEN for Phase B oil induction.", requireConfirm: true, durationSec: 0, stopCondition: "manual" },
        "Phase E": { stageId: "5.3", actionTarget: "Sight Glass Window", actionRequired: "VERIFY", confirmMessage: "Operator visual inspection: Verify emulsion uniformity and gloss.", requireConfirm: true, durationSec: 0, stopCondition: "manual" }
    })

    property bool manualHoldEncountered: false

    function refreshTracks() {
        view.agitatorTrack.phaseAClipped = agitatorOps["Phase A"] || null;
        view.agitatorTrack.phaseBClipped = agitatorOps["Phase B"] || null;
        view.agitatorTrack.phaseCClipped = agitatorOps["Phase C"] || null;
        view.agitatorTrack.phaseDClipped = agitatorOps["Phase D"] || null;
        view.agitatorTrack.phaseEClipped = agitatorOps["Phase E"] || null;

        view.homoTrack.phaseAClipped = homoOps["Phase A"] || null;
        view.homoTrack.phaseBClipped = homoOps["Phase B"] || null;
        view.homoTrack.phaseCClipped = homoOps["Phase C"] || null;
        view.homoTrack.phaseDClipped = homoOps["Phase D"] || null;
        view.homoTrack.phaseEClipped = homoOps["Phase E"] || null;

        view.vacuumTrack.phaseAClipped = vacuumOps["Phase A"] || null;
        view.vacuumTrack.phaseBClipped = vacuumOps["Phase B"] || null;
        view.vacuumTrack.phaseCClipped = vacuumOps["Phase C"] || null;
        view.vacuumTrack.phaseDClipped = vacuumOps["Phase D"] || null;
        view.vacuumTrack.phaseEClipped = vacuumOps["Phase E"] || null;

        view.thermalTrack.phaseAClipped = thermalOps["Phase A"] || null;
        view.thermalTrack.phaseBClipped = thermalOps["Phase B"] || null;
        view.thermalTrack.phaseCClipped = thermalOps["Phase C"] || null;
        view.thermalTrack.phaseDClipped = thermalOps["Phase D"] || null;
        view.thermalTrack.phaseEClipped = thermalOps["Phase E"] || null;

        view.valveTrack.phaseAClipped = valveOps["Phase A"] || null;
        view.valveTrack.phaseBClipped = valveOps["Phase B"] || null;
        view.valveTrack.phaseCClipped = valveOps["Phase C"] || null;
        view.valveTrack.phaseDClipped = valveOps["Phase D"] || null;
        view.valveTrack.phaseEClipped = valveOps["Phase E"] || null;

        view.manualTrack.phaseAClipped = manualOps["Phase A"] || null;
        view.manualTrack.phaseBClipped = manualOps["Phase B"] || null;
        view.manualTrack.phaseCClipped = manualOps["Phase C"] || null;
        view.manualTrack.phaseDClipped = manualOps["Phase D"] || null;
        view.manualTrack.phaseEClipped = manualOps["Phase E"] || null;
    }

    Component.onCompleted: {
        refreshTracks();
        updateSimulationState();
    }

    function formatTimecode(totalSec) {
        var h = Math.floor(totalSec / 3600);
        var m = Math.floor((totalSec % 3600) / 60);
        var s = totalSec % 60;
        var hh = h < 10 ? "0" + h : "" + h;
        var mm = m < 10 ? "0" + m : "" + m;
        var ss = s < 10 ? "0" + s : "" + s;
        return hh + ":" + mm + ":" + ss;
    }

    function updateSimulationState() {
        var sec = view.currentPlayheadSec;
        view.playheadTimecode = formatTimecode(sec);

        if (sec < 480) {
            // Phase A: Aqueous Charge & Heat (0 - 480s)
            view.currentPhaseName = "Phase A";
            view.currentStageId = "1.1";
            view.pidSimulator.activePhase = "Phase A";
            view.pidSimulator.activeStage = "1.1";
            view.pidSimulator.agitatorRpm = agitatorOps["Phase A"] ? agitatorOps["Phase A"].setValue : 25.0;
            view.pidSimulator.homoRpm = 0.0;
            view.pidSimulator.vacuumMbar = 0.0;
            view.pidSimulator.vesselTemp = 25.0 + ((85.0 - 25.0) * (sec / 480.0));
            view.pidSimulator.liquidLevelPct = 45.0;
            view.pidSimulator.isHeating = true;
            view.pidSimulator.isCooling = false;
            view.pidSimulator.valveChargeOpen = (sec < 180);
            view.pidSimulator.fluidColor = "#38bdf8"; // Aqueous clear blue
        } else if (sec < 1200) {
            // Phase B: Oil Phase Emulsification (480 - 1200s)
            view.currentPhaseName = "Phase B";
            view.currentStageId = "2.1";
            view.pidSimulator.activePhase = "Phase B";
            view.pidSimulator.activeStage = "2.1";

            // Check if manual hold on Phase B needs operator prompt
            if (manualOps["Phase B"] && sec >= 480 && sec <= 520 && !manualHoldEncountered && view.isPlaying) {
                view.isPlaying = false;
                playTimer.stop();
                manualHoldEncountered = true;
                view.pidSimulator.manualHoldMessage = manualOps["Phase B"].confirmMessage;
                view.pidSimulator.manualTargetAsset = manualOps["Phase B"].actionTarget;
                view.pidSimulator.isManualHoldActive = true;
                return;
            }

            view.pidSimulator.agitatorRpm = agitatorOps["Phase B"] ? agitatorOps["Phase B"].setValue : 35.0;
            view.pidSimulator.homoRpm = homoOps["Phase B"] ? homoOps["Phase B"].setValue : 2400.0;
            view.pidSimulator.vacuumMbar = vacuumOps["Phase B"] ? vacuumOps["Phase B"].setValue : -350.0;
            view.pidSimulator.vesselTemp = 85.0;
            view.pidSimulator.liquidLevelPct = 75.0;
            view.pidSimulator.isHeating = true;
            view.pidSimulator.isCooling = false;
            view.pidSimulator.valveChargeOpen = false;
            view.pidSimulator.fluidColor = "#f8fafc"; // White lotion emulsion
        } else if (sec < 1800) {
            // Phase C: Surfactant Induction (1200 - 1800s)
            view.currentPhaseName = "Phase C";
            view.currentStageId = "3.1";
            view.pidSimulator.activePhase = "Phase C";
            view.pidSimulator.activeStage = "3.1";
            view.pidSimulator.agitatorRpm = agitatorOps["Phase C"] ? agitatorOps["Phase C"].setValue : 45.0;
            view.pidSimulator.homoRpm = homoOps["Phase C"] ? homoOps["Phase C"].setValue : 1200.0;
            view.pidSimulator.vacuumMbar = vacuumOps["Phase C"] ? vacuumOps["Phase C"].setValue : -450.0;
            view.pidSimulator.vesselTemp = 75.0;
            view.pidSimulator.liquidLevelPct = 80.0;
            view.pidSimulator.isHeating = false;
            view.pidSimulator.isCooling = false;
            view.pidSimulator.valveChargeOpen = false;
            view.pidSimulator.fluidColor = "#f1f5f9";
        } else if (sec < 2280) {
            // Phase D: Neutralization Trim (1800 - 2280s)
            view.currentPhaseName = "Phase D";
            view.currentStageId = "4.1";
            view.pidSimulator.activePhase = "Phase D";
            view.pidSimulator.activeStage = "4.1";
            view.pidSimulator.agitatorRpm = agitatorOps["Phase D"] ? agitatorOps["Phase D"].setValue : 20.0;
            view.pidSimulator.homoRpm = 0.0;
            view.pidSimulator.vacuumMbar = 0.0;
            view.pidSimulator.vesselTemp = 50.0;
            view.pidSimulator.liquidLevelPct = 82.0;
            view.pidSimulator.isHeating = false;
            view.pidSimulator.isCooling = true;
            view.pidSimulator.valveChargeOpen = false;
            view.pidSimulator.fluidColor = "#e2e8f0";
        } else {
            // Phase E: Actives & Final Cooling (2280 - 2700s)
            view.currentPhaseName = "Phase E";
            view.currentStageId = "5.1";
            view.pidSimulator.activePhase = "Phase E";
            view.pidSimulator.activeStage = "5.1";
            view.pidSimulator.agitatorRpm = agitatorOps["Phase E"] ? agitatorOps["Phase E"].setValue : 15.0;
            view.pidSimulator.homoRpm = 0.0;
            view.pidSimulator.vacuumMbar = 0.0;
            view.pidSimulator.vesselTemp = 35.0;
            view.pidSimulator.liquidLevelPct = 85.0;
            view.pidSimulator.isHeating = false;
            view.pidSimulator.isCooling = true;
            view.pidSimulator.valveChargeOpen = false;
            view.pidSimulator.fluidColor = "#ffffff";
        }
    }

    Timer {
        id: playTimer
        interval: 100
        repeat: true
        running: view.isPlaying && !view.pidSimulator.isManualHoldActive
        onTriggered: {
            if (view.currentPlayheadSec < view.totalDurationSec) {
                view.currentPlayheadSec += 5; // Advance 5s per 100ms tick
                timelineDesignerLogicRoot.updateSimulationState();
            } else {
                view.isPlaying = false;
            }
        }
    }

    function setClipConfig(config) {
        if (!config || !config.resourceType || !config.phase) return;

        var targetStore = null;
        if (config.resourceType === "agitator") targetStore = agitatorOps;
        else if (config.resourceType === "homogenizer") targetStore = homoOps;
        else if (config.resourceType === "vacuum") targetStore = vacuumOps;
        else if (config.resourceType === "heater" || config.resourceType === "cooler") targetStore = thermalOps;
        else if (config.resourceType === "fillValve" || config.resourceType === "drainValve") targetStore = valveOps;
        else if (config.resourceType === "manualActivity") targetStore = manualOps;

        if (targetStore) {
            targetStore[config.phase] = {
                stageId: config.stageId,
                setValue: config.setValue || 0,
                unit: config.unit || "",
                purpose: config.purpose || "",
                requireConfirm: config.requireConfirm || false,
                confirmMessage: config.confirmMessage || "",
                durationSec: config.durationSec || 0,
                stopCondition: config.stopCondition || "timer",
                actionTarget: config.actionTarget || "",
                actionRequired: config.actionRequired || "OPEN",
                materials: config.materials || []
            };
            refreshTracks();
            updateSimulationState();
        }
    }

    function deleteClip(trackType, phaseName) {
        var targetStore = null;
        if (trackType === "agitator") targetStore = agitatorOps;
        else if (trackType === "homogenizer") targetStore = homoOps;
        else if (trackType === "vacuum") targetStore = vacuumOps;
        else if (trackType === "heater") targetStore = thermalOps;
        else if (trackType === "fillValve") targetStore = valveOps;
        else if (trackType === "manualActivity") targetStore = manualOps;

        if (targetStore && targetStore[phaseName]) {
            delete targetStore[phaseName];
            refreshTracks();
            updateSimulationState();
        }
    }

    function generateNodeRedJson() {
        var phases = ["Phase A", "Phase B", "Phase C", "Phase D", "Phase E"];
        var stepsArray = [];

        for (var i = 0; i < phases.length; i++) {
            var pName = phases[i];
            var ops = [];

            if (agitatorOps[pName]) ops.push({ device: "agitator", tag: "1M1501", setpoint: agitatorOps[pName].setValue, unit: "RPM", durationSec: agitatorOps[pName].durationSec, hold: agitatorOps[pName].requireConfirm, msg: agitatorOps[pName].confirmMessage, materials: agitatorOps[pName].materials });
            if (homoOps[pName]) ops.push({ device: "homogenizer", tag: "1X1001", setpoint: homoOps[pName].setValue, unit: "RPM", durationSec: homoOps[pName].durationSec, hold: homoOps[pName].requireConfirm, msg: homoOps[pName].confirmMessage, materials: homoOps[pName].materials });
            if (vacuumOps[pName]) ops.push({ device: "vacuum", tag: "1M5001", setpoint: vacuumOps[pName].setValue, unit: "mbar", durationSec: vacuumOps[pName].durationSec, hold: vacuumOps[pName].requireConfirm, msg: vacuumOps[pName].confirmMessage, materials: vacuumOps[pName].materials });
            if (thermalOps[pName]) ops.push({ device: "heater", tag: "1E6001", setpoint: thermalOps[pName].setValue, unit: "°C", durationSec: thermalOps[pName].durationSec, hold: thermalOps[pName].requireConfirm, msg: thermalOps[pName].confirmMessage, materials: thermalOps[pName].materials });
            if (valveOps[pName]) ops.push({ device: "fillValve", tag: "1K1001", setpoint: valveOps[pName].setValue, unit: "% Open", durationSec: valveOps[pName].durationSec, hold: valveOps[pName].requireConfirm, msg: valveOps[pName].confirmMessage, materials: valveOps[pName].materials });
            if (manualOps[pName]) ops.push({ device: "manualActivity", target: manualOps[pName].actionTarget, action: manualOps[pName].actionRequired, hold: true, msg: manualOps[pName].confirmMessage });

            stepsArray.push({
                stepIndex: (i + 1),
                phase: pName,
                name: pName + " Process Execution",
                operations: ops
            });
        }

        var payload = {
            schemaVersion: "3.0-PLC-ISA88",
            recipeId: recipeId,
            recipeTitle: recipeTitle,
            targetPlant: "PVA Systems VPU-50",
            exportedAt: new Date().toISOString(),
            compliance: "21 CFR Part 11 / GAMP 5 Verified",
            batchSequence: stepsArray
        };

        return JSON.stringify(payload, null, 2);
    }

    RecipeTimelineDesignerView {
        id: view
        anchors.fill: parent
        recipeTitle: timelineDesignerLogicRoot.recipeTitle
        mediaBin.ingredientsList: timelineDesignerLogicRoot.ingredientsList

        // Wire media bin selection
        mediaBin.onResourceSelected: function(resData) {
            if (resData.type === "manualActivity") {
                var manConfig = {
                    stageId: "2.1",
                    phaseName: resData.phase || "Phase B",
                    actionTarget: resData.target || "Butterfly Valve abc123",
                    actionRequired: resData.req || "OPEN",
                    displayMessage: "Operator to confirm that " + (resData.target || "valve abc123") + " is " + (resData.req || "OPEN") + "."
                };
                timelineDesignerLogicRoot.openManualModalRequested(manConfig);
            } else {
                var config = {
                    stageId: "1.1",
                    phaseName: resData.phase || "Phase A",
                    resourceType: resData.type || "agitator",
                    resourceName: resData.name || "Resource",
                    unit: resData.unit || "RPM",
                    minLimit: resData.min !== undefined ? resData.min : 0.0,
                    maxLimit: resData.max !== undefined ? resData.max : 100.0,
                    setValue: resData.defVal || "25",
                    purpose: "Material Loading",
                    selectedMaterials: resData.material ? [resData.material] : [],
                    manualConfirm: false,
                    hmiMessage: "Confirm operation for " + resData.name,
                    durationSec: 180,
                    stopConditionType: "timer"
                };
                timelineDesignerLogicRoot.openConfigModalRequested(config);
            }
        }

        // Wire P&ID Simulator signals
        pidSimulator.onManualConfirmed: {
            pidSimulator.isManualHoldActive = false;
            view.isPlaying = true;
            playTimer.start();
        }

        pidSimulator.onToggleFullscreenRequested: {
            pidSimulator.isFullscreen = !pidSimulator.isFullscreen;
        }

        // Wire track triggers
        agitatorTrack.onAddClipRequested: function(phase, rType) {
            var c = { stageId: "1.1", phaseName: phase, resourceType: "agitator", resourceName: "1M1501 Agitator", unit: "RPM", minLimit: 0, maxLimit: 60, setValue: "25", purpose: "Material Loading", selectedMaterials: [], manualConfirm: false, hmiMessage: "", durationSec: 180, stopConditionType: "timer" };
            timelineDesignerLogicRoot.openConfigModalRequested(c);
        }
        agitatorTrack.onConfigureClipRequested: function(clip) {
            var c = { stageId: clip.stageId, phaseName: clip.phase || "Phase A", resourceType: "agitator", resourceName: "1M1501 Agitator", unit: "RPM", minLimit: 0, maxLimit: 60, setValue: String(clip.setValue), purpose: clip.purpose, selectedMaterials: clip.materials || [], manualConfirm: clip.requireConfirm, hmiMessage: clip.confirmMessage, durationSec: clip.durationSec, stopConditionType: clip.stopCondition };
            timelineDesignerLogicRoot.openConfigModalRequested(c);
        }
        agitatorTrack.onDeleteClipRequested: function(phase) { timelineDesignerLogicRoot.deleteClip("agitator", phase); }

        homoTrack.onAddClipRequested: function(phase, rType) {
            var c = { stageId: "2.1", phaseName: phase, resourceType: "homogenizer", resourceName: "1X1001 Homogenizer", unit: "RPM", minLimit: 0, maxLimit: 3600, setValue: "1800", purpose: "High-Shear Emulsification", selectedMaterials: [], manualConfirm: false, hmiMessage: "", durationSec: 300, stopConditionType: "timer" };
            timelineDesignerLogicRoot.openConfigModalRequested(c);
        }
        homoTrack.onConfigureClipRequested: function(clip) {
            var c = { stageId: clip.stageId, phaseName: clip.phase || "Phase B", resourceType: "homogenizer", resourceName: "1X1001 Homogenizer", unit: "RPM", minLimit: 0, maxLimit: 3600, setValue: String(clip.setValue), purpose: clip.purpose, selectedMaterials: clip.materials || [], manualConfirm: clip.requireConfirm, hmiMessage: clip.confirmMessage, durationSec: clip.durationSec, stopConditionType: clip.stopCondition };
            timelineDesignerLogicRoot.openConfigModalRequested(c);
        }
        homoTrack.onDeleteClipRequested: function(phase) { timelineDesignerLogicRoot.deleteClip("homogenizer", phase); }

        vacuumTrack.onAddClipRequested: function(phase, rType) {
            var c = { stageId: "2.2", phaseName: phase, resourceType: "vacuum", resourceName: "1M5001 Vacuum", unit: "mbar", minLimit: -900, maxLimit: 0, setValue: "-400", purpose: "De-aeration", selectedMaterials: [], manualConfirm: false, hmiMessage: "", durationSec: 300, stopConditionType: "timer" };
            timelineDesignerLogicRoot.openConfigModalRequested(c);
        }
        vacuumTrack.onConfigureClipRequested: function(clip) {
            var c = { stageId: clip.stageId, phaseName: clip.phase || "Phase B", resourceType: "vacuum", resourceName: "1M5001 Vacuum", unit: "mbar", minLimit: -900, maxLimit: 0, setValue: String(clip.setValue), purpose: clip.purpose, selectedMaterials: clip.materials || [], manualConfirm: clip.requireConfirm, hmiMessage: clip.confirmMessage, durationSec: clip.durationSec, stopConditionType: clip.stopCondition };
            timelineDesignerLogicRoot.openConfigModalRequested(c);
        }
        vacuumTrack.onDeleteClipRequested: function(phase) { timelineDesignerLogicRoot.deleteClip("vacuum", phase); }

        thermalTrack.onAddClipRequested: function(phase, rType) {
            var c = { stageId: "1.2", phaseName: phase, resourceType: "heater", resourceName: "1E6001 Thermal Jacket", unit: "°C", minLimit: 20, maxLimit: 95, setValue: "80", purpose: "Aqueous Phase Heating", selectedMaterials: [], manualConfirm: false, hmiMessage: "", durationSec: 360, stopConditionType: "temp_above" };
            timelineDesignerLogicRoot.openConfigModalRequested(c);
        }
        thermalTrack.onConfigureClipRequested: function(clip) {
            var c = { stageId: clip.stageId, phaseName: clip.phase || "Phase A", resourceType: "heater", resourceName: "1E6001 Thermal Jacket", unit: "°C", minLimit: 20, maxLimit: 95, setValue: String(clip.setValue), purpose: clip.purpose, selectedMaterials: clip.materials || [], manualConfirm: clip.requireConfirm, hmiMessage: clip.confirmMessage, durationSec: clip.durationSec, stopConditionType: clip.stopCondition };
            timelineDesignerLogicRoot.openConfigModalRequested(c);
        }
        thermalTrack.onDeleteClipRequested: function(phase) { timelineDesignerLogicRoot.deleteClip("heater", phase); }

        valveTrack.onAddClipRequested: function(phase, rType) {
            var c = { stageId: "1.3", phaseName: phase, resourceType: "fillValve", resourceName: "1K1001 Charge Valve", unit: "% Open", minLimit: 0, maxLimit: 100, setValue: "100", purpose: "Material Loading", selectedMaterials: [], manualConfirm: false, hmiMessage: "", durationSec: 180, stopConditionType: "level_above" };
            timelineDesignerLogicRoot.openConfigModalRequested(c);
        }
        valveTrack.onConfigureClipRequested: function(clip) {
            var c = { stageId: clip.stageId, phaseName: clip.phase || "Phase A", resourceType: "fillValve", resourceName: "1K1001 Charge Valve", unit: "% Open", minLimit: 0, maxLimit: 100, setValue: String(clip.setValue), purpose: clip.purpose, selectedMaterials: clip.materials || [], manualConfirm: clip.requireConfirm, hmiMessage: clip.confirmMessage, durationSec: clip.durationSec, stopConditionType: clip.stopCondition };
            timelineDesignerLogicRoot.openConfigModalRequested(c);
        }
        valveTrack.onDeleteClipRequested: function(phase) { timelineDesignerLogicRoot.deleteClip("fillValve", phase); }

        manualTrack.onAddClipRequested: function(phase, rType) {
            var mc = { stageId: "2.1", phaseName: phase, actionTarget: "Butterfly Valve abc123", actionRequired: "OPEN", displayMessage: "Operator to confirm that valve abc123 is OPEN." };
            timelineDesignerLogicRoot.openManualModalRequested(mc);
        }
        manualTrack.onConfigureClipRequested: function(clip) {
            var mc = { stageId: clip.stageId || "2.1", phaseName: clip.phase || "Phase B", actionTarget: clip.actionTarget || "Butterfly Valve abc123", actionRequired: clip.actionRequired || "OPEN", displayMessage: clip.confirmMessage || "" };
            timelineDesignerLogicRoot.openManualModalRequested(mc);
        }
        manualTrack.onDeleteClipRequested: function(phase) { timelineDesignerLogicRoot.deleteClip("manualActivity", phase); }
    }

    // Transport Control Handlers
    MouseArea {
        parent: view.playBtn
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            view.isPlaying = !view.isPlaying;
            if (view.isPlaying) {
                playTimer.start();
            } else {
                playTimer.stop();
            }
        }
    }

    MouseArea {
        parent: view.stepPrevBtn
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            view.currentPlayheadSec = Math.max(0, view.currentPlayheadSec - 480);
            timelineDesignerLogicRoot.updateSimulationState();
        }
    }

    MouseArea {
        parent: view.stepNextBtn
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            view.currentPlayheadSec = Math.min(view.totalDurationSec, view.currentPlayheadSec + 480);
            timelineDesignerLogicRoot.updateSimulationState();
        }
    }

    MouseArea {
        parent: view.resetPlayheadBtn
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            view.isPlaying = false;
            playTimer.stop();
            view.currentPlayheadSec = 0;
            timelineDesignerLogicRoot.manualHoldEncountered = false;
            view.pidSimulator.isManualHoldActive = false;
            timelineDesignerLogicRoot.updateSimulationState();
        }
    }

    Connections {
        target: view.timelineScrubber
        function onMoved() {
            view.currentPlayheadSec = Math.round(view.timelineScrubber.value);
            timelineDesignerLogicRoot.updateSimulationState();
        }
    }

    // Action button handlers
    MouseArea {
        parent: view.backToIngredientsBtn
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: timelineDesignerLogicRoot.backToIngredientsRequested()
    }

    MouseArea {
        parent: view.exportNodeRedBtn
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            var jsonText = timelineDesignerLogicRoot.generateNodeRedJson();
            timelineDesignerLogicRoot.nodeRedExportGenerated(jsonText);
        }
    }

    MouseArea {
        parent: view.submitForApprovalBtn
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            var payload = timelineDesignerLogicRoot.generateNodeRedJson();
            timelineDesignerLogicRoot.recipeSubmittedForReview(payload);
        }
    }

    MouseArea {
        parent: view.saveRecipeBtn
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            var payload = timelineDesignerLogicRoot.generateNodeRedJson();
            timelineDesignerLogicRoot.recipeSaved(payload);
        }
    }
}

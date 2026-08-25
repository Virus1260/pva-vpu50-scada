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
    signal recipeSaved(var recipePayload)
    signal recipeSubmittedForReview(var recipePayload)
    signal nodeRedExportGenerated(string jsonText)

    // In-memory data store for operations on each track and phase
    property var agitatorOps: ({
        "Phase A": { stageId: "1.1", setValue: 25.0, unit: "RPM", purpose: "Material Loading", requireConfirm: false, confirmMessage: "", durationSec: 480, stopCondition: "temp_above", materials: ["WATER (9.2 KG)", "GLYCERINE"] },
        "Phase B": { stageId: "2.1", setValue: 35.0, unit: "RPM", purpose: "Emulsification", requireConfirm: true, confirmMessage: "21 CFR Part 11: Verify Phase B added to Phase A at 85°C.", durationSec: 720, stopCondition: "timer", materials: ["LIGHT LIQUID PARAFFIN", "STEARIC ACID"] },
        "Phase C": { stageId: "3.1", setValue: 45.0, unit: "RPM", purpose: "Material Loading", requireConfirm: false, confirmMessage: "", durationSec: 600, stopCondition: "timer", materials: ["SLES 70%"] },
        "Phase D": { stageId: "4.1", setValue: 20.0, unit: "RPM", purpose: "Gel Neutralization", requireConfirm: false, confirmMessage: "", durationSec: 480, stopCondition: "timer", materials: ["TRIETHANOLAMINE"] },
        "Phase E": { stageId: "5.1", setValue: 15.0, unit: "RPM", purpose: "Cooling & Actives", requireConfirm: true, confirmMessage: "Sign-off: Confirm DMDM Hydantoin added at 40-45°C.", durationSec: 420, stopCondition: "timer", materials: ["DMDM HYDANTOIN"] }
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
    }

    Component.onCompleted: {
        refreshTracks();
    }

    function setClipConfig(config) {
        if (!config || !config.resourceType || !config.phase) return;

        var targetStore = null;
        if (config.resourceType === "agitator") targetStore = agitatorOps;
        else if (config.resourceType === "homogenizer") targetStore = homoOps;
        else if (config.resourceType === "vacuum") targetStore = vacuumOps;
        else if (config.resourceType === "heater" || config.resourceType === "cooler") targetStore = thermalOps;
        else if (config.resourceType === "fillValve" || config.resourceType === "drainValve") targetStore = valveOps;

        if (targetStore) {
            targetStore[config.phase] = {
                stageId: config.stageId,
                setValue: config.setValue,
                unit: config.unit,
                purpose: config.purpose,
                requireConfirm: config.requireConfirm,
                confirmMessage: config.confirmMessage,
                durationSec: config.durationSec,
                stopCondition: config.stopCondition,
                materials: config.materials || []
            };
            refreshTracks();
        }
    }

    function deleteClip(trackType, phaseName) {
        var targetStore = null;
        if (trackType === "agitator") targetStore = agitatorOps;
        else if (trackType === "homogenizer") targetStore = homoOps;
        else if (trackType === "vacuum") targetStore = vacuumOps;
        else if (trackType === "heater") targetStore = thermalOps;
        else if (trackType === "fillValve") targetStore = valveOps;

        if (targetStore && targetStore[phaseName]) {
            delete targetStore[phaseName];
            refreshTracks();
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

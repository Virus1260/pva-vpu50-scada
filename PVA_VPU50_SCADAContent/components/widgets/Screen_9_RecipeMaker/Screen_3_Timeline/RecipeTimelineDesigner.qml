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

    // Dynamic In-memory data store for operations on each track and phase
    property var agitatorOps: ({})
    property var homoOps: ({})
    property var vacuumOps: ({})
    property var thermalOps: ({})
    property var valveOps: ({})
    property var manualOps: ({})

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
        loadBodyLotionOperations();
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

    // =========================================================================
    // RECIPE SPECIFIC TIMELINE DATA LOADERS
    // =========================================================================

    function loadBodyLotionOperations() {
        recipeId = "REC-VPU50-002";
        recipeTitle = "Body Lotion Formulation";
        view.recipeTitle = "Body Lotion Formulation";
        view.totalDurationSec = 2700;
        view.estDurationFormatted = "45 min (2700s)";
        view.totalTimecode = "00:45:00";
        view.totalOperationsCount = 10;
        view.totalHoldsCount = 2;

        view.phaseHeadersModel = [
            { title: "PHASE A: Aqueous Charge", time: "00:00 - 08:00" },
            { title: "PHASE B: Oil Emulsification", time: "08:00 - 20:00" },
            { title: "PHASE C: Surfactant Induction", time: "20:00 - 30:00" },
            { title: "PHASE D: Neutralization Trim", time: "30:00 - 38:00" },
            { title: "PHASE E: Actives & Cooling", time: "38:00 - 45:00" }
        ];

        agitatorOps = {
            "Phase A": { stageId: "1.1", setValue: 25.0, unit: "RPM", purpose: "Material Loading", requireConfirm: false, confirmMessage: "", durationSec: 480, stopCondition: "temp_above", materials: ["WATER (9.2 KG)", "GLYCERINE"] },
            "Phase B": { stageId: "2.1", setValue: 35.0, unit: "RPM", purpose: "Emulsification", requireConfirm: false, confirmMessage: "", durationSec: 720, stopCondition: "timer", materials: ["LIGHT LIQUID PARAFFIN", "STEARIC ACID"] },
            "Phase C": { stageId: "3.1", setValue: 45.0, unit: "RPM", purpose: "Material Loading", requireConfirm: false, confirmMessage: "", durationSec: 600, stopCondition: "timer", materials: ["SLES 70%"] },
            "Phase D": { stageId: "4.1", setValue: 20.0, unit: "RPM", purpose: "Gel Neutralization", requireConfirm: false, confirmMessage: "", durationSec: 480, stopCondition: "timer", materials: ["TRIETHANOLAMINE"] },
            "Phase E": { stageId: "5.1", setValue: 15.0, unit: "RPM", purpose: "Cooling & Actives", requireConfirm: false, confirmMessage: "", durationSec: 420, stopCondition: "timer", materials: ["DMDM HYDANTOIN"] }
        };

        homoOps = {
            "Phase B": { stageId: "2.2", setValue: 2400.0, unit: "RPM", purpose: "High-Shear Emulsification", requireConfirm: false, confirmMessage: "", durationSec: 360, stopCondition: "timer", materials: [] },
            "Phase C": { stageId: "3.2", setValue: 3000.0, unit: "RPM", purpose: "Micro-Droplet Dispersion", requireConfirm: false, confirmMessage: "", durationSec: 420, stopCondition: "timer", materials: [] }
        };

        vacuumOps = {
            "Phase B": { stageId: "2.3", setValue: -350.0, unit: "mbar", purpose: "De-aeration", requireConfirm: false, confirmMessage: "", durationSec: 600, stopCondition: "timer", materials: [] },
            "Phase C": { stageId: "3.3", setValue: -450.0, unit: "mbar", purpose: "Vacuum Suction & De-aeration", requireConfirm: false, confirmMessage: "", durationSec: 600, stopCondition: "timer", materials: ["SLES 70%"] }
        };

        thermalOps = {
            "Phase A": { stageId: "1.2", setValue: 85.0, unit: "°C", purpose: "Aqueous Phase Heating", requireConfirm: false, confirmMessage: "", durationSec: 480, stopCondition: "temp_above", materials: [] },
            "Phase B": { stageId: "2.4", setValue: 85.0, unit: "°C", purpose: "Emulsion Temperature Soak", requireConfirm: false, confirmMessage: "", durationSec: 720, stopCondition: "timer", materials: [] },
            "Phase D": { stageId: "4.2", setValue: 50.0, unit: "°C", purpose: "Controlled Cooling", requireConfirm: false, confirmMessage: "", durationSec: 480, stopCondition: "temp_below", materials: [] },
            "Phase E": { stageId: "5.2", setValue: 40.0, unit: "°C", purpose: "Final Product Cooling", requireConfirm: false, confirmMessage: "", durationSec: 420, stopCondition: "temp_below", materials: [] }
        };

        valveOps = {
            "Phase A": { stageId: "1.3", setValue: 100.0, unit: "% Open", purpose: "Water Charge", requireConfirm: false, confirmMessage: "", durationSec: 180, stopCondition: "level_above", materials: ["WATER (9.2 KG)"] }
        };

        manualOps = {
            "Phase B": { stageId: "2.5", actionTarget: "Butterfly Valve 1V01", actionRequired: "OPEN", confirmMessage: "Operator to confirm that valve 1V01 is OPEN for Phase B oil induction.", requireConfirm: true, durationSec: 0, stopCondition: "manual" },
            "Phase E": { stageId: "5.3", actionTarget: "Sight Glass Window", actionRequired: "VERIFY", confirmMessage: "Operator visual inspection: Verify emulsion uniformity and gloss.", requireConfirm: true, durationSec: 0, stopCondition: "manual" }
        };
    }

    function loadShampooOperations() {
        recipeId = "REC-VPU50-001";
        recipeTitle = "Industrial Shampoo Formulation";
        view.recipeTitle = "Industrial Shampoo Formulation";
        view.totalDurationSec = 2400;
        view.estDurationFormatted = "40 min (2400s)";
        view.totalTimecode = "00:40:00";
        view.totalOperationsCount = 9;
        view.totalHoldsCount = 1;

        view.phaseHeadersModel = [
            { title: "PHASE A: Surfactant Base", time: "00:00 - 10:00" },
            { title: "PHASE B: Pearlizer Dispersion", time: "10:00 - 22:00" },
            { title: "PHASE C: Conditioning Polymers", time: "22:00 - 32:00" },
            { title: "PHASE D: pH & Viscosity Trim", time: "32:00 - 40:00" },
            { title: "PHASE E: Cold Discharge", time: "Completed" }
        ];

        agitatorOps = {
            "Phase A": { stageId: "1.1", setValue: 30.0, unit: "RPM", purpose: "Water & SLES Base", requireConfirm: false, confirmMessage: "", durationSec: 600, stopCondition: "timer", materials: ["DM WATER", "SLES 70%"] },
            "Phase B": { stageId: "2.1", setValue: 40.0, unit: "RPM", purpose: "Pearlizer Melting", requireConfirm: false, confirmMessage: "", durationSec: 720, stopCondition: "timer", materials: ["EGDS", "CAPB 30%"] },
            "Phase C": { stageId: "3.1", setValue: 35.0, unit: "RPM", purpose: "Polymer Dispersion", requireConfirm: false, confirmMessage: "", durationSec: 600, stopCondition: "timer", materials: ["POLYQUATERNIUM-7", "ZPT"] },
            "Phase D": { stageId: "4.1", setValue: 20.0, unit: "RPM", purpose: "Viscosity Trim", requireConfirm: false, confirmMessage: "", durationSec: 480, stopCondition: "timer", materials: ["NaCl", "CITRIC ACID"] }
        };

        homoOps = {
            "Phase B": { stageId: "2.2", setValue: 1800.0, unit: "RPM", purpose: "Pearlizer Micronization", requireConfirm: false, confirmMessage: "", durationSec: 480, stopCondition: "timer", materials: ["EGDS"] }
        };

        vacuumOps = {
            "Phase C": { stageId: "3.2", setValue: -300.0, unit: "mbar", purpose: "Surfactant De-aeration", requireConfirm: false, confirmMessage: "", durationSec: 600, stopCondition: "timer", materials: [] }
        };

        thermalOps = {
            "Phase A": { stageId: "1.2", setValue: 60.0, unit: "°C", purpose: "Water Preheating", requireConfirm: false, confirmMessage: "", durationSec: 600, stopCondition: "temp_above", materials: [] },
            "Phase B": { stageId: "2.3", setValue: 70.0, unit: "°C", purpose: "Pearlizer Dissolution", requireConfirm: false, confirmMessage: "", durationSec: 720, stopCondition: "temp_above", materials: [] },
            "Phase D": { stageId: "4.2", setValue: 35.0, unit: "°C", purpose: "Cold Addition & Trim", requireConfirm: false, confirmMessage: "", durationSec: 480, stopCondition: "temp_below", materials: [] }
        };

        valveOps = {
            "Phase A": { stageId: "1.3", setValue: 100.0, unit: "% Open", purpose: "DM Water Inflow", requireConfirm: false, confirmMessage: "", durationSec: 240, stopCondition: "level_above", materials: ["DM WATER"] }
        };

        manualOps = {
            "Phase D": { stageId: "4.3", actionTarget: "Sampling Port 1S01", actionRequired: "VERIFY", confirmMessage: "Operator to draw QC sample and verify batch viscosity & pH.", requireConfirm: true, durationSec: 0, stopCondition: "manual" }
        };
    }

    function loadBarrierGelOperations() {
        recipeId = "REC-VPU50-003";
        recipeTitle = "Barrier Hydro-Gel Emulsion";
        view.recipeTitle = "Barrier Hydro-Gel Emulsion";
        view.totalDurationSec = 1800;
        view.estDurationFormatted = "30 min (1800s)";
        view.totalTimecode = "00:30:00";
        view.totalOperationsCount = 7;
        view.totalHoldsCount = 1;

        view.phaseHeadersModel = [
            { title: "PHASE A: Polymer Hydration", time: "00:00 - 10:00" },
            { title: "PHASE B: Lipid Barrier Base", time: "10:00 - 22:00" },
            { title: "PHASE C: Gel Setting & Trim", time: "22:00 - 30:00" },
            { title: "PHASE D: Hold", time: "Ready" },
            { title: "PHASE E: Discharge", time: "Ready" }
        ];

        agitatorOps = {
            "Phase A": { stageId: "1.1", setValue: 35.0, unit: "RPM", purpose: "Carbopol Hydration", requireConfirm: false, confirmMessage: "", durationSec: 600, stopCondition: "timer", materials: ["PURIFIED WATER USP", "CARBOPOL ULTREZ 20"] },
            "Phase B": { stageId: "2.1", setValue: 40.0, unit: "RPM", purpose: "Lipid Matrix Blending", requireConfirm: false, confirmMessage: "", durationSec: 720, stopCondition: "timer", materials: ["WHITE PETROLATUM", "DIMETHICONE"] },
            "Phase C": { stageId: "3.1", setValue: 20.0, unit: "RPM", purpose: "Gel Network Setting", requireConfirm: false, confirmMessage: "", durationSec: 480, stopCondition: "timer", materials: ["TRIETHANOLAMINE 99%"] }
        };

        homoOps = {
            "Phase B": { stageId: "2.2", setValue: 2800.0, unit: "RPM", purpose: "High-Shear Vacuum Emulsification", requireConfirm: false, confirmMessage: "", durationSec: 600, stopCondition: "timer", materials: ["WHITE PETROLATUM"] }
        };

        vacuumOps = {
            "Phase A": { stageId: "1.2", setValue: -400.0, unit: "mbar", purpose: "Polymer De-aeration", requireConfirm: false, confirmMessage: "", durationSec: 600, stopCondition: "timer", materials: [] },
            "Phase B": { stageId: "2.3", setValue: -500.0, unit: "mbar", purpose: "Vacuum Homogenization", requireConfirm: false, confirmMessage: "", durationSec: 600, stopCondition: "timer", materials: [] }
        };

        thermalOps = {
            "Phase B": { stageId: "2.4", setValue: 75.0, unit: "°C", purpose: "Petrolatum Melting", requireConfirm: false, confirmMessage: "", durationSec: 720, stopCondition: "temp_above", materials: [] },
            "Phase C": { stageId: "3.2", setValue: 30.0, unit: "°C", purpose: "Gel Stabilization Cooling", requireConfirm: false, confirmMessage: "", durationSec: 480, stopCondition: "temp_below", materials: [] }
        };

        valveOps = {
            "Phase A": { stageId: "1.3", setValue: 100.0, unit: "% Open", purpose: "Water Charging", requireConfirm: false, confirmMessage: "", durationSec: 180, stopCondition: "level_above", materials: ["PURIFIED WATER USP"] }
        };

        manualOps = {
            "Phase B": { stageId: "2.5", actionTarget: "Silicone Port 1V03", actionRequired: "OPEN", confirmMessage: "Operator to connect Dimethicone hose and open port 1V03 under vacuum.", requireConfirm: true, durationSec: 0, stopCondition: "manual" }
        };
    }

    function loadCustomRecipeOperations(recipe, ingredients) {
        recipeId = (recipe && (recipe.recipeId || recipe.id)) || "REC-VPU50-NEW";
        recipeTitle = (recipe && recipe.title) || "New Master Recipe";
        view.recipeTitle = recipeTitle;

        // Collect phases present in ingredients
        var phases = {};
        if (ingredients && ingredients.length > 0) {
            for (var i = 0; i < ingredients.length; i++) {
                var ing = ingredients[i];
                var p = String(ing.phase || "Phase A").trim();
                if (!phases[p]) phases[p] = [];
                phases[p].push(ing.name);
            }
        }

        var phaseKeys = Object.keys(phases);
        if (phaseKeys.length === 0) {
            // Fresh clean slate: Empty tracks
            view.totalDurationSec = 1800;
            view.estDurationFormatted = "30 min (1800s)";
            view.totalTimecode = "00:30:00";
            view.totalOperationsCount = 0;
            view.totalHoldsCount = 0;

            view.phaseHeadersModel = [
                { title: "PHASE A: Formulation Base", time: "00:00 - 10:00" },
                { title: "PHASE B: Active Dispersion", time: "10:00 - 20:00" },
                { title: "PHASE C: Finishing & Trim", time: "20:00 - 30:00" },
                { title: "PHASE D: Empty", time: "--:--" },
                { title: "PHASE E: Empty", time: "--:--" }
            ];

            agitatorOps = {};
            homoOps = {};
            vacuumOps = {};
            thermalOps = {};
            valveOps = {};
            manualOps = {};
        } else {
            // Build dynamically from the user's custom ingredients
            var pHeaders = [];
            var newAgitator = {};
            var newThermal = {};
            var newValve = {};
            var opCount = 0;

            var letters = ["Phase A", "Phase B", "Phase C", "Phase D", "Phase E"];
            for (var k = 0; k < 5; k++) {
                var pName = letters[k];
                var mats = phases[pName] || phases[String(k + 1)] || phases["Phase " + (k + 1)] || [];
                if (mats.length > 0) {
                    pHeaders.push({ title: pName.toUpperCase() + ": " + mats[0], time: (k * 10) + ":00 - " + ((k + 1) * 10) + ":00" });
                    newAgitator[pName] = {
                        stageId: (k + 1) + ".1",
                        setValue: 30.0 + (k * 5),
                        unit: "RPM",
                        purpose: "Agitation & Blending",
                        requireConfirm: false,
                        confirmMessage: "",
                        durationSec: 600,
                        stopCondition: "timer",
                        materials: mats
                    };
                    newThermal[pName] = {
                        stageId: (k + 1) + ".2",
                        setValue: k === 0 ? 60.0 : (k === 1 ? 75.0 : 40.0),
                        unit: "°C",
                        purpose: "Thermal Processing",
                        requireConfirm: false,
                        confirmMessage: "",
                        durationSec: 600,
                        stopCondition: "timer",
                        materials: []
                    };
                    opCount += 2;
                } else {
                    pHeaders.push({ title: pName.toUpperCase() + ": Unallocated", time: "--:--" });
                }
            }

            if (newAgitator["Phase A"]) {
                newValve["Phase A"] = {
                    stageId: "1.3",
                    setValue: 100.0,
                    unit: "% Open",
                    purpose: "Main Liquid Charge",
                    requireConfirm: false,
                    confirmMessage: "",
                    durationSec: 180,
                    stopCondition: "timer",
                    materials: phases["Phase A"] || []
                };
                opCount += 1;
            }

            view.totalDurationSec = Math.max(1800, phaseKeys.length * 600);
            var durMin = Math.round(view.totalDurationSec / 60);
            view.estDurationFormatted = durMin + " min (" + view.totalDurationSec + "s)";
            view.totalTimecode = formatTimecode(view.totalDurationSec);
            view.totalOperationsCount = opCount;
            view.totalHoldsCount = 0;
            view.phaseHeadersModel = pHeaders;

            agitatorOps = newAgitator;
            homoOps = {};
            vacuumOps = {};
            thermalOps = newThermal;
            valveOps = newValve;
            manualOps = {};
        }
    }

    function loadRecipe(recipe, ingredients) {
        if (!recipe) {
            loadBodyLotionOperations();
            refreshTracks();
            view.currentPlayheadSec = 0;
            updateSimulationState();
            return;
        }

        var rId = recipe.recipeId || recipe.id || "";
        if (rId === "REC-VPU50-001") {
            loadShampooOperations();
        } else if (rId === "REC-VPU50-002") {
            loadBodyLotionOperations();
        } else if (rId === "REC-VPU50-003") {
            loadBarrierGelOperations();
        } else {
            loadCustomRecipeOperations(recipe, ingredients);
        }

        refreshTracks();
        view.currentPlayheadSec = 0;
        view.isPlaying = false;
        manualHoldEncountered = false;
        updateSimulationState();
    }

    // =========================================================================
    // DYNAMIC P&ID SIMULATION STATE ENGINE
    // =========================================================================

    function updateSimulationState() {
        var sec = view.currentPlayheadSec;
        view.playheadTimecode = formatTimecode(sec);

        var total = view.totalDurationSec || 2700;
        var progress = Math.min(1.0, sec / Math.max(1, total));

        // Determine current phase based on progress and active recipe
        if (recipeId === "REC-VPU50-001") {
            // Industrial Shampoo
            if (sec < 600) {
                view.currentPhaseName = "Phase A";
                view.currentStageId = "1.1";
                view.pidSimulator.activePhase = "Phase A";
                view.pidSimulator.activeStage = "1.1";
                view.pidSimulator.agitatorRpm = agitatorOps["Phase A"] ? agitatorOps["Phase A"].setValue : 30.0;
                view.pidSimulator.homoRpm = 0.0;
                view.pidSimulator.vacuumMbar = 0.0;
                view.pidSimulator.vesselTemp = 25.0 + ((60.0 - 25.0) * (sec / 600.0));
                view.pidSimulator.liquidLevelPct = 50.0;
                view.pidSimulator.isHeating = true;
                view.pidSimulator.isCooling = false;
                view.pidSimulator.valveChargeOpen = (sec < 240);
                view.pidSimulator.fluidColor = "#0284c7"; // Translucent blue surfactant base
            } else if (sec < 1320) {
                view.currentPhaseName = "Phase B";
                view.currentStageId = "2.1";
                view.pidSimulator.activePhase = "Phase B";
                view.pidSimulator.activeStage = "2.1";
                view.pidSimulator.agitatorRpm = agitatorOps["Phase B"] ? agitatorOps["Phase B"].setValue : 40.0;
                view.pidSimulator.homoRpm = homoOps["Phase B"] ? homoOps["Phase B"].setValue : 1800.0;
                view.pidSimulator.vacuumMbar = 0.0;
                view.pidSimulator.vesselTemp = 70.0;
                view.pidSimulator.liquidLevelPct = 80.0;
                view.pidSimulator.isHeating = true;
                view.pidSimulator.isCooling = false;
                view.pidSimulator.valveChargeOpen = false;
                view.pidSimulator.fluidColor = "#e0f2fe"; // Pearlescent white shampoo
            } else if (sec < 1920) {
                view.currentPhaseName = "Phase C";
                view.currentStageId = "3.1";
                view.pidSimulator.activePhase = "Phase C";
                view.pidSimulator.activeStage = "3.1";
                view.pidSimulator.agitatorRpm = agitatorOps["Phase C"] ? agitatorOps["Phase C"].setValue : 35.0;
                view.pidSimulator.homoRpm = 0.0;
                view.pidSimulator.vacuumMbar = vacuumOps["Phase C"] ? vacuumOps["Phase C"].setValue : -300.0;
                view.pidSimulator.vesselTemp = 50.0;
                view.pidSimulator.liquidLevelPct = 90.0;
                view.pidSimulator.isHeating = false;
                view.pidSimulator.isCooling = true;
                view.pidSimulator.valveChargeOpen = false;
                view.pidSimulator.fluidColor = "#f0f9ff";
            } else {
                view.currentPhaseName = "Phase D";
                view.currentStageId = "4.1";
                view.pidSimulator.activePhase = "Phase D";
                view.pidSimulator.activeStage = "4.1";
                view.pidSimulator.agitatorRpm = agitatorOps["Phase D"] ? agitatorOps["Phase D"].setValue : 20.0;
                view.pidSimulator.homoRpm = 0.0;
                view.pidSimulator.vacuumMbar = 0.0;
                view.pidSimulator.vesselTemp = 35.0;
                view.pidSimulator.liquidLevelPct = 95.0;
                view.pidSimulator.isHeating = false;
                view.pidSimulator.isCooling = false;
                view.pidSimulator.valveChargeOpen = false;
                view.pidSimulator.fluidColor = "#bae6fd";
            }
        } else if (recipeId === "REC-VPU50-003") {
            // Barrier Hydro-Gel Emulsion
            if (sec < 600) {
                view.currentPhaseName = "Phase A";
                view.currentStageId = "1.1";
                view.pidSimulator.activePhase = "Phase A";
                view.pidSimulator.activeStage = "1.1";
                view.pidSimulator.agitatorRpm = agitatorOps["Phase A"] ? agitatorOps["Phase A"].setValue : 35.0;
                view.pidSimulator.homoRpm = 0.0;
                view.pidSimulator.vacuumMbar = vacuumOps["Phase A"] ? vacuumOps["Phase A"].setValue : -400.0;
                view.pidSimulator.vesselTemp = 25.0;
                view.pidSimulator.liquidLevelPct = 40.0;
                view.pidSimulator.isHeating = false;
                view.pidSimulator.isCooling = false;
                view.pidSimulator.valveChargeOpen = (sec < 180);
                view.pidSimulator.fluidColor = "#38bdf8"; // Clear hydro-gel
            } else if (sec < 1320) {
                view.currentPhaseName = "Phase B";
                view.currentStageId = "2.1";
                view.pidSimulator.activePhase = "Phase B";
                view.pidSimulator.activeStage = "2.1";
                view.pidSimulator.agitatorRpm = agitatorOps["Phase B"] ? agitatorOps["Phase B"].setValue : 40.0;
                view.pidSimulator.homoRpm = homoOps["Phase B"] ? homoOps["Phase B"].setValue : 2800.0;
                view.pidSimulator.vacuumMbar = vacuumOps["Phase B"] ? vacuumOps["Phase B"].setValue : -500.0;
                view.pidSimulator.vesselTemp = 75.0;
                view.pidSimulator.liquidLevelPct = 70.0;
                view.pidSimulator.isHeating = true;
                view.pidSimulator.isCooling = false;
                view.pidSimulator.valveChargeOpen = false;
                view.pidSimulator.fluidColor = "#f1f5f9"; // Dense translucent gel
            } else {
                view.currentPhaseName = "Phase C";
                view.currentStageId = "3.1";
                view.pidSimulator.activePhase = "Phase C";
                view.pidSimulator.activeStage = "3.1";
                view.pidSimulator.agitatorRpm = agitatorOps["Phase C"] ? agitatorOps["Phase C"].setValue : 20.0;
                view.pidSimulator.homoRpm = 0.0;
                view.pidSimulator.vacuumMbar = 0.0;
                view.pidSimulator.vesselTemp = 30.0;
                view.pidSimulator.liquidLevelPct = 75.0;
                view.pidSimulator.isHeating = false;
                view.pidSimulator.isCooling = true;
                view.pidSimulator.valveChargeOpen = false;
                view.pidSimulator.fluidColor = "#e2e8f0";
            }
        } else {
            // Body Lotion & Default Recipes
            if (sec < 480) {
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
                view.pidSimulator.fluidColor = "#38bdf8";
            } else if (sec < 1200) {
                view.currentPhaseName = "Phase B";
                view.currentStageId = "2.1";
                view.pidSimulator.activePhase = "Phase B";
                view.pidSimulator.activeStage = "2.1";

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
                view.pidSimulator.fluidColor = "#f8fafc";
            } else if (sec < 1800) {
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
                view.currentPhaseName = "Phase D";
                view.currentStageId = "4.1";
                view.pidSimulator.activePhase = "Phase D";
                view.pidSimulator.activeStage = "4.1";
                view.pidSimulator.agitatorRpm = agitatorOps["Phase D"] ? agitatorOps["Phase D"].setValue : 20.0;
                view.pidSimulator.homoRpm = 0.0;
                view.pidSimulator.vacuumMbar = 0.0;
                view.pidSimulator.vesselTemp = 50.0;
                view.pidSimulator.liquidLevelPct = 85.0;
                view.pidSimulator.isHeating = false;
                view.pidSimulator.isCooling = true;
                view.pidSimulator.valveChargeOpen = false;
                view.pidSimulator.fluidColor = "#f8fafc";
            } else {
                view.currentPhaseName = "Phase E";
                view.currentStageId = "5.1";
                view.pidSimulator.activePhase = "Phase E";
                view.pidSimulator.activeStage = "5.1";
                view.pidSimulator.agitatorRpm = agitatorOps["Phase E"] ? agitatorOps["Phase E"].setValue : 15.0;
                view.pidSimulator.homoRpm = 0.0;
                view.pidSimulator.vacuumMbar = 0.0;
                view.pidSimulator.vesselTemp = 40.0;
                view.pidSimulator.liquidLevelPct = 88.0;
                view.pidSimulator.isHeating = false;
                view.pidSimulator.isCooling = true;
                view.pidSimulator.valveChargeOpen = false;
                view.pidSimulator.fluidColor = "#ffffff";
            }
        }
    }

    Timer {
        id: playTimer
        interval: 100 // 10x real-time simulation step
        repeat: true
        running: false
        onTriggered: {
            if (view.currentPlayheadSec < view.totalDurationSec) {
                view.currentPlayheadSec += 5;
                timelineDesignerLogicRoot.updateSimulationState();
            } else {
                view.isPlaying = false;
                playTimer.stop();
            }
        }
    }

    function setClipConfig(config) {
        if (!config || !config.phaseName) return;
        var p = config.phaseName;
        var rType = String(config.resourceType || "").toLowerCase();

        if (rType.indexOf("agitator") !== -1 || rType.indexOf("stirrer") !== -1) {
            timelineDesignerLogicRoot.agitatorOps[p] = config;
        } else if (rType.indexOf("homo") !== -1) {
            timelineDesignerLogicRoot.homoOps[p] = config;
        } else if (rType.indexOf("vacuum") !== -1) {
            timelineDesignerLogicRoot.vacuumOps[p] = config;
        } else if (rType.indexOf("heat") !== -1 || rType.indexOf("thermal") !== -1) {
            timelineDesignerLogicRoot.thermalOps[p] = config;
        } else if (rType.indexOf("valve") !== -1 || rType.indexOf("dosing") !== -1) {
            timelineDesignerLogicRoot.valveOps[p] = config;
        } else if (rType.indexOf("manual") !== -1 || config.actionTarget) {
            timelineDesignerLogicRoot.manualOps[p] = config;
        }
        timelineDesignerLogicRoot.refreshTracks();
        timelineDesignerLogicRoot.updateSimulationState();
    }

    // Interactive View Bindings
    RecipeTimelineDesignerView {
        id: view
        anchors.fill: parent

        timelineScrubber.onMoved: {
            view.currentPlayheadSec = Math.round(view.timelineScrubber.value);
            timelineDesignerLogicRoot.updateSimulationState();
        }

        // Connect Track Clip Configuration Dialogs
        agitatorTrack.onConfigureClipRequested: function(clipData) {
            timelineDesignerLogicRoot.openConfigModalRequested(clipData);
        }
        homoTrack.onConfigureClipRequested: function(clipData) {
            timelineDesignerLogicRoot.openConfigModalRequested(clipData);
        }
        vacuumTrack.onConfigureClipRequested: function(clipData) {
            timelineDesignerLogicRoot.openConfigModalRequested(clipData);
        }
        thermalTrack.onConfigureClipRequested: function(clipData) {
            timelineDesignerLogicRoot.openConfigModalRequested(clipData);
        }
        valveTrack.onConfigureClipRequested: function(clipData) {
            timelineDesignerLogicRoot.openConfigModalRequested(clipData);
        }
        manualTrack.onConfigureClipRequested: function(clipData) {
            timelineDesignerLogicRoot.openManualModalRequested(clipData);
        }

        // Manual interlock confirmation in Simulator
        pidSimulator.onManualConfirmed: {
            view.pidSimulator.isManualHoldActive = false;
            view.isPlaying = true;
            playTimer.start();
        }
    }

    // Action Bar Button Handlers
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
            var payload = {
                recipeId: timelineDesignerLogicRoot.recipeId,
                recipeTitle: timelineDesignerLogicRoot.recipeTitle,
                totalDurationSec: view.totalDurationSec,
                phases: view.phaseHeadersModel,
                tracks: {
                    agitator: timelineDesignerLogicRoot.agitatorOps,
                    homogenizer: timelineDesignerLogicRoot.homoOps,
                    vacuum: timelineDesignerLogicRoot.vacuumOps,
                    thermal: timelineDesignerLogicRoot.thermalOps,
                    valves: timelineDesignerLogicRoot.valveOps,
                    manual: timelineDesignerLogicRoot.manualOps
                }
            };
            timelineDesignerLogicRoot.nodeRedExportGenerated(JSON.stringify(payload, null, 2));
        }
    }

    MouseArea {
        parent: view.saveRecipeBtn
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            var payload = {
                recipeId: timelineDesignerLogicRoot.recipeId,
                recipeTitle: timelineDesignerLogicRoot.recipeTitle,
                totalDurationSec: view.totalDurationSec,
                tracks: {
                    agitator: timelineDesignerLogicRoot.agitatorOps,
                    homogenizer: timelineDesignerLogicRoot.homoOps,
                    vacuum: timelineDesignerLogicRoot.vacuumOps,
                    thermal: timelineDesignerLogicRoot.thermalOps,
                    valves: timelineDesignerLogicRoot.valveOps,
                    manual: timelineDesignerLogicRoot.manualOps
                }
            };
            timelineDesignerLogicRoot.recipeSaved(payload);
        }
    }

    MouseArea {
        parent: view.submitForApprovalBtn
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            var payload = {
                recipeId: timelineDesignerLogicRoot.recipeId,
                recipeTitle: timelineDesignerLogicRoot.recipeTitle,
                totalDurationSec: view.totalDurationSec,
                tracks: {
                    agitator: timelineDesignerLogicRoot.agitatorOps,
                    homogenizer: timelineDesignerLogicRoot.homoOps,
                    vacuum: timelineDesignerLogicRoot.vacuumOps,
                    thermal: timelineDesignerLogicRoot.thermalOps,
                    valves: timelineDesignerLogicRoot.valveOps,
                    manual: timelineDesignerLogicRoot.manualOps
                }
            };
            timelineDesignerLogicRoot.recipeSubmittedForReview(payload);
        }
    }

    // Transport Control Handlers
    MouseArea {
        parent: view.playBtn
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            view.isPlaying = !view.isPlaying;
            if (view.isPlaying) {
                if (view.currentPlayheadSec >= view.totalDurationSec) {
                    view.currentPlayheadSec = 0;
                }
                playTimer.start();
            } else {
                playTimer.stop();
            }
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
}

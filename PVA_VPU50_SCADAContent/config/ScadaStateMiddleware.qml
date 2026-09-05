import QtQuick

Item {
    id: middlewareRoot

    property ScadaConfig config: ScadaConfig {}

    // =========================================================================
    // 1. ACTIVE BATCH & RECIPE CONTEXT (ISA-88 Batch Engine)
    // =========================================================================
    property string activeBatchId: "B1"
    property string activeProductName: "Industrial Shampoo Formulation"
    property string activeRecipeName: "Industrial Shampoo Formulation"
    property int currentRecipeStepIndex: 0
    property string currentRecipeStepName: "Phase A: Initial Water Charge"
    property string currentRecipeStepDescription: "Fill vessel to 55% with DI water at ambient temperature"
    property int totalRecipeSteps: 10
    property bool isRecipeRunning: false
    property bool isRecipePaused: false
    property int stepTimerSec: 0
    property int batchTimerSec: 0
    property real activeStepProgress: 0.0
    property int activeOperationsCount: 1
    property string activeOpDevices: "Fill Valve"

    // 21 CFR Part 11 Phase Hold Point State
    property bool isManualWaiting: false
    property bool confirmActive: false
    property string confirmMessage: ""
    property int confirmCountdown: 0

    // =========================================================================
    // 2. LIVE MOTOR & ACTUATOR STATES (Shared by Control, P&ID, Trends, Alarms)
    // =========================================================================
    // (A) Agitator Drive (1M1001 / M 162 001)
    property bool isAgitatorRunning: false
    property real agitatorTargetSpeed: 10.0 // RPM
    property real agitatorSpeed: 0.0 // Actual RPM
    property real agitatorPower: 0.0 // kW
    property real agitatorCurrent: 0.0 // A
    property string agitatorMode: "agitator_cw" // CW, CCW, Interval

    // (B) Homogenizer Drive (1M1002 / M 163 001)
    property bool isHomogenizerRunning: false
    property real homogenizerTargetSpeed: 4800.0 // RPM
    property real homogenizerSpeed: 0.0 // Actual RPM
    property real homogenizerPower: 0.0 // kW
    property real homogenizerCurrent: 0.0 // A
    property string homogenizerMode: "homo_permanent"

    // (C) External Circulation & Suction (1M2001) & CIP System
    property bool isCirculationRunning: true
    property string circulationMode: "recirculation" // "recirculation", "discharge_product", "discharge_circulation_pipe"
    readonly property bool isRecirculating: (isCirculationRunning && circulationMode === "recirculation")
    property bool isCipActive: false // Active during CIP spray rinsing

    // (D) Vacuum & Pressure System (1M3001)
    property bool isVacuumActive: true
    property real vacuumPressure: -179.0 // Actual mbar
    property real vacuumTargetPressure: -450.0 // Target mbar

    // (E) Thermal Jacket (Heating & Cooling)
    property bool isHeating: false
    property bool isCooling: false
    property real vesselTemp: 34.4 // °C
    property real jacketTemp: 35.8 // °C
    property real targetTemp: 95.0 // °C
    property real deltaT: 5.0 // °C

    // (F) Mass & Level Transmitter (WIRAH 161001)
    property real vesselWeightKg: 154.4 // kg
    property real vesselLevelPercent: 65.0 // %

    // (G) Lid Hydraulic Position & Interlocks
    property bool isLidRaised: false
    property bool isLidLocked: true

    // =========================================================================
    // 3. HARDWARE VALVE MATRIX (Shared by P&ID and Confirmation Modals)
    // =========================================================================
    property var valveStates: ({
        "K 166 002": false,
        "K 161 002": false,
        "K 161 003": false,
        "K 141 001": false,
        "K 171 001": true,
        "Z 163 001": true,
        "K 163 002": true,
        "K 165 002": true,
        "K 165 003": true,
        "K 143 002": false,
        "K 143 001": false,
        "V 142 201": false,
        "K 168 201": false,
        "K 168 202": false,
        "K 168 204": false,
        "K 168 206": false,
        "K 168 208": false,
        "K 168 205": false,
        "K 168 207": false,
        "K 172 001": false,
        "K 172 002": false
    })

    // =========================================================================
    // 4. GLOBAL AUDIT TRAIL & ALARM SIGNALS (21 CFR Part 11)
    // =========================================================================
    signal auditLogEmitted(string timestamp, string user, string action, string category)
    signal alarmEmitted(string alarmId, string severity, string message)
    signal alarmAcknowledged(string alarmId)
    signal stateChangedExternally()

    // =========================================================================
    // 5. UNIFIED DISPATCHERS (Callable from Recipes, Control Screen, Modals & PLC)
    // =========================================================================
    function setAgitator(running, rpm, mode) {
        isAgitatorRunning = running;
        if (rpm !== undefined) agitatorTargetSpeed = rpm;
        if (mode !== undefined) agitatorMode = mode;
        auditLogEmitted(new Date().toLocaleTimeString(), "operator", "Agitator set to " + (running ? "RUN (" + agitatorTargetSpeed + " RPM)" : "STOP"), "DRIVE_CONTROL");
        stateChangedExternally();
    }

    function setHomogenizer(running, rpm, mode) {
        isHomogenizerRunning = running;
        if (rpm !== undefined) homogenizerTargetSpeed = rpm;
        if (mode !== undefined) homogenizerMode = mode;
        auditLogEmitted(new Date().toLocaleTimeString(), "operator", "Homogenizer set to " + (running ? "RUN (" + homogenizerTargetSpeed + " RPM)" : "STOP"), "DRIVE_CONTROL");
        stateChangedExternally();
    }

    function setCirculation(running, mode) {
        isCirculationRunning = running;
        if (mode !== undefined) circulationMode = mode;
        auditLogEmitted(new Date().toLocaleTimeString(), "operator", "Circulation loop set to " + (running ? "RUN [" + circulationMode + "]" : "STOP"), "VALVE_CONTROL");
        stateChangedExternally();
    }

    function setVacuum(running, targetMbar) {
        isVacuumActive = running;
        if (targetMbar !== undefined) vacuumTargetPressure = targetMbar;
        auditLogEmitted(new Date().toLocaleTimeString(), "operator", "Vacuum system set to " + (running ? "ACTIVE (" + vacuumTargetPressure + " mbar)" : "OFF"), "PRESSURE_CONTROL");
        stateChangedExternally();
    }

    function setHeating(running, temp) {
        isHeating = running;
        isCooling = false;
        if (temp !== undefined) targetTemp = temp;
        auditLogEmitted(new Date().toLocaleTimeString(), "operator", "Thermal Heating set to " + (running ? "ON (SP: " + targetTemp + " °C)" : "OFF"), "TEMPERATURE_CONTROL");
        stateChangedExternally();
    }

    function setCooling(running, temp) {
        isCooling = running;
        isHeating = false;
        if (temp !== undefined) targetTemp = temp;
        auditLogEmitted(new Date().toLocaleTimeString(), "operator", "Thermal Cooling set to " + (running ? "ON (SP: " + targetTemp + " °C)" : "OFF"), "TEMPERATURE_CONTROL");
        stateChangedExternally();
    }

    function isValveOpen(tag) {
        return !!valveStates[tag];
    }

    function setValve(tag, isOpen) {
        var copy = Object.assign({}, valveStates);
        copy[tag] = isOpen;
        valveStates = copy;
        auditLogEmitted(new Date().toLocaleTimeString(), "operator", "Valve " + tag + " set to " + (isOpen ? "OPEN" : "CLOSED"), "VALVE_POSITION");
        stateChangedExternally();
    }

    function toggleValve(tag) {
        setValve(tag, !isValveOpen(tag));
    }

    function applyValvePreset(presetMap) {
        var copy = Object.assign({}, valveStates);
        for (var k in presetMap) {
            copy[k] = (presetMap[k] === "OPEN" || presetMap[k] === true);
        }
        valveStates = copy;
        stateChangedExternally();
    }

    function updateRecipeExecution(running, paused, recipeName, stepIdx, stepName, stepDesc, totalSteps, stepSec, batchSec, waiting, confirmAct, confirmMsg, opDevs) {
        isRecipeRunning = running;
        isRecipePaused = paused;
        if (recipeName !== undefined) activeRecipeName = recipeName;
        if (stepIdx !== undefined) currentRecipeStepIndex = stepIdx;
        if (stepName !== undefined) currentRecipeStepName = stepName;
        if (stepDesc !== undefined) currentRecipeStepDescription = stepDesc;
        if (totalSteps !== undefined) totalRecipeSteps = totalSteps;
        if (stepSec !== undefined) stepTimerSec = stepSec;
        if (batchSec !== undefined) batchTimerSec = batchSec;
        if (waiting !== undefined) isManualWaiting = waiting;
        if (confirmAct !== undefined) confirmActive = confirmAct;
        if (confirmMsg !== undefined) confirmMessage = confirmMsg;
        if (opDevs !== undefined) activeOpDevices = opDevs;
        stateChangedExternally();
    }
}

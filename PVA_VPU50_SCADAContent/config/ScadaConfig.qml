import QtQuick

Item {
    id: scadaConfigRoot

    // =========================================================================
    // 1. SYSTEM, MACHINE & BATCH METADATA (ISA-88 / FDA 21 CFR Part 11 / GAMP 5)
    // =========================================================================
    readonly property string systemName: "PVA Systems VPU-50 Industrial SCADA"
    readonly property string machineName: "VPU 50"
    readonly property string defaultBatchId: "B1"
    readonly property string defaultProductName: "Carbopol 980 Pharma Gel"
    readonly property string defaultRecipeName: "UNIMIX_BATCH_01"
    readonly property string defaultBatchVolume: "500 L"
    readonly property string complianceStandard: "FDA 21 CFR Part 11 & ISPE GAMP 5"
    readonly property string isa88Model: "ISA-88 Batch Control Architecture"
    readonly property string softwareVersion: "v2.6.4-GAMP5"
    readonly property string defaultUserId: "operator"

    // =========================================================================
    // 2. UI DESIGN TOKENS & APPLICATION DEFAULTS
    // =========================================================================
    readonly property int headerHeight: 64
    readonly property int sidebarWidth: 110
    readonly property int defaultSensorPanelWidth: 350
    readonly property int minSensorPanelWidth: 280
    readonly property int maxSensorPanelWidth: 480

    // Colors
    readonly property color colorBackgroundDark: "#04101e"
    readonly property color colorSurfacePanel: "#071c33"
    readonly property color colorSurfaceCard: "#092440"
    readonly property color colorSurfaceActive: "#0e3c66"
    readonly property color colorBorderNormal: "#184d7e"
    readonly property color colorBorderHighlight: "#0284c7"
    readonly property color colorTextPrimary: "#ffffff"
    readonly property color colorTextSecondary: "#94a3b8"
    readonly property color colorTextMuted: "#64748b"
    readonly property color colorCyanAccent: "#38bdf8"
    readonly property color colorGreenLive: "#22c55e"
    readonly property color colorAmberAlert: "#f59e0b"
    readonly property color colorRedCritical: "#ef4444"

    // Severity Colors
    readonly property var severityColors: {
        "CRITICAL": "#ef4444",
        "WARNING": "#f59e0b",
        "INFO": "#38bdf8",
        "NORMAL": "#22c55e"
    }

    // =========================================================================
    // 3. TRENDS & HISTORICAL TELEMETRY CONFIGURATION (Single Source of Truth)
    // =========================================================================
    readonly property string defaultTrendsPreset: "5min"
    readonly property int defaultTrendsDurationSec: 300 // 5 minutes = 300 seconds
    readonly property string defaultTrendsMode: "chart" // "chart" or "table"
    readonly property bool defaultLiveStreaming: true

    readonly property var presetDurations: {
        "1min": 60,
        "5min": 300,
        "15min": 900,
        "1h": 3600,
        "8h": 28800,
        "24h": 86400
    }

    function getPresetDuration(presetKey) {
        return presetDurations[presetKey] || 300;
    }

    // =========================================================================
    // 4. CANONICAL SENSOR CATALOG (24 Complete Industrial Process Channels)
    // =========================================================================
    readonly property var sensorCatalog: [
        // --- TEMPERATURE SUBSYSTEM ---
        { section: "TEMPERATURE", tag: "RTD 1TI1301", desc: "Main Vessel Temp", unit: "°C", color: "#38bdf8", activeDefault: true, defaultVal: "34.4 °C", rangeMin: 0, rangeMax: 120, field: "temp_vessel" },
        { section: "TEMPERATURE", tag: "RTD 2TI1001", desc: "Jacket Thermal Temp", unit: "°C", color: "#f97316", activeDefault: true, defaultVal: "46.9 °C", rangeMin: 0, rangeMax: 140, field: "temp_jacket" },
        { section: "TEMPERATURE", tag: "RTD HEATER 1", desc: "Heater Element 01", unit: "°C", color: "#f43f5e", activeDefault: false, defaultVal: "43.4 °C", rangeMin: 0, rangeMax: 160, field: "temp_heater1" },
        { section: "TEMPERATURE", tag: "RTD HEATER 2", desc: "Heater Element 02", unit: "°C", color: "#ec4899", activeDefault: false, defaultVal: "42.9 °C", rangeMin: 0, rangeMax: 160, field: "temp_heater2" },
        { section: "TEMPERATURE", tag: "RTD 3TI1003", desc: "Lid Surface Temp", unit: "°C", color: "#fb7185", activeDefault: false, defaultVal: "28.4 °C", rangeMin: 0, rangeMax: 100, field: "temp_lid" },
        { section: "TEMPERATURE", tag: "RTD 4TI1004", desc: "Cooling Return Temp", unit: "°C", color: "#34d399", activeDefault: false, defaultVal: "21.5 °C", rangeMin: 0, rangeMax: 100, field: "temp_coolwater" },
        { section: "TEMPERATURE", tag: "RTD 5TI1005", desc: "Steam Condensate Temp", unit: "°C", color: "#fb923c", activeDefault: false, defaultVal: "88.2 °C", rangeMin: 0, rangeMax: 150, field: "temp_condensate" },

        // --- PRESSURE SUBSYSTEM ---
        { section: "PRESSURE", tag: "PR TRANSMITTER", desc: "Chamber Vacuum", unit: "mbar", color: "#c084fc", activeDefault: true, defaultVal: "-450.0 mbar", rangeMin: -1000, rangeMax: 0, field: "vacuum_pressure" },
        { section: "PRESSURE", tag: "PIT 1002", desc: "Jacket Steam Pressure", unit: "bar", color: "#a855f7", activeDefault: false, defaultVal: "1.8 bar", rangeMin: 0, rangeMax: 6, field: "press_steam" },
        { section: "PRESSURE", tag: "PIT 1003", desc: "Purge Air Pressure", unit: "bar", color: "#818cf8", activeDefault: false, defaultVal: "5.5 bar", rangeMin: 0, rangeMax: 10, field: "press_air" },
        { section: "PRESSURE", tag: "PIT 1004", desc: "Nitrogen Blanket Press", unit: "bar", color: "#60a5fa", activeDefault: false, defaultVal: "1.2 bar", rangeMin: 0, rangeMax: 4, field: "press_nitrogen" },
        { section: "PRESSURE", tag: "PIT 1005", desc: "Hydraulic Lift Pressure", unit: "bar", color: "#93c5fd", activeDefault: false, defaultVal: "120.0 bar", rangeMin: 0, rangeMax: 200, field: "press_hydraulic" },

        // --- DRIVE SUBSYSTEM ---
        { section: "DRIVES", tag: "1M1501 Speed", desc: "Main Agitator Drive", unit: "rpm", color: "#22c55e", activeDefault: true, defaultVal: "35.0 rpm", rangeMin: 0, rangeMax: 60, field: "speed_agitator" },
        { section: "DRIVES", tag: "2M1501 Speed", desc: "Wall Scraper Motor", unit: "rpm", color: "#10b981", activeDefault: false, defaultVal: "17.5 rpm", rangeMin: 0, rangeMax: 40, field: "speed_scraper" },
        { section: "DRIVES", tag: "1M2003 Speed", desc: "Homogenizer Rotor", unit: "rpm", color: "#eab308", activeDefault: true, defaultVal: "0 rpm", rangeMin: 0, rangeMax: 3500, field: "speed_homo" },
        { section: "DRIVES", tag: "3M1001 Speed", desc: "Discharge Pump", unit: "rpm", color: "#f59e0b", activeDefault: false, defaultVal: "0 rpm", rangeMin: 0, rangeMax: 600, field: "speed_pump" },
        { section: "DRIVES", tag: "4M1002 Speed", desc: "CIP Recirc Pump", unit: "rpm", color: "#4ade80", activeDefault: false, defaultVal: "0 rpm", rangeMin: 0, rangeMax: 1500, field: "speed_cip" },

        // --- PHYSICAL & ANALYTICAL SUBSYSTEM ---
        { section: "ANALYTICAL", tag: "LIT 1001", desc: "Vessel Product Weight", unit: "kg", color: "#a3e635", activeDefault: false, defaultVal: "42.5 kg", rangeMin: 0, rangeMax: 60, field: "weight_product" },
        { section: "ANALYTICAL", tag: "PH SENSOR 01", desc: "In-Line Emulsion pH", unit: "pH", color: "#2dd4bf", activeDefault: false, defaultVal: "6.8 pH", rangeMin: 0, rangeMax: 14, field: "ph_value" },
        { section: "ANALYTICAL", tag: "VISC SENSOR 01", desc: "Dynamic Viscosity", unit: "cP", color: "#06b6d4", activeDefault: false, defaultVal: "12400 cP", rangeMin: 0, rangeMax: 50000, field: "viscosity_cp" },

        // --- POWER & ELECTRICAL SUBSYSTEM ---
        { section: "POWER", tag: "KW TRANSMITTER", desc: "Total Skid Power", unit: "kW", color: "#38bdf8", activeDefault: false, defaultVal: "6.3 kW", rangeMin: 0, rangeMax: 45, field: "power_kw" },
        { section: "POWER", tag: "CURR 1M1501", desc: "Agitator Drive Current", unit: "A", color: "#14b8a6", activeDefault: false, defaultVal: "1.2 A", rangeMin: 0, rangeMax: 20, field: "curr_agitator" },
        { section: "POWER", tag: "CURR 1M2003", desc: "Homogenizer Current", unit: "A", color: "#0ea5e9", activeDefault: false, defaultVal: "0.5 A", rangeMin: 0, rangeMax: 35, field: "curr_homo" },
        { section: "POWER", tag: "CURR 5M1001", desc: "Hydraulic Pump Current", unit: "A", color: "#6366f1", activeDefault: false, defaultVal: "0.0 A", rangeMin: 0, rangeMax: 15, field: "curr_hydraulic" }
    ]

    function getSensorByField(field) {
        for (var i = 0; i < sensorCatalog.length; i++) {
            if (sensorCatalog[i].field === field) return sensorCatalog[i];
        }
        return null;
    }

    // =========================================================================
    // 5. CANONICAL ALARMS CATALOG (Single Source of Truth)
    // =========================================================================
    readonly property var alarmCatalog: [
        {
            id: "ALM-101",
            tag: "1TI1301",
            title: "VESSEL HIGH TEMP LIMIT EXCEEDED",
            severity: "CRITICAL",
            description: "Product temperature exceeded safe setpoint threshold (75.0°C).",
            source: "Reactor Core",
            actionReq: "Verify jacket cooling flow and throttle thermal power.",
            threshold: "Max 75.0 °C"
        },
        {
            id: "ALM-102",
            tag: "PR-3001",
            title: "VACUUM INTEGRITY DEVIATION",
            severity: "CRITICAL",
            description: "Main chamber pressure rose above allowable vacuum limit during active deaeration.",
            source: "Vacuum Skid",
            actionReq: "Check lid gasket seal and vacuum suction valve V303.",
            threshold: "Min -400 mbar"
        },
        {
            id: "ALM-103",
            tag: "1M1501",
            title: "AGITATOR MOTOR OVERLOAD WARNING",
            severity: "WARNING",
            description: "VFD motor driver current exceeded continuous running specification limit.",
            source: "Agitator VFD",
            actionReq: "Inspect product viscosity and lower agitator target RPM.",
            threshold: "Max 18.0 A"
        },
        {
            id: "ALM-104",
            tag: "FIT-2001",
            title: "JACKET COOLING FLOW RESTRICTION",
            severity: "WARNING",
            description: "Thermal jacket cooling water flow rate dropped below minimum threshold.",
            source: "Utility Line",
            actionReq: "Check inlet chiller valve and supply line pressure.",
            threshold: "Min 15 L/min"
        },
        {
            id: "ALM-105",
            tag: "1M2003",
            title: "HOMOGENIZER BEARING TEMPERATURE",
            severity: "WARNING",
            description: "Rotor seal housing temperature elevated above standard operating band.",
            source: "Homogenizer",
            actionReq: "Verify mechanical seal barrier fluid circulation.",
            threshold: "Max 65.0 °C"
        },
        {
            id: "ALM-106",
            tag: "LIT-1001",
            title: "VESSEL MAXIMUM FILL LEVEL REACHED",
            severity: "INFO",
            description: "Batch liquid mass reached target volume threshold (50.0 kg).",
            source: "Load Cells",
            actionReq: "Close raw material charge ports.",
            threshold: "Target 50.0 kg"
        },
        {
            id: "ALM-107",
            tag: "SYS-CIP",
            title: "SCHEDULED CIP VALIDATION REQUIRED",
            severity: "INFO",
            description: "Batch cycle complete. 21 CFR automated sanitization sequence recommended.",
            source: "CIP System",
            actionReq: "Execute validated CIP sanitization recipe.",
            threshold: "GAMP 5 Periodic"
        }
    ]

    // =========================================================================
    // 6. RECIPES & ISA-88 BATCH STAGES (Single Source of Truth)
    // =========================================================================
    readonly property var recipeCatalog: [
        {
            id: "REC-01",
            name: "UNIMIX_BATCH_01",
            product: "Carbopol 980 Pharma Gel",
            batchSize: "500 L",
            targetTemp: "70.0 °C",
            targetVacuum: "-450 mbar",
            agitatorRpm: "35 rpm",
            homoRpm: "2800 rpm",
            durationMins: 45
        },
        {
            id: "REC-02",
            name: "COSMETIC_CREAM_02",
            product: "Hydrating Day Emulsion",
            batchSize: "400 L",
            targetTemp: "75.0 °C",
            targetVacuum: "-500 mbar",
            agitatorRpm: "40 rpm",
            homoRpm: "3200 rpm",
            durationMins: 60
        },
        {
            id: "REC-03",
            name: "CIP_SANITIZATION_03",
            product: "Purified Water / CIP Rinse",
            batchSize: "200 L",
            targetTemp: "85.0 °C",
            targetVacuum: "0 mbar",
            agitatorRpm: "20 rpm",
            homoRpm: "1500 rpm",
            durationMins: 30
        }
    ]

    readonly property var standardRecipeStages: [
        { step: 1, name: "RAW MATERIAL CHARGING", desc: "Manual & vacuum loading of liquid base and active phase ingredients.", targetTemp: "25.0 °C", targetVac: "-200 mbar", agitatorRpm: "15 rpm", homoRpm: "0 rpm", durationSec: 300, autoNext: false },
        { step: 2, name: "THERMAL RAMP & PRE-MIXING", desc: "Jacket heating to 70°C with continuous counter-rotating agitation.", targetTemp: "70.0 °C", targetVac: "-300 mbar", agitatorRpm: "35 rpm", homoRpm: "0 rpm", durationSec: 600, autoNext: true },
        { step: 3, name: "VACUUM DEAERATION", desc: "High vacuum degassing to eliminate micro-bubbles from formulation.", targetTemp: "70.0 °C", targetVac: "-450 mbar", agitatorRpm: "25 rpm", homoRpm: "0 rpm", durationSec: 450, autoNext: true },
        { step: 4, name: "HIGH-SHEAR HOMOGENIZATION", desc: "Bottom-mounted rotor-stator high shear particle size reduction.", targetTemp: "68.0 °C", targetVac: "-450 mbar", agitatorRpm: "35 rpm", homoRpm: "2800 rpm", durationSec: 600, autoNext: true },
        { step: 5, name: "CONTROLLED COOLING & DISCHARGE", desc: "Cooling water circulation to 35°C and transfer via discharge valve.", targetTemp: "35.0 °C", targetVac: "0 mbar", agitatorRpm: "15 rpm", homoRpm: "0 rpm", durationSec: 450, autoNext: false }
    ]

    // =========================================================================
    // 7. HARDWARE VALVE DEFINITIONS & PRESET MATRICES
    // =========================================================================
    readonly property var valveList: [
        { tag: "V101", name: "Main Vessel Discharge Valve", isSolenoid: true, type: "solenoid" },
        { tag: "V102", name: "External Circulation Line Return Valve", isSolenoid: true, type: "solenoid" },
        { tag: "V103", name: "Recirculation Divert Valve", isSolenoid: true, type: "solenoid" },
        { tag: "V201", name: "CIP Rinse Water Valve", isSolenoid: true, type: "solenoid" },
        { tag: "V202", name: "CIP Drain Discharge Valve", isSolenoid: true, type: "solenoid" },
        { tag: "V203", name: "CIP Air Drying Valve", isSolenoid: true, type: "solenoid" },
        { tag: "V301", name: "Liquid Port Charging Butterfly Valve", isSolenoid: false, type: "manual_butterfly" },
        { tag: "V302", name: "Solids Powder Funnel Butterfly Valve", isSolenoid: false, type: "manual_butterfly" },
        { tag: "V303", name: "Bottom Suction Butterfly Valve", isSolenoid: false, type: "manual_butterfly" }
    ]

    readonly property var operationPresets: {
        "discharge_product": {
            name: "Discharge Product",
            instruction: "Product Discharge requires opening V101 & V102 solenoid valves, and manually setting V303 Butterfly Valve to OPEN position.",
            expected: { V101: "OPEN", V102: "OPEN", V103: "CLOSED", V201: "CLOSED", V202: "CLOSED", V203: "CLOSED", V301: "CLOSED", V302: "CLOSED", V303: "OPEN" }
        },
        "discharge_circulation_pipe": {
            name: "Discharge Circulation Pipe",
            instruction: "Discharge Circulation Pipe requires opening V101 & V102 solenoid valves, and closing all manual charging ports.",
            expected: { V101: "OPEN", V102: "OPEN", V103: "CLOSED", V201: "CLOSED", V202: "CLOSED", V203: "CLOSED", V301: "CLOSED", V302: "CLOSED", V303: "CLOSED" }
        },
        "recirculation": {
            name: "External Circulation",
            instruction: "External Circulation requires opening V102 & V103 solenoid valves, and closing all manual charging ports.",
            expected: { V101: "CLOSED", V102: "OPEN", V103: "OPEN", V201: "CLOSED", V202: "CLOSED", V203: "CLOSED", V301: "CLOSED", V302: "CLOSED", V303: "CLOSED" }
        },
        "cip_discharge": {
            name: "CIP Discharge",
            instruction: "CIP Drain Discharge requires opening V202 Drain Discharge solenoid valve.",
            expected: { V101: "CLOSED", V102: "CLOSED", V103: "CLOSED", V201: "CLOSED", V202: "OPEN", V203: "CLOSED", V301: "CLOSED", V302: "CLOSED", V303: "CLOSED" }
        },
        "cip_drying": {
            name: "CIP Drying",
            instruction: "CIP Air Drying requires opening V203 Air Drying solenoid valve.",
            expected: { V101: "CLOSED", V102: "CLOSED", V103: "CLOSED", V201: "CLOSED", V202: "CLOSED", V203: "OPEN", V301: "CLOSED", V302: "CLOSED", V303: "CLOSED" }
        },
        "cip_rinse": {
            name: "CIP Rinse Water",
            instruction: "CIP Water Rinse requires opening V201 Rinse & V202 Drain solenoid valves.",
            expected: { V101: "CLOSED", V102: "CLOSED", V103: "CLOSED", V201: "OPEN", V202: "OPEN", V203: "CLOSED", V301: "CLOSED", V302: "CLOSED", V303: "CLOSED" }
        },
        "suction_liquids": {
            name: "Suction Liquids",
            instruction: "Liquid Port Charging requires manually turning V301 Butterfly Valve to OPEN position.",
            expected: { V101: "CLOSED", V102: "CLOSED", V103: "CLOSED", V201: "CLOSED", V202: "CLOSED", V203: "CLOSED", V301: "OPEN", V302: "CLOSED", V303: "CLOSED" }
        },
        "suction_solids": {
            name: "Suction Solids",
            instruction: "Solids Powder Funnel Charging requires manually turning V302 Butterfly Valve to OPEN position.",
            expected: { V101: "CLOSED", V102: "CLOSED", V103: "CLOSED", V201: "CLOSED", V202: "CLOSED", V203: "CLOSED", V301: "CLOSED", V302: "OPEN", V303: "CLOSED" }
        },
        "suction_bottom": {
            name: "Suction Bottom",
            instruction: "Bottom Port Suction requires manually turning V303 Butterfly Valve to OPEN position.",
            expected: { V101: "CLOSED", V102: "CLOSED", V103: "CLOSED", V201: "CLOSED", V202: "CLOSED", V203: "CLOSED", V301: "CLOSED", V302: "CLOSED", V303: "OPEN" }
        }
    }

    function getPreset(key) {
        var normKey = String(key || "").toLowerCase();
        if (normKey.indexOf("ext_") === 0) normKey = normKey.substring(4);

        if (normKey === "discharge_circulation" || normKey === "discharge circulation" || normKey === "discharge circulation pipe") {
            normKey = "discharge_circulation_pipe";
        } else if (normKey === "discharge_product" || normKey === "discharge product") {
            normKey = "discharge_product";
        } else if (normKey === "cip_rinse" || normKey === "cip rinse") {
            normKey = "cip_rinse";
        } else if (normKey === "cip_discharge" || normKey === "cip discharge") {
            normKey = "cip_discharge";
        } else if (normKey === "cip_drying" || normKey === "cip drying") {
            normKey = "cip_drying";
        } else if (normKey === "recirculation" || normKey === "external_circulation" || normKey === "external circulation") {
            normKey = "recirculation";
        } else if (normKey === "suction_liquids" || normKey === "suction liquids") {
            normKey = "suction_liquids";
        } else if (normKey === "suction_solids" || normKey === "suction solids") {
            normKey = "suction_solids";
        } else if (normKey === "suction_bottom" || normKey === "suction bottom") {
            normKey = "suction_bottom";
        }

        return operationPresets[normKey] || operationPresets["discharge_circulation_pipe"];
    }

    // =========================================================================
    // 8. USER AUTHENTICATION & RBAC HIERARCHY (21 CFR Part 11)
    // =========================================================================
    readonly property var userList: [
        {
            id: "operator",
            name: "Line Operator",
            role: "Operator (Level 1)",
            level: 1,
            pin: "1234",
            description: "Standard production operation, alarm acknowledgement, process start/stop."
        },
        {
            id: "supervisor",
            name: "Production Supervisor",
            role: "Supervisor (Level 2)",
            level: 2,
            pin: "2345",
            description: "Recipe parameter adjustment, batch phase verification, alarm limit overrides."
        },
        {
            id: "qa_officer",
            name: "Florian Rismondo",
            role: "QA Officer (21 CFR Part 11)",
            level: 3,
            pin: "3456",
            description: "Electronic Batch Record sign-off, audit trail verification, batch release."
        },
        {
            id: "engineer",
            name: "Service Engineer",
            role: "Maintenance (Level 4)",
            level: 4,
            pin: "4567",
            description: "Hardware I/O diagnostics, motor VFD calibration, forced valve overrides."
        },
        {
            id: "admin",
            name: "System Administrator",
            role: "Administrator (Level 5)",
            level: 5,
            pin: "9999",
            description: "Full unrestricted system access, user management, security audit log export."
        }
    ]

    function getUser(userId) {
        for (var i = 0; i < userList.length; i++) {
            if (userList[i].id === userId) return userList[i];
        }
        return userList[0];
    }

    function verifyCredentials(userId, pin) {
        var user = getUser(userId);
        return (user && user.pin === pin);
    }

    // =========================================================================
    // 9. MOTOR & EQUIPMENT SPECIFICATIONS
    // =========================================================================
    readonly property var motorSpecs: {
        "stirrer": {
            name: "Agitator Stirrer (1M1501)",
            peakPowerKw: 8.0,
            peakCurrentA: 25.0,
            minSpeedRpm: 30.0,
            maxSpeedRpm: 220.0,
            defaultSpeedRpm: 40.0
        },
        "homogenizer": {
            name: "High-Shear Homogenizer (1M2003)",
            peakPowerKw: 20.0,
            peakCurrentA: 38.0,
            minSpeedRpm: 500.0,
            maxSpeedRpm: 8000.0,
            defaultSpeedRpm: 2500.0
        },
        "vacuum": {
            name: "Vacuum Pump System (1P1001)",
            minPressureMbar: -1000.0,
            maxPressureMbar: 0.0,
            vacuumPresetMbar: -400.0,
            materialLoadingPresetMbar: -850.0,
            allowedDeviationMbar: 5.0
        }
    }

    // =========================================================================
    // 10. PROCESS ROW VISIBILITY MATRIX
    // =========================================================================
    readonly property var rowVisibility: {
        "row1_agitator": true,
        "row2_homogenizer": true,
        "row3_recirculation": true,
        "row4_vacuum": true,
        "row5_suction_ports": false,
        "row6_heating_cooling": true
    }
}

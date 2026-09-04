import QtQuick

Item {
    id: hardwareDefs

    // =========================================================================
    // 1. ANCHOR AGITATOR SUBSYSTEM (M 162 001 / 1M1501)
    // =========================================================================
    readonly property var agitator: ({
        "tagPrefix": "MAIN_AGITATOR",
        "displayName": "Main Anchor Agitator",
        "unit": "RPM",
        "minSpeed": 25.0,
        "maxSpeed": 120.0,
        "defaultSpeed": 25.0,
        "stepResolution": 1.0,
        "decimals": 1,
        "interlockMinTempAgitation": 15.0, // Agitator must run >= 15 RPM during jacket heating
        "modes": [
            {
                "id": "agitator_cw",
                "code": "CW_DOWN",
                "title": "Clockwise (CW)",
                "subtitle": "Down-Pumping",
                "icon": "agitator_cw"
            },
            {
                "id": "agitator_ccw",
                "code": "CCW_UP",
                "title": "Counter-CW (CCW)",
                "subtitle": "Up-Pumping",
                "icon": "agitator_ccw"
            },
            {
                "id": "agitator_reversing",
                "code": "REVERSING",
                "title": "Reversing Cycle",
                "subtitle": "Interval CW/CCW",
                "icon": "agitator_reversing"
            }
        ]
    })

    // =========================================================================
    // 2. HIGH SHEAR HOMOGENIZER SUBSYSTEM (M 163 001 / 1M2003)
    // =========================================================================
    readonly property var homogenizer: ({
        "tagPrefix": "MAIN_HOMOGENIZER",
        "displayName": "High Shear Homogenizer",
        "unit": "RPM",
        "minSpeed": 600.0,
        "maxSpeed": 4800.0,
        "defaultSpeed": 2800.0,
        "stepResolution": 50.0,
        "decimals": 0,
        "interlockSealFlushFlowTag": "FS-102",
        "interlockMinVesselLevelL": 150.0,
        "modes": [
            {
                "id": "homo_permanent",
                "code": "CONTINUOUS",
                "title": "Permanent",
                "subtitle": "Continuous Run",
                "icon": "homo_permanent"
            },
            {
                "id": "homo_interval",
                "code": "INTERVAL_PULSE",
                "title": "Interval Pulse",
                "subtitle": "(Timer ON/OFF)",
                "icon": "homo_interval"
            },
            {
                "id": "homogenizer",
                "code": "RECIRCULATION",
                "title": "Internal Vessel",
                "subtitle": "Recirculation",
                "icon": "homogenizer"
            }
        ]
    })

    // =========================================================================
    // 3. VACUUM & DEAERATION SUBSYSTEM (1M3001)
    // =========================================================================
    readonly property var vacuum: ({
        "tagPrefix": "MAIN_VACUUM",
        "displayName": "Vacuum De-Aeration",
        "unit": "mbar",
        "minPressure": -800.0,
        "maxPressure": 0.0,
        "defaultStart": -400.0,
        "defaultEnd": -450.0,
        "stepResolution": 10.0,
        "decimals": 1,
        "modes": [
            {
                "id": "vac_auto_drawdown",
                "code": "AUTOMATIC_DRAWDOWN",
                "title": "Automatic Drawdown",
                "subtitle": "Vacuum Header Control",
                "icon": "vacuum_gauge"
            },
            {
                "id": "vac_manual_hose",
                "code": "MANUAL_HOSE_TRANSFER",
                "title": "Manual Hose Suction",
                "subtitle": "Wand Transfer Line",
                "icon": "suction_liquids"
            },
            {
                "id": "vac_vent_atm",
                "code": "ATMOSPHERIC_VENT",
                "title": "Atmospheric Vent",
                "subtitle": "Sterile Breather Filter",
                "icon": "vacuum_gauge"
            }
        ]
    })

    // =========================================================================
    // 4. THERMAL JACKET SUBSYSTEM (HEATING & COOLING)
    // =========================================================================
    readonly property var jacket: ({
        "tagPrefix": "JACKET_THERMAL",
        "displayName": "Jacket Heating / Cooling",
        "unit": "°C",
        "minTemp": 15.0,
        "maxTemp": 95.0,
        "defaultTemp": 70.0,
        "stepResolution": 0.5,
        "decimals": 1,
        "minGradient": 1.0,
        "maxGradient": 30.0, // °C/h
        "defaultGradient": 12.0,
        "gradientStep": 0.5,
        "modes": [
            {
                "id": "heat_mode_heating",
                "code": "HEATING",
                "title": "Heating Mode",
                "subtitle": "Utility Steam Modulation",
                "icon": "heat_mode_heating"
            },
            {
                "id": "heat_mode_cooling",
                "code": "COOLING",
                "title": "Cooling Mode",
                "subtitle": "Tower / Chilled Water",
                "icon": "heat_mode_cooling"
            }
        ]
    })

    // Helper functions
    function getAgitatorMode(modeId) {
        for (var i = 0; i < agitator.modes.length; i++) {
            if (agitator.modes[i].id === modeId || agitator.modes[i].code === modeId) {
                return agitator.modes[i];
            }
        }
        return agitator.modes[0];
    }

    function getHomogenizerMode(modeId) {
        for (var i = 0; i < homogenizer.modes.length; i++) {
            if (homogenizer.modes[i].id === modeId || homogenizer.modes[i].code === modeId) {
                return homogenizer.modes[i];
            }
        }
        return homogenizer.modes[0];
    }

    function getVacuumMode(modeId) {
        for (var i = 0; i < vacuum.modes.length; i++) {
            if (vacuum.modes[i].id === modeId || vacuum.modes[i].code === modeId) {
                return vacuum.modes[i];
            }
        }
        return vacuum.modes[0];
    }

    function getJacketMode(modeId) {
        for (var i = 0; i < jacket.modes.length; i++) {
            if (jacket.modes[i].id === modeId || jacket.modes[i].code === modeId) {
                return jacket.modes[i];
            }
        }
        return jacket.modes[0];
    }
}

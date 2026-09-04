// PVA_VPU50_SCADAContent/theme/AppConstants.qml
pragma Singleton
import QtQuick

Item {
    // Standard UI Placeholders
    readonly property string placeholderTitle:       "Enter Process Step Name..."
    readonly property string placeholderInstruction: "Specify exact operator instructions here..."
    readonly property string placeholderNumeric:     "0.0"

    // Standard Units
    readonly property string unitRpm:        "RPM"
    readonly property string unitTemp:       "°C"
    readonly property string unitVacuum:     "mbar"
    readonly property string unitSeconds:    "sec"
    readonly property string unitMinutes:    "min"

    // Asset Source Paths
    readonly property string iconAgitator:   "qrc:/PVA_VPU50_SCADAContent/assets/icons/equipment/stirrer_anchor.svg"
    readonly property string iconHomo:       "qrc:/PVA_VPU50_SCADAContent/assets/icons/equipment/homogenizer_rotor.svg"
    readonly property string iconJacket:     "qrc:/PVA_VPU50_SCADAContent/assets/icons/equipment/heating_thermometer.svg"
    readonly property string iconVacuum:     "qrc:/PVA_VPU50_SCADAContent/assets/icons/equipment/vacuum_gauge.svg"
    readonly property string iconManual:     "qrc:/PVA_VPU50_SCADAContent/assets/icons/equipment/suction_funnel.svg"
}

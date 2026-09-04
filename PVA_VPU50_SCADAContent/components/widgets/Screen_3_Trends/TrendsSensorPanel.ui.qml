/*
This is a UI file (.ui.qml) for Trends Sensor Channel Panel.
Strictly declarative for Qt Design Studio. Uses SVG icons for web/WASM compatibility.
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: sensorPanelRoot
    width: panelWidth
    height: 560
    implicitWidth: panelWidth
    implicitHeight: 560
    Layout.preferredWidth: panelWidth
    Layout.fillHeight: true
    radius: 6
    color: "#071c33"
    border.color: "#184d7e"
    border.width: 1.2

    property int panelWidth: 350
    property alias selectAllBtnItem: selectAllActionButton
    property alias clearAllBtnItem: clearAllActionButton
    property alias sensorListViewItem: sensorChannelListView

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6

        // 1. Header with Ergonomic High-Visibility "Select All" / "Clear All" Touch Buttons
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 46
            radius: 5
            color: "#0d2b4a"
            border.color: "#184d7e"
            border.width: 1.0

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                anchors.topMargin: 4
                anchors.bottomMargin: 4
                spacing: 6

                Image {
                    source: "../../../assets/icons/nav/tools_maintenance.svg"
                    width: 16
                    height: 16
                    sourceSize: Qt.size(16, 16)
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    text: "SENSORS"
                    color: "#38bdf8"
                    font.bold: true
                    font.pixelSize: 12
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Rectangle {
                    id: selectAllActionButton
                    Layout.preferredWidth: 88
                    Layout.preferredHeight: 32
                    radius: 4
                    color: "#1e3a8a"
                    border.color: "#38bdf8"
                    border.width: 1.2
                    Text { anchors.centerIn: parent; text: "Select All"; color: "#ffffff"; font.pixelSize: 11; font.bold: true }
                }
                Rectangle {
                    id: clearAllActionButton
                    Layout.preferredWidth: 82
                    Layout.preferredHeight: 32
                    radius: 4
                    color: "#334155"
                    border.color: "#64748b"
                    border.width: 1.2
                    Text { anchors.centerIn: parent; text: "Clear All"; color: "#ffffff"; font.pixelSize: 11; font.bold: true }
                }
            }
        }

        // 2. Comprehensive Industrial Process Sensor Catalog
        ListView {
            id: sensorChannelListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 5
            ScrollBar.vertical: ScrollBar {
                active: true
                policy: ScrollBar.AlwaysOn
                width: 6
            }

            model: ListModel {
                id: sensorModelCatalogItems
                
                // --- TEMPERATURE SUBSYSTEM ---
                ListElement { section: "TEMPERATURE"; tag: "RTD 1TI1301"; desc: "Main Vessel Temp"; unit: "°C"; color: "#38bdf8"; active: true; val: "34.4 °C"; rangeMin: 0; rangeMax: 120; field: "temp_vessel" }
                ListElement { section: "TEMPERATURE"; tag: "RTD 2TI1001"; desc: "Jacket Thermal Temp"; unit: "°C"; color: "#f97316"; active: true; val: "46.9 °C"; rangeMin: 0; rangeMax: 140; field: "temp_jacket" }
                ListElement { section: "TEMPERATURE"; tag: "RTD HEATER 1"; desc: "Heater Element 01"; unit: "°C"; color: "#f43f5e"; active: false; val: "43.4 °C"; rangeMin: 0; rangeMax: 160; field: "temp_heater1" }
                ListElement { section: "TEMPERATURE"; tag: "RTD HEATER 2"; desc: "Heater Element 02"; unit: "°C"; color: "#ec4899"; active: false; val: "42.9 °C"; rangeMin: 0; rangeMax: 160; field: "temp_heater2" }
                ListElement { section: "TEMPERATURE"; tag: "RTD 3TI1003"; desc: "Lid Surface Temp"; unit: "°C"; color: "#fb7185"; active: false; val: "28.4 °C"; rangeMin: 0; rangeMax: 100; field: "temp_lid" }
                ListElement { section: "TEMPERATURE"; tag: "RTD 4TI1004"; desc: "Cooling Return Temp"; unit: "°C"; color: "#34d399"; active: false; val: "21.5 °C"; rangeMin: 0; rangeMax: 100; field: "temp_coolwater" }
                ListElement { section: "TEMPERATURE"; tag: "RTD 5TI1005"; desc: "Steam Condensate Temp"; unit: "°C"; color: "#fb923c"; active: false; val: "88.2 °C"; rangeMin: 0; rangeMax: 150; field: "temp_condensate" }

                // --- PRESSURE SUBSYSTEM ---
                ListElement { section: "PRESSURE"; tag: "PR TRANSMITTER"; desc: "Chamber Vacuum"; unit: "mbar"; color: "#c084fc"; active: true; val: "-450.0 mbar"; rangeMin: -1000; rangeMax: 0; field: "vacuum_pressure" }
                ListElement { section: "PRESSURE"; tag: "PIT 1002"; desc: "Jacket Steam Pressure"; unit: "bar"; color: "#a855f7"; active: false; val: "1.8 bar"; rangeMin: 0; rangeMax: 6; field: "press_steam" }
                ListElement { section: "PRESSURE"; tag: "PIT 1003"; desc: "Purge Air Pressure"; unit: "bar"; color: "#818cf8"; active: false; val: "5.5 bar"; rangeMin: 0; rangeMax: 10; field: "press_air" }
                ListElement { section: "PRESSURE"; tag: "PIT 1004"; desc: "Nitrogen Blanket Press"; unit: "bar"; color: "#60a5fa"; active: false; val: "1.2 bar"; rangeMin: 0; rangeMax: 4; field: "press_nitrogen" }
                ListElement { section: "PRESSURE"; tag: "PIT 1005"; desc: "Hydraulic Lift Pressure"; unit: "bar"; color: "#93c5fd"; active: false; val: "120.0 bar"; rangeMin: 0; rangeMax: 200; field: "press_hydraulic" }

                // --- DRIVE SUBSYSTEM ---
                ListElement { section: "DRIVES"; tag: "1M1501 Speed"; desc: "Main Agitator Drive"; unit: "rpm"; color: "#22c55e"; active: true; val: "35.0 rpm"; rangeMin: 0; rangeMax: 60; field: "speed_agitator" }
                ListElement { section: "DRIVES"; tag: "2M1501 Speed"; desc: "Wall Scraper Motor"; unit: "rpm"; color: "#10b981"; active: false; val: "17.5 rpm"; rangeMin: 0; rangeMax: 40; field: "speed_scraper" }
                ListElement { section: "DRIVES"; tag: "1M2003 Speed"; desc: "Homogenizer Rotor"; unit: "rpm"; color: "#eab308"; active: true; val: "0 rpm"; rangeMin: 0; rangeMax: 3500; field: "speed_homo" }
                ListElement { section: "DRIVES"; tag: "3M1001 Speed"; desc: "Discharge Pump"; unit: "rpm"; color: "#f59e0b"; active: false; val: "0 rpm"; rangeMin: 0; rangeMax: 600; field: "speed_pump" }
                ListElement { section: "DRIVES"; tag: "4M1002 Speed"; desc: "CIP Recirc Pump"; unit: "rpm"; color: "#4ade80"; active: false; val: "0 rpm"; rangeMin: 0; rangeMax: 1500; field: "speed_cip" }

                // --- PHYSICAL & ANALYTICAL SUBSYSTEM ---
                ListElement { section: "ANALYTICAL"; tag: "LIT 1001"; desc: "Vessel Product Weight"; unit: "kg"; color: "#a3e635"; active: false; val: "42.5 kg"; rangeMin: 0; rangeMax: 60; field: "weight_product" }
                ListElement { section: "ANALYTICAL"; tag: "PH SENSOR 01"; desc: "In-Line Emulsion pH"; unit: "pH"; color: "#2dd4bf"; active: false; val: "6.8 pH"; rangeMin: 0; rangeMax: 14; field: "ph_value" }
                ListElement { section: "ANALYTICAL"; tag: "VISC SENSOR 01"; desc: "Dynamic Viscosity"; unit: "cP"; color: "#06b6d4"; active: false; val: "12400 cP"; rangeMin: 0; rangeMax: 50000; field: "viscosity_cp" }

                // --- POWER & ELECTRICAL SUBSYSTEM ---
                ListElement { section: "POWER"; tag: "KW TRANSMITTER"; desc: "Total Skid Power"; unit: "kW"; color: "#38bdf8"; active: false; val: "6.3 kW"; rangeMin: 0; rangeMax: 45; field: "power_kw" }
                ListElement { section: "POWER"; tag: "CURR 1M1501"; desc: "Agitator Drive Current"; unit: "A"; color: "#14b8a6"; active: false; val: "1.2 A"; rangeMin: 0; rangeMax: 20; field: "curr_agitator" }
                ListElement { section: "POWER"; tag: "CURR 1M2003"; desc: "Homogenizer Current"; unit: "A"; color: "#0ea5e9"; active: false; val: "0.5 A"; rangeMin: 0; rangeMax: 35; field: "curr_homo" }
                ListElement { section: "POWER"; tag: "CURR 5M1001"; desc: "Hydraulic Pump Current"; unit: "A"; color: "#6366f1"; active: false; val: "0.0 A"; rangeMin: 0; rangeMax: 15; field: "curr_hydraulic" }
            }

            delegate: Rectangle {
                id: sensorCardItem
                width: ListView.view ? ListView.view.width - 10 : 340
                height: 52
                radius: 5
                color: model.active ? "#0e3c66" : "#081d33"
                border.color: model.active ? model.color : "#184d7e"
                border.width: model.active ? 1.8 : 1.0

                // 1. Leftmost Status Circle Indicator
                Rectangle {
                    id: statusDot
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    width: 14
                    height: 14
                    radius: 7
                    color: model.active ? model.color : "#334155"
                    border.color: model.active ? "#ffffff" : "#475569"
                    border.width: model.active ? 1.5 : 1.0
                }

                // 2. Right-Anchored Value Readout Pill (Strictly anchored to right edge!)
                Rectangle {
                    id: valuePill
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    height: 32
                    width: Math.max(90, valueText.implicitWidth + 18)
                    radius: 4
                    color: "#051627"
                    border.color: model.active ? model.color : "#1e3a8a"
                    border.width: 1.0

                    Text {
                        id: valueText
                        anchors.centerIn: parent
                        text: model.val
                        color: model.active ? model.color : "#94a3b8"
                        font.bold: true
                        font.pixelSize: 11
                    }
                }

                // 3. Middle Dynamic Title & Description (Elides with ... if panel is squeezed)
                Column {
                    anchors.left: statusDot.right
                    anchors.leftMargin: 10
                    anchors.right: valuePill.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    clip: true

                    Text {
                        width: parent.width
                        text: model.tag
                        color: model.active ? "#ffffff" : "#cbd5e1"
                        font.bold: true
                        font.pixelSize: 12
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: model.desc
                        color: "#94a3b8"
                        font.pixelSize: 10
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}

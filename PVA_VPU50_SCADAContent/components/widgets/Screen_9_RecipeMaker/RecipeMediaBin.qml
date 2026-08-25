pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../../../components/widgets"

Rectangle {
    id: mediaBinRoot
    implicitWidth: 260
    implicitHeight: 500
    Layout.fillHeight: true
    color: "#071b30"
    border.color: "#1d5b94"
    border.width: 1
    radius: 6

    property var ingredientsList: [] // Populated from Screen 2
    property bool motorsExpanded: true
    property bool utilitiesExpanded: true
    property bool ingredientsExpanded: true
    property bool manualExpanded: true

    signal resourceSelected(var resourceData)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 6

        // Bin Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            radius: 4
            color: "#0b2e52"
            border.color: "#1d5b94"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 6

                ScadaIcon {
                    Layout.preferredWidth: 18
                    Layout.preferredHeight: 18
                    iconName: "act_equip"
                }

                Text {
                    text: "RESOURCE MEDIA BIN"
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 11
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "Drag / Click"
                    color: "#64748b"
                    font.pixelSize: 9
                }
            }
        }

        // Scrollable Accordion Content
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: contentCol.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: contentCol
                width: parent.width
                spacing: 6

                // =============================================================
                // ACCORDION 1: MOTORS & DRIVES
                // =============================================================
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    radius: 3
                    color: "#0d365e"
                    border.color: "#1d5b94"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 6

                        Text {
                            text: mediaBinRoot.motorsExpanded ? "▼" : "▶"
                            color: "#38bdf8"
                            font.pixelSize: 10
                        }

                        Text {
                            text: "MOTORS & ROTATING DRIVES"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 10
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mediaBinRoot.motorsExpanded = !mediaBinRoot.motorsExpanded
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    visible: mediaBinRoot.motorsExpanded
                    spacing: 4

                    Repeater {
                        model: [
                            { type: "agitator", tag: "1M1501", name: "Anchor Agitator Stirrer", min: 0, max: 60, unit: "RPM", defVal: "25", icon: "stirrer_anchor" },
                            { type: "homogenizer", tag: "1X1001", name: "High-Shear Homogenizer", min: 0, max: 3600, unit: "RPM", defVal: "1800", icon: "homogenizer_rotor" },
                            { type: "vacuum", tag: "1M5001", name: "Vacuum De-aeration Pump", min: -900, max: 0, unit: "mbar", defVal: "-400", icon: "vacuum_gauge" }
                        ]
                        delegate: Rectangle {
                            id: motorCard
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 38
                            radius: 4
                            color: mMouse.containsMouse ? "#124373" : "#092442"
                            border.color: mMouse.containsMouse ? "#38bdf8" : "#1d5b94"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 6
                                spacing: 8

                                ScadaIcon {
                                    Layout.preferredWidth: 20
                                    Layout.preferredHeight: 20
                                    iconName: motorCard.modelData.icon
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text {
                                        text: motorCard.modelData.name
                                        color: "#ffffff"
                                        font.bold: true
                                        font.pixelSize: 10
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        text: motorCard.modelData.tag + " (" + motorCard.modelData.min + " - " + motorCard.modelData.max + " " + motorCard.modelData.unit + ")"
                                        color: "#94a3b8"
                                        font.pixelSize: 9
                                    }
                                }

                                Text {
                                    text: "✚"
                                    color: "#38bdf8"
                                    font.bold: true
                                    font.pixelSize: 12
                                }
                            }

                            MouseArea {
                                id: mMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: mediaBinRoot.resourceSelected(motorCard.modelData)
                            }
                        }
                    }
                }

                // =============================================================
                // ACCORDION 2: ASSEMBLIES & UTILITIES
                // =============================================================
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    radius: 3
                    color: "#0d365e"
                    border.color: "#1d5b94"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 6

                        Text {
                            text: mediaBinRoot.utilitiesExpanded ? "▼" : "▶"
                            color: "#38bdf8"
                            font.pixelSize: 10
                        }

                        Text {
                            text: "THERMAL & UTILITY ASSEMBLIES"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 10
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mediaBinRoot.utilitiesExpanded = !mediaBinRoot.utilitiesExpanded
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    visible: mediaBinRoot.utilitiesExpanded
                    spacing: 4

                    Repeater {
                        model: [
                            { type: "heater", tag: "1E6001", name: "Jacket Heating Circuit", min: 20, max: 95, unit: "°C", defVal: "80", icon: "heating_thermometer" },
                            { type: "cooler", tag: "1E6001", name: "Jacket Cooling Circuit", min: 10, max: 40, unit: "°C", defVal: "25", icon: "heat_mode_cooling" },
                            { type: "fillValve", tag: "1K1001", name: "Charging Port Suction Valve", min: 0, max: 100, unit: "% Open", defVal: "100", icon: "suction_funnel" },
                            { type: "drainValve", tag: "1M2001", name: "Bottom Discharge / Recirc", min: 0, max: 100, unit: "% Open", defVal: "100", icon: "ext_discharge_circulation" }
                        ]
                        delegate: Rectangle {
                            id: utilCard
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 38
                            radius: 4
                            color: uMouse.containsMouse ? "#124373" : "#092442"
                            border.color: uMouse.containsMouse ? "#38bdf8" : "#1d5b94"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 6
                                spacing: 8

                                ScadaIcon {
                                    Layout.preferredWidth: 20
                                    Layout.preferredHeight: 20
                                    iconName: utilCard.modelData.icon
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text {
                                        text: utilCard.modelData.name
                                        color: "#ffffff"
                                        font.bold: true
                                        font.pixelSize: 10
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        text: utilCard.modelData.tag + " (" + utilCard.modelData.min + " - " + utilCard.modelData.max + " " + utilCard.modelData.unit + ")"
                                        color: "#94a3b8"
                                        font.pixelSize: 9
                                    }
                                }

                                Text {
                                    text: "✚"
                                    color: "#38bdf8"
                                    font.bold: true
                                    font.pixelSize: 12
                                }
                            }

                            MouseArea {
                                id: uMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: mediaBinRoot.resourceSelected(utilCard.modelData)
                            }
                        }
                    }
                }

                // =============================================================
                // ACCORDION 3: FORMULATION INGREDIENTS (SCREEN 2)
                // =============================================================
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    radius: 3
                    color: "#0d365e"
                    border.color: "#1d5b94"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 6

                        Text {
                            text: mediaBinRoot.ingredientsExpanded ? "▼" : "▶"
                            color: "#38bdf8"
                            font.pixelSize: 10
                        }

                        Text {
                            text: "FORMULATION RAW MATERIALS (" + mediaBinRoot.ingredientsList.length + ")"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 10
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mediaBinRoot.ingredientsExpanded = !mediaBinRoot.ingredientsExpanded
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    visible: mediaBinRoot.ingredientsExpanded
                    spacing: 4

                    Repeater {
                        model: mediaBinRoot.ingredientsList
                        delegate: Rectangle {
                            id: ingCard
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            radius: 3
                            color: ingMouse.containsMouse ? "#164e85" : "#081d33"
                            border.color: ingMouse.containsMouse ? "#38bdf8" : "#1d5b94"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 6

                                Rectangle {
                                    Layout.preferredWidth: 20
                                    Layout.preferredHeight: 18
                                    radius: 2
                                    color: ingCard.modelData.phase === "A" ? "#0369a1" : (ingCard.modelData.phase === "B" ? "#b45309" : (ingCard.modelData.phase === "C" ? "#047857" : "#6b21a8"))
                                    Text {
                                        anchors.centerIn: parent
                                        text: ingCard.modelData.phase
                                        color: "#ffffff"
                                        font.bold: true
                                        font.pixelSize: 9
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: ingCard.modelData.name
                                    color: "#e2e8f0"
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: ingCard.modelData.qty
                                    color: "#34d399"
                                    font.bold: true
                                    font.pixelSize: 9
                                }
                            }

                            MouseArea {
                                id: ingMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var resData = {
                                        type: "fillValve",
                                        tag: "1K1001",
                                        name: "Charge: " + ingCard.modelData.name,
                                        min: 0,
                                        max: 100,
                                        unit: "% Open",
                                        defVal: "100",
                                        phase: ingCard.modelData.phase,
                                        material: ingCard.modelData.name
                                    };
                                    mediaBinRoot.resourceSelected(resData);
                                }
                            }
                        }
                    }
                }

                // =============================================================
                // ACCORDION 4: MANUAL ACTIVITIES & SEQUENCE INTERLOCKS
                // =============================================================
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    radius: 3
                    color: "#581c87"
                    border.color: "#c084fc"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 6

                        Text {
                            text: mediaBinRoot.manualExpanded ? "▼" : "▶"
                            color: "#facc15"
                            font.pixelSize: 10
                        }

                        Text {
                            text: "✋ MANUAL ACTIVITIES & INTERLOCKS"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 10
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mediaBinRoot.manualExpanded = !mediaBinRoot.manualExpanded
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    visible: mediaBinRoot.manualExpanded
                    spacing: 4

                    Repeater {
                        model: [
                            { type: "manualActivity", target: "Butterfly Valve abc123", req: "OPEN", tag: "V101", name: "Manual Butterfly Valve abc123", icon: "act_manual" },
                            { type: "manualActivity", target: "Charging Hatch Clamp", req: "OPEN", tag: "H101", name: "Top Charging Hatch Clamp", icon: "act_hold" },
                            { type: "manualActivity", target: "Sight Glass Window", req: "VERIFY", tag: "SG101", name: "Sight Glass Visual Inspection", icon: "icon_check" },
                            { type: "manualActivity", target: "Sampling Valve V204", req: "OPEN", tag: "V204", name: "Manual Sampling Valve V204", icon: "act_manual" },
                            { type: "manualActivity", target: "Powder Funnel V301", req: "OPEN", tag: "V301", name: "Powder Funnel V301 Induction", icon: "suction_funnel" }
                        ]
                        delegate: Rectangle {
                            id: manCard
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 38
                            radius: 4
                            color: manMouse.containsMouse ? "#78350f" : "#451a03"
                            border.color: manMouse.containsMouse ? "#fcd34d" : "#d97706"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 6
                                spacing: 8

                                Rectangle {
                                    Layout.preferredWidth: 22
                                    Layout.preferredHeight: 22
                                    radius: 3
                                    color: "#78350f"
                                    border.color: "#fbbf24"
                                    border.width: 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: "✋"
                                        font.pixelSize: 11
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text {
                                        text: manCard.modelData.name
                                        color: "#ffffff"
                                        font.bold: true
                                        font.pixelSize: 10
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        text: "Req: " + manCard.modelData.req + " | Sequence Hold Gate"
                                        color: "#fde68a"
                                        font.pixelSize: 9
                                    }
                                }

                                Text {
                                    text: "✚"
                                    color: "#facc15"
                                    font.bold: true
                                    font.pixelSize: 12
                                }
                            }

                            MouseArea {
                                id: manMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: mediaBinRoot.resourceSelected(manCard.modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}

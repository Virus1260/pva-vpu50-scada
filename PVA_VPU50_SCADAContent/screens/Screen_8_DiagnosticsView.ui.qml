/*
This is a UI file (.ui.qml) for Screen 8: Delta PLC Communication & COMMGR Diagnostics.
Strictly declarative for Qt Design Studio.
*/

import QtQuick
import QtQuick.Layouts

Rectangle {
    id: commgrRoot
    width: 1184
    height: 626
    color: "#08213b"

    // Property Aliases for Controller Binding
    property alias targetIpInput: ipField.text
    property alias targetPortInput: portField.text
    property alias connectMouseArea: applyArea
    property alias scanMouseArea: scanArea
    property alias selectIp2MouseArea: selectNode2Area

    property bool isConnected: true
    property bool isScanning: false
    property string currentConnectedIp: "192.168.1.7"
    property alias linkStatusText: linkStatusLabel.text
    property alias latencyText: latencyLabel.text
    property alias packetStatsText: packetStatsLabel.text
    property alias scanStatusText: scanStatusLabel.text

    // Dynamic ListModels
    property alias discoveredDevicesModel: discoveredDevicesModel
    property alias discoveredDevicesListView: discoveredDevicesListView
    property alias rackModulesModel: rackModulesModel
    property alias rackModulesListView: rackModulesListView

    // Digital Outputs Y0.0 - Y0.15
    property bool y0_0: false
    property bool y0_1: false
    property bool y0_2: false
    property bool y0_3: false
    property bool y0_4: false
    property bool y0_5: false
    property bool y0_6: false
    property bool y0_7: false
    property bool y0_8: false
    property bool y0_9: false
    property bool y0_10: false
    property bool y0_11: false
    property bool y0_12: false
    property bool y0_13: false
    property bool y0_14: false
    property bool y0_15: false

    // Digital Inputs CPU X0.0 - X0.7
    property bool x0_0: false
    property bool x0_1: false
    property bool x0_2: false
    property bool x0_3: false
    property bool x0_4: false
    property bool x0_5: false
    property bool x0_6: false
    property bool x0_7: false

    // Digital Inputs Extension X1.0 - X1.7
    property bool x1_0: false
    property bool x1_1: false
    property bool x1_2: false
    property bool x1_3: false
    property bool x1_4: false
    property bool x1_5: false
    property bool x1_6: false
    property bool x1_7: false

    // Telemetry Registers
    property alias agitSpeedText: agitSpeedLabel.text
    property alias homoSpeedText: homoSpeedLabel.text
    property alias prodTempText: prodTempLabel.text
    property alias jacketTempText: jacketTempLabel.text
    property alias aiErrorText: aiErrorLabel.text
    property alias rtdErrorText: rtdErrorLabel.text

    // Backward-compatible MouseArea for external selectors
    MouseArea {
        id: selectNode2Area
        visible: false
        enabled: false
    }

    // Dynamic Discovery ListModel
    ListModel {
        id: discoveredDevicesModel
        ListElement {
            ip: "192.168.1.7"
            device: "Delta AS-FFTP01 Ethernet Card"
            ports: "502 (Modbus), 80, 4840"
            mac: "56:F0:3A:39:10:CC"
            status: "ACTIVE LINK"
            rtt: "1ms"
            isCurrent: true
        }
        ListElement {
            ip: "192.168.1.5"
            device: "Delta AS332T-A CPU Main Port"
            ports: "Standby / Port Unlinked"
            mac: "00:18:23:xx:xx:xx"
            status: "STANDBY"
            rtt: "--"
            isCurrent: false
        }
        ListElement {
            ip: "192.168.1.10"
            device: "Host PC (Realtek GbE Controller)"
            ports: "Local Adapter"
            mac: "Local Machine"
            status: "LOCAL HOST"
            rtt: "0ms"
            isCurrent: false
        }
    }

    // Dynamic Rack Topology ListModel
    ListModel {
        id: rackModulesModel
        ListElement {
            slot: "PS"
            name: "AS-PS02"
            desc: "Power Supply (24VDC 2.0A)"
            status: "NORMAL"
            detail: "24VDC Output, 2000mA Capacity"
            isFault: false
        }
        ListElement {
            slot: "CPU"
            name: "AS332T-A"
            desc: "Main CPU (16 DI / 16 DO Transistor)"
            status: "RUN"
            detail: "Firmware v1.08.01, Modbus Port 502"
            isFault: false
        }
        ListElement {
            slot: "CARD2"
            name: "AS-FFTP01"
            desc: "Ethernet Function Card"
            status: "CONNECTED"
            detail: "192.168.1.7 | Cable Plugged In"
            isFault: false
        }
        ListElement {
            slot: "SLOT 1"
            name: "AS16AM10N-A"
            desc: "16 Digital Inputs (X1.0-X1.15)"
            status: "READY"
            detail: "24VDC Sink/Source Inputs"
            isFault: false
        }
        ListElement {
            slot: "SLOT 2"
            name: "AS04AD-A"
            desc: "4-Ch Analog Input (D28020)"
            status: "16#1801"
            detail: "Error: 16#1801 No Ext 24V"
            isFault: true
        }
        ListElement {
            slot: "SLOT 3"
            name: "AS04DA-A"
            desc: "4-Ch Analog Output (D28040)"
            status: "16#1801"
            detail: "Error: 16#1801 No Ext 24V"
            isFault: true
        }
        ListElement {
            slot: "SLOT 4"
            name: "AS06RTD-A"
            desc: "6-Ch RTD PT100 (D28060)"
            status: "16#1801"
            detail: "Error: 16#1801 No Ext 24V"
            isFault: true
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // =====================================================================
        // 1. TOP HEADER & COMMGR CONTROL TOOLBAR (Height: 48)
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            radius: 5
            color: "#0a2e50"
            border.color: "#1d5b94"
            border.width: 1.2

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    Layout.alignment: Qt.AlignVCenter
                    radius: 4
                    color: "#0284c7"
                    Image {
                        source: "../assets/icons/nav/tools_maintenance.svg"
                        width: 18
                        height: 18
                        sourceSize: Qt.size(18, 18)
                        fillMode: Image.PreserveAspectFit
                        anchors.centerIn: parent
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 1
                    Text {
                        text: "DELTA AS300 PLC COMMUNICATION & COMMGR SUITE"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 13
                    }
                    Text {
                        text: "Subnet Discovery, Physical Hardware Rack Topology & Live Field I/O Monitoring"
                        color: "#38bdf8"
                        font.bold: true
                        font.pixelSize: 9
                    }
                }

                Item { Layout.fillWidth: true }

                // Target IP Input
                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 6
                    Text {
                        text: "PLC IP:"
                        color: "#94a3b8"
                        font.bold: true
                        font.pixelSize: 11
                    }
                    Rectangle {
                        Layout.preferredWidth: 110
                        Layout.preferredHeight: 28
                        radius: 3
                        color: "#051829"
                        border.color: "#38bdf8"
                        border.width: 1
                        TextInput {
                            id: ipField
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            verticalAlignment: TextInput.AlignVCenter
                            text: "192.168.1.7"
                            color: "#38bdf8"
                            font.bold: true
                            font.pixelSize: 11
                        }
                    }

                    Text {
                        text: "Port:"
                        color: "#94a3b8"
                        font.bold: true
                        font.pixelSize: 11
                    }
                    Rectangle {
                        Layout.preferredWidth: 46
                        Layout.preferredHeight: 28
                        radius: 3
                        color: "#051829"
                        border.color: "#38bdf8"
                        border.width: 1
                        TextInput {
                            id: portField
                            anchors.fill: parent
                            anchors.leftMargin: 4
                            anchors.rightMargin: 4
                            verticalAlignment: TextInput.AlignVCenter
                            text: "502"
                            color: "#38bdf8"
                            font.bold: true
                            font.pixelSize: 11
                        }
                    }
                }

                // Connect Button
                Rectangle {
                    id: applyBtn
                    Layout.preferredWidth: 74
                    Layout.preferredHeight: 28
                    Layout.alignment: Qt.AlignVCenter
                    radius: 3
                    color: "#0284c7"
                    Text {
                        anchors.centerIn: parent
                        text: "CONNECT"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 10
                    }
                    MouseArea {
                        id: applyArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                // Scan Button
                Rectangle {
                    id: scanBtn
                    Layout.preferredWidth: 74
                    Layout.preferredHeight: 28
                    Layout.alignment: Qt.AlignVCenter
                    radius: 3
                    color: commgrRoot.isScanning ? "#0c4a6e" : "#1e3a8a"
                    border.color: "#38bdf8"
                    border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: commgrRoot.isScanning ? "SCAN..." : "SCAN IP"
                        color: "#38bdf8"
                        font.bold: true
                        font.pixelSize: 10
                    }
                    MouseArea {
                        id: scanArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                // Link Status & Counters Badge
                Rectangle {
                    Layout.preferredWidth: 185
                    Layout.preferredHeight: 32
                    Layout.alignment: Qt.AlignVCenter
                    radius: 4
                    color: commgrRoot.isConnected ? "#052e16" : "#450a0a"
                    border.color: commgrRoot.isConnected ? "#22c55e" : "#ef4444"
                    border.width: 1.2

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 6

                        Rectangle {
                            Layout.preferredWidth: 8
                            Layout.preferredHeight: 8
                            Layout.alignment: Qt.AlignVCenter
                            radius: 4
                            color: commgrRoot.isConnected ? "#22c55e" : "#ef4444"
                        }

                        ColumnLayout {
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 0
                            RowLayout {
                                spacing: 4
                                Text {
                                    id: linkStatusLabel
                                    text: commgrRoot.isConnected ? "PLC: ONLINE" : "PLC: OFFLINE"
                                    color: commgrRoot.isConnected ? "#4ade80" : "#f87171"
                                    font.bold: true
                                    font.pixelSize: 10
                                }
                                Text {
                                    id: latencyLabel
                                    text: commgrRoot.isConnected ? "(1ms)" : "(Timeout)"
                                    color: "#94a3b8"
                                    font.pixelSize: 9
                                }
                            }
                            Text {
                                id: packetStatsLabel
                                text: "Tx: 1,420 | Rx: 1,420 | Err: 0"
                                color: "#94a3b8"
                                font.pixelSize: 9
                            }
                        }
                    }
                }
            }
        }

        // =====================================================================
        // 2. MAIN BODY (TWO COLUMNS)
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            // -----------------------------------------------------------------
            // LEFT COLUMN (WIDTH: 480) - DISCOVERY & RACK TOPOLOGY
            // -----------------------------------------------------------------
            ColumnLayout {
                Layout.preferredWidth: 480
                Layout.minimumWidth: 460
                Layout.maximumWidth: 500
                Layout.fillHeight: true
                spacing: 8

                // CARD A1: SUBNET DISCOVERY & COMMGR DETECTION
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 215
                    radius: 5
                    color: "#0a2e50"
                    border.color: "#1d5b94"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 6

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "SUBNET DISCOVERY (COMMGR DETECTION)"
                                color: "#38bdf8"
                                font.bold: true
                                font.pixelSize: 11
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                id: scanStatusLabel
                                text: "Subnet: 192.168.1.0/24"
                                color: "#94a3b8"
                                font.pixelSize: 10
                            }
                        }

                        ListView {
                            id: discoveredDevicesListView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 4
                            model: discoveredDevicesModel

                            delegate: Rectangle {
                                width: discoveredDevicesListView ? discoveredDevicesListView.width : 0
                                height: 48
                                radius: 4
                                color: (model.ip === commgrRoot.currentConnectedIp) ? "#07233f" : "#051829"
                                border.color: (model.ip === commgrRoot.currentConnectedIp) ? "#22c55e" : "#1e3a8a"
                                border.width: (model.ip === commgrRoot.currentConnectedIp) ? 1.4 : 1.0

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    spacing: 8

                                    Rectangle {
                                        Layout.preferredWidth: 4
                                        Layout.preferredHeight: 34
                                        Layout.alignment: Qt.AlignVCenter
                                        radius: 2
                                        color: (model.ip === commgrRoot.currentConnectedIp) ? "#22c55e" : (model.status === "ACTIVE LINK" ? "#38bdf8" : (model.status === "LOCAL HOST" ? "#64748b" : "#f59e0b"))
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        spacing: 1

                                        Text {
                                            text: model.ip + " — " + model.device
                                            color: "#ffffff"
                                            font.bold: true
                                            font.pixelSize: 11
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        Text {
                                            text: model.ports + " | MAC: " + model.mac
                                            color: "#94a3b8"
                                            font.pixelSize: 9
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 76
                                        Layout.preferredHeight: 24
                                        Layout.alignment: Qt.AlignVCenter
                                        radius: 3
                                        color: (model.ip === commgrRoot.currentConnectedIp) ? "#052e16" : "#0284c7"
                                        border.color: (model.ip === commgrRoot.currentConnectedIp) ? "#22c55e" : "#38bdf8"
                                        border.width: 1

                                        Text {
                                            anchors.centerIn: parent
                                            text: (model.ip === commgrRoot.currentConnectedIp) ? "ACTIVE" : "CONNECT"
                                            color: (model.ip === commgrRoot.currentConnectedIp) ? "#4ade80" : "#ffffff"
                                            font.bold: true
                                            font.pixelSize: 9
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // CARD A2: DELTA AS300 PHYSICAL RACK TOPOLOGY
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 5
                    color: "#0a2e50"
                    border.color: "#1d5b94"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 5

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "PHYSICAL RACK TOPOLOGY (DIN RAIL MOUNT)"
                                color: "#38bdf8"
                                font.bold: true
                                font.pixelSize: 11
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: (rackModulesModel ? rackModulesModel.count : 0) + " Modules Detected"
                                color: "#64748b"
                                font.pixelSize: 10
                            }
                        }

                        ListView {
                            id: rackModulesListView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 4
                            model: rackModulesModel

                            delegate: Rectangle {
                                width: rackModulesListView ? rackModulesListView.width : 0
                                height: 38
                                radius: 3
                                color: "#051829"
                                border.color: model.isFault ? "#78350f" : "#1e3a8a"
                                border.width: model.isFault ? 1.2 : 1.0

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    spacing: 8

                                    Rectangle {
                                        Layout.preferredWidth: 48
                                        Layout.preferredHeight: 24
                                        Layout.alignment: Qt.AlignVCenter
                                        radius: 2
                                        color: model.isFault ? "#78350f" : (model.slot === "CPU" ? "#065f46" : (model.slot === "CARD2" ? "#0c4a6e" : "#1e293b"))
                                        Text {
                                            anchors.centerIn: parent
                                            text: model.slot
                                            color: model.isFault ? "#fbbf24" : (model.slot === "CPU" ? "#34d399" : (model.slot === "CARD2" ? "#38bdf8" : "#94a3b8"))
                                            font.bold: true
                                            font.pixelSize: 9
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        spacing: 1

                                        Text {
                                            text: model.name + " (" + model.desc + ")"
                                            color: "#ffffff"
                                            font.bold: true
                                            font.pixelSize: 10
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        Text {
                                            text: model.detail
                                            color: model.isFault ? "#f87171" : "#94a3b8"
                                            font.pixelSize: 9
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                    }

                                    Text {
                                        Layout.alignment: Qt.AlignVCenter
                                        text: model.status
                                        color: model.isFault ? "#f87171" : "#22c55e"
                                        font.bold: true
                                        font.pixelSize: 10
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // -----------------------------------------------------------------
            // RIGHT COLUMN (WIDTH: FILL, MIN: 600) - LIVE I/O & REGISTERS
            // -----------------------------------------------------------------
            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: 600
                Layout.fillHeight: true
                spacing: 8

                // CARD B1: LIVE CPU DIGITAL OUTPUTS (Y0.0 – Y0.15)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 170
                    radius: 5
                    color: "#0a2e50"
                    border.color: "#1d5b94"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 6

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "LIVE CPU TRANSISTOR OUTPUTS (Y0.0 – Y0.15)"
                                color: "#38bdf8"
                                font.bold: true
                                font.pixelSize: 11
                            }
                            Item { Layout.fillWidth: true }
                            Rectangle {
                                Layout.preferredWidth: 220
                                Layout.preferredHeight: 20
                                radius: 3
                                color: "#064e3b"
                                border.color: "#059669"
                                Text {
                                    anchors.centerIn: parent
                                    text: "REFLECTING ACTIVE SAMPLE CHASER PROGRAM"
                                    color: "#6ee7b7"
                                    font.bold: true
                                    font.pixelSize: 9
                                }
                            }
                        }

                        // Row 1: Y0.0 to Y0.7
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 56
                                radius: 4
                                color: commgrRoot.y0_0 ? "#064e3b" : "#051829"
                                border.color: commgrRoot.y0_0 ? "#22c55e" : "#1e3a8a"
                                border.width: commgrRoot.y0_0 ? 1.5 : 1.0
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 24; Layout.preferredHeight: 24; Layout.alignment: Qt.AlignHCenter; radius: 12; color: commgrRoot.y0_0 ? "#22c55e" : "#0f2b48"; border.color: commgrRoot.y0_0 ? "#86efac" : "#1e3a8a"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "Y0.0"; color: commgrRoot.y0_0 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 10 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 56
                                radius: 4
                                color: commgrRoot.y0_1 ? "#064e3b" : "#051829"
                                border.color: commgrRoot.y0_1 ? "#22c55e" : "#1e3a8a"
                                border.width: commgrRoot.y0_1 ? 1.5 : 1.0
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 24; Layout.preferredHeight: 24; Layout.alignment: Qt.AlignHCenter; radius: 12; color: commgrRoot.y0_1 ? "#22c55e" : "#0f2b48"; border.color: commgrRoot.y0_1 ? "#86efac" : "#1e3a8a"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "Y0.1"; color: commgrRoot.y0_1 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 10 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 56
                                radius: 4
                                color: commgrRoot.y0_2 ? "#064e3b" : "#051829"
                                border.color: commgrRoot.y0_2 ? "#22c55e" : "#1e3a8a"
                                border.width: commgrRoot.y0_2 ? 1.5 : 1.0
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 24; Layout.preferredHeight: 24; Layout.alignment: Qt.AlignHCenter; radius: 12; color: commgrRoot.y0_2 ? "#22c55e" : "#0f2b48"; border.color: commgrRoot.y0_2 ? "#86efac" : "#1e3a8a"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "Y0.2"; color: commgrRoot.y0_2 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 10 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 56
                                radius: 4
                                color: commgrRoot.y0_3 ? "#064e3b" : "#051829"
                                border.color: commgrRoot.y0_3 ? "#22c55e" : "#1e3a8a"
                                border.width: commgrRoot.y0_3 ? 1.5 : 1.0
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 24; Layout.preferredHeight: 24; Layout.alignment: Qt.AlignHCenter; radius: 12; color: commgrRoot.y0_3 ? "#22c55e" : "#0f2b48"; border.color: commgrRoot.y0_3 ? "#86efac" : "#1e3a8a"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "Y0.3"; color: commgrRoot.y0_3 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 10 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 56
                                radius: 4
                                color: commgrRoot.y0_4 ? "#064e3b" : "#051829"
                                border.color: commgrRoot.y0_4 ? "#22c55e" : "#1e3a8a"
                                border.width: commgrRoot.y0_4 ? 1.5 : 1.0
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 24; Layout.preferredHeight: 24; Layout.alignment: Qt.AlignHCenter; radius: 12; color: commgrRoot.y0_4 ? "#22c55e" : "#0f2b48"; border.color: commgrRoot.y0_4 ? "#86efac" : "#1e3a8a"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "Y0.4"; color: commgrRoot.y0_4 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 10 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 56
                                radius: 4
                                color: commgrRoot.y0_5 ? "#064e3b" : "#051829"
                                border.color: commgrRoot.y0_5 ? "#22c55e" : "#1e3a8a"
                                border.width: commgrRoot.y0_5 ? 1.5 : 1.0
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 24; Layout.preferredHeight: 24; Layout.alignment: Qt.AlignHCenter; radius: 12; color: commgrRoot.y0_5 ? "#22c55e" : "#0f2b48"; border.color: commgrRoot.y0_5 ? "#86efac" : "#1e3a8a"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "Y0.5"; color: commgrRoot.y0_5 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 10 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 56
                                radius: 4
                                color: commgrRoot.y0_6 ? "#064e3b" : "#051829"
                                border.color: commgrRoot.y0_6 ? "#22c55e" : "#1e3a8a"
                                border.width: commgrRoot.y0_6 ? 1.5 : 1.0
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 24; Layout.preferredHeight: 24; Layout.alignment: Qt.AlignHCenter; radius: 12; color: commgrRoot.y0_6 ? "#22c55e" : "#0f2b48"; border.color: commgrRoot.y0_6 ? "#86efac" : "#1e3a8a"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "Y0.6"; color: commgrRoot.y0_6 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 10 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 56
                                radius: 4
                                color: commgrRoot.y0_7 ? "#064e3b" : "#051829"
                                border.color: commgrRoot.y0_7 ? "#22c55e" : "#1e3a8a"
                                border.width: commgrRoot.y0_7 ? 1.5 : 1.0
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 24; Layout.preferredHeight: 24; Layout.alignment: Qt.AlignHCenter; radius: 12; color: commgrRoot.y0_7 ? "#22c55e" : "#0f2b48"; border.color: commgrRoot.y0_7 ? "#86efac" : "#1e3a8a"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "Y0.7"; color: commgrRoot.y0_7 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 10 }
                                }
                            }
                        }

                        // Row 2: Y0.8 to Y0.15
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 56
                                radius: 4
                                color: commgrRoot.y0_8 ? "#064e3b" : "#051829"
                                border.color: commgrRoot.y0_8 ? "#22c55e" : "#1e3a8a"
                                border.width: commgrRoot.y0_8 ? 1.5 : 1.0
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 24; Layout.preferredHeight: 24; Layout.alignment: Qt.AlignHCenter; radius: 12; color: commgrRoot.y0_8 ? "#22c55e" : "#0f2b48"; border.color: commgrRoot.y0_8 ? "#86efac" : "#1e3a8a"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "Y0.8"; color: commgrRoot.y0_8 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 10 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 56
                                radius: 4
                                color: commgrRoot.y0_9 ? "#064e3b" : "#051829"
                                border.color: commgrRoot.y0_9 ? "#22c55e" : "#1e3a8a"
                                border.width: commgrRoot.y0_9 ? 1.5 : 1.0
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 24; Layout.preferredHeight: 24; Layout.alignment: Qt.AlignHCenter; radius: 12; color: commgrRoot.y0_9 ? "#22c55e" : "#0f2b48"; border.color: commgrRoot.y0_9 ? "#86efac" : "#1e3a8a"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "Y0.9"; color: commgrRoot.y0_9 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 10 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 56
                                radius: 4
                                color: commgrRoot.y0_10 ? "#064e3b" : "#051829"
                                border.color: commgrRoot.y0_10 ? "#22c55e" : "#1e3a8a"
                                border.width: commgrRoot.y0_10 ? 1.5 : 1.0
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 24; Layout.preferredHeight: 24; Layout.alignment: Qt.AlignHCenter; radius: 12; color: commgrRoot.y0_10 ? "#22c55e" : "#0f2b48"; border.color: commgrRoot.y0_10 ? "#86efac" : "#1e3a8a"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "Y0.10"; color: commgrRoot.y0_10 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 10 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 56
                                radius: 4
                                color: commgrRoot.y0_11 ? "#064e3b" : "#051829"
                                border.color: commgrRoot.y0_11 ? "#22c55e" : "#1e3a8a"
                                border.width: commgrRoot.y0_11 ? 1.5 : 1.0
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 24; Layout.preferredHeight: 24; Layout.alignment: Qt.AlignHCenter; radius: 12; color: commgrRoot.y0_11 ? "#22c55e" : "#0f2b48"; border.color: commgrRoot.y0_11 ? "#86efac" : "#1e3a8a"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "Y0.11"; color: commgrRoot.y0_11 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 10 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 56
                                radius: 4
                                color: commgrRoot.y0_12 ? "#064e3b" : "#051829"
                                border.color: commgrRoot.y0_12 ? "#22c55e" : "#1e3a8a"
                                border.width: commgrRoot.y0_12 ? 1.5 : 1.0
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 24; Layout.preferredHeight: 24; Layout.alignment: Qt.AlignHCenter; radius: 12; color: commgrRoot.y0_12 ? "#22c55e" : "#0f2b48"; border.color: commgrRoot.y0_12 ? "#86efac" : "#1e3a8a"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "Y0.12"; color: commgrRoot.y0_12 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 10 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 56
                                radius: 4
                                color: commgrRoot.y0_13 ? "#064e3b" : "#051829"
                                border.color: commgrRoot.y0_13 ? "#22c55e" : "#1e3a8a"
                                border.width: commgrRoot.y0_13 ? 1.5 : 1.0
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 24; Layout.preferredHeight: 24; Layout.alignment: Qt.AlignHCenter; radius: 12; color: commgrRoot.y0_13 ? "#22c55e" : "#0f2b48"; border.color: commgrRoot.y0_13 ? "#86efac" : "#1e3a8a"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "Y0.13"; color: commgrRoot.y0_13 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 10 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 56
                                radius: 4
                                color: commgrRoot.y0_14 ? "#064e3b" : "#051829"
                                border.color: commgrRoot.y0_14 ? "#22c55e" : "#1e3a8a"
                                border.width: commgrRoot.y0_14 ? 1.5 : 1.0
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 24; Layout.preferredHeight: 24; Layout.alignment: Qt.AlignHCenter; radius: 12; color: commgrRoot.y0_14 ? "#22c55e" : "#0f2b48"; border.color: commgrRoot.y0_14 ? "#86efac" : "#1e3a8a"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "Y0.14"; color: commgrRoot.y0_14 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 10 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 56
                                radius: 4
                                color: commgrRoot.y0_15 ? "#064e3b" : "#051829"
                                border.color: commgrRoot.y0_15 ? "#22c55e" : "#1e3a8a"
                                border.width: commgrRoot.y0_15 ? 1.5 : 1.0
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 24; Layout.preferredHeight: 24; Layout.alignment: Qt.AlignHCenter; radius: 12; color: commgrRoot.y0_15 ? "#22c55e" : "#0f2b48"; border.color: commgrRoot.y0_15 ? "#86efac" : "#1e3a8a"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "Y0.15"; color: commgrRoot.y0_15 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 10 }
                                }
                            }
                        }
                    }
                }

                // CARD B2: LIVE FIELD DIGITAL INPUTS (X0 CPU & X1 EXTENSION)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 160
                    radius: 5
                    color: "#0a2e50"
                    border.color: "#1d5b94"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 6

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "LIVE FIELD DIGITAL INPUTS (CPU X0 & EXTENSION X1)"
                                color: "#38bdf8"
                                font.bold: true
                                font.pixelSize: 11
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: "Discrete 24VDC Inputs (Modbus 0x6000 & 0x6010)"
                                color: "#64748b"
                                font.pixelSize: 10
                            }
                        }

                        // Row 1: CPU Inputs X0.0 to X0.7
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                radius: 3
                                color: commgrRoot.x0_0 ? "#14532d" : "#051829"
                                border.color: commgrRoot.x0_0 ? "#4ade80" : "#1e293b"
                                border.width: 1
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 14; Layout.preferredHeight: 14; Layout.alignment: Qt.AlignHCenter; radius: 7; color: commgrRoot.x0_0 ? "#4ade80" : "#334155"; border.color: commgrRoot.x0_0 ? "#86efac" : "#1e293b"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "X0.0"; color: commgrRoot.x0_0 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 9 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                radius: 3
                                color: commgrRoot.x0_1 ? "#14532d" : "#051829"
                                border.color: commgrRoot.x0_1 ? "#4ade80" : "#1e293b"
                                border.width: 1
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 14; Layout.preferredHeight: 14; Layout.alignment: Qt.AlignHCenter; radius: 7; color: commgrRoot.x0_1 ? "#4ade80" : "#334155"; border.color: commgrRoot.x0_1 ? "#86efac" : "#1e293b"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "X0.1"; color: commgrRoot.x0_1 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 9 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                radius: 3
                                color: commgrRoot.x0_2 ? "#14532d" : "#051829"
                                border.color: commgrRoot.x0_2 ? "#4ade80" : "#1e293b"
                                border.width: 1
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 14; Layout.preferredHeight: 14; Layout.alignment: Qt.AlignHCenter; radius: 7; color: commgrRoot.x0_2 ? "#4ade80" : "#334155"; border.color: commgrRoot.x0_2 ? "#86efac" : "#1e293b"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "X0.2"; color: commgrRoot.x0_2 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 9 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                radius: 3
                                color: commgrRoot.x0_3 ? "#14532d" : "#051829"
                                border.color: commgrRoot.x0_3 ? "#4ade80" : "#1e293b"
                                border.width: 1
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 14; Layout.preferredHeight: 14; Layout.alignment: Qt.AlignHCenter; radius: 7; color: commgrRoot.x0_3 ? "#4ade80" : "#334155"; border.color: commgrRoot.x0_3 ? "#86efac" : "#1e293b"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "X0.3"; color: commgrRoot.x0_3 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 9 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                radius: 3
                                color: commgrRoot.x0_4 ? "#14532d" : "#051829"
                                border.color: commgrRoot.x0_4 ? "#4ade80" : "#1e293b"
                                border.width: 1
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 14; Layout.preferredHeight: 14; Layout.alignment: Qt.AlignHCenter; radius: 7; color: commgrRoot.x0_4 ? "#4ade80" : "#334155"; border.color: commgrRoot.x0_4 ? "#86efac" : "#1e293b"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "X0.4"; color: commgrRoot.x0_4 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 9 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                radius: 3
                                color: commgrRoot.x0_5 ? "#14532d" : "#051829"
                                border.color: commgrRoot.x0_5 ? "#4ade80" : "#1e293b"
                                border.width: 1
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 14; Layout.preferredHeight: 14; Layout.alignment: Qt.AlignHCenter; radius: 7; color: commgrRoot.x0_5 ? "#4ade80" : "#334155"; border.color: commgrRoot.x0_5 ? "#86efac" : "#1e293b"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "X0.5"; color: commgrRoot.x0_5 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 9 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                radius: 3
                                color: commgrRoot.x0_6 ? "#14532d" : "#051829"
                                border.color: commgrRoot.x0_6 ? "#4ade80" : "#1e293b"
                                border.width: 1
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 14; Layout.preferredHeight: 14; Layout.alignment: Qt.AlignHCenter; radius: 7; color: commgrRoot.x0_6 ? "#4ade80" : "#334155"; border.color: commgrRoot.x0_6 ? "#86efac" : "#1e293b"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "X0.6"; color: commgrRoot.x0_6 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 9 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                radius: 3
                                color: commgrRoot.x0_7 ? "#14532d" : "#051829"
                                border.color: commgrRoot.x0_7 ? "#4ade80" : "#1e293b"
                                border.width: 1
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 14; Layout.preferredHeight: 14; Layout.alignment: Qt.AlignHCenter; radius: 7; color: commgrRoot.x0_7 ? "#4ade80" : "#334155"; border.color: commgrRoot.x0_7 ? "#86efac" : "#1e293b"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "X0.7"; color: commgrRoot.x0_7 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 9 }
                                }
                            }
                        }

                        // Row 2: Slot 1 Extension Inputs X1.0 to X1.7
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                radius: 3
                                color: commgrRoot.x1_0 ? "#14532d" : "#051829"
                                border.color: commgrRoot.x1_0 ? "#4ade80" : "#1e293b"
                                border.width: 1
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 14; Layout.preferredHeight: 14; Layout.alignment: Qt.AlignHCenter; radius: 7; color: commgrRoot.x1_0 ? "#4ade80" : "#334155"; border.color: commgrRoot.x1_0 ? "#86efac" : "#1e293b"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "X1.0"; color: commgrRoot.x1_0 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 9 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                radius: 3
                                color: commgrRoot.x1_1 ? "#14532d" : "#051829"
                                border.color: commgrRoot.x1_1 ? "#4ade80" : "#1e293b"
                                border.width: 1
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 14; Layout.preferredHeight: 14; Layout.alignment: Qt.AlignHCenter; radius: 7; color: commgrRoot.x1_1 ? "#4ade80" : "#334155"; border.color: commgrRoot.x1_1 ? "#86efac" : "#1e293b"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "X1.1"; color: commgrRoot.x1_1 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 9 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                radius: 3
                                color: commgrRoot.x1_2 ? "#14532d" : "#051829"
                                border.color: commgrRoot.x1_2 ? "#4ade80" : "#1e293b"
                                border.width: 1
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 14; Layout.preferredHeight: 14; Layout.alignment: Qt.AlignHCenter; radius: 7; color: commgrRoot.x1_2 ? "#4ade80" : "#334155"; border.color: commgrRoot.x1_2 ? "#86efac" : "#1e293b"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "X1.2"; color: commgrRoot.x1_2 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 9 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                radius: 3
                                color: commgrRoot.x1_3 ? "#14532d" : "#051829"
                                border.color: commgrRoot.x1_3 ? "#4ade80" : "#1e293b"
                                border.width: 1
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 14; Layout.preferredHeight: 14; Layout.alignment: Qt.AlignHCenter; radius: 7; color: commgrRoot.x1_3 ? "#4ade80" : "#334155"; border.color: commgrRoot.x1_3 ? "#86efac" : "#1e293b"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "X1.3"; color: commgrRoot.x1_3 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 9 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                radius: 3
                                color: commgrRoot.x1_4 ? "#14532d" : "#051829"
                                border.color: commgrRoot.x1_4 ? "#4ade80" : "#1e293b"
                                border.width: 1
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 14; Layout.preferredHeight: 14; Layout.alignment: Qt.AlignHCenter; radius: 7; color: commgrRoot.x1_4 ? "#4ade80" : "#334155"; border.color: commgrRoot.x1_4 ? "#86efac" : "#1e293b"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "X1.4"; color: commgrRoot.x1_4 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 9 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                radius: 3
                                color: commgrRoot.x1_5 ? "#14532d" : "#051829"
                                border.color: commgrRoot.x1_5 ? "#4ade80" : "#1e293b"
                                border.width: 1
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 14; Layout.preferredHeight: 14; Layout.alignment: Qt.AlignHCenter; radius: 7; color: commgrRoot.x1_5 ? "#4ade80" : "#334155"; border.color: commgrRoot.x1_5 ? "#86efac" : "#1e293b"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "X1.5"; color: commgrRoot.x1_5 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 9 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                radius: 3
                                color: commgrRoot.x1_6 ? "#14532d" : "#051829"
                                border.color: commgrRoot.x1_6 ? "#4ade80" : "#1e293b"
                                border.width: 1
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 14; Layout.preferredHeight: 14; Layout.alignment: Qt.AlignHCenter; radius: 7; color: commgrRoot.x1_6 ? "#4ade80" : "#334155"; border.color: commgrRoot.x1_6 ? "#86efac" : "#1e293b"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "X1.6"; color: commgrRoot.x1_6 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 9 }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                radius: 3
                                color: commgrRoot.x1_7 ? "#14532d" : "#051829"
                                border.color: commgrRoot.x1_7 ? "#4ade80" : "#1e293b"
                                border.width: 1
                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: 3
                                    Rectangle { Layout.preferredWidth: 14; Layout.preferredHeight: 14; Layout.alignment: Qt.AlignHCenter; radius: 7; color: commgrRoot.x1_7 ? "#4ade80" : "#334155"; border.color: commgrRoot.x1_7 ? "#86efac" : "#1e293b"; border.width: 1 }
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "X1.7"; color: commgrRoot.x1_7 ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 9 }
                                }
                            }
                        }
                    }
                }

                // CARD B3: REAL-TIME REGISTERS & MODULE ERROR STATUS
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 5
                    color: "#0a2e50"
                    border.color: "#1d5b94"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 6

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "REAL-TIME PLC REGISTERS & MODULE FAULT STATUS"
                                color: "#38bdf8"
                                font.bold: true
                                font.pixelSize: 11
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: "Modbus Holding Registers (D-Addresses)"
                                color: "#64748b"
                                font.pixelSize: 10
                            }
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            columns: 3
                            rowSpacing: 6
                            columnSpacing: 6

                            // Tile 1: Agitator Speed D0
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 4
                                color: "#051829"
                                border.color: "#1e3a8a"
                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 3
                                    Text {
                                        text: "AGITATOR SPEED (D0)"
                                        color: "#94a3b8"
                                        font.bold: true
                                        font.pixelSize: 9
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                    Text {
                                        id: agitSpeedLabel
                                        text: "0.0 RPM"
                                        color: "#38bdf8"
                                        font.bold: true
                                        font.pixelSize: 13
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }
                            }

                            // Tile 2: Homogenizer Speed D1
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 4
                                color: "#051829"
                                border.color: "#1e3a8a"
                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 3
                                    Text {
                                        text: "HOMOGENIZER SPEED (D1)"
                                        color: "#94a3b8"
                                        font.bold: true
                                        font.pixelSize: 9
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                    Text {
                                        id: homoSpeedLabel
                                        text: "0.0 RPM"
                                        color: "#38bdf8"
                                        font.bold: true
                                        font.pixelSize: 13
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }
                            }

                            // Tile 3: Chamber Temp D2
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 4
                                color: "#051829"
                                border.color: "#1e3a8a"
                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 3
                                    Text {
                                        text: "VESSEL TEMP (D2)"
                                        color: "#94a3b8"
                                        font.bold: true
                                        font.pixelSize: 9
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                    Text {
                                        id: prodTempLabel
                                        text: "24.5 °C"
                                        color: "#4ade80"
                                        font.bold: true
                                        font.pixelSize: 13
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }
                            }

                            // Tile 4: Jacket Temp D3
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 4
                                color: "#051829"
                                border.color: "#1e3a8a"
                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 3
                                    Text {
                                        text: "JACKET TEMP (D3)"
                                        color: "#94a3b8"
                                        font.bold: true
                                        font.pixelSize: 9
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                    Text {
                                        id: jacketTempLabel
                                        text: "23.8 °C"
                                        color: "#4ade80"
                                        font.bold: true
                                        font.pixelSize: 13
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }
                            }

                            // Tile 5: AI Module Fault D28020
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 4
                                color: "#051829"
                                border.color: "#78350f"
                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 3
                                    Text {
                                        text: "AI SLOT 2 FAULT (D28020)"
                                        color: "#f59e0b"
                                        font.bold: true
                                        font.pixelSize: 9
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                    Text {
                                        id: aiErrorLabel
                                        text: "FAULT 16#1801"
                                        color: "#f87171"
                                        font.bold: true
                                        font.pixelSize: 13
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }
                            }

                            // Tile 6: RTD Module Fault D28060
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 4
                                color: "#051829"
                                border.color: "#78350f"
                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 3
                                    Text {
                                        text: "RTD SLOT 4 FAULT (D28060)"
                                        color: "#f59e0b"
                                        font.bold: true
                                        font.pixelSize: 9
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                    Text {
                                        id: rtdErrorLabel
                                        text: "FAULT 16#1801"
                                        color: "#f87171"
                                        font.bold: true
                                        font.pixelSize: 13
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

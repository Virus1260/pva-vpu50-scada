import QtQuick
import QtQuick.Layouts

Item {
    id: maintContainer
    width: 1184
    height: 626
    implicitWidth: 1184
    implicitHeight: 626
    Layout.fillWidth: true
    Layout.fillHeight: true

    property string lastRackJson: ""

    Screen_8_DiagnosticsView {
        id: ui
        anchors.fill: parent

        Component.onCompleted: {
            if (typeof Scada !== "undefined" && Scada) {
                if (Scada.plcHost) {
                    ui.targetIpInput = Scada.plcHost;
                    ui.currentConnectedIp = Scada.plcHost;
                    ui.targetPortInput = "" + Scada.plcPort;
                }
                const devJson = Scada.probeSubnetDevicesJson();
                populateDiscoveredDevices(devJson);
                const rackJson = Scada.getDeltaHardwareRackJson();
                populateRackModules(rackJson);
            }
        }
    }

    // Connect User Actions - Toolbar Connect Button
    Connections {
        target: ui.connectMouseArea
        function onClicked() {
            const ip = ui.targetIpInput.trim();
            const p = parseInt(ui.targetPortInput) || 502;
            ui.currentConnectedIp = ip;
            updateDeviceConnectionStatus(ip);
            if (typeof Scada !== "undefined" && Scada) {
                Scada.setPlcTarget(ip, p);
            }
        }
    }

    // Connect User Actions - Toolbar Scan Button
    Connections {
        target: ui.scanMouseArea
        function onClicked() {
            ui.isScanning = true;
            ui.scanStatusText = "Scanning subnet 192.168.1.0/24...";
            scanFeedbackTimer.restart();
            if (typeof Scada !== "undefined" && Scada) {
                Scada.startNetworkScan();
            }
        }
    }

    // Safety fallback timer for scan visual feedback
    Timer {
        id: scanFeedbackTimer
        interval: 1000
        repeat: false
        onTriggered: {
            ui.isScanning = false;
            if (typeof Scada !== "undefined" && Scada) {
                const devJson = Scada.probeSubnetDevicesJson();
                populateDiscoveredDevices(devJson);
            }
        }
    }

    // Handle Clicks on Discovered Device Cards (CONNECT action button or row click)
    MouseArea {
        parent: ui.discoveredDevicesListView
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: function(mouse) {
            const idx = ui.discoveredDevicesListView.indexAt(mouse.x, mouse.y + ui.discoveredDevicesListView.contentY);
            const model = ui.discoveredDevicesModel;
            if (model && idx >= 0 && idx < model.count) {
                const item = model.get(idx);
                const targetIp = item.ip;
                const targetPort = (item.port !== undefined && item.port > 0) ? item.port : 502;
                ui.targetIpInput = targetIp;
                ui.targetPortInput = "" + targetPort;
                ui.currentConnectedIp = targetIp;
                updateDeviceConnectionStatus(targetIp);
                if (typeof Scada !== "undefined" && Scada) {
                    Scada.setPlcTarget(targetIp, targetPort);
                }
            }
        }
    }

    // Dynamic Telemetry & Digital I/O Synchronization
    Connections {
        target: (typeof Scada !== "undefined" && Scada) ? Scada : null

        function onTelemetryUpdated() {
            refreshDiagnostics();
        }

        function onPlcConfigChanged() {
            if (Scada) {
                ui.targetIpInput = Scada.plcHost;
                ui.currentConnectedIp = Scada.plcHost;
                ui.targetPortInput = "" + Scada.plcPort;
                updateDeviceConnectionStatus(Scada.plcHost);
            }
        }

        function onNetworkScanFinished(devicesJson) {
            ui.isScanning = false;
            scanFeedbackTimer.stop();
            populateDiscoveredDevices(devicesJson);
        }
    }

    // Polling refresh fallback every 200ms
    Timer {
        id: refreshTimer
        interval: 200
        repeat: true
        running: true
        onTriggered: {
            refreshDiagnostics();
        }
    }

    function updateDeviceConnectionStatus(currentIp) {
        const model = ui.discoveredDevicesModel;
        if (!model) return;
        for (let i = 0; i < model.count; ++i) {
            const d = model.get(i);
            model.setProperty(i, "isCurrent", (d.ip === currentIp));
        }
    }

    function populateDiscoveredDevices(jsonStr) {
        if (!jsonStr || !ui.discoveredDevicesModel) return;
        try {
            const list = JSON.parse(jsonStr);
            if (Array.isArray(list) && list.length > 0) {
                ui.discoveredDevicesModel.clear();
                const currIp = ui.targetIpInput.trim();
                for (let i = 0; i < list.length; ++i) {
                    const d = list[i];
                    let portsStr = "";
                    if (d.modbus_502) portsStr += "502 (Modbus) ";
                    if (d.http_80) portsStr += "80 (Web) ";
                    if (d.opcua_4840) portsStr += "4840 (OPC UA)";
                    if (!portsStr) {
                        portsStr = (d.status === "PORT UNLINKED") ? "Unlinked / Standby" : "Local Host Adapter";
                    }

                    const rttStr = (d.rtt_ms !== undefined && d.rtt_ms >= 0) ? (d.rtt_ms + "ms") : "--";
                    const isCurr = (d.ip === currIp || d.ip === ui.currentConnectedIp);

                    ui.discoveredDevicesModel.append({
                        ip: d.ip || "",
                        device: d.device || "",
                        ports: portsStr.trim(),
                        mac: d.mac || "--",
                        status: d.status || "STANDBY",
                        rtt: rttStr,
                        isCurrent: isCurr
                    });
                }
                ui.scanStatusText = "Subnet: " + list.length + " devices discovered";
            }
        } catch (e) {
            console.warn("Failed to parse discovered devices JSON:", e);
        }
    }

    function populateRackModules(jsonStr) {
        if (!jsonStr || !ui.rackModulesModel) return;
        try {
            const list = JSON.parse(jsonStr);
            if (Array.isArray(list) && list.length > 0) {
                ui.rackModulesModel.clear();
                for (let i = 0; i < list.length; ++i) {
                    const m = list[i];
                    const isFlt = (m.status && m.status.indexOf("FAULT") !== -1);
                    const detailText = m.detail || m.error || m.warning || "";
                    ui.rackModulesModel.append({
                        slot: m.slot || ("SLOT " + i),
                        name: m.name || "",
                        desc: m.desc || "",
                        status: m.status || "NORMAL",
                        detail: detailText,
                        isFault: isFlt
                    });
                }
            }
        } catch (e) {
            console.warn("Failed to parse rack modules JSON:", e);
        }
    }

    function refreshDiagnostics() {
        if (typeof Scada === "undefined" || !Scada) {
            return;
        }

        // Connection status & metrics
        ui.isConnected = Scada.isPlcConnected;
        ui.linkStatusText = Scada.isPlcConnected ? "PLC: ONLINE" : "PLC: OFFLINE";
        ui.latencyText = Scada.isPlcConnected ? ("(" + Scada.plcLatencyMs + "ms)") : "(Timeout)";
        ui.packetStatsText = "Tx: " + Scada.packetsSent + " | Rx: " + Scada.packetsReceived + " | Err: " + Scada.packetErrors;

        // Synchronize Rack Topology if changed
        const rackJson = Scada.getDeltaHardwareRackJson();
        if (rackJson && rackJson !== maintContainer.lastRackJson) {
            maintContainer.lastRackJson = rackJson;
            populateRackModules(rackJson);
        }

        // Synchronize Live CPU Digital Outputs (Y0.0 – Y0.15)
        const dOut = Scada.digitalOutputs;
        if (dOut && dOut.length >= 16) {
            ui.y0_0 = !!dOut[0];
            ui.y0_1 = !!dOut[1];
            ui.y0_2 = !!dOut[2];
            ui.y0_3 = !!dOut[3];
            ui.y0_4 = !!dOut[4];
            ui.y0_5 = !!dOut[5];
            ui.y0_6 = !!dOut[6];
            ui.y0_7 = !!dOut[7];
            ui.y0_8 = !!dOut[8];
            ui.y0_9 = !!dOut[9];
            ui.y0_10 = !!dOut[10];
            ui.y0_11 = !!dOut[11];
            ui.y0_12 = !!dOut[12];
            ui.y0_13 = !!dOut[13];
            ui.y0_14 = !!dOut[14];
            ui.y0_15 = !!dOut[15];
        }

        // Synchronize Live CPU Digital Inputs (X0.0 – X0.7)
        const dIn0 = Scada.digitalInputs;
        if (dIn0 && dIn0.length >= 8) {
            ui.x0_0 = !!dIn0[0];
            ui.x0_1 = !!dIn0[1];
            ui.x0_2 = !!dIn0[2];
            ui.x0_3 = !!dIn0[3];
            ui.x0_4 = !!dIn0[4];
            ui.x0_5 = !!dIn0[5];
            ui.x0_6 = !!dIn0[6];
            ui.x0_7 = !!dIn0[7];
        }

        // Synchronize Live Extension Inputs (X1.0 – X1.7)
        const dIn1 = Scada.extensionInputs;
        if (dIn1 && dIn1.length >= 8) {
            ui.x1_0 = !!dIn1[0];
            ui.x1_1 = !!dIn1[1];
            ui.x1_2 = !!dIn1[2];
            ui.x1_3 = !!dIn1[3];
            ui.x1_4 = !!dIn1[4];
            ui.x1_5 = !!dIn1[5];
            ui.x1_6 = !!dIn1[6];
            ui.x1_7 = !!dIn1[7];
        }

        // Synchronize Live Registers & Fault Status
        const t = Scada.telemetry;
        if (t) {
            if (t["vpu.main.agitator_speed"] !== undefined) {
                ui.agitSpeedText = Number(t["vpu.main.agitator_speed"]).toFixed(1) + " RPM";
            }
            if (t["vpu.main.homogenizer_speed"] !== undefined) {
                ui.homoSpeedText = Number(t["vpu.main.homogenizer_speed"]).toFixed(0) + " RPM";
            }
            if (t["vpu.main.temperature"] !== undefined) {
                ui.prodTempText = Number(t["vpu.main.temperature"]).toFixed(1) + " °C";
            }
            if (t["vpu.jacket.temperature"] !== undefined) {
                ui.jacketTempText = Number(t["vpu.jacket.temperature"]).toFixed(1) + " °C";
            }
            ui.aiErrorText = t["ad_slot2_fault"] ? "FAULT 16#1801" : "NORMAL";
            ui.rtdErrorText = t["rtd_slot4_fault"] ? "FAULT 16#1801" : "NORMAL";
        }
    }
}

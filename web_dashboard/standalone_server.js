#!/usr/bin/env node
/**
 * PVA SYSTEMS VPU-50 SCADA - Real-Time Industrial Web Server & Modbus TCP Bridge
 * Zero-dependency, ultra-fast HTTP + Modbus TCP server.
 * Connects directly to Delta AS332T PLC at 192.168.1.5:502 (via AS-FFTP01 or CPU port).
 */

const http = require("http");
const net = require("net");
const url = require("url");

const PORT = process.env.PORT || 3000;
const PLC_HOST = process.env.PLC_IP || "192.168.1.5";
const PLC_PORT = parseInt(process.env.PLC_PORT || "502", 10);

const Y_COIL_BASE = 40960;   // 0xA000: Y0.0
const X_INPUT_BASE = 24576;  // 0x6000: X0.0
const D_REG_BASE = 0;        // D0

const OUTPUT_NAMES = [
  "Agitator VFD Run",
  "Homogenizer High-Shear",
  "Steam Heating Solenoid (V201)",
  "Cooling Water Solenoid (V202)",
  "Vacuum Pump Contactor (P101)",
  "Atmospheric Vent Valve (V203)",
  "Recirculation Valve (V301)",
  "CIP Supply Solenoid (V302)",
  "Vessel Bottom Drain (V101)",
  "Jacket Recirculation Pump",
  "Powder Suction Valve (V303)",
  "Homogenizer Seal Water Flush",
  "Auxiliary Relay 1",
  "Auxiliary Relay 2",
  "Panel Warning Buzzer",
  "Strobe Beacon Tower (Amber/Red)",
];

const INPUT_NAMES = [
  "Emergency Stop (PB-101 NC)",
  "Vessel Lid Closed Safety Switch",
  "Homogenizer Seal Water Flow (FS-102)",
  "Minimum Vessel Level Sensor (LSL-101)",
  "High Vessel Level Sensor (LSH-101)",
  "Valve V301 Open Limit Switch",
  "Valve V302 Open Limit Switch",
  "Valve V303 Open Limit Switch",
  "Thermal Overload Trip (OL-101)",
  "VFD Fault Relay (Agitator)",
  "VFD Fault Relay (Homogenizer)",
  "Air Pressure Sensor Switch (>6 bar)",
  "Spare Digital Input 12",
  "Spare Digital Input 13",
  "Spare Digital Input 14",
  "Panel Remote Start Pushbutton",
];

function sendModbusTransaction(pduReq) {
  return new Promise((resolve, reject) => {
    const socket = new net.Socket();
    let timer = setTimeout(() => {
      socket.removeAllListeners();
      socket.destroy();
      reject(new Error("Modbus TCP timeout"));
    }, 2000);

    socket.connect(PLC_PORT, PLC_HOST, () => {
      const mbap = Buffer.alloc(7);
      mbap.writeUInt16BE(1, 0);
      mbap.writeUInt16BE(0, 2);
      mbap.writeUInt16BE(pduReq.length + 1, 4);
      mbap.writeUInt8(1, 6);
      socket.write(Buffer.concat([mbap, pduReq]));
    });

    socket.on("data", (data) => {
      clearTimeout(timer);
      socket.removeAllListeners();
      socket.destroy();
      resolve(data);
    });

    socket.on("error", (err) => {
      clearTimeout(timer);
      socket.removeAllListeners();
      socket.destroy();
      reject(err);
    });
  });
}

async function getPlcState() {
  const t0 = Date.now();
  const outputs = new Array(16).fill(false);
  const inputs = new Array(16).fill(false);
  let registers = {
    agitatorSpeed: 0,
    homoSpeed: 0,
    vesselTemp: 0.0,
    jacketTemp: 0.0,
    vacuumPressure: 0.0,
    vesselLevel: 0.0,
  };

  try {
    // 1. Read 16 Output Coils (Y0.0 to Y0.15)
    const coilReq = Buffer.from([1, (Y_COIL_BASE >> 8) & 0xff, Y_COIL_BASE & 0xff, 0, 16]);
    const coilRes = await sendModbusTransaction(coilReq);
    if (coilRes.length >= 11) {
      const b0 = coilRes[9];
      const b1 = coilRes[10];
      for (let i = 0; i < 8; i++) outputs[i] = Boolean(b0 & (1 << i));
      for (let i = 0; i < 8; i++) outputs[8 + i] = Boolean(b1 & (1 << i));
    }

    // 2. Read 16 Discrete Inputs (X0.0 to X0.15)
    const inReq = Buffer.from([2, (X_INPUT_BASE >> 8) & 0xff, X_INPUT_BASE & 0xff, 0, 16]);
    const inRes = await sendModbusTransaction(inReq);
    if (inRes.length >= 11) {
      const b0 = inRes[9];
      const b1 = inRes[10];
      for (let i = 0; i < 8; i++) inputs[i] = Boolean(b0 & (1 << i));
      for (let i = 0; i < 8; i++) inputs[8 + i] = Boolean(b1 & (1 << i));
    }

    // 3. Read 10 Holding Registers D0–D9
    const regReq = Buffer.from([3, (D_REG_BASE >> 8) & 0xff, D_REG_BASE & 0xff, 0, 10]);
    const regRes = await sendModbusTransaction(regReq);
    if (regRes.length >= 9 + 20) {
      const regs = [];
      for (let i = 0; i < 10; i++) regs.push(regRes.readInt16BE(9 + i * 2));
      registers = {
        agitatorSpeed: Math.max(0, regs[0]),
        homoSpeed: Math.max(0, regs[1]),
        vesselTemp: parseFloat((regs[2] / 10.0).toFixed(1)),
        jacketTemp: parseFloat((regs[3] / 10.0).toFixed(1)),
        vacuumPressure: parseFloat((regs[4] / 10.0).toFixed(1)),
        vesselLevel: parseFloat((regs[5] / 10.0).toFixed(1)),
      };
    }

    return {
      connected: true,
      latencyMs: Date.now() - t0,
      timestamp: new Date().toLocaleTimeString(),
      outputs,
      inputs,
      registers,
    };
  } catch (err) {
    return {
      connected: false,
      error: err.message,
      timestamp: new Date().toLocaleTimeString(),
      outputs,
      inputs,
      registers,
    };
  }
}

async function writeOutput(outputIdx, state) {
  const coilAddr = Y_COIL_BASE + outputIdx;
  const pdu = Buffer.from([5, (coilAddr >> 8) & 0xff, coilAddr & 0xff, state ? 0xff : 0x00, 0x00]);
  const res = await sendModbusTransaction(pdu);
  return res.length >= 12 && res[7] === 5;
}

async function writeAllOff() {
  for (let i = 0; i < 16; i++) {
    await writeOutput(i, false);
  }
  return true;
}

async function writeRegister(regOffset, value) {
  const pdu = Buffer.from([6, (regOffset >> 8) & 0xff, regOffset & 0xff, (value >> 8) & 0xff, value & 0xff]);
  const res = await sendModbusTransaction(pdu);
  return res.length >= 12 && res[7] === 6;
}

const HTML_PAGE = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PVA Systems VPU-50 SCADA - Web Commissioning Dashboard</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
    body { background-color: #08213b; color: #e2e8f0; min-height: 100vh; padding: 20px; }
    
    /* Top Header Bar */
    .header-bar {
      display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center;
      background: #0a2e50; border: 1px solid #1d5b94; border-radius: 8px;
      padding: 16px 24px; margin-bottom: 20px; box-shadow: 0 4px 12px rgba(0,0,0,0.3);
    }
    .brand-title { display: flex; align-items: center; gap: 14px; }
    .brand-badge { background: #154d80; color: #00d2ff; padding: 6px 12px; border-radius: 6px; font-weight: 700; font-size: 14px; letter-spacing: 1px; }
    .brand-h1 { font-size: 20px; font-weight: 700; color: #f8fafc; letter-spacing: 0.5px; }
    .sub-title { font-size: 13px; color: #94a3b8; }
    .comm-status { display: flex; align-items: center; gap: 20px; font-size: 13px; }
    .status-pill {
      display: flex; align-items: center; gap: 8px; padding: 6px 14px; border-radius: 20px;
      background: rgba(34, 197, 94, 0.15); border: 1px solid #22c55e; color: #4ade80; font-weight: 600;
    }
    .status-pill.offline { background: rgba(220, 38, 38, 0.15); border-color: #dc2626; color: #f87171; }
    .pulse-dot { width: 10px; height: 10px; border-radius: 50%; background: #22c55e; animation: pulse 1.5s infinite; }
    .pulse-dot.offline { background: #dc2626; animation: none; }
    @keyframes pulse { 0% { opacity: 1; transform: scale(1); } 50% { opacity: 0.4; transform: scale(1.2); } 100% { opacity: 1; transform: scale(1); } }
    
    /* Dashboard Grid */
    .dash-grid { display: grid; grid-template-columns: repeat(12, 1fr); gap: 20px; }
    
    /* Cards */
    .card {
      background: #0a2e50; border: 1px solid #1d5b94; border-radius: 8px; padding: 18px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.25);
    }
    .card-title {
      font-size: 15px; font-weight: 700; color: #38bdf8; text-transform: uppercase;
      letter-spacing: 0.8px; margin-bottom: 14px; display: flex; justify-content: space-between; align-items: center;
    }
    
    /* Output Controls Grid */
    .output-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 12px; }
    .output-item {
      background: #0c345a; border: 1px solid #1e40af; border-radius: 6px; padding: 12px 14px;
      display: flex; justify-content: space-between; align-items: center; cursor: pointer;
      transition: all 0.15s ease; user-select: none;
    }
    .output-item:hover { border-color: #38bdf8; transform: translateY(-1px); }
    .output-item.active {
      background: #144570; border-color: #22c55e; box-shadow: 0 0 12px rgba(34, 197, 94, 0.3);
    }
    .output-info { display: flex; flex-direction: column; gap: 3px; }
    .output-tag { font-size: 11px; font-weight: 700; color: #38bdf8; }
    .output-name { font-size: 13px; font-weight: 600; color: #f1f5f9; }
    .output-coil { font-size: 10px; color: #64748b; }
    .toggle-led {
      width: 20px; height: 20px; border-radius: 50%; border: 2px solid #475569;
      background: #1e293b; display: flex; align-items: center; justify-content: center;
      transition: all 0.2s;
    }
    .output-item.active .toggle-led {
      border-color: #22c55e; background: #22c55e; box-shadow: 0 0 10px #22c55e;
    }
    
    /* Inputs Matrix */
    .input-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 10px; }
    .input-item {
      background: #082846; border: 1px solid #1a426b; border-radius: 6px; padding: 10px 12px;
      display: flex; align-items: center; gap: 12px;
    }
    .input-led {
      width: 14px; height: 14px; border-radius: 50%; border: 1.5px solid #475569; background: #1e293b;
    }
    .input-item.active .input-led {
      border-color: #22c55e; background: #22c55e; box-shadow: 0 0 8px #22c55e;
    }
    .input-desc { font-size: 12px; color: #cbd5e1; }
    
    /* Telemetry KPI Cards */
    .kpi-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 14px; margin-bottom: 20px; }
    .kpi-box {
      background: #0c345a; border: 1px solid #1d5b94; border-radius: 8px; padding: 16px;
      display: flex; flex-direction: column; gap: 6px;
    }
    .kpi-label { font-size: 12px; font-weight: 600; color: #94a3b8; text-transform: uppercase; }
    .kpi-val { font-size: 28px; font-weight: 800; color: #00d2ff; }
    .kpi-unit { font-size: 14px; color: #64748b; font-weight: 500; }
    
    /* Emergency & Action Buttons */
    .btn-emergency {
      background: #dc2626; color: white; border: none; border-radius: 6px; padding: 8px 16px;
      font-weight: 700; font-size: 13px; cursor: pointer; transition: all 0.2s;
    }
    .btn-emergency:hover { background: #b91c1c; box-shadow: 0 0 10px rgba(220, 38, 38, 0.5); }
    .btn-action {
      background: #154d80; color: #38bdf8; border: 1px solid #1d5b94; border-radius: 6px;
      padding: 6px 12px; font-size: 12px; font-weight: 600; cursor: pointer; transition: all 0.2s;
    }
    .btn-action:hover { background: #1e5c96; color: white; }

    /* Event Audit Stream */
    .log-box {
      background: #051628; border: 1px solid #173d63; border-radius: 6px; padding: 12px;
      font-family: "Courier New", monospace; font-size: 12px; max-height: 180px; overflow-y: auto;
    }
    .log-entry { margin-bottom: 4px; color: #94a3b8; }
    .log-entry.write { color: #38bdf8; }
    .log-entry.err { color: #f87171; }
  </style>
</head>
<body>

  <!-- Top Navigation & Machine Header -->
  <div class="header-bar">
    <div class="brand-title">
      <span class="brand-badge">VPU 50</span>
      <div>
        <h1 class="brand-h1">PVA SYSTEMS — BATCH SKID SCADA</h1>
        <div class="sub-title">Industrial Commissioning & Diagnostics Web Console (AS-FFTP01 Port)</div>
      </div>
    </div>
    <div class="comm-status">
      <div id="statusPill" class="status-pill">
        <span id="pulseDot" class="pulse-dot"></span>
        <span id="statusText">CONNECTING...</span>
      </div>
      <div>Target: <strong>${PLC_HOST}:${PLC_PORT}</strong></div>
      <div id="latencyDisplay">Latency: -- ms</div>
      <div id="timestampDisplay">--:--:--</div>
    </div>
  </div>

  <!-- Live Process Telemetry Gauges -->
  <div class="kpi-row">
    <div class="kpi-box">
      <div class="kpi-label">Vessel Product Temp (D2)</div>
      <div><span id="kpiVesselTemp" class="kpi-val">0.0</span> <span class="kpi-unit">°C</span></div>
    </div>
    <div class="kpi-box">
      <div class="kpi-label">Jacket Recirc Temp (D3)</div>
      <div><span id="kpiJacketTemp" class="kpi-val">0.0</span> <span class="kpi-unit">°C</span></div>
    </div>
    <div class="kpi-box">
      <div class="kpi-label">Vessel Vacuum (D4)</div>
      <div><span id="kpiVacuum" class="kpi-val">0.0</span> <span class="kpi-unit">mbar</span></div>
    </div>
    <div class="kpi-box">
      <div class="kpi-label">Agitator Speed (D0)</div>
      <div><span id="kpiAgitator" class="kpi-val">0</span> <span class="kpi-unit">RPM</span></div>
    </div>
    <div class="kpi-box">
      <div class="kpi-label">Homogenizer Speed (D1)</div>
      <div><span id="kpiHomo" class="kpi-val">0</span> <span class="kpi-unit">RPM</span></div>
    </div>
  </div>

  <!-- Main Work Area Grid -->
  <div class="dash-grid">
    <!-- Physical Digital Outputs Control (Y0.0 - Y0.15) -->
    <div class="card" style="grid-column: span 12;">
      <div class="card-title">
        <span>Physical Digital Outputs Control — Transistor/Relay (Y0.0 – Y0.15)</span>
        <div style="display:flex; gap: 10px;">
          <button class="btn-action" onclick="pollCycle(true)">Refresh Now</button>
          <button class="btn-emergency" onclick="emergencyAllOff()">EMERGENCY ALL OFF</button>
        </div>
      </div>
      <div class="output-grid" id="outputContainer">
        <!-- Rendered dynamically -->
      </div>
    </div>

    <!-- Physical Digital Inputs Matrix (X0.0 - X0.15) -->
    <div class="card" style="grid-column: span 12;">
      <div class="card-title">
        <span>Physical Digital Inputs Status Matrix (X0.0 – X0.15)</span>
        <span style="font-size: 11px; color: #94a3b8;">Refreshed every 500 ms</span>
      </div>
      <div class="input-grid" id="inputContainer">
        <!-- Rendered dynamically -->
      </div>
    </div>

    <!-- 21 CFR Part 11 Audit Action Log -->
    <div class="card" style="grid-column: span 12;">
      <div class="card-title">
        <span>Real-Time Operator Action & Interlock Audit Log</span>
        <button class="btn-action" onclick="clearLogs()">Clear Log</button>
      </div>
      <div class="log-box" id="logBox">
        <div class="log-entry">[SYSTEM] PVA VPU-50 SCADA Web Console initialized. Ready on AS-FFTP01 port.</div>
      </div>
    </div>
  </div>

  <script>
    const OUTPUT_NAMES = ${JSON.stringify(OUTPUT_NAMES)};
    const INPUT_NAMES = ${JSON.stringify(INPUT_NAMES)};
    let isPolling = false;

    function addLog(msg, type = "info") {
      const box = document.getElementById("logBox");
      const div = document.createElement("div");
      div.className = "log-entry " + type;
      div.textContent = "[" + new Date().toLocaleTimeString() + "] " + msg;
      box.appendChild(div);
      box.scrollTop = box.scrollHeight;
    }

    function clearLogs() {
      document.getElementById("logBox").innerHTML = "";
    }

    async function toggleOutput(idx, currentState) {
      const targetState = !currentState;
      addLog("Operator command: Set Output Y0." + idx + " (" + OUTPUT_NAMES[idx] + ") -> " + (targetState ? "ON" : "OFF"), "write");
      try {
        const res = await fetch("/api/plc", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ action: "set_output", output: idx, state: targetState })
        });
        const json = await res.json();
        if (json.success) {
          addLog("PLC ACK: Output Y0." + idx + " confirmed " + (targetState ? "ENERGIZED" : "DE-ENERGIZED"), "write");
          pollCycle();
        } else {
          addLog("PLC ERROR: " + (json.error || "Write rejected"), "err");
        }
      } catch (err) {
        addLog("Network communication error: " + err.message, "err");
      }
    }

    async function emergencyAllOff() {
      if (!confirm("Are you sure you want to turn OFF all 16 digital outputs on the PLC rack?")) return;
      addLog("SAFETY INTERLOCK: EMERGENCY ALL OUTPUTS OFF ACTIVATED", "err");
      try {
        const res = await fetch("/api/plc", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ action: "all_off" })
        });
        const json = await res.json();
        if (json.success) {
          addLog("PLC ACK: All 16 outputs confirmed OFF.", "write");
          pollCycle();
        }
      } catch (err) {
        addLog("Network error: " + err.message, "err");
      }
    }

    async function pollCycle(force = false) {
      if (isPolling && !force) return;
      isPolling = true;
      try {
        const res = await fetch("/api/plc");
        const data = await res.json();

        const statusPill = document.getElementById("statusPill");
        const pulseDot = document.getElementById("pulseDot");
        const statusText = document.getElementById("statusText");
        const latencyDisplay = document.getElementById("latencyDisplay");
        const timestampDisplay = document.getElementById("timestampDisplay");

        if (data.connected) {
          statusPill.className = "status-pill";
          pulseDot.className = "pulse-dot";
          statusText.textContent = "ONLINE (AS-FFTP01)";
          latencyDisplay.textContent = "Latency: " + data.latencyMs + " ms";
          timestampDisplay.textContent = data.timestamp;

          // Update KPI values
          document.getElementById("kpiVesselTemp").textContent = data.registers.vesselTemp.toFixed(1);
          document.getElementById("kpiJacketTemp").textContent = data.registers.jacketTemp.toFixed(1);
          document.getElementById("kpiVacuum").textContent = data.registers.vacuumPressure.toFixed(1);
          document.getElementById("kpiAgitator").textContent = data.registers.agitatorSpeed;
          document.getElementById("kpiHomo").textContent = data.registers.homoSpeed;

          // Render Outputs Grid
          const outContainer = document.getElementById("outputContainer");
          outContainer.innerHTML = "";
          data.outputs.forEach((val, idx) => {
            const item = document.createElement("div");
            item.className = "output-item " + (val ? "active" : "");
            item.onclick = () => toggleOutput(idx, val);
            item.innerHTML = \`
              <div class="output-info">
                <div class="output-tag">OUT \${idx} / Y0.\${idx}</div>
                <div class="output-name">\${OUTPUT_NAMES[idx]}</div>
                <div class="output-coil">Coil 4096\${idx} (\${val ? "ENERGIZED" : "OFF"})</div>
              </div>
              <div class="toggle-led"></div>
            \`;
            outContainer.appendChild(item);
          });

          // Render Inputs Grid
          const inContainer = document.getElementById("inputContainer");
          inContainer.innerHTML = "";
          data.inputs.forEach((val, idx) => {
            const item = document.createElement("div");
            item.className = "input-item " + (val ? "active" : "");
            item.innerHTML = \`
              <div class="input-led"></div>
              <div>
                <div style="font-weight:700; font-size:11px; color:#38bdf8;">IN \${idx} / X0.\${idx}</div>
                <div class="input-desc">\${INPUT_NAMES[idx]}</div>
              </div>
            \`;
            inContainer.appendChild(item);
          });
        } else {
          statusPill.className = "status-pill offline";
          pulseDot.className = "pulse-dot offline";
          statusText.textContent = "OFFLINE (" + (data.error || "Timeout") + ")";
        }
      } catch (err) {
        document.getElementById("statusPill").className = "status-pill offline";
        document.getElementById("pulseDot").className = "pulse-dot offline";
        document.getElementById("statusText").textContent = "DISCONNECTED";
      } finally {
        isPolling = false;
      }
    }

    // Start 500 ms continuous polling loop
    pollCycle();
    setInterval(pollCycle, 500);
  </script>
</body>
</html>
`;

const server = http.createServer(async (req, res) => {
  const parsed = url.parse(req.url, true);
  const pathname = parsed.pathname;

  // CORS headers
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    res.writeHead(204);
    res.end();
    return;
  }

  if (pathname === "/api/plc" && req.method === "GET") {
    const data = await getPlcState();
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify(data));
    return;
  }

  if (pathname === "/api/plc" && req.method === "POST") {
    let body = "";
    req.on("data", chunk => { body += chunk; });
    req.on("end", async () => {
      try {
        const payload = JSON.parse(body || "{}");
        if (payload.action === "set_output") {
          const ok = await writeOutput(parseInt(payload.output, 10), Boolean(payload.state));
          res.writeHead(200, { "Content-Type": "application/json" });
          res.end(JSON.stringify({ success: ok, output: payload.output, state: payload.state }));
          return;
        }
        if (payload.action === "all_off") {
          const ok = await writeAllOff();
          res.writeHead(200, { "Content-Type": "application/json" });
          res.end(JSON.stringify({ success: ok }));
          return;
        }
        if (payload.action === "set_register") {
          const ok = await writeRegister(parseInt(payload.register, 10), parseInt(payload.value, 10));
          res.writeHead(200, { "Content-Type": "application/json" });
          res.end(JSON.stringify({ success: ok }));
          return;
        }
        res.writeHead(400, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ success: false, error: "Unknown action" }));
      } catch (err) {
        res.writeHead(500, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ success: false, error: err.message }));
      }
    });
    return;
  }

  // Serve Main Dashboard
  res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
  res.end(HTML_PAGE);
});

server.listen(PORT, () => {
  console.log("====================================================================");
  console.log("  PVA SYSTEMS VPU-50 SCADA - REAL-TIME INDUSTRIAL WEB DASHBOARD");
  console.log(`  Local Web Server:  http://localhost:${PORT}`);
  console.log(`  Target Delta PLC:  ${PLC_HOST}:${PLC_PORT} (via AS-FFTP01)`);
  console.log("====================================================================");
});


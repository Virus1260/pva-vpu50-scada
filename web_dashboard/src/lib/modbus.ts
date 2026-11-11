import net from "net";

export const PLC_CONFIG = {
  host: process.env.PLC_IP || "192.168.1.5",
  port: parseInt(process.env.PLC_PORT || "502", 10),
  timeoutMs: 2500,
  yCoilBase: 40960,     // 0xA000: Y0.0
  xInputBase: 24576,    // 0x6000: X0.0
  dRegBase: 0,          // D0
};

export interface PlcSnapshot {
  connected: boolean;
  host: string;
  port: number;
  latencyMs: number;
  timestamp: string;
  outputs: boolean[];       // Y0.0 - Y0.15
  inputs: boolean[];        // X0.0 - X0.15
  registers: {
    agitatorSpeedPv: number;       // D0 (RPM)
    homogenizerSpeedPv: number;    // D1 (RPM)
    vesselTempC: number;           // D2 (0.1 °C)
    jacketTempC: number;           // D3 (0.1 °C)
    vacuumMbar: number;            // D4 (-8000 to 0)
    levelL: number;                // D5 (Liters)
    agitatorCurrentA: number;      // D10 (Amps)
    homoCurrentA: number;          // D11 (Amps)
  };
  error?: string;
}

function sendModbusTransaction(host: string, port: number, pduReq: Buffer): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    const socket = new net.Socket();
    let timer: NodeJS.Timeout | null = null;
    let resolved = false;

    const cleanup = () => {
      if (timer) clearTimeout(timer);
      socket.removeAllListeners();
      socket.destroy();
    };

    timer = setTimeout(() => {
      if (!resolved) {
        resolved = true;
        cleanup();
        reject(new Error(`Modbus TCP connection timeout to ${host}:${port}`));
      }
    }, PLC_CONFIG.timeoutMs);

    socket.connect(port, host, () => {
      // Build MBAP Header (7 bytes): TransactionId(2), Protocol(2), Length(2), UnitId(1)
      const mbap = Buffer.alloc(7);
      mbap.writeUInt16BE(1, 0); // Transaction ID
      mbap.writeUInt16BE(0, 2); // Protocol ID (Modbus = 0)
      mbap.writeUInt16BE(pduReq.length + 1, 4); // Length = PDU + UnitId
      mbap.writeUInt8(1, 6);   // Unit ID

      socket.write(Buffer.concat([mbap, pduReq]));
    });

    socket.on("data", (data) => {
      if (!resolved) {
        resolved = true;
        cleanup();
        resolve(data);
      }
    });

    socket.on("error", (err) => {
      if (!resolved) {
        resolved = true;
        cleanup();
        reject(err);
      }
    });
  });
}

export async function readPlcState(host = PLC_CONFIG.host, port = PLC_CONFIG.port): Promise<PlcSnapshot> {
  const startTime = Date.now();
  const snapshot: PlcSnapshot = {
    connected: false,
    host,
    port,
    latencyMs: 0,
    timestamp: new Date().toISOString(),
    outputs: new Array(16).fill(false),
    inputs: new Array(16).fill(false),
    registers: {
      agitatorSpeedPv: 0,
      homogenizerSpeedPv: 0,
      vesselTempC: 0.0,
      jacketTempC: 0.0,
      vacuumMbar: 0.0,
      levelL: 0.0,
      agitatorCurrentA: 0.0,
      homoCurrentA: 0.0,
    },
  };

  try {
    // 1. Read 16 Output Coils (FC 01, Address 40960 / 0xA000)
    const coilReq = Buffer.alloc(5);
    coilReq.writeUInt8(1, 0); // FC 01
    coilReq.writeUInt16BE(PLC_CONFIG.yCoilBase, 1);
    coilReq.writeUInt16BE(16, 3);
    const coilRes = await sendModbusTransaction(host, port, coilReq);
    if (coilRes.length >= 11) {
      const b0 = coilRes[9];
      const b1 = coilRes[10];
      for (let i = 0; i < 8; i++) snapshot.outputs[i] = Boolean(b0 & (1 << i));
      for (let i = 0; i < 8; i++) snapshot.outputs[8 + i] = Boolean(b1 & (1 << i));
    }

    // 2. Read 16 Discrete Inputs (FC 02, Address 24576 / 0x6000)
    const inputReq = Buffer.alloc(5);
    inputReq.writeUInt8(2, 0); // FC 02
    inputReq.writeUInt16BE(PLC_CONFIG.xInputBase, 1);
    inputReq.writeUInt16BE(16, 3);
    const inputRes = await sendModbusTransaction(host, port, inputReq);
    if (inputRes.length >= 11) {
      const b0 = inputRes[9];
      const b1 = inputRes[10];
      for (let i = 0; i < 8; i++) snapshot.inputs[i] = Boolean(b0 & (1 << i));
      for (let i = 0; i < 8; i++) snapshot.inputs[8 + i] = Boolean(b1 & (1 << i));
    }

    // 3. Read 14 Holding Registers D0–D13 (FC 03, Address 0)
    const regReq = Buffer.alloc(5);
    regReq.writeUInt8(3, 0); // FC 03
    regReq.writeUInt16BE(PLC_CONFIG.dRegBase, 1);
    regReq.writeUInt16BE(14, 3);
    const regRes = await sendModbusTransaction(host, port, regReq);
    if (regRes.length >= 9 + 28) {
      const regs: number[] = [];
      for (let i = 0; i < 14; i++) {
        regs.push(regRes.readInt16BE(9 + i * 2));
      }
      snapshot.registers = {
        agitatorSpeedPv: Math.max(0, regs[0]),
        homogenizerSpeedPv: Math.max(0, regs[1]),
        vesselTempC: parseFloat((regs[2] / 10.0).toFixed(1)),
        jacketTempC: parseFloat((regs[3] / 10.0).toFixed(1)),
        vacuumMbar: parseFloat((regs[4] / 10.0).toFixed(1)),
        levelL: parseFloat((regs[5] / 10.0).toFixed(1)),
        agitatorCurrentA: parseFloat((regs[10] / 10.0).toFixed(1)),
        homoCurrentA: parseFloat((regs[11] / 10.0).toFixed(1)),
      };
    }

    snapshot.connected = true;
    snapshot.latencyMs = Date.now() - startTime;
  } catch (err: any) {
    snapshot.connected = false;
    snapshot.error = err.message || String(err);
  }

  return snapshot;
}

export async function writePlcOutput(outputIndex: number, state: boolean, host = PLC_CONFIG.host, port = PLC_CONFIG.port): Promise<boolean> {
  const req = Buffer.alloc(5);
  req.writeUInt8(5, 0); // FC 05 (Write Single Coil)
  req.writeUInt16BE(PLC_CONFIG.yCoilBase + outputIndex, 1);
  req.writeUInt16BE(state ? 0xFF00 : 0x0000, 3);
  const res = await sendModbusTransaction(host, port, req);
  return res.length >= 12 && res[7] === 5;
}

export async function writeAllOutputsOff(host = PLC_CONFIG.host, port = PLC_CONFIG.port): Promise<boolean> {
  for (let i = 0; i < 16; i++) {
    await writePlcOutput(i, false, host, port);
  }
  return true;
}

export async function writePlcRegister(registerOffset: number, value: number, host = PLC_CONFIG.host, port = PLC_CONFIG.port): Promise<boolean> {
  const req = Buffer.alloc(5);
  req.writeUInt8(6, 0); // FC 06 (Write Single Register)
  req.writeUInt16BE(registerOffset, 1);
  req.writeInt16BE(value, 3);
  const res = await sendModbusTransaction(host, port, req);
  return res.length >= 12 && res[7] === 6;
}


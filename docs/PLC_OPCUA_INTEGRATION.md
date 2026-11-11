# Delta AS332T-A PLC Integration Guide & Canonical Register Map

## 1. Hardware Architecture
- **PLC**: Delta AS332T-A Compact Modular Mid-Range PLC
- **CPU**: 32-bit SoC, built-in RJ45 Ethernet (Port 502, Default IP: `192.168.1.5`), Mini-USB, RS-485
- **Power**: PS02 (100–240V AC to 24V DC backplane)
- **Expansion Modules**:
  - `AS16AM10N-A`: 16-channel 24V DC Digital Input (Valve feedback & safety limit switches)
  - `AS04AD-A`: 4-channel 16-bit Analog Input (Level 1L1001, Vacuum 1P1001)
  - `AS04DA-A`: 4-channel 16-bit Analog Output (VFD 0–10V, Steam Valve 4–20mA)
  - `AS06RTD-A`: 6-channel RTD Input (PT100 3-Wire Temperature Sensors: Vessel 1T1001, Jacket)
- **Communication Protocol**: Modbus TCP over Industrial Ethernet (Native Port 502)

---

## 2. Canonical Delta Register & Coil Memory Map
Standard Delta Modbus Addressing:
- **Holding Registers D0–D99** $\rightarrow$ Modbus `40001`–`40100` (Zero-based offset `0`–`99`)
- **Coils M0–M63** $\rightarrow$ Modbus `00001`–`00064` (Zero-based offset `0`–`63`)

### Real-Time Telemetry Registers (PLC $\rightarrow$ SCADA Read-Only: D0–D19)
| Delta Reg | Modbus Address | Tag Name | Description | Scaling / Resolution | Engineering Unit |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **D0** | `40001` (Offset 0) | `vpu.main.agitator_speed` | Anchor Agitator Speed PV | 1 = 1 RPM | RPM (0–120) |
| **D1** | `40002` (Offset 1) | `vpu.main.homogenizer_speed`| Rotor-Stator Speed PV | 1 = 1 RPM | RPM (0–4800) |
| **D2** | `40003` (Offset 2) | `vpu.main.temperature` | Vessel Product Temp PV (RTD) | Signed 16-bit, 10 = 1.0 °C | °C (-20.0 to 150.0) |
| **D3** | `40004` (Offset 3) | `vpu.jacket.temperature` | Heating Jacket Temp PV (RTD) | Signed 16-bit, 10 = 1.0 °C | °C (-20.0 to 160.0) |
| **D4** | `40005` (Offset 4) | `vpu.main.vacuum_pressure` | Headspace Vacuum PV | Signed 16-bit, 10 = 1.0 mbar | mbar (-1000.0 to 0) |
| **D5** | `40006` (Offset 5) | `vpu.main.level` | Vessel Level PV | 10 = 1.0 L | Liters (0 to 500.0) |
| **D10**| `40011` (Offset 10)| `vpu.main.agitator_current`| Agitator Motor Current | 10 = 1.0 A | Amperes |
| **D11**| `40012` (Offset 11)| `vpu.main.homogenizer_current`| Homogenizer Motor Current | 10 = 1.0 A | Amperes |
| **D12**| `40013` (Offset 12)| `vpu.main.agitator_power` | Agitator Active Power | 10 = 1.0 kW | kW |
| **D13**| `40014` (Offset 13)| `vpu.main.homogenizer_power` | Homogenizer Active Power | 10 = 1.0 kW | kW |

### Active Step Setpoints (SCADA $\rightarrow$ PLC Write: D50–D59)
| Delta Reg | Modbus Address | Description | Format |
| :--- | :--- | :--- | :--- |
| **D50** | `40051` (Offset 50) | Target Agitator Speed SP | Integer RPM |
| **D51** | `40052` (Offset 51) | Target Homogenizer Speed SP | Integer RPM |
| **D52** | `40053` (Offset 52) | Target Temperature SP | Signed, 10 = 1.0 °C |
| **D53** | `40054` (Offset 53) | Temperature Ramp Rate SP | 10 = 1.0 °C/h |
| **D54** | `40055` (Offset 54) | Target Vacuum Pressure SP | Signed, 10 = 1.0 mbar |
| **D55** | `40056` (Offset 55) | Step Duration SP | Seconds |
| **D56** | `40057` (Offset 56) | Operating Mode Bitmask | Bitfield flags |

### Status & Control Coils
| Coil | Modbus Address | Direction | Description |
| :--- | :--- | :--- | :--- |
| **M0** | `00001` (Offset 0) | SCADA $\rightarrow$ PLC | Process Sequence Start / Run Command |
| **M1** | `00002` (Offset 1) | SCADA $\rightarrow$ PLC | Step Execution Pulse Trigger |
| **M2** | `00003` (Offset 2) | SCADA $\rightarrow$ PLC | Mode Select (1 = Auto/Locked, 0 = Manual) |
| **M3** | `00004` (Offset 3) | SCADA $\rightarrow$ PLC | Process Sequence Abort |
| **M4** | `00005` (Offset 4) | SCADA $\rightarrow$ PLC | Process Sequence Hold / Pause |
| **M10**| `00011` (Offset 10)| SCADA $\rightarrow$ PLC | SCADA Watchdog Heartbeat (toggled every 500 ms) |
| **M32**| `00033` (Offset 32)| PLC $\rightarrow$ SCADA | PLC Sequence Running Feedback |
| **M33**| `00034` (Offset 33)| PLC $\rightarrow$ SCADA | PLC Active Step Running Feedback |
| **M34**| `00035` (Offset 34)| PLC $\rightarrow$ SCADA | PLC Step Complete Pulse |
| **M35**| `00036` (Offset 35)| PLC $\rightarrow$ SCADA | PLC Hold / Interlock Tripped |
| **M40**| `00041` (Offset 40)| PLC $\rightarrow$ SCADA | FS-102 Homogenizer Seal Water Flow (1 = OK) |
| **M41**| `00042` (Offset 41)| PLC $\rightarrow$ SCADA | LSL-101 Minimum Vessel Level >150L (1 = OK) |
| **M42**| `00043` (Offset 42)| PLC $\rightarrow$ SCADA | Agitator $\ge$ 15 RPM during Heating (1 = OK) |
| **M43**| `00044` (Offset 43)| PLC $\rightarrow$ SCADA | Vessel Hatch & Ports Closed Interlock (1 = OK) |

---

## 3. Operational Modes
Launch the SCADA client with the desired operational mode:

```bash
# 1. Pure Simulation (offline software testing)
python main.py --mode SIMULATION

# 2. Bench Monitor (read-only telemetry from physical Delta PLC, zero writes)
python main.py --mode BENCH_MONITOR --plc-ip 192.168.1.5 --plc-port 502

# 3. Bench Control (physical Delta PLC with active output setpoints & interlocks)
python main.py --mode BENCH_CONTROL --plc-ip 192.168.1.5 --plc-port 502
```

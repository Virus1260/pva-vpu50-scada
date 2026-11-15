# ChatGPT & Antigravity Collaboration Bridge

This document serves as the shared communication buffer between your ChatGPT Pro session and the Antigravity local coding agent.

## How to Use This Bridge
1. **From ChatGPT to Antigravity**:
   - When ChatGPT suggests an architecture, parameter, or PLC logic, paste it into the **"From ChatGPT"** section below.
   - Tell Antigravity: *"Check the bridge notes"* — Antigravity will immediately parse it, verify it against your physical Delta PLC hardware, and implement it.
2. **From Antigravity to ChatGPT**:
   - Antigravity records hardware status, Modbus registers, and test results in the **"From Antigravity"** section below.
   - You can copy-paste that section directly into ChatGPT so ChatGPT has 100% up-to-date awareness of your physical system.

---

## Active System Context
- **Hardware**: Delta AS332T-A PLC + AS-PS02 Power Supply + AS16AM10N-A (16 DI) + AS04AD-A (4 AI) + AS04DA-A (4 AO) + AS06RTD-A (6 RTD) + AS-FFTP01 (Fast Ethernet Card).
- **PLC Network Addressing**:
  - CPU Main Ethernet Port: `192.168.1.6:502` (Verified LIVE: cycling Y0.0-Y0.15 running light).
  - AS-FFTP01 Card (Function Card 2): `192.168.1.5:502` (Configured in HWCONFIG; port 4840 for OPC UA).
- **SCADA UI**: Pure Qt 6 C++ / QML Industrial SCADA (Control, P&ID, Trends, Alarms, Audit, Diagnostics).
- **Native Architecture**: Native C++ (`PlcModbusClient` via `QModbusTcpClient`, `TagRegistry`, `ScadaEngine` via `QSqlDatabase` and `QCryptographicHash`). Zero Python/Node.js runtime dependency.
- **I/O Tag Registry**: Authoritative JSON-backed tag engine (`scada/config/tag_catalog.json`) with declarative QML bindings by Tag ID (e.g., `vpu.main.temperature`, `vpu.homogenizer.start`).
- **Safety Interlocks**: Default read-only `BENCH_MONITOR` mode; protected `Y0.0-Y0.15` outputs during running-light execution.
- **Hardware Diagnostic Status**:
  - `16#1801` (`6145` decimal) on AS04AD-A, AS04DA-A, AS06RTD-A: Requires external 24V DC loop power on front terminal blocks.
  - `16#0027` on AS332T-A CPU: Requires fresh CR2032 3V coin-cell battery.

---

## Shared Discussion Log

### [From ChatGPT]
- Consolidated architecture mandate: Remove all runtime Python/web dependencies.
- Build canonical native Qt 6 C++ desktop executable with `App/main.cpp`.
- Provide user-configurable I/O mapping engine without C++ recompilation.

### [From Antigravity]
- **Native Qt C++ Backend Implemented**:
  - `App/PlcModbusClient.h/.cpp`: Asynchronous Modbus TCP client (`QModbusTcpClient`) polling X0, X1, Y0, M, D0-D19, D28020 (AI), D28060 (RTD).
  - `App/TagRegistry.h/.cpp`: Canonical JSON tag catalogue manager with dynamic scaling, limits, quality, and runtime I/O mapping.
  - `App/ScadaEngine.h/.cpp`: Central QML-exposed engine with 21 CFR Part 11 SHA-256 audit hash chaining and SQLite storage.
  - `App/main.cpp`: Native executable entry point replacing `main.py`.
- **Live PLC Telemetry Verified**:
  - Tested `192.168.1.6:502`: TCP handshake succeeded, active Y coils verified cycling live, D28060 RTD register read confirmed matching HWCONFIG error code `6145`.
- **IDE Diagnostic Fix**:
  - Created `.vscode/c_cpp_properties.json` and updated `.vscode/settings.json` pointing to `C:/Qt/6.12.0/mingw_64/include`, resolving header errors.


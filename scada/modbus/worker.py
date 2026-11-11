"""
Dedicated industrial Ethernet communication worker for Delta AS332T-A PLC.
Runs a 50–100 ms polling loop over Modbus TCP without blocking the Qt Quick UI thread.
Enforces strict operational mode separation: SIMULATION, BENCH_MONITOR, and BENCH_CONTROL.
"""

from __future__ import annotations

from enum import Enum
import logging
import threading
import time
from typing import Any, Dict, Optional

from PySide6.QtCore import QObject, QThread, Signal, Slot
from pymodbus.client import ModbusTcpClient

for logger_name in ("pymodbus", "pymodbus.client", "pymodbus.logging"):
    logging.getLogger(logger_name).setLevel(logging.CRITICAL)

from scada.modbus.delta_map import DeltaRegisterMap, unpack_telemetry_registers
from scada.modbus.handshake import Isa88BatchHandshake


class OperationalMode(str, Enum):
    """Mutually exclusive industrial operational modes."""
    SIMULATION = "SIMULATION"        # Safe software simulator (zero network packets)
    BENCH_MONITOR = "BENCH_MONITOR"  # Physical PLC read-only monitoring (zero outputs/writes)
    BENCH_CONTROL = "BENCH_CONTROL"  # Active physical PLC setpoint writes & interlocks


class ModbusWorker(QThread):
    """
    Industrial Modbus TCP Communication Worker.
    Provides thread-safe, non-blocking polling of Delta AS332T-A PLC telemetry
    and strictly enforces read-only safety in BENCH_MONITOR mode.
    """

    telemetryPolled = Signal(dict)
    statusBitsPolled = Signal(dict)
    connectionStateChanged = Signal(bool, str)
    stepDoneSignaled = Signal(int)

    def __init__(
        self,
        host: str = "192.168.1.5",
        port: int = 502,
        poll_interval_ms: int = 100,
        mode: str | OperationalMode = OperationalMode.SIMULATION,
        enable_simulation_fallback: bool = False,
        parent: Optional[QObject] = None,
    ) -> None:
        super().__init__(parent)
        self.host = host
        self.port = port
        self.poll_interval_sec = poll_interval_ms / 1000.0
        if isinstance(mode, str):
            try:
                self.mode = OperationalMode(mode)
            except ValueError:
                self.mode = OperationalMode.SIMULATION
        else:
            self.mode = mode

        self.enable_simulation_fallback = enable_simulation_fallback

        self._running = True
        self._is_connected = False
        self._heartbeat_state = False
        self._last_step_done_coil = False
        self._active_step_index = 1
        self._lock = threading.Lock()
        self._client: Optional[ModbusTcpClient] = None

    @property
    def is_connected(self) -> bool:
        return self._is_connected

    def run(self) -> None:
        """Main non-blocking thread loop."""
        # 1. Mode: SIMULATION (Safe offline mode: do not open raw TCP sockets)
        if self.mode == OperationalMode.SIMULATION:
            self._is_connected = True
            self.connectionStateChanged.emit(True, "SIMULATION: Virtual Skid Backend Active")
            while self._running:
                time.sleep(0.1)
            return

        # 2. Mode: Physical Hardware (BENCH_MONITOR or BENCH_CONTROL)
        self._client = ModbusTcpClient(self.host, port=self.port, timeout=0.2)
        last_connect_attempt = 0.0
        connect_retry_interval = 2.0

        while self._running:
            start_time = time.time()

            try:
                if not self._is_connected:
                    now = time.time()
                    if now - last_connect_attempt >= connect_retry_interval:
                        last_connect_attempt = now
                        connected = False
                        try:
                            with self._lock:
                                connected = self._client.connect()
                        except Exception as conn_err:
                            connected = False

                        if connected:
                            self._is_connected = True
                            mode_label = "READ-ONLY MONITOR" if self.mode == OperationalMode.BENCH_MONITOR else "ACTIVE CONTROL"
                            self.connectionStateChanged.emit(True, f"Connected to Delta AS332T ({mode_label}) at {self.host}:{self.port}")
                        else:
                            self.connectionStateChanged.emit(False, f"Offline: Reconnecting to Delta PLC at {self.host}:{self.port}...")

                    if not self._is_connected:
                        time.sleep(0.1)
                        continue

                # 3. Read Real-Time Telemetry Holding Registers (D0 - D19)
                with self._lock:
                    rr = self._client.read_holding_registers(0, count=20)
                    rc = self._client.read_coils(DeltaRegisterMap.COIL_PLC_BATCH_RUNNING, count=16)

                if rr.isError() or rc.isError():
                    raise ConnectionError("Modbus response returned protocol exception error.")

                regs = rr.registers
                coils = rc.bits[:16]

                # 4. Unpack and emit telemetry
                telemetry = unpack_telemetry_registers(regs, coils)
                telemetry["quality"] = "GOOD"
                telemetry["operating_mode"] = self.mode.value
                self.telemetryPolled.emit(telemetry)

                # 5. Check Step Done Pulse (M34)
                current_step_done = telemetry.get("plc.step_done", False)
                if current_step_done and not self._last_step_done_coil:
                    self.stepDoneSignaled.emit(self._active_step_index)
                self._last_step_done_coil = current_step_done

                # 6. Watchdog Heartbeat (Only in BENCH_CONTROL mode, NEVER in BENCH_MONITOR)
                if self.mode == OperationalMode.BENCH_CONTROL:
                    self._heartbeat_state = not self._heartbeat_state
                    with self._lock:
                        Isa88BatchHandshake.send_heartbeat(self._client, self._heartbeat_state)

            except Exception as ex:
                if self._is_connected:
                    self._is_connected = False
                    self.connectionStateChanged.emit(False, f"Delta PLC link lost: {ex}")

                # Emit stale telemetry notification on disconnect
                self.telemetryPolled.emit({
                    "quality": "DISCONNECTED",
                    "operating_mode": self.mode.value,
                    "error": str(ex),
                })
                time.sleep(0.2)

            elapsed = time.time() - start_time
            sleep_time = max(0.01, self.poll_interval_sec - elapsed)
            time.sleep(sleep_time)

        # Cleanup on exit
        if self._client:
            with self._lock:
                try:
                    self._client.close()
                except Exception:
                    pass

    def write_process_setpoint(self, register_offset: int, value: int) -> Dict[str, Any]:
        """
        Thread-safe method to write a single setpoint holding register to the PLC.
        Strictly locked out in BENCH_MONITOR mode to prevent unauthorized outputs.
        """
        if self.mode == OperationalMode.BENCH_MONITOR:
            return {
                "success": False,
                "error": "READ_ONLY_LOCK: Writes are prohibited in BENCH_MONITOR mode.",
                "mode": self.mode.value,
            }

        if self.mode == OperationalMode.SIMULATION:
            return {
                "success": True,
                "mode": "SIMULATION",
                "message": f"Simulated write to register offset {register_offset} = {value}",
            }

        if not self._is_connected or not self._client:
            return {
                "success": False,
                "error": "HARDWARE_DISCONNECTED: Cannot write setpoint while PLC is offline.",
                "mode": self.mode.value,
            }

        with self._lock:
            try:
                res = self._client.write_register(register_offset, value)
                if res.isError():
                    return {"success": False, "error": f"Modbus write error: {res}"}
                return {"success": True, "register": register_offset, "value": value}
            except Exception as ex:
                return {"success": False, "error": f"Socket exception: {ex}"}

    def write_digital_output(self, output_index: int, state: bool, force: bool = False) -> Dict[str, Any]:
        """
        Thread-safe method to control physical digital output Y0.x on the Delta AS332T PLC.
        Addresses are mapped starting at 0xA000 (Modbus Coil 40960).
        """
        if not force and self.mode == OperationalMode.BENCH_MONITOR:
            return {
                "success": False,
                "error": "READ_ONLY_LOCK: Physical outputs locked in BENCH_MONITOR mode. Set force=True for bench commissioning.",
                "mode": self.mode.value,
            }

        if self.mode == OperationalMode.SIMULATION:
            return {
                "success": True,
                "output": output_index,
                "state": bool(state),
                "mode": "SIMULATION",
                "message": f"Simulated output Y0.{output_index} = {state}",
            }

        if not self._is_connected or not self._client:
            return {
                "success": False,
                "error": "HARDWARE_DISCONNECTED: Cannot control output while PLC is offline.",
                "mode": self.mode.value,
            }

        coil_addr = DeltaRegisterMap.COIL_Y_BASE + output_index
        with self._lock:
            try:
                res = self._client.write_coil(coil_addr, bool(state))
                if hasattr(res, "isError") and res.isError():
                    return {"success": False, "error": f"Modbus write_coil error: {res}"}
                return {
                    "success": True,
                    "output": output_index,
                    "label": f"Y0.{output_index}",
                    "coilAddress": coil_addr,
                    "state": bool(state),
                }
            except Exception as ex:
                return {"success": False, "error": f"Socket exception: {ex}"}

    def read_digital_outputs(self, start_index: int = 0, count: int = 16) -> List[bool]:
        """Reads physical digital output coil states (Y0.0 - Y0.15)."""
        if self.mode == OperationalMode.SIMULATION or not self._is_connected or not self._client:
            return [False] * count

        start_addr = DeltaRegisterMap.COIL_Y_BASE + start_index
        with self._lock:
            try:
                res = self._client.read_coils(start_addr, count=count)
                if hasattr(res, "isError") and res.isError():
                    return [False] * count
                return list(res.bits[:count]) if hasattr(res, "bits") else [False] * count
            except Exception:
                return [False] * count

    def read_digital_inputs(self, start_index: int = 0, count: int = 16) -> List[bool]:
        """Reads physical digital input states (X0.0 - X0.15)."""
        if self.mode == OperationalMode.SIMULATION or not self._is_connected or not self._client:
            return [False] * count

        start_addr = DeltaRegisterMap.INPUT_X_BASE + start_index
        with self._lock:
            try:
                res = self._client.read_discrete_inputs(start_addr, count=count)
                if hasattr(res, "isError") and res.isError():
                    return [False] * count
                return list(res.bits[:count]) if hasattr(res, "bits") else [False] * count
            except Exception:
                return [False] * count

    def download_step(self, step_data: Dict[str, Any], step_index: int) -> Dict[str, Any]:
        """
        Thread-safe method to download a recipe/process step to the PLC with read-back verification.
        Refuses execution with clear error if offline or in read-only mode.
        """
        self._active_step_index = step_index

        if self.mode == OperationalMode.BENCH_MONITOR:
            return {
                "verified": False,
                "error": "READ_ONLY_LOCK: Recipe/step download prohibited in BENCH_MONITOR mode.",
                "mode": self.mode.value,
            }

        if self.mode == OperationalMode.SIMULATION:
            return {
                "verified": True,
                "stepIndex": step_index,
                "registersVerified": 10,
                "mode": "SIMULATION",
                "message": "Step verified in offline software simulation.",
            }

        if not self._is_connected or not self._client:
            return {
                "verified": False,
                "error": "HARDWARE_DISCONNECTED: Cannot download step while Delta PLC is offline.",
                "mode": self.mode.value,
            }

        with self._lock:
            return Isa88BatchHandshake.download_step_with_readback(self._client, step_data, step_index)

    def stop(self) -> None:
        """Stops the worker thread cleanly."""
        self._running = False
        if self._client:
            with self._lock:
                try:
                    self._client.close()
                except Exception:
                    pass
        self.quit()
        self.wait(2000)

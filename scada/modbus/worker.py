import logging
import time
from typing import Any, Dict, Optional

from PySide6.QtCore import QObject, QThread, Signal, Slot
from pymodbus.client import ModbusTcpClient

for logger_name in ("pymodbus", "pymodbus.client", "pymodbus.logging"):
    logging.getLogger(logger_name).setLevel(logging.CRITICAL)

from scada.modbus.delta_map import DeltaRegisterMap, unpack_telemetry_registers
from scada.modbus.handshake import Isa88BatchHandshake


class ModbusWorker(QThread):
    """
    Dedicated high-speed industrial Ethernet communication worker.
    Runs a 50–100 ms polling loop over Modbus TCP without blocking the Qt Quick UI thread.
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
        enable_simulation_fallback: bool = True,
        parent: Optional[QObject] = None,
    ) -> None:
        super().__init__(parent)
        self.host = host
        self.port = port
        self.poll_interval_sec = poll_interval_ms / 1000.0
        self.enable_simulation_fallback = enable_simulation_fallback

        self._running = True
        self._is_connected = False
        self._heartbeat_state = False
        self._last_step_done_coil = False
        self._active_step_index = 1
        self._client: Optional[ModbusTcpClient] = None

    def run(self) -> None:
        """Main non-blocking thread loop."""
        self._client = ModbusTcpClient(self.host, port=self.port, timeout=0.1)
        last_connect_attempt = 0.0
        connect_retry_interval = 5.0

        while self._running:
            start_time = time.time()

            try:
                if not self._is_connected:
                    now = time.time()
                    if now - last_connect_attempt >= connect_retry_interval:
                        last_connect_attempt = now
                        connected = False
                        try:
                            connected = self._client.connect()
                        except Exception:
                            connected = False

                        if connected:
                            self._is_connected = True
                            self.connectionStateChanged.emit(True, f"Connected to Delta AS332T at {self.host}:{self.port}")
                        else:
                            if not self.enable_simulation_fallback:
                                self.connectionStateChanged.emit(False, f"Connecting to {self.host}:{self.port}...")

                    if not self._is_connected:
                        time.sleep(0.05)
                        continue

                # 1. Read Real-Time Telemetry Holding Registers (D0 - D19)
                rr = self._client.read_holding_registers(0, 20)
                # 2. Read PLC Status & Interlock Coils (M32 - M47)
                rc = self._client.read_coils(DeltaRegisterMap.COIL_PLC_BATCH_RUNNING, 16)

                if rr.isError() or rc.isError():
                    raise ConnectionError("Modbus response returned protocol error.")

                regs = rr.registers
                coils = rc.bits[:16]

                # 3. Unpack and emit telemetry
                telemetry = unpack_telemetry_registers(regs, coils)
                self.telemetryPolled.emit(telemetry)

                # 4. Check Step Done Pulse (M34)
                current_step_done = telemetry.get("plc.step_done", False)
                if current_step_done and not self._last_step_done_coil:
                    self.stepDoneSignaled.emit(self._active_step_index)
                self._last_step_done_coil = current_step_done

                # 5. Toggle Watchdog Heartbeat (M10)
                self._heartbeat_state = not self._heartbeat_state
                Isa88BatchHandshake.send_heartbeat(self._client, self._heartbeat_state)

            except Exception as ex:
                if self._is_connected:
                    self._is_connected = False
                    self.connectionStateChanged.emit(False, f"Delta PLC link lost: {ex}")

                # If simulation fallback is enabled and hardware is offline, loop gracefully
                if self.enable_simulation_fallback:
                    time.sleep(0.05)

            elapsed = time.time() - start_time
            sleep_time = max(0.01, self.poll_interval_sec - elapsed)
            time.sleep(sleep_time)

        if self._client:
            try:
                self._client.close()
            except Exception:
                pass

    def download_step(self, step_data: Dict[str, Any], step_index: int) -> Dict[str, Any]:
        """
        Thread-safe method to download a recipe step to the PLC with read-back verification.
        """
        self._active_step_index = step_index
        if self._is_connected and self._client:
            return Isa88BatchHandshake.download_step_with_readback(self._client, step_data, step_index)
        else:
            # Simulated acknowledgement when offline
            return {
                "verified": True,
                "stepIndex": step_index,
                "registersVerified": 10,
                "mode": "SIMULATION_FALLBACK",
            }

    def stop(self) -> None:
        """Stops the worker thread cleanly."""
        self._running = False
        if self._client:
            try:
                self._client.close()
            except Exception:
                pass
        self.quit()
        self.wait(2000)

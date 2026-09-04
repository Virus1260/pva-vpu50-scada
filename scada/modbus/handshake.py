"""21 CFR Part 11 Read-Back Verification & ISA-88 Batch Handshake Protocol."""

from __future__ import annotations

import time
from typing import Any, Dict, List, Tuple

from scada.modbus.delta_map import DeltaRegisterMap, pack_step_setpoints


class ReadBackVerificationError(RuntimeError):
    """Raised when the PLC read-back does not match the signed recipe setpoint byte-for-byte."""
    pass


class Isa88BatchHandshake:
    """
    Manages the transactional download, read-back verification,
    and execution state transitions between SCADA and the Delta AS332T-A PLC.
    """

    @staticmethod
    def download_step_with_readback(client: Any, step_data: Dict[str, Any], step_index: int = 1) -> Dict[str, Any]:
        """
        Executes a 21 CFR Part 11 compliant download:
        1. Packs engineering setpoints into Delta D50-D59 registers.
        2. Writes registers over Modbus TCP.
        3. Reads holding registers back from PLC memory.
        4. Verifies byte-for-byte integrity before asserting execution bit M1.
        """
        packed = pack_step_setpoints(step_data, step_index)
        start_addr = DeltaRegisterMap.REG_STEP_AGITATOR_SPEED_SP
        count = len(packed)
        values_to_write = [packed[start_addr + i] for i in range(count)]

        # 1. Write Holding Registers (D50 - D59)
        write_res = client.write_registers(start_addr, values_to_write)
        if hasattr(write_res, "isError") and write_res.isError():
            raise IOError(f"Modbus write failed to registers D{start_addr}-D{start_addr + count - 1}: {write_res}")

        # 2. Read Back Verification Check
        read_res = client.read_holding_registers(start_addr, count)
        if hasattr(read_res, "isError") and read_res.isError():
            raise IOError(f"Modbus read-back verification failed on registers D{start_addr}-D{start_addr + count - 1}: {read_res}")

        read_vals = read_res.registers if hasattr(read_res, "registers") else []
        if len(read_vals) != len(values_to_write):
            raise ReadBackVerificationError(
                f"Read-back length mismatch: expected {len(values_to_write)} registers, received {len(read_vals)}"
            )

        # 3. Strict Byte-for-Byte Comparison
        mismatches = []
        for i, (expected, actual) in enumerate(zip(values_to_write, read_vals)):
            reg_num = start_addr + i
            if expected != actual:
                mismatches.append(f"D{reg_num} (Expected: {expected}, Read: {actual})")

        if mismatches:
            raise ReadBackVerificationError(
                f"21 CFR Part 11 Read-Back Verification Mismatch detected on Delta PLC: {', '.join(mismatches)}"
            )

        # 4. Assert Execution Coils (M2=Auto, Pulse M1=Step Start)
        client.write_coil(DeltaRegisterMap.COIL_AUTO_MANUAL_SELECT, True)
        client.write_coil(DeltaRegisterMap.COIL_STEP_START, True)
        time.sleep(0.05)  # 50 ms pulse width for Delta AS300 scan cycle
        client.write_coil(DeltaRegisterMap.COIL_STEP_START, False)

        return {
            "verified": True,
            "stepIndex": step_index,
            "registersVerified": count,
            "startAddress": f"D{start_addr}",
        }

    @staticmethod
    def send_heartbeat(client: Any, state: bool) -> None:
        """Toggles watchdog coil M10 on Delta PLC."""
        try:
            client.write_coil(DeltaRegisterMap.COIL_HEARTBEAT_WATCHDOG, state)
        except Exception:
            pass

    @staticmethod
    def abort_execution(client: Any) -> None:
        """Issues immediate emergency batch abort to PLC and releases Auto Mode lock."""
        try:
            client.write_coil(DeltaRegisterMap.COIL_BATCH_ABORT, True)
            time.sleep(0.05)
            client.write_coil(DeltaRegisterMap.COIL_BATCH_ABORT, False)
            client.write_coil(DeltaRegisterMap.COIL_AUTO_MANUAL_SELECT, False)
        except Exception:
            pass

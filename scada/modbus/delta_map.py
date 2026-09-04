"""Delta AS332T-A Modbus TCP Register & Coil Memory Map for PVA VPU-50 SCADA."""

from __future__ import annotations

from typing import Any, Dict, List, Tuple


class DeltaRegisterMap:
    """
    Delta AS332T-A Modbus TCP Memory Allocation (Port 502).
    Standard Delta Modbus Addressing:
      - Holding Registers D0–D99 -> Modbus 40001–40100 (Offset 0–99)
      - Coils M0–M63 -> Modbus 00001–00064 (Offset 0–63)
    """

    # --- TELEMETRY HOLDING REGISTERS (Read-Only: D0 - D19) ---
    REG_AGITATOR_SPEED_PV = 0        # D0: 1 = 1 RPM (0 - 120 RPM)
    REG_HOMOGENIZER_SPEED_PV = 1     # D1: 1 = 1 RPM (0 - 4800 RPM)
    REG_VESSEL_TEMP_PV = 2           # D2: 10 = 1.0 °C (Signed, 0.1 °C resolution)
    REG_JACKET_TEMP_PV = 3           # D3: 10 = 1.0 °C (Signed, 0.1 °C resolution)
    REG_VACUUM_PRESSURE_PV = 4       # D4: 10 = 1.0 mbar (Signed, -8000 to 0)
    REG_VESSEL_LEVEL_PV = 5          # D5: 10 = 1.0 L (0 to 500.0 L)
    REG_AGITATOR_CURRENT = 10        # D10: 10 = 1.0 Amp
    REG_HOMOGENIZER_CURRENT = 11     # D11: 10 = 1.0 Amp
    REG_AGITATOR_POWER = 12          # D12: 10 = 1.0 kW
    REG_HOMOGENIZER_POWER = 13       # D13: 10 = 1.0 kW

    # --- ACTIVE STEP SETPOINTS (Write/Read-Back: D50 - D60) ---
    REG_STEP_AGITATOR_SPEED_SP = 50   # D50: Target Agitator Speed SP (RPM)
    REG_STEP_HOMOGENIZER_SPEED_SP = 51 # D51: Target Homogenizer Speed SP (RPM)
    REG_STEP_TEMP_SP = 52             # D52: Target Temp SP (10 = 1.0 °C)
    REG_STEP_TEMP_RAMP_SP = 53        # D53: Temp Ramp Rate SP (10 = 1.0 °C/h)
    REG_STEP_VACUUM_SP = 54           # D54: Target Vacuum SP (10 = 1.0 mbar, signed)
    REG_STEP_DURATION_SEC_SP = 55     # D55: Step Duration SP (Seconds)
    REG_STEP_MODE_BITMASK = 56        # D56: Operating Mode Bitmask
    REG_STEP_PULSE_ON_SEC = 57        # D57: Interval Pulse ON Time (Seconds)
    REG_STEP_PULSE_OFF_SEC = 58       # D58: Interval Pulse OFF Time (Seconds)
    REG_STEP_INDEX = 59               # D59: Step Number (1-based index)

    # --- CONTROL COILS (SCADA -> PLC: M0 - M15) ---
    COIL_BATCH_START = 0              # M0: Master Batch Start / Run Command
    COIL_STEP_START = 1               # M1: Step Execution Pulse Trigger
    COIL_AUTO_MANUAL_SELECT = 2       # M2: Mode Select (1 = Auto/Locked, 0 = Manual)
    COIL_BATCH_ABORT = 3              # M3: Batch Abort
    COIL_BATCH_HOLD = 4               # M4: Batch Pause / Hold
    COIL_HEARTBEAT_WATCHDOG = 10      # M10: SCADA Heartbeat (toggled every 500 ms)

    # --- STATUS & INTERLOCK COILS (PLC -> SCADA: M32 - M47) ---
    COIL_PLC_BATCH_RUNNING = 32       # M32: PLC Batch Running State Feedback
    COIL_PLC_STEP_RUNNING = 33        # M33: PLC Active Step Running Feedback
    COIL_PLC_STEP_DONE = 34           # M34: PLC Step Complete Pulse (Triggers Next Step)
    COIL_PLC_HELD = 35                # M35: PLC Hold / Interlock Tripped
    COIL_INTERLOCK_SEAL_FLUSH = 40    # M40: FS-102 Homogenizer Seal Water Flow (1=OK)
    COIL_INTERLOCK_MIN_LEVEL = 41     # M41: LSL-101 Minimum Vessel Level >150L (1=OK)
    COIL_INTERLOCK_AGIT_HEATING = 42  # M42: Agitator >= 15 RPM during heat (1=OK)
    COIL_INTERLOCK_VESSEL_CLOSED = 43 # M43: Vessel Hatch & Ports Closed (1=OK)

    # --- MODE BITMASK CONSTANTS (D56) ---
    MODE_BIT_AGITATOR_CW = 1 << 0       # Bit 0: Agitator Clockwise (CW Down)
    MODE_BIT_AGITATOR_CCW = 1 << 1      # Bit 1: Agitator Counter-CW (CCW Up)
    MODE_BIT_AGITATOR_REV_CYCLE = 1 << 2 # Bit 2: Agitator Reversing Cycle
    MODE_BIT_HOMO_CONTINUOUS = 1 << 3   # Bit 3: Homogenizer Permanent Run
    MODE_BIT_HOMO_PULSE = 1 << 4        # Bit 4: Homogenizer Interval Pulse
    MODE_BIT_THERMAL_HEATING = 1 << 5   # Bit 5: Utility Steam Heating Mode
    MODE_BIT_THERMAL_COOLING = 1 << 6   # Bit 6: Chilled Water Cooling Mode
    MODE_BIT_VACUUM_DRAWDOWN = 1 << 7   # Bit 7: Vacuum Drawdown Active
    MODE_BIT_ATMOSPHERIC_VENT = 1 << 8  # Bit 8: Atmospheric Release Vent


def to_signed_16(val: int) -> int:
    """Converts a 16-bit unsigned integer to signed (-32768 to 32767)."""
    val = val & 0xFFFF
    return val - 0x10000 if val >= 0x8000 else val


def to_unsigned_16(val: int) -> int:
    """Converts a signed integer to 16-bit unsigned (0 to 65535)."""
    return val & 0xFFFF


def unpack_telemetry_registers(regs: List[int], coils: List[bool]) -> Dict[str, Any]:
    """
    Unpacks raw Delta AS332T-A Modbus registers (D0-D19) and coils (M32-M47)
    into standard SCADA engineering tags.
    """
    # Safe index access with 0 defaults
    def get_reg(idx: int) -> int:
        return regs[idx] if idx < len(regs) else 0

    def get_coil(offset: int) -> bool:
        # coils list corresponds to M32-M47
        return bool(coils[offset]) if offset < len(coils) else False

    agit_rpm = float(get_reg(DeltaRegisterMap.REG_AGITATOR_SPEED_PV))
    homo_rpm = float(get_reg(DeltaRegisterMap.REG_HOMOGENIZER_SPEED_PV))
    vessel_temp = to_signed_16(get_reg(DeltaRegisterMap.REG_VESSEL_TEMP_PV)) / 10.0
    jacket_temp = to_signed_16(get_reg(DeltaRegisterMap.REG_JACKET_TEMP_PV)) / 10.0
    vacuum_mbar = to_signed_16(get_reg(DeltaRegisterMap.REG_VACUUM_PRESSURE_PV)) / 10.0
    vessel_level = float(get_reg(DeltaRegisterMap.REG_VESSEL_LEVEL_PV)) / 10.0

    agit_amp = float(get_reg(DeltaRegisterMap.REG_AGITATOR_CURRENT)) / 10.0
    homo_amp = float(get_reg(DeltaRegisterMap.REG_HOMOGENIZER_CURRENT)) / 10.0
    agit_kw = float(get_reg(DeltaRegisterMap.REG_AGITATOR_POWER)) / 10.0
    homo_kw = float(get_reg(DeltaRegisterMap.REG_HOMOGENIZER_POWER)) / 10.0

    # Status coils (offset from M32 = 0)
    plc_running = get_coil(0)        # M32
    step_running = get_coil(1)       # M33
    step_done = get_coil(2)          # M34
    plc_held = get_coil(3)           # M35
    seal_flush_ok = get_coil(8)      # M40 (offset 8 from M32)
    min_level_ok = get_coil(9)       # M41 (offset 9)
    agit_heat_ok = get_coil(10)      # M42 (offset 10)
    hatch_closed = get_coil(11)      # M43 (offset 11)

    return {
        "vpu.main.agitator_speed": agit_rpm,
        "vpu.main.homogenizer_speed": homo_rpm,
        "vpu.main.temperature": vessel_temp,
        "vpu.jacket.temperature": jacket_temp,
        "vpu.main.vacuum_pressure": vacuum_mbar,
        "vpu.main.level": vessel_level,
        "vpu.main.agitator_current": agit_amp,
        "vpu.main.homogenizer_current": homo_amp,
        "vpu.main.agitator_power": agit_kw,
        "vpu.main.homogenizer_power": homo_kw,
        "plc.batch_running": plc_running,
        "plc.step_running": step_running,
        "plc.step_done": step_done,
        "plc.held": plc_held,
        "interlock.seal_flush_fs102": seal_flush_ok,
        "interlock.min_level_lsl101": min_level_ok,
        "interlock.agitator_heating": agit_heat_ok,
        "interlock.hatch_closed": hatch_closed,
    }


def pack_step_setpoints(step_data: Dict[str, Any], step_index: int = 1) -> Dict[int, int]:
    """
    Packs a recipe step definition into raw 16-bit register values for D50-D59.
    Returns mapping of {register_offset: unsigned_16bit_val}.
    """
    duration_min = int(step_data.get("durationMin", 0))
    duration_sec = int(step_data.get("durationSec", 0))
    total_sec = (duration_min * 60) + duration_sec

    agit_sp = int(round(float(step_data.get("agitatorSpeed", 0.0))))
    homo_sp = int(round(float(step_data.get("homogenizerSpeed", 0.0))))
    if step_data.get("runAgitatorCoActive", False) and agit_sp == 0:
        agit_sp = int(round(float(step_data.get("coActiveAgitatorSpeed", 35.0))))

    temp_sp = int(round(float(step_data.get("targetTemp", 25.0)) * 10.0))
    ramp_sp = int(round(float(step_data.get("tempGradient", 12.0)) * 10.0))
    vac_sp = int(round(float(step_data.get("targetVacuum", 0.0)) * 10.0))

    pulse_on = int(step_data.get("homoPulseOnSec", 30))
    pulse_off = int(step_data.get("homoPulseOffSec", 10))

    # Calculate mode bitmask
    mask = 0
    agit_mode = step_data.get("agitatorMode", "agitator_cw")
    if agit_mode == "agitator_ccw":
        mask |= DeltaRegisterMap.MODE_BIT_AGITATOR_CCW
    elif agit_mode == "agitator_rev":
        mask |= DeltaRegisterMap.MODE_BIT_AGITATOR_REV_CYCLE
    else:
        mask |= DeltaRegisterMap.MODE_BIT_AGITATOR_CW

    homo_mode = step_data.get("homogenizerMode", "homo_permanent")
    if homo_mode == "homo_pulse":
        mask |= DeltaRegisterMap.MODE_BIT_HOMO_PULSE
    else:
        mask |= DeltaRegisterMap.MODE_BIT_HOMO_CONTINUOUS

    therm_mode = step_data.get("thermalMode", "heat_mode_heating")
    if therm_mode == "heat_mode_cooling":
        mask |= DeltaRegisterMap.MODE_BIT_THERMAL_COOLING
    else:
        mask |= DeltaRegisterMap.MODE_BIT_THERMAL_HEATING

    vac_mode = step_data.get("vacuumMode", "vac_auto_drawdown")
    if vac_mode == "vac_vent_atm":
        mask |= DeltaRegisterMap.MODE_BIT_ATMOSPHERIC_VENT
    else:
        mask |= DeltaRegisterMap.MODE_BIT_VACUUM_DRAWDOWN

    return {
        DeltaRegisterMap.REG_STEP_AGITATOR_SPEED_SP: to_unsigned_16(agit_sp),
        DeltaRegisterMap.REG_STEP_HOMOGENIZER_SPEED_SP: to_unsigned_16(homo_sp),
        DeltaRegisterMap.REG_STEP_TEMP_SP: to_unsigned_16(temp_sp),
        DeltaRegisterMap.REG_STEP_TEMP_RAMP_SP: to_unsigned_16(ramp_sp),
        DeltaRegisterMap.REG_STEP_VACUUM_SP: to_unsigned_16(vac_sp),
        DeltaRegisterMap.REG_STEP_DURATION_SEC_SP: to_unsigned_16(total_sec),
        DeltaRegisterMap.REG_STEP_MODE_BITMASK: to_unsigned_16(mask),
        DeltaRegisterMap.REG_STEP_PULSE_ON_SEC: to_unsigned_16(pulse_on),
        DeltaRegisterMap.REG_STEP_PULSE_OFF_SEC: to_unsigned_16(pulse_off),
        DeltaRegisterMap.REG_STEP_INDEX: to_unsigned_16(step_index),
    }

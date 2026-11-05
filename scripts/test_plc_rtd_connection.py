#!/usr/bin/env python3
"""
Delta AS332T-A & AS06RTD-A Live Hardware Diagnostic & RTD Temperature Verifier.
Connects via Modbus TCP (Port 502) to verify physical PLC rack communication and
read live temperature from the PT100 probe on AS06RTD Channel 1 (Register D2).
"""

import sys
import time
import argparse
from typing import Optional

try:
    from pymodbus.client import ModbusTcpClient
except ImportError:
    print("[ERROR] pymodbus is not installed in the active Python environment.")
    print("Please run: pip install pymodbus")
    sys.exit(1)


def parse_args():
    parser = argparse.ArgumentParser(description="Delta AS332T PLC Live Hardware Verifier")
    parser.add_argument("--ip", default="192.168.1.5", help="Delta PLC IP Address (default: 192.168.1.5)")
    parser.add_argument("--port", type=int, default=502, help="Modbus TCP Port (default: 502)")
    parser.add_argument("--poll", action="store_true", help="Continuously poll temperature every 500ms")
    return parser.parse_args()


def to_signed_16(val: int) -> int:
    val = val & 0xFFFF
    return val - 0x10000 if val >= 0x8000 else val


def main():
    args = parse_args()
    print("=" * 68)
    print("  DELTA AS332T-A INDUSTRIAL SCADA HARDWARE VERIFICATION TOOL")
    print(f"  Target: {args.ip}:{args.port} | Protocol: Modbus TCP")
    print("=" * 68)

    client = ModbusTcpClient(args.ip, port=args.port, timeout=1.5)
    print(f"\n[1/3] Attempting connection to Delta PLC at {args.ip}:{args.port}...")

    connected = False
    try:
        connected = client.connect()
    except Exception as exc:
        print(f"[ERROR] Connection failed: {exc}")

    if not connected:
        print("\n" + "!" * 68)
        print("  [CONNECTION FAILED] Unable to reach Delta AS332T at " + f"{args.ip}:{args.port}")
        print("!" * 68)
        print("\nTroubleshooting Checklist:")
        print("  1. Cat6 Ethernet Port:")
        print("     Make sure your LAN cable is plugged into the MAIN CPU PORT on the")
        print("     AS332T (marked 'Ethernet' next to flip cover), NOT the AS-FFTP01 card.")
        print("  2. PC Network Adapter Subnet:")
        print("     Your laptop Ethernet adapter MUST be set to a static IP on the same")
        print("     subnet: e.g., IP: 192.168.1.10, Subnet: 255.255.255.0.")
        print("  3. Power Supply:")
        print("     Verify the green 'POWER' LED is solid on the PS02 power module and")
        print("     the 'POWER' LED is on on the AS332T CPU.")
        print("  4. Switch State:")
        print("     Ensure the toggle switch under the CPU flip door is set to RUN.")
        print("=" * 68)
        sys.exit(2)

    print("[SUCCESS] Connected to Delta AS332T PLC over Modbus TCP!\n")
    print("[2/3] Querying Holding Registers (D0–D9) and Status Coils (M32–M47)...")

    def read_plc_cycle():
        rr = client.read_holding_registers(0, 10)
        rc = client.read_coils(32, 16)

        if rr.isError() or rc.isError():
            print("[WARN] Modbus read returned exception error.")
            return

        regs = rr.registers
        coils = rc.bits if hasattr(rc, "bits") else []

        raw_d2 = regs[2] if len(regs) > 2 else 0
        signed_d2 = to_signed_16(raw_d2)
        vessel_temp_c = signed_d2 / 10.0

        raw_d3 = regs[3] if len(regs) > 3 else 0
        signed_d3 = to_signed_16(raw_d3)
        jacket_temp_c = signed_d3 / 10.0

        agit_rpm = regs[0] if len(regs) > 0 else 0
        homo_rpm = regs[1] if len(regs) > 1 else 0

        plc_running = coils[0] if len(coils) > 0 else False

        timestamp = time.strftime("%H:%M:%S")
        print(f"[{timestamp}] RTD Temp (D2 / Vessel): {vessel_temp_c:6.1f} °C (Raw: {raw_d2:5d}) | "
              f"Jacket Temp (D3): {jacket_temp_c:6.1f} °C | "
              f"Agitator: {agit_rpm} RPM | PLC Running: {plc_running}")

    print("\n[3/3] Live Sensor Telemetry:")
    print("-" * 68)

    if not args.poll:
        read_plc_cycle()
        print("-" * 68)
        print("\nTip: Run with '--poll' to stream live temperature continuously:")
        print("     python scripts/test_plc_rtd_connection.py --poll\n")
    else:
        print("Streaming live readings every 500ms (Press Ctrl+C to stop)...\n")
        try:
            while True:
                read_plc_cycle()
                time.sleep(0.5)
        except KeyboardInterrupt:
            print("\nStopped polling.")

    client.close()
    print("Connection closed cleanly.")


if __name__ == "__main__":
    main()


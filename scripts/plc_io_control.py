#!/usr/bin/env python3
"""
Delta AS332T-A Digital I/O Testing & Commissioning Utility.
Provides CLI and interactive control over physical transistor/relay outputs (Y0.0–Y0.15)
and reads physical digital inputs (X0.0–X0.15) via Modbus TCP (Port 502).
"""

from __future__ import annotations

import sys
import os
import time
import argparse
from typing import List

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

try:
    from pymodbus.client import ModbusTcpClient
except ImportError:
    print("[ERROR] pymodbus is not installed in the active environment.")
    print("Please run: pip install pymodbus")
    sys.exit(1)

from scada.modbus.delta_map import DeltaRegisterMap


def parse_args():
    parser = argparse.ArgumentParser(description="Delta AS332T Digital Output & Input Testing Tool")
    parser.add_argument("--ip", default="192.168.1.5", help="Delta PLC IP Address (default: 192.168.1.5)")
    parser.add_argument("--port", type=int, default=502, help="Modbus TCP Port (default: 502)")
    parser.add_argument("--output", type=int, choices=range(0, 16), help="Output index to control (0=Y0.0, 1=Y0.1, 2=Y0.2, etc.)")
    parser.add_argument("--state", choices=["on", "off", "toggle"], help="State to set for the targeted output")
    parser.add_argument("--status", action="store_true", help="Read and display current state of all inputs and outputs")
    parser.add_argument("--blink", type=int, choices=range(0, 16), help="Blink specified output index repeatedly")
    parser.add_argument("--count", type=int, default=5, help="Number of blink cycles (default: 5)")
    parser.add_argument("--interval", type=float, default=0.5, help="Blink cycle interval in seconds (default: 0.5)")
    parser.add_argument("--all-off", action="store_true", help="Turn off all outputs Y0.0 through Y0.15")
    parser.add_argument("--interactive", action="store_true", help="Launch interactive keyboard terminal to toggle outputs")
    return parser.parse_args()


def read_outputs(client: ModbusTcpClient, count: int = 16) -> List[bool]:
    res = client.read_coils(DeltaRegisterMap.COIL_Y_BASE, count=count)
    if hasattr(res, "isError") and res.isError():
        return [False] * count
    return list(res.bits[:count]) if hasattr(res, "bits") else [False] * count


def read_inputs(client: ModbusTcpClient, count: int = 16) -> List[bool]:
    res = client.read_discrete_inputs(DeltaRegisterMap.INPUT_X_BASE, count=count)
    if hasattr(res, "isError") and res.isError():
        return [False] * count
    return list(res.bits[:count]) if hasattr(res, "bits") else [False] * count


def write_output(client: ModbusTcpClient, output_idx: int, state: bool) -> bool:
    coil_addr = DeltaRegisterMap.COIL_Y_BASE + output_idx
    res = client.write_coil(coil_addr, state)
    return not (hasattr(res, "isError") and res.isError())


def print_io_matrix(client: ModbusTcpClient):
    outputs = read_outputs(client, 16)
    inputs = read_inputs(client, 16)

    print("\n" + "=" * 70)
    print("  DELTA AS332T-A LIVE DIGITAL I/O STATUS MATRIX")
    print(f"  Target: {client.comm_params.host}:{client.comm_params.port}")
    print("=" * 70)

    print("\n  [OUTPUTS - Y0.0 to Y0.15] (Coils 40960 - 40975 / Hex 0xA000 - 0xA00F):")
    print("  " + "-" * 66)
    hdr_top = "  Idx:  " + "  ".join(f"{i:2d}" for i in range(8))
    out_top = "  Y:    " + "  ".join("[#]" if outputs[i] else "[ ]" for i in range(8))
    print(hdr_top)
    print(out_top)
    print("  " + "-" * 66)
    hdr_bot = "  Idx:  " + "  ".join(f"{i:2d}" for i in range(8, 16))
    out_bot = "  Y:    " + "  ".join("[#]" if outputs[i] else "[ ]" for i in range(8, 16))
    print(hdr_bot)
    print(out_bot)

    print("\n  [INPUTS - X0.0 to X0.15] (Discrete Inputs 24576 - 24591 / Hex 0x6000 - 0x600F):")
    print("  " + "-" * 66)
    in_hdr_top = "  Idx:  " + "  ".join(f"{i:2d}" for i in range(8))
    in_top = "  X:    " + "  ".join("[#]" if inputs[i] else "[ ]" for i in range(8))
    print(in_hdr_top)
    print(in_top)
    print("  " + "-" * 66)
    in_hdr_bot = "  Idx:  " + "  ".join(f"{i:2d}" for i in range(8, 16))
    in_bot = "  X:    " + "  ".join("[#]" if inputs[i] else "[ ]" for i in range(8, 16))
    print(in_hdr_bot)
    print(in_bot)
    print("=" * 70 + "\n")


def interactive_terminal(client: ModbusTcpClient):
    print("\n" + "=" * 70)
    print("  INTERACTIVE DELTA PLC OUTPUT CONTROLLER")
    print("  Type an output number (0-15) to toggle it ON/OFF.")
    print("  Type 'matrix' to refresh status, 'off' to turn all OFF, 'q' to quit.")
    print("=" * 70)

    while True:
        print_io_matrix(client)
        try:
            cmd = input("  Command [0-15, matrix, off, q] > ").strip().lower()
        except (KeyboardInterrupt, EOFError):
            print("\nExiting interactive terminal.")
            break

        if cmd in ["q", "exit", "quit"]:
            break
        elif cmd == "matrix":
            continue
        elif cmd == "off":
            for i in range(16):
                write_output(client, i, False)
            print("[INFO] All outputs Y0.0 - Y0.15 turned OFF.")
        else:
            try:
                idx = int(cmd)
                if 0 <= idx < 16:
                    current_states = read_outputs(client, 16)
                    new_state = not current_states[idx]
                    ok = write_output(client, idx, new_state)
                    status_str = "ON" if new_state else "OFF"
                    if ok:
                        print(f"  [SUCCESS] Toggled Output Y0.{idx} -> {status_str} (Coil {DeltaRegisterMap.COIL_Y_BASE + idx})")
                    else:
                        print(f"  [ERROR] Failed to write to Output Y0.{idx}")
                else:
                    print("  [WARN] Output index must be between 0 and 15.")
            except ValueError:
                print(f"  [WARN] Unrecognized command '{cmd}'. Type an output number 0-15 or 'q'.")


def main():
    args = parse_args()
    client = ModbusTcpClient(args.ip, port=args.port, timeout=2.0)

    if not client.connect():
        print(f"[ERROR] Could not connect to Delta PLC at {args.ip}:{args.port}")
        print("Please check Ethernet cable and PC static IP (192.168.1.10).")
        sys.exit(2)

    try:
        if args.all_off:
            print("[INFO] Turning OFF all 16 digital outputs...")
            for i in range(16):
                write_output(client, i, False)
            print("[SUCCESS] All outputs set to OFF.")
            print_io_matrix(client)
            return

        if args.blink is not None:
            idx = args.blink
            print(f"[INFO] Blinking output Y0.{idx} {args.count} times (interval: {args.interval}s)...")
            for c in range(args.count):
                write_output(client, idx, True)
                sys.stdout.write(f"\r  Cycle {c + 1}/{args.count}: Output Y0.{idx} [ON ]")
                sys.stdout.flush()
                time.sleep(args.interval)
                write_output(client, idx, False)
                sys.stdout.write(f"\r  Cycle {c + 1}/{args.count}: Output Y0.{idx} [OFF]")
                sys.stdout.flush()
                time.sleep(args.interval)
            print("\n[SUCCESS] Blink sequence complete.")
            return

        if args.output is not None:
            idx = args.output
            target_state = True
            if args.state == "off":
                target_state = False
            elif args.state == "toggle":
                curr = read_outputs(client, 16)
                target_state = not curr[idx]

            ok = write_output(client, idx, target_state)
            state_str = "ON" if target_state else "OFF"
            if ok:
                print(f"[SUCCESS] Output Y0.{idx} set to {state_str} (Coil {DeltaRegisterMap.COIL_Y_BASE + idx})")
            else:
                print(f"[ERROR] Failed to write Output Y0.{idx}")
            print_io_matrix(client)
            return

        if args.interactive:
            interactive_terminal(client)
            return

        # Default action: print matrix
        print_io_matrix(client)

    finally:
        client.close()


if __name__ == "__main__":
    main()

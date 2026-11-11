#!/usr/bin/env python3
"""
Queries the physical Delta AS332T PLC over its embedded web management API
and reads hardware slot registers to identify all connected extension modules,
function cards, and power supplies.
"""

import re
import urllib.request
import xml.etree.ElementTree as ET

PLC_IP = "192.168.1.5"

def main():
    print("=" * 72)
    print("  DELTA AS300 SYSTEM HARDWARE & EXTENSION MODULE IDENTIFICATION")
    print(f"  Target: http://{PLC_IP}")
    print("=" * 72)

    # 1. Parse mdl_as.js for module name catalog
    try:
        js = urllib.request.urlopen(f"http://{PLC_IP}/mdl_as.js", timeout=3).read().decode("utf-8")
    except Exception as ex:
        print(f"[ERROR] Could not fetch module catalog from PLC: {ex}")
        return

    # m_nm[0][idx]=0x...; m_nm[1][idx]="name";
    ids = re.findall(r'm_nm\[0\]\[(\d+)\]\s*=\s*(0x[0-9A-Fa-f]+|\d+);', js)
    names = re.findall(r'm_nm\[1\]\[(\d+)\]\s*=\s*["\']([^"\']+)["\'];', js)
    name_map = {idx: name for idx, name in names}
    id_to_name = {}
    for idx, code in ids:
        int_code = int(code, 16) if code.startswith("0x") else int(code)
        if idx in name_map:
            id_to_name[int_code] = name_map[idx]

    # Additional standard Delta models
    id_to_name[0x02003000] = "AS332T-A"
    id_to_name[0x02000108] = "AS-FFTP01"
    id_to_name[0x00010002] = "AS-PS02"

    slots = [
        "Power Supply (PS)",
        "CPU Base Module",
        "Function Card Slot 1",
        "Function Card Slot 2",
    ] + [f"Expansion Slot {i}" for i in range(1, 17)]

    modules_detected = []

    for i in range(len(slots)):
        addr = 20480 + (i * 6)
        try:
            url = f"http://{PLC_IP}/P{addr}_6.xml"
            resp = urllib.request.urlopen(url, timeout=2).read()
            tree = ET.fromstring(resp)
            vals = [int(p.find("V").text, 16) for p in tree.findall("P")]
            mod_id = vals[0] * 65536 + vals[1]
            if mod_id != 0 or i < 4:
                name = id_to_name.get(mod_id, f"Code 0x{mod_id:08X}")
                run_st = "RUN" if vals[3] != 0 else "STOP/READY"
                err_st = f"ERR (0x{vals[5]:04X})" if vals[4] != 0 else "OK"
                modules_detected.append({
                    "slot_idx": i,
                    "slot_name": slots[i],
                    "mod_id": mod_id,
                    "model": name,
                    "run": run_st,
                    "error": err_st,
                    "raw": vals,
                })
        except Exception as ex:
            pass

    print(f"\nDetected {len(modules_detected)} Hardware Slot Positions:\n")
    print(f" {'Slot':<24} | {'Model':<16} | {'Module ID':<12} | {'State':<10} | {'Diagnostics'}")
    print("-" * 72)
    for m in modules_detected:
        if m["mod_id"] != 0 or m["slot_idx"] < 2:
            print(f" {m['slot_name']:<24} | {m['model']:<16} | 0x{m['mod_id']:08X}   | {m['run']:<10} | {m['error']}")

    print("=" * 72)

if __name__ == "__main__":
    main()


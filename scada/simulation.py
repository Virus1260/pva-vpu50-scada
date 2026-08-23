"""Deterministic multi-physics simulation of the PVA Systems VPU-50 Skid."""

from __future__ import annotations

import json
from pathlib import Path
import random
from typing import Any


class PlantSimulator:
    def __init__(self, profile_path: Path) -> None:
        if profile_path.exists():
            with open(profile_path, "r", encoding="utf-8") as f:
                self.profile = json.load(f)
        else:
            self.profile = {
                "ambient_temp_c": 24.5,
                "jacket_heat_rate_c_per_sec": 0.4,
                "jacket_cool_rate_c_per_sec": 0.3,
                "vacuum_draw_rate_mbar_per_sec": 8.0,
            }

        # Simulated Process State
        self.vessel_temp = 24.5
        self.target_vessel_temp = 25.0
        self.jacket_temp = 24.5
        self.vacuum_pressure = -5.0  # atmospheric ~0 mbar relative
        self.target_vacuum = -5.0
        self.agitator_speed = 0.0
        self.target_agitator_speed = 0.0
        self.homogenizer_speed = 0.0
        self.target_homogenizer_speed = 0.0
        self.heater_power = 0.0
        self.is_heating = False
        self.is_cooling = False
        self.is_vacuum_on = False
        self.seal_pressure = 2.8
        self.seal_temp = 26.2
        self.level_percent = 45.0
        self.weight_kg = 22.5

    def step(self, dt: float = 0.5) -> dict[str, float]:
        # Agitator Ramp
        if abs(self.agitator_speed - self.target_agitator_speed) > 0.1:
            step_val = 3.0 * dt
            if self.agitator_speed < self.target_agitator_speed:
                self.agitator_speed = min(self.target_agitator_speed, self.agitator_speed + step_val)
            else:
                self.agitator_speed = max(self.target_agitator_speed, self.agitator_speed - step_val)

        # Homogenizer Ramp
        if abs(self.homogenizer_speed - self.target_homogenizer_speed) > 1.0:
            step_val = 150.0 * dt
            if self.homogenizer_speed < self.target_homogenizer_speed:
                self.homogenizer_speed = min(self.target_homogenizer_speed, self.homogenizer_speed + step_val)
            else:
                self.homogenizer_speed = max(self.target_homogenizer_speed, self.homogenizer_speed - step_val)

        # Thermal Dynamics
        if self.is_heating and self.vessel_temp < self.target_vessel_temp:
            self.heater_power = min(100.0, max(20.0, (self.target_vessel_temp - self.vessel_temp) * 5.0))
            self.jacket_temp += 0.8 * dt
            self.vessel_temp += 0.45 * dt * (self.heater_power / 100.0)
        elif self.is_cooling and self.vessel_temp > self.target_vessel_temp:
            self.heater_power = 0.0
            self.jacket_temp = max(15.0, self.jacket_temp - 0.7 * dt)
            self.vessel_temp = max(self.target_vessel_temp, self.vessel_temp - 0.35 * dt)
        else:
            self.heater_power = 0.0
            # Ambient loss
            self.vessel_temp += (24.5 - self.vessel_temp) * 0.005 * dt
            self.jacket_temp += (24.5 - self.jacket_temp) * 0.01 * dt

        # Vacuum Dynamics
        if self.is_vacuum_on and self.vacuum_pressure > self.target_vacuum:
            self.vacuum_pressure = max(self.target_vacuum, self.vacuum_pressure - 8.5 * dt)
        elif not self.is_vacuum_on and self.vacuum_pressure < -5.0:
            self.vacuum_pressure = min(-5.0, self.vacuum_pressure + 15.0 * dt)

        # Flow Rate & Filling/Draining Dynamics
        self.flow_rate = 0.0
        if getattr(self, "is_filling", False):
            self.level_percent = min(100.0, self.level_percent + 2.5 * dt)
            self.weight_kg = (self.level_percent / 100.0) * 50.0
            self.flow_rate = 12.5
        elif getattr(self, "is_draining", False):
            self.level_percent = max(0.0, self.level_percent - 3.0 * dt)
            self.weight_kg = (self.level_percent / 100.0) * 50.0
            self.flow_rate = 15.0 if self.level_percent > 0 else 0.0

        return {
            "vpu.main.temperature": round(self.vessel_temp, 2),
            "vpu.jacket.temperature": round(self.jacket_temp, 2),
            "vpu.main.vacuum_pressure": round(self.vacuum_pressure, 1),
            "vpu.main.agitator_speed": round(self.agitator_speed, 1),
            "vpu.main.homogenizer_speed": round(self.homogenizer_speed, 0),
            "vpu.heater.power": round(self.heater_power, 1),
            "vpu.seal.temperature": round(self.seal_temp, 1),
            "vpu.seal.pressure": round(self.seal_pressure, 2),
            "vpu.main.level": round(self.level_percent, 1),
            "vpu.main.weight": round(self.weight_kg, 1),
            "vpu.main.flow_rate": round(self.flow_rate, 1),
        }
